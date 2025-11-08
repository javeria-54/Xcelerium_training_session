module spi_master #(
    parameter int NUM_SLAVES = 4,
    parameter int DATA_WIDTH = 8,
    parameter int CS_SETUP_CYCLES = 1,
    parameter int CS_HOLD_CYCLES  = 1
)(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [DATA_WIDTH-1:0]     tx_data,
    input  logic [$clog2(NUM_SLAVES)-1:0] slave_sel,
    input  logic                      start_transfer, 
    input  logic                      cpol,
    input  logic                      cpha,
    input  logic [15:0]               clk_div,      
    
    output logic [DATA_WIDTH-1:0]     rx_data,
    output logic                      transfer_done,
    output logic                      busy,
    
    output logic                      spi_clk,
    output logic                      spi_mosi,
    input  logic                      spi_miso,
    output logic [NUM_SLAVES-1:0]     spi_cs_n
);

    typedef enum logic [2:0] {
        IDLE,
        ASSERT_CS,
        TRANSFER,
        DEASSERT_CS,
        DONE_STATE
    } state_t;

    state_t state, next_state;

    logic [DATA_WIDTH-1:0] tx_shift;
    logic [DATA_WIDTH-1:0] rx_shift;
    logic [$clog2(DATA_WIDTH):0] bit_cnt; 
    logic [$clog2(NUM_SLAVES)-1:0] sel_reg;
    logic [3:0] count_tx;
    logic [3:0] count_rx;
    logic [15:0] div_cnt; 
    logic spi_clk_reg;
    logic spi_clk_prev;
    logic running; 

    logic [$clog2(CS_SETUP_CYCLES+1)-1:0] cs_setup_cnt;
    logic [$clog2(CS_HOLD_CYCLES+1)-1:0]  cs_hold_cnt;

    assign spi_clk = spi_clk_reg;

    always_comb begin
        spi_cs_n = {NUM_SLAVES{1'b1}};
        if (state == ASSERT_CS || state == TRANSFER || state == DEASSERT_CS) begin
            spi_cs_n[sel_reg] = 1'b0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt      <= 16'd1;
            spi_clk_reg  <= cpol;
            spi_clk_prev <= cpol;
        end else begin
            spi_clk_prev <= spi_clk_reg; 
            if (running) begin
                if (clk_div <= 16'd1) begin
                    spi_clk_reg <= ~spi_clk_reg;
                    div_cnt <= 16'd1;
                end else begin
                    if (div_cnt == 0) begin
                        spi_clk_reg <= ~spi_clk_reg;
                        div_cnt <= clk_div - 1;
                    end else begin
                        div_cnt <= div_cnt - 1;
                    end
                end
            end else begin
                spi_clk_reg <= cpol;
                div_cnt <= (clk_div <= 1) ? 16'd1 : clk_div - 1;
            end
        end
    end

    logic rising_edge_sck; 
    logic falling_edge_sck;

    logic shift_edge;
    logic sample_edge;
    always_comb begin
        rising_edge_sck  = (spi_clk_prev == 1'b0) && (spi_clk_reg == 1'b1);
        falling_edge_sck = (spi_clk_prev == 1'b1) && (spi_clk_reg == 1'b0);
        sample_edge = 1'b0;
        shift_edge = 1'b0;
    if (cpol == 0 && cpha == 0) begin
        sample_edge = rising_edge_sck;
        shift_edge = falling_edge_sck;
       end
     else if (cpol == 0 && cpha == 1)begin
        sample_edge = falling_edge_sck;
        shift_edge = rising_edge_sck;
       end
     else if (cpol == 1 && cpha == 0)begin
        sample_edge = falling_edge_sck;
        shift_edge = rising_edge_sck;
       end
     else  begin
        sample_edge = rising_edge_sck;
        shift_edge = falling_edge_sck;
       end
       end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start_transfer)
                    next_state = ASSERT_CS;
            end
            ASSERT_CS: begin
                if (cs_setup_cnt == 0)
                    next_state = TRANSFER;
            end
            TRANSFER: begin
                if ((bit_cnt == 0) && sample_edge)
                    next_state = DEASSERT_CS;
            end
            DEASSERT_CS: begin
                if (cs_hold_cnt == 0)
                    next_state = DONE_STATE;
            end
            DONE_STATE: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy          <= 1'b0;
            running       <= 1'b0;
            sel_reg       <= '0;
            tx_shift      <= '0;
            rx_shift      <= '0;
            bit_cnt       <= '0;
            cs_setup_cnt  <= '0;
            cs_hold_cnt   <= '0;
            spi_mosi      <= 1'b0;
            count_tx      <= 4'd0;
            count_rx      <= 4'd0; 
        end else begin
            
            case (state)
                IDLE: begin
                    busy    <= 1'b0;
                    running <= 1'b0;
                    if (start_transfer) begin
                        busy     <= 1'b1;
                        sel_reg  <= slave_sel;
                        tx_shift <= tx_data;
                        rx_shift <= '0;
                        bit_cnt <= DATA_WIDTH;
                        spi_mosi <= tx_data[DATA_WIDTH-1];
                        cs_setup_cnt <= (CS_SETUP_CYCLES > 0) ? CS_SETUP_CYCLES - 1 : 0;
                    end
                end

                ASSERT_CS: begin
                    busy <= 1'b1;
                    if (cs_setup_cnt != 0)
                        cs_setup_cnt <= cs_setup_cnt - 1;
                end

                TRANSFER: begin
                    busy <= 1'b1;
                    running <= 1'b1;
                    if (shift_edge) begin
                  
                        tx_shift <= {tx_shift[DATA_WIDTH-2:0], 1'b0};
                        count_tx <= count_tx + 4'd1;
    
                        spi_mosi <= tx_shift[DATA_WIDTH-1];
                    end

                    if (sample_edge) begin
                        rx_shift <= {rx_shift[DATA_WIDTH-2:0], spi_miso};
                        count_rx <= count_rx + 4'd1;
                        if (bit_cnt != 0)
                            bit_cnt <= bit_cnt - 1;
                    
                    end
                end

                DEASSERT_CS: begin
                    running <= 1'b0; 
                    if (cs_hold_cnt == 0) begin
                        cs_hold_cnt <= (CS_HOLD_CYCLES > 0) ? CS_HOLD_CYCLES - 1 : 0;
                    end else begin
                        cs_hold_cnt <= cs_hold_cnt - 1;
                    end
                    
                end

                DONE_STATE: begin
                    count_rx <= 4'd0;
                    count_tx <= 0;
                    busy <= 1'b0;
                    running <= 1'b0;
                end

                default: begin
                    busy <= 1'b0;  
                    running <= 1'b0;
                end
            endcase
        end
    end
    assign transfer_done = ((count_tx == 4'd8) && (count_rx == 4'd8)) ? 1'b1 : 1'b0;
    
        always_ff @(posedge clk or negedge rst_n) begin
        if (transfer_done) begin
            rx_data <= rx_shift;
        end else begin
            rx_data <= 8'b0;
        end
    end
endmodule


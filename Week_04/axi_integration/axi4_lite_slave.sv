module axi4_lite_slave (
    input  logic    clk,
    input  logic    rst_n,

    // UART → AXI (status signals, read-only for CPU)
    input  logic    tx_done,
    input  logic    tx_ready,
    input  logic    tx_busy,
    input  logic    rx_valid,
    input  logic    rx_error,
    input  logic    rx_done,
    input  logic    rx_busy,
    input  logic    rx_ready,

    input  logic [7:0] rx_data, 

    // AXI → UART (control signals, driven from control register)
    output logic [1:0] parity_sel,
    output logic       tx_valid,
    output logic [7:0] tx_data,
    output logic       tx_start,
    output logic       data_available,

    // AXI interface
    axi4_lite_if.slave  axi_if
);

     // Register addresses
    localparam TX_DATA_ADDR   = 32'h04;  // transmit data reg
    localparam RX_DATA_ADDR   = 32'h28;  // receive data reg
    localparam STATUS_ADDR    = 32'h24;  // status reg
    localparam CONTROL_ADDR   = 32'h20;  // control reg

    // Register bank - 16 x 32-bit registers
    //logic [0:17] [31:0] register_bank ;
      
    // Address decode
    logic [31:0] write_addr_index, read_addr_index;
    logic       addr_valid_write, addr_valid_read;
     
    // State machines for read and write channels
    typedef enum logic [1:0] {
        W_IDLE, W_ADDR, W_DATA, W_RESP
    } write_state_t;
    
    typedef enum logic [1:0] {
        R_IDLE, R_ADDR, R_DATA
    } read_state_t;
    
    write_state_t write_state, write_next_state;
    read_state_t  read_state, read_next_state;
    
    //  Implement write channel state machine
    // Consider: Outstanding transaction handling

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_state <= W_IDLE;
        end else begin
            write_state <= write_next_state;
        end  
    end

    always_comb begin
        unique case (write_state)
            W_IDLE: begin
                if (axi_if.awvalid) begin
                    write_next_state = W_ADDR;
                end else begin
                    write_next_state = W_IDLE;
                end
            end  
            W_ADDR: begin
                if (axi_if.wvalid) begin
                    write_next_state = W_DATA;
                end else begin
                    write_next_state = W_ADDR;
                end 
            end 
            W_DATA: begin
                    write_next_state = W_RESP;
                end 
            W_RESP: begin
                if (axi_if.bready) begin
                    write_next_state = W_IDLE;
                end else begin
                    write_next_state = W_RESP;
                end
            end 
            default: 
                write_next_state = W_IDLE;        
        endcase
    end

    always_comb begin 
        axi_if.awready = 1'b0;
        axi_if.wready  = 1'b0;
        axi_if.bvalid  = 1'b0;
        axi_if.bresp   = 2'b00;

        unique case(write_state)
            W_IDLE: begin
                if (axi_if.awvalid) begin
                    axi_if.awready = 1'b1;
                end
            end 
            W_ADDR: begin
                if (axi_if.wvalid)
                    axi_if.wready = 1'b1;
            end
            W_DATA: begin

            end 
            W_RESP: begin
                axi_if.bvalid = 1'b1;    // response valid
                axi_if.bresp = (addr_valid_write) ? 2'b00 : 2'b10;   // OKAY
            end
        endcase
    end  

    // Implement read channel state machine  
    // Consider: Read data pipeline timing
    
    logic [31:0] latched_read_addr;

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            latched_read_addr <= '0;
            read_state <= R_IDLE;
        end else begin
            read_state <= read_next_state;
            if (axi_if.arvalid && axi_if.arready)
                latched_read_addr <= axi_if.araddr[31:0];
        end
    end

    // Next-state logic
    always_comb begin
        read_next_state = read_state;
        unique case (read_state)
            R_IDLE: begin
                if (axi_if.arvalid)
                    read_next_state = R_ADDR;
            end
            R_ADDR: begin
                if (axi_if.rready)
                    read_next_state = R_DATA;
            end
            R_DATA: begin
                    read_next_state = R_IDLE;
            end
            default: read_next_state = R_IDLE;
        endcase
    end

    // Output logic
    always_comb begin
        // defaults
        axi_if.arready = 1'b0;
        axi_if.rvalid  = 1'b0;
        axi_if.rresp   = 2'b00;    // OKAY response

        unique case (read_state)
            R_IDLE: begin
                    axi_if.arready = 1'b0;   // ready for address
            end
            R_ADDR: begin
                axi_if.arready = 1'b1;
            end
            R_DATA: begin
                axi_if.rvalid = 1'b1;
                axi_if.rresp  = 2'b00;
            end
        endcase
    end

    logic write_en, read_en;
    assign write_en = (write_state == W_DATA) ? 1 : 0;
    assign read_en = (read_state == R_ADDR) ? 1 : 0;
    assign read_addr_index  = axi_if.araddr[3:0];   // 0..15
    
    //--------------------------------------------------------------------------
    // Address decode
    //--------------------------------------------------------------------------
    always_comb begin
    addr_valid_write = 1'b0;
        case (axi_if.awaddr)
            32'h00, 32'h04, 32'h08, 32'h0C, 32'h10, 32'h14, 32'h18, 32'h1C, 32'h20 : addr_valid_write = 1'b1; //32'h20 = control reg
            default: addr_valid_write = 1'b0;
        endcase
    end
    always_comb begin
    addr_valid_read = 1'b0;
        case (axi_if.araddr)
            32'h24, 32'h28, 32'h2C, 32'h30, 32'h34, 32'h38, 32'h3C, 32'h40, 32'h44 : addr_valid_read = 1'b1; // 32'h24=status reg 
            default: addr_valid_read = 1'b0;
        endcase
    end

    //----------------------------------------
    // Internal registers
    //----------------------------------------
    logic [31:0]  control_reg;
    logic [31:0]  status_reg;
    logic [31:0]  rx_data_reg;
    logic [31:0]  tx_data_reg;

    //----------------------------------------
    // Status register (read-only)
    //----------------------------------------
    always_comb begin
        status_reg = 32'b0;
        status_reg[0] = tx_done;
        status_reg[1] = tx_ready;
        status_reg[2] = tx_busy;
        status_reg[3] = rx_valid;
        status_reg[4] = rx_error;
        status_reg[5] = rx_done;
        status_reg[6] = rx_busy;
    end

    // -----------------------
    // RX data capture
    // -----------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_data_reg <= 0;
        end else if (rx_valid) begin
            rx_data_reg <= {24'h0, rx_data};
        end
    end

    //--------------------------------------------------------------------------
    // Write logic
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                write_addr_index <= 4'h0;
        end else if (axi_if.awvalid && axi_if.awready ) begin
                write_addr_index <= axi_if.awaddr;
        end
    end

    // ----------------------------------------------------
    // Write operation (AXI -> Registers)
    // ---------------------------------------------------- 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_data_reg   <= 0;
            control_reg   <= 0;
            tx_start <= 0;
        end else if (axi_if.wvalid && axi_if.wready) begin
            case (write_addr_index)
                TX_DATA_ADDR: begin
                    tx_data_reg   <= axi_if.wdata;
                    tx_data  <= axi_if.wdata[7:0];
                    tx_start <= 1'b1;
                end
                CONTROL_ADDR: control_reg <= axi_if.wdata;
            endcase
        end else begin
            tx_start <= 1'b0; 
        end
    end

    //----------------------------------------
    // Connect control fields to UART
    //----------------------------------------
    assign parity_sel = control_reg[1:0];
    assign tx_valid   = control_reg[2];
    assign rx_ready   = control_reg[3];
    
    // ----------------------------------------------------
    // Read operation (Registers -> AXI)
    // ----------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
            axi_if.rdata = 32'b0;
        end
        else 
            unique case (axi_if.araddr)
                RX_DATA_ADDR: axi_if.rdata = rx_data_reg;  // UART RX data
                STATUS_ADDR : axi_if.rdata = status_reg;   // UART status flags
                CONTROL_ADDR: axi_if.rdata = control_reg;  // control reg
                TX_DATA_ADDR: axi_if.rdata = tx_data_reg;  // optional readback
                default:      axi_if.rdata = 32'hDEAD_BEEF;
            endcase
        end
    
    always_comb begin
        if (axi_if.bvalid && !axi_if.bresp) begin
            data_available = 1;
        end
    end

endmodule

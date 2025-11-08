module sram_controller (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        read_req,
    input  logic        write_req,
    input  logic [14:0] address,
    input  logic [15:0] write_data,
    output logic [15:0] read_data,
    output logic        ready,

    // SRAM interface
    output logic [14:0] sram_addr,
    inout  wire  [15:0] sram_data,
    output logic        sram_ce_n,
    output logic        sram_oe_n, 
    output logic        sram_we_n
);

    typedef enum logic [1:0] {
            IDLE, 
            READ, 
            WRITE,
            DONE
    } state_t;
    
    state_t state, next_state;

    logic [15:0] read_data_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end
                                                                                                     
    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                if (read_req)
                    next_state = READ;
                else if (write_req)
                    next_state = WRITE;
                else
                    next_state = IDLE;
            end
            READ: begin
                next_state = DONE;
            end
            WRITE: begin
                next_state = DONE;
            end
            DONE: begin
                if (read_req)
                    next_state = READ;
                else if (write_req)
                    next_state = WRITE;
                else
                    next_state = IDLE;
            end
        endcase
    end
    always_comb begin
        ready      = 0;
        sram_ce_n  = 1;
        sram_oe_n  = 1;
        sram_we_n  = 1;

        case (state)
            IDLE: begin
                ready      = 0;
                sram_ce_n  = 1;
                sram_oe_n  = 1;
                sram_we_n  = 1;
            end 
            READ: begin
                sram_ce_n  = 0;   // Enable SRAM
                sram_oe_n  = 0;   // Enable output (read)
                sram_we_n  = 1;   // Disable write
            end

            WRITE: begin
                sram_ce_n  = 0;   // Enable SRAM
                sram_oe_n  = 1;   // Disable output
                sram_we_n  = 0;   // Enable write
            end
            DONE: begin
                ready      = 1;
                sram_ce_n  = 1;
                sram_oe_n  = 1;
                sram_we_n  = 1;
            end
        endcase
    end

    // Assign SRAM address (now from input)
    assign sram_addr = address;

    // Bidirectional data bus
    assign sram_data = (state == WRITE) ? write_data : 16'bz;

    // Latch read data only when READ is done
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data_reg <= 16'h0;
        end else if (state == READ && ready) begin
            read_data_reg <= sram_data;
        end
    end

    // Output read data
    assign read_data = read_data_reg;

endmodule
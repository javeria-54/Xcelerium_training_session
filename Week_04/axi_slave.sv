// AXI Memory Slave - Simulates 256MB main memory with AXI interface
module axi_memory_slave #(
    parameter ADDR_WIDTH = 28,  // 256MB = 2^28 bytes
    parameter DATA_WIDTH = 32   // AXI4-Lite uses 32-bit data
)(
    input logic clk,
    input logic rst_n,
    axi4_lite_if.slave axi_if
);

    // Memory array - using sparse memory model for simulation
    // Full 256MB would be impractical, so we use associative array
    logic [DATA_WIDTH-1:0] memory [logic [ADDR_WIDTH-1:0]];
    
    typedef enum logic [1:0] {
        W_IDLE, W_ADDR, W_DATA, W_RESP
    } write_state_t;
    
    typedef enum logic [1:0] {
        R_IDLE, R_ADDR, R_DATA
    } read_state_t;

    write_state_t write_state, write_next_state;
    read_state_t read_state, read_next_state;
    
    logic [ADDR_WIDTH-1:0] latched_write_addr;
    logic [ADDR_WIDTH-1:0] latched_read_addr;
    logic [DATA_WIDTH-1:0] latched_write_data;
    logic [3:0] latched_wstrb;

    // Write FSM - State Update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_state <= W_IDLE;
        end else begin
            write_state <= write_next_state;
        end
    end

    // Write FSM - Next State Logic
    always_comb begin
        write_next_state = write_state;
        case (write_state)
            W_IDLE: begin
                if (axi_if.awvalid)
                    write_next_state = W_ADDR;
            end
            W_ADDR: begin
                if (axi_if.wvalid)
                    write_next_state = W_DATA;
            end
            W_DATA: begin
                write_next_state = W_RESP;
            end
            W_RESP: begin
                if (axi_if.bready)
                    write_next_state = W_IDLE;
            end
        endcase
    end

    // Write FSM - Output Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi_if.awready <= 1'b0;
            axi_if.wready <= 1'b0;
            axi_if.bvalid <= 1'b0;
            axi_if.bresp <= 2'b00;
            latched_write_addr <= '0;
            latched_write_data <= '0;
            latched_wstrb <= '0;
        end else begin
            // Default values
            axi_if.awready <= 1'b0;
            axi_if.wready <= 1'b0;
            axi_if.bvalid <= 1'b0;
            
            case (write_state)
                W_IDLE: begin
                    if (axi_if.awvalid) begin
                        axi_if.awready <= 1'b1;
                        latched_write_addr <= axi_if.awaddr[ADDR_WIDTH-1:0];
                    end
                end
                W_ADDR: begin
                    if (axi_if.wvalid) begin
                        axi_if.wready <= 1'b1;
                        latched_write_data <= axi_if.wdata;
                        latched_wstrb <= axi_if.wstrb;
                    end
                end
                W_DATA: begin
                    // Perform the write
                    if (latched_write_addr < (2**ADDR_WIDTH)) begin
                        // Apply write strobe
                        if (latched_wstrb[0]) memory[latched_write_addr][7:0] = latched_write_data[7:0];
                        if (latched_wstrb[1]) memory[latched_write_addr][15:8] = latched_write_data[15:8];
                        if (latched_wstrb[2]) memory[latched_write_addr][23:16] = latched_write_data[23:16];
                        if (latched_wstrb[3]) memory[latched_write_addr][31:24] = latched_write_data[31:24];
                    end
                end
                W_RESP: begin
                    axi_if.bvalid <= 1'b1;
                    axi_if.bresp <= 2'b00; // OKAY response
                end
            endcase
        end
    end

    // Read FSM - State Update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_state <= R_IDLE;
            latched_read_addr <= '0;
        end else begin
            read_state <= read_next_state;
            if (axi_if.arvalid && axi_if.arready)
                latched_read_addr <= axi_if.araddr[ADDR_WIDTH-1:0];
        end
    end

    // Read FSM - Next State Logic
    always_comb begin
        read_next_state = read_state;
        case (read_state)
            R_IDLE: begin
                if (axi_if.arvalid)
                    read_next_state = R_ADDR;
            end
            R_ADDR: begin
                read_next_state = R_DATA;
            end
            R_DATA: begin
                if (axi_if.rready)
                    read_next_state = R_IDLE;
            end
        endcase
    end

    // Read FSM - Output Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi_if.arready <= 1'b0;
            axi_if.rvalid <= 1'b0;
            axi_if.rresp <= 2'b00;
            axi_if.rdata <= '0;
        end else begin
            // Default values
            axi_if.arready <= 1'b0;
            axi_if.rvalid <= 1'b0;
            
            case (read_state)
                R_IDLE: begin
                    if (axi_if.arvalid) begin
                        axi_if.arready <= 1'b1;
                    end
                end
                R_ADDR: begin
                    // Read data from memory
                    if (latched_read_addr < (2**ADDR_WIDTH)) begin
                        if (memory.exists(latched_read_addr))
                            axi_if.rdata <= memory[latched_read_addr];
                        else
                            axi_if.rdata <= '0; // Uninitialized memory reads as 0
                    end else begin
                        axi_if.rdata <= 32'hDEADBEEF; // Error pattern
                    end
                end
                R_DATA: begin
                    axi_if.rvalid <= 1'b1;
                    axi_if.rresp <= 2'b00; // OKAY response
                end
            endcase
        end
    end

endmodule
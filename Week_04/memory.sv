// Main Memory Module - 256MB Physical Memory
module main_memory #(
    parameter ADDR_WIDTH = 26,  // 64M words = 256MB (word-addressed)
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic [ADDR_WIDTH-1:0] address,
    input logic [DATA_WIDTH-1:0] write_data,
    input logic [3:0] write_strobe,  // Byte-level write enable
    input logic write_enable,
    output logic [DATA_WIDTH-1:0] read_data
);
    // Memory array - 256MB = 64M x 32-bit words
    // For simulation, using associative array
    logic [DATA_WIDTH-1:0] mem_array [logic [ADDR_WIDTH-1:0]];
    
    // Initialize some test data
    initial begin
        // Initialize specific locations for testing
        mem_array[26'h0] = 32'h00000000;
        mem_array[26'h1] = 32'h11111111;
    end
    
    // Synchronous write with byte strobes
    always_ff @(posedge clk) begin
        if (write_enable && address < (2**ADDR_WIDTH)) begin
            if (write_strobe[0]) mem_array[address][7:0]   <= write_data[7:0];
            if (write_strobe[1]) mem_array[address][15:8]  <= write_data[15:8];
            if (write_strobe[2]) mem_array[address][23:16] <= write_data[23:16];
            if (write_strobe[3]) mem_array[address][31:24] <= write_data[31:24];
        end
    end
    
    // Asynchronous read
    always_comb begin
        if (address < (2**ADDR_WIDTH)) begin
            if (mem_array.exists(address))
                read_data = mem_array[address];
            else
                read_data = 32'h00000000; // Uninitialized memory reads as 0
        end else begin
            read_data = 32'hDEADBEEF; // Out of bounds
        end
    end
    
endmodule

// AXI Memory Slave - Acts as memory controller/bridge to actual memory
module axi_memory_slave #(
    parameter ADDR_WIDTH = 28,  // 256MB byte addressing
    parameter DATA_WIDTH = 32   // AXI4-Lite uses 32-bit data
)(
    input logic clk,
    input logic rst_n,
    axi4_lite_if.slave axi_if
);

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
    
    // Memory interface signals
    logic [25:0] mem_addr;  // Word address (28-bit byte addr >> 2)
    logic [31:0] mem_write_data;
    logic [3:0] mem_write_strobe;
    logic mem_write_enable;
    logic [31:0] mem_read_data;

    // Instantiate actual main memory
    main_memory #(
        .ADDR_WIDTH(26),  // 64M words
        .DATA_WIDTH(32)
    ) memory_inst (
        .clk(clk),
        .address(mem_addr),
        .write_data(mem_write_data),
        .write_strobe(mem_write_strobe),
        .write_enable(mem_write_enable),
        .read_data(mem_read_data)
    );

    // Convert byte address to word address
    assign mem_addr = latched_write_addr[27:2]; // For write
    
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

    // Write FSM - Output Logic and Memory Write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi_if.awready <= 1'b0;
            axi_if.wready <= 1'b0;
            axi_if.bvalid <= 1'b0;
            axi_if.bresp <= 2'b00;
            latched_write_addr <= '0;
            latched_write_data <= '0;
            latched_wstrb <= '0;
            mem_write_enable <= 1'b0;
            mem_write_data <= '0;
            mem_write_strobe <= '0;
        end else begin
            // Default values
            axi_if.awready <= 1'b0;
            axi_if.wready <= 1'b0;
            axi_if.bvalid <= 1'b0;
            mem_write_enable <= 1'b0;
            
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
                    // Perform the write to memory
                    if (latched_write_addr < (2**ADDR_WIDTH)) begin
                        mem_write_enable <= 1'b1;
                        mem_write_data <= latched_write_data;
                        mem_write_strobe <= latched_wstrb;
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
    logic [25:0] read_mem_addr;
    assign read_mem_addr = latched_read_addr[27:2]; // Convert to word address
    
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
                    // Memory read happens here (combinational from main_memory)
                    // Data will be available in mem_read_data
                end
                R_DATA: begin
                    axi_if.rvalid <= 1'b1;
                    axi_if.rdata <= mem_read_data;  // Data from memory
                    axi_if.rresp <= 2'b00; // OKAY response
                end
            endcase
        end
    end
    
    // Continuous assignment for memory read address
    always_comb begin
        if (read_state == R_ADDR || read_state == R_DATA) begin
            mem_addr = read_mem_addr;
        end else begin
            mem_addr = latched_write_addr[27:2];
        end
    end

endmodule
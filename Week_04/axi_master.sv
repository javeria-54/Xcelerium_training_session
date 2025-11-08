// AXI Memory Controller - Converts cache requests to AXI transactions
module axi_memory_controller (
    input logic clk,
    input logic rst_n,
    
    // Cache interface
    input logic [27:0] cache_addr,
    input logic [127:0] cache_write_data,
    input logic cache_write_req,
    input logic cache_read_req,
    output logic [127:0] cache_read_data,
    output logic cache_ready,
    
    // AXI Master interface
    axi4_lite_if.master axi_if
);

    typedef enum logic [2:0] {
        IDLE,
        READ_WORD0, READ_WORD1, READ_WORD2, READ_WORD3,
        WRITE_WORD0, WRITE_WORD1, WRITE_WORD2, WRITE_WORD3
    } state_t;
    
    state_t state, next_state;
    
    logic [127:0] read_buffer;
    logic [127:0] write_buffer;
    logic [27:0] base_addr;
    logic [1:0] word_count;
    
    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            word_count <= 2'b0;
            base_addr <= '0;
            write_buffer <= '0;
        end else begin
            state <= next_state;
            
            case(state)
                IDLE: begin
                    if (cache_read_req || cache_write_req) begin
                        base_addr <= {cache_addr[27:4], 4'b0}; // Align to 16-byte boundary
                        word_count <= 2'b0;
                        if (cache_write_req)
                            write_buffer <= cache_write_data;
                    end
                end
                
                READ_WORD0, READ_WORD1, READ_WORD2, READ_WORD3: begin
                    word_count <= word_count + 1'b1;
                end
                
                WRITE_WORD0, WRITE_WORD1, WRITE_WORD2, WRITE_WORD3: begin
                    word_count <= word_count + 1'b1;
                end
            endcase
        end
    end
    
    // Capture read data
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_buffer <= '0;
        end else begin
            if (axi_if.rvalid && axi_if.rready) begin
                case(state)
                    READ_WORD0: read_buffer[127:96] <= axi_if.rdata;
                    READ_WORD1: read_buffer[95:64] <= axi_if.rdata;
                    READ_WORD2: read_buffer[63:32] <= axi_if.rdata;
                    READ_WORD3: read_buffer[31:0] <= axi_if.rdata;
                endcase
            end
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = state;
        
        case(state)
            IDLE: begin
                if (cache_read_req)
                    next_state = READ_WORD0;
                else if (cache_write_req)
                    next_state = WRITE_WORD0;
            end
            
            READ_WORD0: begin
                if (axi_if.rvalid && axi_if.rready)
                    next_state = READ_WORD1;
            end
            
            READ_WORD1: begin
                if (axi_if.rvalid && axi_if.rready)
                    next_state = READ_WORD2;
            end
            
            READ_WORD2: begin
                if (axi_if.rvalid && axi_if.rready)
                    next_state = READ_WORD3;
            end
            
            READ_WORD3: begin
                if (axi_if.rvalid && axi_if.rready)
                    next_state = IDLE;
            end
            
            WRITE_WORD0: begin
                if (axi_if.bvalid && axi_if.bready)
                    next_state = WRITE_WORD1;
            end
            
            WRITE_WORD1: begin
                if (axi_if.bvalid && axi_if.bready)
                    next_state = WRITE_WORD2;
            end
            
            WRITE_WORD2: begin
                if (axi_if.bvalid && axi_if.bready)
                    next_state = WRITE_WORD3;
            end
            
            WRITE_WORD3: begin
                if (axi_if.bvalid && axi_if.bready)
                    next_state = IDLE;
            end
        endcase
    end
    
    // Output logic
    always_comb begin
        cache_ready = (state == IDLE && next_state == IDLE);
        cache_read_data = read_buffer;
    end
    
    // AXI write address and data generation
    logic [31:0] current_write_addr;
    logic [31:0] current_write_data;
    
    always_comb begin
        case(state)
            WRITE_WORD0: begin
                current_write_addr = {4'b0, base_addr};
                current_write_data = write_buffer[127:96];
            end
            WRITE_WORD1: begin
                current_write_addr = {4'b0, base_addr} + 32'h4;
                current_write_data = write_buffer[95:64];
            end
            WRITE_WORD2: begin
                current_write_addr = {4'b0, base_addr} + 32'h8;
                current_write_data = write_buffer[63:32];
            end
            WRITE_WORD3: begin
                current_write_addr = {4'b0, base_addr} + 32'hC;
                current_write_data = write_buffer[31:0];
            end
            default: begin
                current_write_addr = '0;
                current_write_data = '0;
            end
        endcase
    end
    
    // AXI read address generation
    logic [31:0] current_read_addr;
    
    always_comb begin
        case(state)
            READ_WORD0: current_read_addr = {4'b0, base_addr};
            READ_WORD1: current_read_addr = {4'b0, base_addr} + 32'h4;
            READ_WORD2: current_read_addr = {4'b0, base_addr} + 32'h8;
            READ_WORD3: current_read_addr = {4'b0, base_addr} + 32'hC;
            default: current_read_addr = '0;
        endcase
    end
    
    // Instantiate AXI master for writes
    axi4_lite_master_wrapper write_master (
        .clk(clk),
        .rst_n(rst_n),
        .write_address(current_write_addr),
        .write_data(current_write_data),
        .write_start(state inside {WRITE_WORD0, WRITE_WORD1, WRITE_WORD2, WRITE_WORD3}),
        .read_address(current_read_addr),
        .read_start(state inside {READ_WORD0, READ_WORD1, READ_WORD2, READ_WORD3}),
        .read_data(),
        .write_done(),
        .read_done(),
        .axi_if(axi_if)
    );
    
endmodule

// Wrapper for AXI master with better control
module axi4_lite_master_wrapper (
    input logic clk,
    input logic rst_n,
    input logic [31:0] write_address,
    input logic [31:0] write_data,
    input logic write_start,
    input logic [31:0] read_address,
    input logic read_start,
    output logic [31:0] read_data,
    output logic write_done,
    output logic read_done,
    axi4_lite_if.master axi_if
);

    typedef enum logic [1:0] {
        W_IDLE, W_ADDR, W_DATA, W_RESP
    } write_state_t;

    typedef enum logic [1:0] {
        R_IDLE, R_ADDR, R_DATA
    } read_state_t;

    write_state_t write_state, write_next_state;
    read_state_t read_state, read_next_state;

    // Write FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            write_state <= W_IDLE;
        else
            write_state <= write_next_state;
    end

    always_comb begin
        write_next_state = write_state;
        case (write_state)
            W_IDLE: if (write_start) write_next_state = W_ADDR;
            W_ADDR: if (axi_if.awready) write_next_state = W_DATA;
            W_DATA: if (axi_if.wready) write_next_state = W_RESP;
            W_RESP: if (axi_if.bvalid) write_next_state = W_IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi_if.awvalid <= 1'b0;
            axi_if.wvalid <= 1'b0;
            axi_if.bready <= 1'b0;
            axi_if.awaddr <= '0;
            axi_if.wdata <= '0;
            axi_if.wstrb <= '0;
        end else begin
            case (write_state)
                W_IDLE: begin
                    axi_if.awvalid <= 1'b0;
                    axi_if.wvalid <= 1'b0;
                    axi_if.bready <= 1'b0;
                end
                W_ADDR: begin
                    axi_if.awaddr <= write_address;
                    axi_if.awvalid <= 1'b1;
                end
                W_DATA: begin
                    axi_if.awvalid <= 1'b0;
                    axi_if.wvalid <= 1'b1;
                    axi_if.wdata <= write_data;
                    axi_if.wstrb <= 4'hF;
                end
                W_RESP: begin
                    axi_if.wvalid <= 1'b0;
                    axi_if.bready <= 1'b1;
                end
            endcase
        end
    end

    // Read FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_state <= R_IDLE;
            read_data <= '0;
        end else begin
            read_state <= read_next_state;
            if (axi_if.rvalid && axi_if.rready)
                read_data <= axi_if.rdata;
        end
    end

    always_comb begin
        read_next_state = read_state;
        case (read_state)
            R_IDLE: if (read_start) read_next_state = R_ADDR;
            R_ADDR: if (axi_if.arready) read_next_state = R_DATA;
            R_DATA: if (axi_if.rvalid) read_next_state = R_IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi_if.arvalid <= 1'b0;
            axi_if.rready <= 1'b0;
            axi_if.araddr <= '0;
        end else begin
            case (read_state)
                R_IDLE: begin
                    axi_if.arvalid <= 1'b0;
                    axi_if.rready <= 1'b0;
                end
                R_ADDR: begin
                    axi_if.arvalid <= 1'b1;
                    axi_if.araddr <= read_address;
                end
                R_DATA: begin
                    axi_if.arvalid <= 1'b0;
                    axi_if.rready <= 1'b1;
                end
            endcase
        end
    end

    assign write_done = (write_state == W_RESP) && (write_next_state == W_IDLE);
    assign read_done = (read_state == R_DATA) && (read_next_state == R_IDLE);

endmodule
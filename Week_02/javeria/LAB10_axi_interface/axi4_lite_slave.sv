module axi4_lite_slave (
    input  logic        clk,
    input  logic        rst_n,
    axi4_lite_if.slave  axi_if
);

    // Register bank - 16 x 32-bit registers
    logic [0:15] [31:0] register_bank ;
    
    // Address decode
    logic [3:0] write_addr_index, read_addr_index;
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
    
    logic [3:0] latched_read_addr;

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            latched_read_addr <= '0;
            read_state <= R_IDLE;
        end else begin
            read_state <= read_next_state;
            if (axi_if.arvalid && axi_if.arready)
                latched_read_addr <= axi_if.araddr[3:0];
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
            32'h00, 32'h04, 32'h08, 32'h0C, 32'h10, 32'h14, 32'h18, 32'h1C, 32'h20, 32'h24, 32'h28, 32'h2C, 
            32'h30, 32'h34, 32'h38, 32'h3C : addr_valid_write = 1'b1;
            default: addr_valid_write = 1'b0;
        endcase
    end
    always_comb begin
    addr_valid_read = 1'b0;
        case (axi_if.araddr)
            32'h00, 32'h04, 32'h08, 32'h0C, 32'h10, 32'h14, 32'h18, 32'h1C, 32'h20, 32'h24, 32'h28, 32'h2C, 
            32'h30, 32'h34, 32'h38, 32'h3C : addr_valid_read = 1'b1;
            default: addr_valid_read = 1'b0;
        endcase
    end

    //--------------------------------------------------------------------------
    // Write logic
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                write_addr_index <= 4'h0;
        end else if (axi_if.awvalid && axi_if.awready ) begin
                write_addr_index <= axi_if.awaddr[3:0];
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            integer i;
            for (i = 0; i < 16; i++)
                register_bank[i] <= 32'h0;
        end else if (addr_valid_write && write_en) begin
                register_bank[write_addr_index] <= axi_if.wdata;
        end
    end

    //--------------------------------------------------------------------------
    // Read logic
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi_if.rdata <= 32'h0;
        end else if (read_en && addr_valid_read) begin
            axi_if.rdata <= register_bank[latched_read_addr];
        end else begin
            axi_if.rdata <= 32'hDEAD_BEEF; // invalid address
        end 
    end

endmodule

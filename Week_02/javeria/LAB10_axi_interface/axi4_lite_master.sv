module axi4_lite_master (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start_write,     // New: Trigger write transaction
    input  logic        start_read,      // New: Trigger read transaction
    input  logic [31:0] write_address,
    input  logic [31:0] write_data,
    input  logic [31:0] read_address,    // New: Separate read address
    output logic [31:0] read_data,       // New: Output for read data
    output logic        write_done,      // New: Write completion indicator
    output logic        read_done,       // New: Read completion indicator
    
    axi4_lite_if.master axi_if
);

    typedef enum logic [1:0] {
        W_IDLE, W_ADDR, W_DATA, W_RESP
    } write_state_t;

    typedef enum logic [1:0] {
        R_IDLE, R_ADDR, R_DATA
    } read_state_t;

    write_state_t write_state, write_next_state;
    read_state_t  read_state, read_next_state;

    // 1. Write State Update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_state <= W_IDLE;
        end else begin
            write_state <= write_next_state;
        end
    end

    // 2. Write Next-State Logic
    always_comb begin
    write_next_state = write_state;
    unique case (write_state)
        W_IDLE: begin
            if (start_write)
                write_next_state = W_ADDR;
        end
        W_ADDR: begin
            if (axi_if.awready) begin
                write_next_state = W_DATA;
            end
        end
        W_DATA: begin
            if (axi_if.wready) begin
                write_next_state = W_RESP;
            end
        end
        W_RESP: begin
            if (axi_if.bvalid) begin
                write_next_state = W_IDLE;
            end
        end
    endcase
end


    // 3. Write Outputs
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi_if.awvalid <= 1'b0;
            axi_if.wvalid  <= 1'b0;
            axi_if.bready  <= 1'b0;
            axi_if.awaddr  <= '0;
            axi_if.wdata   <= '0;
            axi_if.wstrb   <= '0;
        end else begin
            unique case (write_state)
                W_IDLE: begin
                    axi_if.awvalid <= 1'b0;
                    axi_if.wvalid  <= 1'b0;
                    axi_if.bready  <= 1'b0;
                end
                W_ADDR: begin
                    axi_if.awaddr  <= write_address;
                    axi_if.awvalid  <= 1'b1;                  
                end
                W_DATA: begin
                    axi_if.wvalid <= 1'b1;
                    axi_if.wdata   <= write_data;
                    axi_if.wstrb   <= 4'hF;
                end
                W_RESP: begin
                    axi_if.bready <= 1'b1 ;
                    // Wait for response
                end
            endcase
        end
    end

    // 1. Read State Update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_state <= R_IDLE;
            read_data <= '0;
        end else begin
            read_state <= read_next_state;
            // Capture read data and set done flag
            if (axi_if.rvalid && axi_if.rready) begin
                read_data <= axi_if.rdata;
            end 
        end
    end

    // 2. Read Next-State Logic
    always_comb begin
        read_next_state = read_state;
        unique case (read_state)
            R_IDLE: begin
                if (start_read)
                    read_next_state = R_ADDR;
                end
            R_ADDR: begin
                if (axi_if.arready) begin
                    read_next_state = R_DATA;
                end
            end
            R_DATA: begin
                if (axi_if.rvalid & axi_if.rresp) begin
                    read_next_state = R_IDLE;
                end
            end
        endcase
    end

    // 3. Read Outputs
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi_if.arvalid <= 1'b0;
            axi_if.rready  <= 1'b0;
            axi_if.araddr  <= '0;
        end else begin
            unique case (read_state)
                R_IDLE: begin
                    axi_if.arvalid <= 1'b0;
                    axi_if.rready  <= 1'b0;
                    
                end
                R_ADDR: begin
                    axi_if.arvalid <= 1'b1;
                    axi_if.araddr  <= read_address;
                end
                R_DATA: begin
                    axi_if.rready  <= 1'b1;
                end
            endcase
        end
    end

    // Write_done flag (goes high for 1 cycle when write completes)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            write_done <= 0;
        else
            write_done <= (write_state == W_RESP) && (write_next_state == W_IDLE);
    end

// Read_done flag (goes high for 1 cycle when read completes)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            read_done <= 0;
        else
            read_done <= (read_state == R_DATA) && (read_next_state == R_IDLE);
end

endmodule
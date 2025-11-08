`timescale 1ns/1ps

module tb_cache_and_ram_top();

    // Parameters
    localparam ADDRESS_BITS = 32;
    localparam LINE_SIZE    = 256;
    localparam INDEX_BITS   = 8;
    localparam SIZE         = 256;

    // DUT Inputs
    logic clk;
    logic reset;
    logic read_en;
    logic write_en;
    logic [ADDRESS_BITS-1:0] address;
    logic [LINE_SIZE-1:0] write_data;

    logic cache_flush_i;
    logic [INDEX_BITS-1:0] evict_index_o;
    logic cache_line_wr_o;
    logic cache_wrb_req_o;
    logic cache_line_clean_o;

    // DUT Outputs
    logic [LINE_SIZE-1:0] read_data;
    logic cache_hit;
    logic cache_evict_req_i;
    logic [SIZE-1:0] dirty_vector;
    logic dcache2mem_req_o;
    logic dcache2mem_wr_o;
    logic mem2dcache_ack_i;

    // Instantiate DUT
    cache_and_ram_top dut(
        .clk(clk),
        .reset(reset),
        .read_en(read_en),
        .write_en(write_en),
        .address(address),
        .write_data(write_data),
        .read_data(read_data),
        .cache_hit(cache_hit),
        .cache_flush_i(cache_flush_i),
        .evict_index_o(evict_index_o),
        .cache_line_wr_o(cache_line_wr_o),
        .cache_wrb_req_o(cache_wrb_req_o),
        .cache_line_clean_o(cache_line_clean_o),
        .cache_evict_req_i(cache_evict_req_i),
        .dirty_vector(dirty_vector),
        .dcache2mem_req_o(dcache2mem_req_o),
        .dcache2mem_wr_o(dcache2mem_wr_o),
        .mem2dcache_ack_i(mem2dcache_ack_i)
    );

    // ===== Clock Generation =====
    always #5 clk = ~clk;

    // ===== Task: Perform WRITE with FSM simulation =====
    task do_write(input [ADDRESS_BITS-1:0] addr, input [LINE_SIZE-1:0] data);
    begin
        // Initiate write request
        @(posedge clk);
        write_en <= 1; 
        read_en <= 0; 
        address <= addr; 
        write_data <= data;
        
        @(posedge clk);
        write_en <= 0;
        
        // Check if it's a hit
        @(posedge clk);
        if (cache_hit) begin
            $display("[WRITE HIT] Addr=%h | Data=%h", addr, data);
        end else begin
            $display("[WRITE MISS] Addr=%h | Data=%h - Fetching from memory...", addr, data);
            
            // Wait for memory request
            @(posedge clk);
            @(posedge clk); // Memory latency
            
            // Simulate FSM: Write line from memory
            cache_line_wr_o <= 1;
            @(posedge clk);
            cache_line_wr_o <= 0;
            
            @(posedge clk);
            $display("[WRITE COMPLETE] Data written to cache");
        end
    end
    endtask

    // ===== Task: Perform READ with FSM simulation =====
    task do_read(input [ADDRESS_BITS-1:0] addr);
    begin
        // Initiate read request
        @(posedge clk);
        read_en <= 1; 
        write_en <= 0; 
        address <= addr;
        
        @(posedge clk);
        read_en <= 0;
        
        // Check result
        @(posedge clk);
        if (cache_hit) begin
            $display("[READ HIT] Addr=%h | Data=%h", addr, read_data);
        end else begin
            $display("[READ MISS] Addr=%h - Fetching from memory...", addr);
            
            // Wait for memory request
            @(posedge clk);
            @(posedge clk); // Memory latency
            
            // Simulate FSM: Write line from memory
            cache_line_wr_o <= 1;
            @(posedge clk);
            cache_line_wr_o <= 0;
            
            @(posedge clk);
            $display("[READ COMPLETE] Addr=%h | Data=%h", addr, read_data);
        end
    end
    endtask

    // ===== Task: Perform EVICTION =====
    task do_eviction(input [INDEX_BITS-1:0] idx);
    begin
        $display("\n[EVICTION] Starting eviction of index = 0x%0h...", idx);
        evict_index_o = idx;
        cache_flush_i = 1;
        @(posedge clk);
        cache_flush_i = 0;
        @(posedge clk);

        // Check if eviction requested (dirty line)
        if (cache_evict_req_i) begin
            $display("[EVICTION] Dirty line detected - writing back to memory...");

            // FSM requests cache to output the line to memory
            cache_wrb_req_o = 1;
            @(posedge clk);
            cache_wrb_req_o = 0;
            
            @(posedge clk); // Memory write latency

            // After memory acknowledges, FSM cleans the line
            cache_line_clean_o = 1;
            @(posedge clk);
            cache_line_clean_o = 0;
            
            $display("[EVICTION] Write-back complete, dirty bit cleared");
        end else begin
            $display("[EVICTION] Line was clean or invalid - no write-back needed");
        end
        @(posedge clk);
    end
    endtask

    // ===== Simulation Start =====
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        read_en = 0;
        write_en = 0;
        address = 0;
        write_data = 0;
        cache_flush_i = 0;
        evict_index_o = 0;
        cache_line_wr_o = 0;
        cache_wrb_req_o = 0;
        cache_line_clean_o = 0;

        // Apply Reset
        $display("========================================");
        $display("Starting Cache Simulation");
        $display("========================================");
        $display("\n[RESET] Applying reset...");
        reset = 0; #20; 
        reset = 1; #20;
        $display("[RESET] Reset complete\n");

        // ***********************
        // TEST 1: WRITE MISS (causes line to be fetched and marked dirty)
        // ***********************
        $display("========================================");
        $display("TEST 1: WRITE MISS");
        $display("========================================");
        do_write(32'h0000_0040, 256'hAAAA_FFFF_AAAA_FFFF_DEAD_BEEF_CAFE_BABE);

        // ***********************
        // TEST 2: READ HIT (same address as before)
        // ***********************
        $display("\n========================================");
        $display("TEST 2: READ HIT (same line)");
        $display("========================================");
        do_read(32'h0000_0040);

        // ***********************
        // TEST 3: WRITE HIT (same address)
        // ***********************
        $display("\n========================================");
        $display("TEST 3: WRITE HIT (modify same line)");
        $display("========================================");
        do_write(32'h0000_0040, 256'h1111_2222_3333_4444_5555_6666_7777_8888);

        // ***********************
        // TEST 4: READ HIT (verify modified data)
        // ***********************
        $display("\n========================================");
        $display("TEST 4: READ HIT (verify modification)");
        $display("========================================");
        do_read(32'h0000_0040);

        // ***********************
        // TEST 5: FORCE EVICTION
        // ***********************
        $display("\n========================================");
        $display("TEST 5: FORCE EVICTION of dirty line");
        $display("========================================");
        do_eviction(8'h02); // Index 2 from address 0x40

        // ***********************
        // TEST 6: READ MISS (different address)
        // ***********************
        $display("\n========================================");
        $display("TEST 6: READ MISS (new address)");
        $display("========================================");
        do_read(32'h0000_2000);

        // ***********************
        // TEST 7: Multiple writes to different addresses
        // ***********************
        $display("\n========================================");
        $display("TEST 7: Multiple WRITE operations");
        $display("========================================");
        do_write(32'h0000_0080, 256'hFEED_FACE_DEAD_BEEF);
        do_write(32'h0000_00C0, 256'hCAFE_BABE_1234_5678);

        $display("\n========================================");
        $display("Simulation Complete");
        $display("========================================");
        #50 $finish;
    end

    // Monitor for debugging
    initial begin
        $monitor("Time=%0t | cache_hit=%b | dcache2mem_req=%b | mem_ack=%b | evict_req=%b", 
                 $time, cache_hit, dcache2mem_req_o, mem2dcache_ack_i, cache_evict_req_i);
    end

endmodule
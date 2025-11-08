// Copyright 2023 University of Engineering and Technology Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: Data cache controller for a write-back cache.
// Handles cache hits, misses, allocation, write-back, and flush operations.
//
// Author: Muhammad Tahir, UET Lahore
// Date: 11.6.2023

`timescale 1 ns / 100 ps

`ifndef VERILATOR
`include "../../defines/cache_defs.svh"
`else
`include "cache_defs.svh"
`endif

module wb_dcache_controller (
    input wire                            clk,              // Clock signal - From: System clock
    input wire                            rst_n,            // Active-low reset - From: Reset controller

    // ============================================================================
    // Interface signals to/from cache datapath (wb_dcache_datapath module)
    // ============================================================================
    
    input wire                            cache_hit_i,      // From: wb_dcache_datapath → To: FSM logic
                                                           // Indicates if requested address found in cache (tag match & valid)
      
    input wire                            cache_evict_req_i,// From: wb_dcache_datapath → To: FSM logic
                                                           // Indicates cache line is dirty and needs write-back before replacement
    
    input wire                            dcache_flush_i,   // From: Top module (wb_dcache_top) → To: FSM
                                                           // Signal to flush all cache lines (write back all dirty lines)
    
    output logic                          cache_wr_o,       // From: FSM logic → To: wb_dcache_datapath
                                                           // Write enable for cache on cache hit (write operations)
    
    output logic                          cache_line_wr_o,  // From: FSM logic → To: wb_dcache_datapath
                                                           // Write entire cache line from memory during allocation
    
    output logic                          cache_line_clean_o,// From: FSM logic → To: wb_dcache_datapath
                                                            // Clear dirty bit after successful write-back to memory
    
    output logic                          cache_wrb_req_o,  // From: FSM logic → To: wb_dcache_datapath
                                                           // Request to output cache line data for write-back to memory
    
    output logic [DCACHE_IDX_BITS-1:0]    evict_index_o,   // From: FSM register → To: wb_dcache_datapath
                                                           // Index of cache line to evict/flush (used during flush operation)

    // ============================================================================
    // LSU/MMU to data cache interface
    // ============================================================================
    
    input wire                            lsummu2dcache_req_i, // From: LSU/MMU (Load-Store Unit) → To: FSM
                                                              // Request signal for cache read/write operation
    
    input wire                            lsummu2dcache_wr_i,  // From: LSU/MMU → To: FSM
                                                              // Operation type: 1 = Write, 0 = Read
    
    output logic                          dcache2lsummu_ack_o, // From: FSM logic → To: LSU/MMU
                                                              // Acknowledge signal indicating operation complete
    
    input wire                            dcache_kill_i,       // From: Top module (pipeline flush) → To: FSM
                                                              // Kill/abort current cache operation (e.g., branch mispredict)

    // ============================================================================
    // Data memory to data cache interface
    // ============================================================================
    
    input wire                            mem2dcache_ack_i,    // From: Memory interface → To: FSM
                                                              // Memory operation acknowledgment (read/write complete)
    
    output logic                          dcache2mem_req_o,    // From: FSM logic → To: Memory interface
                                                              // Memory request signal (for allocation or write-back)
    
    output logic                          dcache2mem_wr_o,     // From: FSM logic → To: Memory interface
                                                              // Memory write enable: 1 = Write-back, 0 = Read allocation
    
    output logic                          dcache2mem_kill_o,   // From: FSM logic → To: Memory interface
                                                              // Cancel ongoing memory operation
    
    input wire                            dmem_sel_i           // From: Top module → To: FSM
                                                              // Data memory select (enables cache when high)
);

    // ============================================================================
    // Internal state variables
    // ============================================================================
    
    type_dcache_states_e dcache_state_ff, dcache_state_next;        // FSM: Current and next state registers
                                                                      // States: IDLE, PROCESS_REQ, ALLOCATE, 
                                                                      // WRITE_BACK, FLUSH, FLUSH_NEXT, FLUSH_DONE
    
    logic [DCACHE_IDX_BITS-1:0] evict_index_next, evict_index_ff;  // Eviction index counter for flush operation
                                                                     // Increments through all cache lines during flush

    // ============================================================================
    // Latched input signals (registered to avoid timing issues)
    // ============================================================================
    
    logic lsummu2dcache_wr_ff;      // Registered: LSU/MMU write signal (1=write, 0=read)
    logic lsummu2dcache_req_ff;     // Registered: LSU/MMU request signal
    logic dmem_sel_ff;              // Registered: Data memory select signal

    // ============================================================================
    // Internal combinational signals for FSM logic
    // ============================================================================
    
    logic dcache2lsummu_ack;        // Internal: Acknowledge to LSU/MMU (before output assignment)
    logic dcache_hit;               // Internal: Cache hit condition (req & sel & cache_hit_i)
    logic dcache_miss;              // Internal: Cache miss condition (req & sel & !cache_hit_i)
    logic dcache_evict;             // Internal: Eviction required (dirty line needs write-back)
    logic dcache2mem_wr;            // Internal: Memory write signal (before output assignment)
    logic dcache2mem_req;           // Internal: Memory request signal (before output assignment)
    logic cache_wrb_req;            // Internal: Cache write-back request (before output assignment)
    logic cache_wr;                 // Internal: Cache write enable (before output assignment)
    logic cache_line_wr;            // Internal: Cache line write (before output assignment)
    logic cache_line_clean;         // Internal: Mark line clean (before output assignment)
    logic dcache2mem_kill;          // Internal: Kill memory request (before output assignment)

    // ============================================================================
    // Cache hit/miss/evict logic (combinational)
    // ============================================================================
    
    // Cache hit: Valid request + memory selected + tag match from datapath
    assign dcache_hit   = lsummu2dcache_req_ff & dmem_sel_ff & cache_hit_i;
    
    // Cache miss: Valid request + memory selected + no tag match from datapath
    assign dcache_miss  = lsummu2dcache_req_ff & dmem_sel_ff & ~cache_hit_i;
    
    // Eviction needed: Datapath indicates target line is dirty (needs write-back)
    assign dcache_evict = cache_evict_req_i;

    // ============================================================================
    // Input signal latching (sequential logic)
    // Purpose: Register inputs to avoid glitches and timing issues
    // ============================================================================
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            lsummu2dcache_req_ff <= '0;   // Clear: No request
            dmem_sel_ff          <= '0;   // Clear: Memory not selected
            lsummu2dcache_wr_ff  <= '0;   // Clear: Default to read
        end else begin
            lsummu2dcache_req_ff <= lsummu2dcache_req_i;  // Latch: LSU/MMU request
            dmem_sel_ff          <= dmem_sel_i;           // Latch: Memory select
            lsummu2dcache_wr_ff  <= lsummu2dcache_wr_i;   // Latch: Write/read indicator
        end
    end

    // ============================================================================
    // FSM state register and eviction index counter (sequential logic)
    // ============================================================================
    
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            dcache_state_ff <= DCACHE_IDLE;  // Reset: Return to idle state
            evict_index_ff  <= '0;            // Reset: Start eviction from index 0
        end else begin
            dcache_state_ff <= dcache_state_next;  // Update: Next FSM state
            evict_index_ff  <= evict_index_next;   // Update: Next eviction index
        end
    end

    // ============================================================================
    // FSM next state and output logic (combinational)
    // ============================================================================
    
    always_comb begin
        // --------------------------------------------------------------------
        // Default assignments (prevent latches)
        // --------------------------------------------------------------------
        dcache_state_next = dcache_state_ff;  // Default: Stay in current state
        evict_index_next  = evict_index_ff;   // Default: Keep current eviction index
        dcache2lsummu_ack = 1'b0;             // Default: No acknowledge to LSU/MMU
        dcache2mem_req    = 1'b0;             // Default: No memory request
        dcache2mem_wr     = 1'b0;             // Default: Memory read (not write)
        cache_wrb_req     = 1'b0;             // Default: No write-back request
        cache_line_wr     = 1'b0;             // Default: Don't write cache line
        cache_line_clean  = 1'b0;             // Default: Don't mark line clean
        cache_wr          = 1'b0;             // Default: No cache write
        dcache2mem_kill   = 1'b0;             // Default: Don't kill memory operation

        unique case (dcache_state_ff)

            // ----------------------------------------------------------------
            // DCACHE_IDLE: Waiting for flush or cache request
            // ----------------------------------------------------------------
            DCACHE_IDLE: begin
                if (dcache_flush_i) begin                    
                    // Transition: Start cache flush operation
                    dcache_state_next = DCACHE_FLUSH;
                end else if (lsummu2dcache_req_i) begin
                    // Transition: Process incoming load/store request
                    dcache_state_next = DCACHE_PROCESS_REQ;
                end else begin
                    // Stay: Remain in idle, reset eviction index
                    dcache_state_next = DCACHE_IDLE;
                    evict_index_next  = '0;
                end
            end

            // ----------------------------------------------------------------
            // DCACHE_PROCESS_REQ: Handle cache read/write request
            // ----------------------------------------------------------------
            DCACHE_PROCESS_REQ: begin
                if (dcache_hit) begin
                    // Cache Hit Path
                    if (lsummu2dcache_wr_ff) begin  // Write operation
                        // Action: Write to cache on hit (write-back cache)
                        cache_wr          = 1'b1;   // Enable cache write → To: datapath
                        dcache2lsummu_ack = 1'b1;   // Acknowledge complete → To: LSU/MMU
                        dcache_state_next = DCACHE_IDLE;  // Return to idle
                    end else begin  // Read operation
                        // Action: Data already available from cache
                        dcache2lsummu_ack = 1'b1;   // Acknowledge complete → To: LSU/MMU
                        dcache_state_next = DCACHE_IDLE;  // Return to idle
                    end 
                end else if (dcache_miss) begin
                    // Cache Miss Path
                    if (dcache_evict) begin
                        // Scenario: Target line is dirty, needs write-back first
                        // Transition: Go to write-back state
                        dcache_state_next = DCACHE_WRITE_BACK;
                        dcache2mem_req    = 1'b1;   // Request memory write → To: memory interface
                        dcache2mem_wr     = 1'b1;   // Set write mode → To: memory interface
                        cache_wrb_req     = 1'b1;   // Request write-back data → To: datapath
                    end else begin
                        // Scenario: Target line is clean/invalid, allocate directly
                        // Transition: Go to allocation state
                        dcache_state_next = DCACHE_ALLOCATE;
                        dcache2mem_req    = 1'b1;   // Request memory read → To: memory interface
                    end
                end
            end

            // ----------------------------------------------------------------
            // DCACHE_ALLOCATE: Fetch cache line from memory
            // ----------------------------------------------------------------
            DCACHE_ALLOCATE: begin
                if (mem2dcache_ack_i) begin
                    // Action: Memory has provided data
                    cache_line_wr     = 1'b1;   // Write memory data to cache → To: datapath
                    // Transition: Return to process request (will be cache hit now)
                    dcache_state_next = DCACHE_PROCESS_REQ;
                end else begin
                    // Action: Keep waiting for memory
                    dcache2mem_req    = 1'b1;   // Maintain memory request → To: memory interface
                    dcache_state_next = DCACHE_ALLOCATE;  // Stay in allocate state
                end
            end

            // ----------------------------------------------------------------
            // DCACHE_WRITE_BACK: Write dirty cache line to memory
            // ----------------------------------------------------------------
            DCACHE_WRITE_BACK: begin  
                if (mem2dcache_ack_i) begin
                    // Action: Dirty line successfully written to memory
                    if (dcache_flush_i) begin
                        // Context: Write-back during flush operation
                        dcache_state_next = DCACHE_FLUSH_NEXT;  // Continue flush
                        cache_line_clean  = 1'b1;   // Clear dirty bit → To: datapath
                        if (~(&evict_index_ff)) begin
                            // Action: Move to next cache line
                            evict_index_next = evict_index_ff + 1;
                        end
                    end else begin
                        // Context: Write-back during cache miss
                        // Transition: Now allocate new line from memory
                        dcache_state_next = DCACHE_ALLOCATE;
                        dcache2mem_req    = 1'b1;   // Request allocation → To: memory interface
                    end 
                end else begin
                    // Action: Keep waiting for memory write to complete
                    dcache_state_next = DCACHE_WRITE_BACK;  // Stay in write-back state
                    dcache2mem_req    = 1'b1;   // Maintain memory request → To: memory interface
                    dcache2mem_wr     = 1'b1;   // Maintain write mode → To: memory interface
                    cache_wrb_req     = 1'b1;   // Maintain write-back request → To: datapath
                end
            end

            // ----------------------------------------------------------------
            // DCACHE_FLUSH_NEXT: Transition state after flush step
            // ----------------------------------------------------------------
            DCACHE_FLUSH_NEXT: begin
                // Transition: Return to flush state to check next line
                dcache_state_next = DCACHE_FLUSH;
            end

            // ----------------------------------------------------------------
            // DCACHE_FLUSH: Iterate through all cache lines for flush
            // ----------------------------------------------------------------
            DCACHE_FLUSH: begin
                if (dcache_evict) begin
                    // Scenario: Current line (at evict_index) is dirty
                    // Transition: Write-back this dirty line
                    dcache_state_next = DCACHE_WRITE_BACK;
                    dcache2mem_req    = 1'b1;   // Request memory write → To: memory interface
                    dcache2mem_wr     = 1'b1;   // Set write mode → To: memory interface
                    cache_wrb_req     = 1'b1;   // Request write-back data → To: datapath
                end else begin 
                    // Scenario: Current line is clean or invalid
                    if (&evict_index_ff) begin
                        // Check: All cache lines flushed (index reached maximum)
                        dcache_state_next = DCACHE_FLUSH_DONE;
                        evict_index_next  = '0;  // Reset eviction index
                    end else begin
                        // Action: Move to next cache line
                        evict_index_next = evict_index_ff + 1;
                        dcache_state_next = DCACHE_FLUSH_NEXT;
                    end
                end
            end

            // ----------------------------------------------------------------
            // DCACHE_FLUSH_DONE: Flush operation complete
            // ----------------------------------------------------------------
            DCACHE_FLUSH_DONE: begin
                // Action: Signal flush completion
                dcache2lsummu_ack = 1'b1;   // Acknowledge flush done → To: LSU/MMU
                dcache_state_next = DCACHE_IDLE;  // Return to idle
            end

            // ----------------------------------------------------------------
            // DEFAULT: Safety net
            // ----------------------------------------------------------------
            default: begin
                dcache_state_next = DCACHE_IDLE;
            end
        endcase

        // --------------------------------------------------------------------
        // Kill/Abort logic: Overrides FSM decisions
        // Triggered when: Memory not selected OR external kill signal
        // --------------------------------------------------------------------
        if (~dmem_sel_i | dcache_kill_i) begin
            // Action: Abort current operation and return to idle
            dcache_state_next = DCACHE_IDLE;       // Force idle state
            evict_index_next  = '0;                 // Reset eviction index
            cache_wr          = 1'b0;               // Cancel cache write
            dcache2mem_req    = 1'b0;               // Cancel memory request
            dcache2mem_kill   = 1'b1;               // Signal memory to abort → To: memory interface
        end
    end

    // ============================================================================
    // Output assignments (connect internal signals to module outputs)
    // ============================================================================
    
    // To: wb_dcache_datapath
    assign cache_wrb_req_o      = cache_wrb_req;      // Write-back request
    assign cache_wr_o           = cache_wr;           // Cache write enable
    assign cache_line_wr_o      = cache_line_wr;      // Cache line write (allocation)
    assign cache_line_clean_o   = cache_line_clean;   // Clear dirty bit
    assign evict_index_o        = evict_index_ff;     // Eviction/flush index

    // To: Memory interface
    assign dcache2mem_wr_o      = dcache2mem_wr;      // Memory write enable
    assign dcache2mem_req_o     = dcache2mem_req;     // Memory request
    assign dcache2mem_kill_o    = dcache2mem_kill;    // Memory kill/abort

    // To: LSU/MMU
    assign dcache2lsummu_ack_o = dcache2lsummu_ack;   // Operation acknowledge

endmodule'
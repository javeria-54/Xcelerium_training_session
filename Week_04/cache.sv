package cacheLinePackage;
    typedef struct packed{
        logic valid;
        logic dirty;
        logic [18:0] tag; // 28 total - 9 index - 4 offset = 15 bits tag (rounded to 19 for alignment)
        logic [127:0] block; // 16 bytes block
    } cacheLine;
endpackage

import cacheLinePackage::*;

module simpleCache(
    input logic clk, reset,
    input logic read, write, valid,
    input logic [27:0] cpuAddr, // 28-bit address for 256MB
    input logic [31:0] word_to_cache,
    output logic [31:0] word_to_cpu,
    output logic ready,
    
    // AXI interface for memory access
    output logic [27:0] mem_addr,
    output logic [127:0] mem_write_data,
    output logic mem_write_req,
    output logic mem_read_req,
    input logic [127:0] mem_read_data,
    input logic mem_ready
);
    // Address breakdown
    logic [8:0] index;     // 9 bits for 512 lines
    logic [1:0] wordOff;   // 2 bits for word offset
    logic [1:0] byteOff;   // 2 bits for byte offset
    logic [14:0] addrTag;  // 15 bits tag (28 - 9 - 4 = 15)
    
    assign {addrTag, index, wordOff, byteOff} = cpuAddr;
    
    parameter int rows = 1024; // 512 lines for 8KB cache (rounded up from 6KB)
    cacheLine cacheTable [0:rows-1];
    
    initial begin
        for (int i = 0; i < rows; i++) begin
            cacheTable[i].valid = 1'b0;
            cacheTable[i].dirty = 1'b0;
            cacheTable[i].tag = '0;
            cacheTable[i].block = '0;
        end
    end
    
    cacheLine newCacheLine;
    
    cacheFSM controller(
        .clk(clk), 
        .reset(reset), 
        .read(read), 
        .write(write), 
        .valid(valid),
        .wordOff(wordOff), 
        .addrTag(addrTag),
        .cpuAddr(cpuAddr),
        .word_to_cache(word_to_cache), 
        .oldCL(cacheTable[index]), 
        .mem_read_data(mem_read_data),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_write_data(mem_write_data),
        .mem_write_req(mem_write_req),
        .mem_read_req(mem_read_req),
        .word_to_cpu(word_to_cpu), 
        .newCL(newCacheLine), 
        .ready(ready)
    );
    
    always_ff @(posedge clk) begin
        if (!reset)
            cacheTable[index] <= newCacheLine;
    end
endmodule

module cacheFSM(
    input logic clk, reset,
    input logic read, write, valid,
    input logic [1:0] wordOff,
    input logic [14:0] addrTag,
    input logic [27:0] cpuAddr,
    input logic [31:0] word_to_cache,
    input cacheLine oldCL,
    input logic [127:0] mem_read_data,
    input logic mem_ready,
    output logic [27:0] mem_addr,
    output logic [127:0] mem_write_data,
    output logic mem_write_req,
    output logic mem_read_req,
    output logic [31:0] word_to_cpu,
    output cacheLine newCL,
    output logic ready
);

    typedef enum logic [2:0] {
        IDLE, 
        COMPARE_TAG, 
        ALLOCATE, 
        WRITEBACK,
        WAIT_MEM
    } fsm_states;

    fsm_states state, nextstate;

    always_ff @(posedge clk) begin
        if (reset)    state <= IDLE;
        else          state <= nextstate;
    end

    always_comb begin
        // Default values
        ready = 1'b0;
        mem_write_data = '0;
        mem_write_req = 1'b0;
        mem_read_req = 1'b0;
        mem_addr = cpuAddr;
        newCL = oldCL;
        word_to_cpu = '0;
        nextstate = state;
        
        case(state)
            IDLE: begin
                if(valid)    nextstate = COMPARE_TAG;
                else begin
                    nextstate = IDLE;
                    ready = 1'b1;
                end
            end
            
            COMPARE_TAG: begin
                if(oldCL.valid && (oldCL.tag == addrTag)) begin
                    // Cache hit
                    nextstate = IDLE;
                    ready = 1'b1;
                    
                    if(read) begin
                        case(wordOff)
                            2'b00: word_to_cpu = oldCL.block[127:96];
                            2'b01: word_to_cpu = oldCL.block[95:64];
                            2'b10: word_to_cpu = oldCL.block[63:32];
                            2'b11: word_to_cpu = oldCL.block[31:0];
                        endcase
                    end    
                    else if(write) begin
                        newCL.dirty = 1'b1;
                        case(wordOff)
                            2'b00: newCL.block[127:96] = word_to_cache;
                            2'b01: newCL.block[95:64] = word_to_cache;
                            2'b10: newCL.block[63:32] = word_to_cache;
                            2'b11: newCL.block[31:0] = word_to_cache;
                        endcase
                    end
                end else begin
                    // Cache miss
                    nextstate = oldCL.dirty ? WRITEBACK : ALLOCATE;
                    newCL.valid = 1'b1;
                    newCL.tag = addrTag;
                end
            end
            
            WRITEBACK: begin
                mem_write_req = 1'b1;
                mem_write_data = oldCL.block;
                mem_addr = {oldCL.tag, cpuAddr[12:0]}; // Old tag + index + offset
                
                if(mem_ready) begin
                    nextstate = ALLOCATE;
                end else begin
                    nextstate = WRITEBACK;
                end
            end
            
            ALLOCATE: begin
                mem_read_req = 1'b1;
                mem_addr = cpuAddr;
                
                if(mem_ready) begin
                    newCL.valid = 1'b1;
                    newCL.dirty = 1'b0;
                    newCL.block = mem_read_data;
                    nextstate = COMPARE_TAG;
                end else begin
                    nextstate = ALLOCATE;
                end
            end
            
            default: begin
                nextstate = IDLE;
            end
        endcase
    end
endmodule
// ============ Cache Module (Fixed Datapath with FSM Integration) ============
// Integrated signals from FSM: cache_line_wr_o, cache_wrb_req_o, cache_line_clean_o
module cache #(
    parameter SIZE         = 256,
    parameter ADDRESS_BITS = 32,
    parameter BUS_ADDR_BITS = 16,
    parameter LINE_SIZE    = 256,
    parameter INDEX_BITS   = 8,
    parameter TAG_BITS     = 8,
    parameter OFFSET_BITS  = 5
)(
    input  logic                        clk,
    input  logic                        reset,             // active-low reset
    input  logic                        read_en,
    input  logic                        write_en,
    input  logic [ADDRESS_BITS-1:0]     address_in,
    input  logic [LINE_SIZE-1:0]        write_data,
    input  logic                        c_flush_i,
    input  logic [INDEX_BITS-1 :0]      evict_index_o,      // From FSM: index to evict/write-back
    output logic                        c_evict_req_i,  // To FSM: datapath requests eviction
    input  logic                        cc_line_wr_o,    // From FSM: write whole line into datapath
    input  logic                        cc_wrb_req_o,    // From FSM: ask datapath to output line for write-back
    input  logic                        cc_line_clean_o, // From FSM: clear dirty bit after write-back
    input  logic                        dcache2mem_req_o,
    input  logic                        dcache2mem_wr_o,

    output logic [LINE_SIZE-1:0]        c_read_data,
    output logic                        c_hit_i,
    output logic [SIZE-1:0]             dirty_vector,


    // Bus interface
    input  logic [LINE_SIZE-1:0]        b_read_data,
    output logic [BUS_ADDR_BITS-1:0]    b_address,
    output logic                        b_read_req,
    output logic                        b_write_req,
    output logic [LINE_SIZE-1:0]        b_write_data
);

    // Internal storage
    logic [LINE_SIZE-1:0] data_array [0:SIZE-1];
    logic [TAG_BITS-1:0]  tag_array  [0:SIZE-1];
    logic                 valid_array[0:SIZE-1];
    logic                 dirty_array[0:SIZE-1];

    // Saved request information for multi-cycle operations
    logic [INDEX_BITS-1:0] saved_index;
    logic [TAG_BITS-1:0]   saved_tag;
    logic                  saved_is_write;
    logic [LINE_SIZE-1:0]  saved_write_data;

    // Expose dirty bits
    genvar i;
    generate
        for (i = 0; i < SIZE; i++) begin
            assign dirty_vector[i] = dirty_array[i];
        end
    endgenerate

    // Address mapping - Extract TAG and INDEX from CPU address
    wire [BUS_ADDR_BITS-1:0] block_addr = address[OFFSET_BITS + BUS_ADDR_BITS - 1 : OFFSET_BITS];
    wire [INDEX_BITS-1:0] cpu_index = block_addr[INDEX_BITS-1:0];
    wire [TAG_BITS-1:0]   cpu_tag   = block_addr[BUS_ADDR_BITS-1 : INDEX_BITS];

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            // Reset all arrays
            integer k;
            for (k = 0; k < SIZE; k++) begin
                valid_array[k] <= 0;
                dirty_array[k] <= 0;
                tag_array[k]   <= 0;
                data_array[k]  <= 0;
            end
            cache_hit          <= 0;
            bus_write_req      <= 0;
            bus_read_req       <= 0;
            bus_write_data     <= '0;
            bus_address        <= '0;
            read_data          <= '0;
            cache_evict_req_i  <= 0;
            saved_index        <= 0;
            saved_tag          <= 0;
            saved_is_write     <= 0;
            saved_write_data   <= '0;
        end else begin
            // Default values for control signals
            cache_hit          <= 0;
            bus_read_req       <= 0;
            bus_write_req      <= 0;
            bus_write_data     <= '0;
            cache_evict_req_i  <= 0;

            // ========================================================================
            // FSM-DRIVEN OPERATIONS (Highest Priority)
            // ========================================================================
            
            // -------------------- CACHE LINE WRITE (from memory) --------------------
            // FSM asserts this after memory responds with data during allocation
            if (cache_line_wr_o) begin      //compuslory misss
                data_array[saved_index]  <= b_read_data;
                tag_array[saved_index]   <= saved_tag;
                valid_array[saved_index] <= 1;
                
                // If this was a write miss, now perform the actual write
                if (saved_is_write) begin
                    data_array[saved_index] <= saved_write_data;
                    dirty_array[saved_index] <= 1;
                end else begin
                    // Read miss - data is now available for CPU
                    read_data <= b_read_data;
                    dirty_array[saved_index] <= 0;
                end
            end
            
            // -------------------- WRITE-BACK REQUEST --------------------
            // FSM requests datapath to output cache line for write-back to memory
            else if (cache_wrb_req_o) begin
                if (valid_array[evict_index_o]) begin
                    bus_address    <= {tag_array[evict_index_o], evict_index_o};
                    bus_write_data <= data_array[evict_index_o];
                    bus_write_req  <= 1;
                end
            end
            
            // -------------------- CLEAN DIRTY BIT --------------------
            // FSM tells datapath to clear dirty bit after successful write-back
            else if (cache_line_clean_o) begin
                dirty_array[evict_index_o] <= 0;
            end

            // ========================================================================
            // CPU-DRIVEN OPERATIONS
            // ========================================================================
            
            // -------------------- CACHE FLUSH --------------------
            else if (cache_flush_i) begin
                // Check if evict_index_o is valid and dirty
                if (valid_array[evict_index_o] && dirty_array[evict_index_o]) begin
                    b_write_data <= data_array[cpu_index];
                    b_address    <= {cpu_tag,cpu_index}  ;
                end else begin
                    // Not dirty or invalid - just invalidate the line
                    valid_array[evict_index_o] <= 0;
                    dirty_array[evict_index_o] <= 0;
                end
            end
            
            // -------------------- CPU WRITE REQUEST --------------------
            else if (write_en) begin
                if (valid_array[cpu_index] && (tag_array[cpu_index] == cpu_tag)) begin
                    // WRITE HIT with dirty already = 0 
                    data_array[cpu_index]  <= write_data;
                    dirty_array[cpu_index] <= 1;
                    cache_hit              <= 1;
                end else begin
                    //  WRITE MISS
                    // Check if eviction is needed
                    if (valid_array[cpu_index] && dirty_array[cpu_index]) begin
                        // Dirty line exists - request eviction from FSM
                        saved_index       <= cpu_index;
                        saved_tag         <= cpu_tag;
                        saved_is_write    <= 1;
                        saved_write_data  <= write_data;
                    end else begin
                        // No eviction needed - request data from memory
                        bus_address       <= {cpu_tag, cpu_index};
                        bus_read_req      <= 1;
                        saved_index       <= cpu_index;
                        saved_tag         <= cpu_tag;
                        saved_is_write    <= 1;
                        saved_write_data  <= write_data;
                    end
                end
            end
            
            // -------------------- CPU READ REQUEST --------------------
            else if (read_en) begin
                if (valid_array[cpu_index] && (tag_array[cpu_index] == cpu_tag)) begin
                    // READ HIT
                    read_data <= data_array[cpu_index];
                    cache_hit <= 1;
                end else begin
                    //  READ MISS
                    // Check if eviction is needed
                    if (valid_array[cpu_index] && dirty_array[cpu_index]) begin
                        // Dirty line exists - request eviction from FSM
                        cache_evict_req_i <= 1;
                        saved_index       <= cpu_index;
                        saved_tag         <= cpu_tag;
                        saved_is_write    <= 0;
                    end else begin
                        // No eviction needed - request data from memory  
                        // compulsory miss
                        b_address    <= {cpu_tag, cpu_index};
                        b_read_req   <= dcache2mem_req_o && !dcache2mem_wr_o;
                        saved_index    <= cpu_index;
                        saved_tag      <= cpu_tag;
                        saved_is_write <= 0;
                    end
                end
            end
        end // else (not reset)
    end // always_ff

endmodule

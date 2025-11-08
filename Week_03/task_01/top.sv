// ============ Fixed Top Module ============
module cache_and_mem_top #(
    parameter SIZE = 256,
    parameter ADDRESS_BITS = 32,
    parameter BUS_ADDR_BITS = 16,
    parameter INDEX_BITS = 8,
    parameter LINE_SIZE = 256,
    parameter TAG_BITS = 8,
    parameter OFFSET_BITS = 5
)(
    input   logic                           clk,
    input   logic                           reset,
    
    // CPU Interface
    input   logic                           read_en,
    input   logic                           write_en,
    input   logic   [ADDRESS_BITS-1:0]      address_in,
    input   logic   [LINE_SIZE-1:0]         write_data,
    output  logic   [LINE_SIZE-1:0]         read_data,
    output  logic                           cache_hit_i,
    
    // Cache Control (from external controller or testbench)
    input   logic                           cache_flush_i,
    input   logic   [INDEX_BITS-1:0]        evict_index_o,
    input   logic                           cache_line_wr_o,
    input   logic                           cache_wrb_req_o,
    input   logic                           cache_line_clean_o,
    
    // Status outputs
    output  logic                           cache_evict_req_i,
    output  logic   [SIZE-1:0]              dirty_vector,
    
    //  controller 
    output  logic                           dcache2mem_req_o,
    output  logic                           dcache2mem_wr_o,
    output  logic                           mem2dcache_ack_i
);

    // Internal wires for Cache to Bus
    wire [BUS_ADDR_BITS-1:0] b_address;
    wire                     b_read_req;
    wire                     b_write_req;
    wire [LINE_SIZE-1:0]     b_write_data;
    wire [LINE_SIZE-1:0]     b_read_data;
    
    // Internal wires for Bus to mem
    wire                     mem_read_req;
    wire                     mem_write_req;
    wire [BUS_ADDR_BITS-1:0] mem_address;
    wire [LINE_SIZE-1:0]     mem_write_data;
    wire [LINE_SIZE-1:0]     mem_read_data;

    // Internal wire for cache read data
    wire [LINE_SIZE-1:0]     c_read_data;

    // Cache instance
    cache #(
        .SIZE(SIZE),
        .ADDRESS_BITS(ADDRESS_BITS),
        .BUS_ADDR_BITS(BUS_ADDR_BITS),
        .LINE_SIZE(LINE_SIZE),
        .INDEX_BITS(INDEX_BITS),
        .TAG_BITS(TAG_BITS),
        .OFFSET_BITS(OFFSET_BITS)
    ) cache_inst (
        .clk(clk),
        .reset(reset),
        //CPU INTERFACE
        .read_en(read_en),
        .write_en(write_en),
        .address_in(address_in),
        .write_data(write_data),
        .c_read_data(c_read_data),

        //CONTROLLER_DATAPATH 
        .c_hit_i(cache_hit_i),
        .c_flush_i(c_flush_i),
        .evict_index_o(evict_index_o),
        .c_evict_req_i(cache_evict_req_i),
        .cc_line_wr_o(cache_line_wr_o),
        .cc_wrb_req_o(cache_wrb_req_o),
        .cc_line_clean_o(cache_line_clean_o),
        
        .dirty_vector(dirty_vector),

        //BUS INTERFACE
        .b_address(b_address),
        .b_read_req(b_read_req),
        .b_write_req(b_write_req),
        .b_write_data(b_write_data),
        .b_read_data(b_read_data)
    );

    // Bus instance
    logic wire  bus_ack;
    bus #(
        .SIZE(LINE_SIZE),
        .ADDRESS_BITS(BUS_ADDR_BITS)
    ) bus_inst (
        .clk(clk),
        .reset(reset),
        .bus_req(dcache2mem_req_o),
        .bus_read_en(b_read_req),
        .bus_write_en(~dcache2mem_wr_o), 
        .bus_address(bus_address),
        .bus_write_data(bus_write_data),
        .bus_read_data(bus_read_data),
        .bus_ack(mem2dcache_ack_i), //input

        .mem_req(mem_req),
        .mem_write_en(mem_write_en),
        .mem_read_en(mem_read_en),
        .mem_address(mem_address),
        .mem_write_data(mem_write_data),
        .mem_read_data(mem_read_data),
        .ack_i(mem2dcache_ack_i) //output
    );

    // mem instance
    mem #(
        .SIZE(65536),
        .ADDRESS_BITS(BUS_ADDR_BITS),
        .LINE_SIZE(LINE_SIZE)
    ) mem_inst (
        .clk(clk),
        .reset(reset),
        .address(mem_address),
        .data(mem_write_data),
        .read_data(mem_read_data),
        .mem_req(mem_req),
        .mem_write_en(mem_write_en),
        .mem_read_en(mem_read_en),
     
        .mem_ack(mem2dcache_ack_i)

    );

endmodule
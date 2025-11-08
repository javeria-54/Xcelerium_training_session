module top_axi4_lite(

    // Clock & Reset
    input logic clk,
    input logic rst_n,
   
    // Master control signals
    input   logic        start_write,
    input   logic        start_read,
    input   logic [31:0] write_address,
    input   logic [31:0] write_data,
    input   logic [31:0] read_address,       
    output  logic [31:0] read_data,
    output  logic        write_done,
    output  logic        read_done,

    // AXI Interface
    axi4_lite_if axi_if
);
    // DUT Instantiation
    axi4_lite_master u_master (
        .clk            (clk),
        .rst_n          (rst_n),
        .write_address  (write_address),
        .write_data     (write_data),
        .read_address   (read_address),
        .read_data      (read_data),
        .start_read     (start_read),
        .start_write    (start_write),
        .write_done     (write_done),
        .read_done      (read_done),
        .axi_if         (axi_if.master)
    );

    axi4_lite_slave u_slave (
        .clk            (clk),
        .rst_n          (rst_n),
        .axi_if         (axi_if.slave)
    );

endmodule
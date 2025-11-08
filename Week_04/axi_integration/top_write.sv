`timescale 1ns/1ps

module tb_top_write;

    // clock & reset
    logic clk;
    logic rst_n;

    // DUT inputs
    logic start_write, start_read;
    logic [31:0] write_address, write_data, read_address;
    logic rx_serial;
    logic [1:0] parity_sel;
    logic rx_ready;

    // DUT outputs
    logic tx_done, tx_ready, tx_serial, tx_busy;
    logic [31:0] read_data;
    logic write_done, read_done;

    // clock generation (50 MHz)
    initial clk = 0;
    always #10 clk = ~clk;

    // DUT instance
    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .start_write(start_write),
        .start_read(start_read),
        .write_address(write_address),
        .write_data(write_data),
        .read_address(read_address),
        .rx_serial(rx_serial),
        .parity_sel(parity_sel),
        .rx_ready(rx_ready),
        .tx_done(tx_done),
        .tx_ready(tx_ready),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy),
        .read_data(read_data),
        .write_done(write_done),
        .read_done(read_done)
    );

    // stimulus
    initial begin
        // initialize
        start_write   = 0;
        start_read    = 0;
        write_address = 32'h0;
        write_data    = 32'h0;
        read_address  = 32'h0;
        parity_sel    = 2'b00;   // no parity for now
        rx_ready      = 1'b1;    // ready by default
        rx_serial     = 1'b1;    // idle line

        // apply reset
        rst_n = 0;
        #10;
        rst_n = 1;
        #10;

        $display("[%0t] Starting AXI write on status_reg...", $time);
        write_address = 32'h0000_0020;
        write_data    = 32'h0000_0004;   // sending 0x04
        start_write   = 1;
        @(posedge clk);
        start_write   = 0;
        wait(write_done)

        // perform a write
        $display("[%0t] Starting AXI write...", $time);
        write_address = 32'h0000_0004;
        write_data    = 32'h0000_00A5;   // sending 0xA5
        start_write   = 1;
        @(posedge clk);
        start_write   = 0;

        // wait for write_done
        wait(write_done);
        $display("[%0t] Write completed.", $time);

        $finish;
    end

endmodule

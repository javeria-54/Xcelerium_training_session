`timescale 1ns/1ps

module tb_axi4_lite;

    // Clock & Reset
    logic clk;
    logic rst_n;
    
    // Master control signals
    logic [31:0] write_address;
    logic [31:0] write_data;
    logic [31:0] read_address;
    logic [31:0] read_data;
    logic        write_done, start_write;
    logic        read_done,start_read;


    // AXI Interface
    axi4_lite_if axi_if();

    // DUT Instantiation
    axi4_lite_master u_master (
        .clk           (clk),
        .rst_n         (rst_n),
        .write_address (write_address),
        .write_data    (write_data),
        .read_address  (read_address),
        .read_data     (read_data),
        .start_read(start_read),
        .start_write   (start_write),
        .write_done    (write_done),
        .read_done     (read_done),
        .axi_if        (axi_if.master)
    );

    axi4_lite_slave u_slave (
        .clk    (clk),
        .rst_n  (rst_n),
        .axi_if (axi_if.slave)
    );

    // Clock Generation (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset Sequence
    initial begin
        rst_n = 0;
        write_address = 0;
        start_write = 0;
        start_read = 0;
        write_data    = 0;
        read_address  = 0;
        #50;
        rst_n = 1;
        $display("[%0t] Reset deasserted", $time);
    end

    // Test stimulus without tasks
    initial begin
        @(posedge rst_n);
        #20;

        // ---------- WRITE 1 ----------
        write_address = 32'h08;
        write_data    = 32'hceebbead;
        start_write = 1;
        @(posedge clk);
        wait(write_done);       // wait until write completes
        @(posedge clk);
        $display("[%0t] WRITE 1 complete: addr=0x%0h data=0x%0h", $time, write_address, write_data);

        #20; // small delay between transactions

     
        // ---------- READ 1 ----------
        read_address = 32'h08;
        start_read = 1;
        @(posedge clk);
        wait(read_done);
        @(posedge clk);
        $display("[%0t] READ 1 complete: addr=0x%0h data=0x%0h", $time, read_address, read_data);

        #20;

        $display("[%0t] All transactions done", $time);
        $finish;
    end

endmodule

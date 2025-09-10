`timescale 1ns/1ps

module tb_sync_fifo;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;

    // Signals
    logic clk;
    logic rst_n;
    logic wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic rd_en;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full;
    logic empty;
    logic almost_full;
    logic almost_empty;
    logic [$clog2(FIFO_DEPTH):0] count;

    // Instantiate FIFO
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .count(count)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period

    // Test sequence
    initial begin
        // Reset
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        #20;
        rst_n = 1;
        #10;

        // Write some data
        for (int i=0; i<10; i++) begin
            wr_en = 1;
            wr_data = i;
            #10;
        end
        wr_en = 0;
        #20;

        // Read some data
        for (int i=0; i<5; i++) begin
            rd_en = 1;
            #10;
        end
        rd_en = 0;
        #20;

        // Write more data
        for (int i=10; i<20; i++) begin
            wr_en = 1;
            wr_data = i;
            #10;
        end
        wr_en = 0;
        #20;

        // Read remaining data
        rd_en = 1;
        for (int i=0; i<15; i++) begin
            #10;
        end
        rd_en = 0;

        #50;
        $stop;
    end

    // Monitor
    initial begin
        $display("Time\twr_data\trd_data\tcount\tfull\tempty");
        $monitor("%0t\t%0d\t%0d\t%0d\t%b\t%b", $time, wr_data, rd_data, count, full, empty);
    end

endmodule

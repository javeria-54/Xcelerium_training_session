`timescale 1ns/1ps

module uart_transmitter_tb;

    // Parameters for simulation (small values to make sim fast)
    localparam int CLK_FREQ   = 1_000_000;  // 1 MHz clock
    localparam int BAUD_RATE  = 9600;       // 9600 baud
    localparam int FIFO_DEPTH = 8;

    // DUT I/O
    logic clk;
    logic rst_n;
    logic [7:0] tx_data;
    logic       tx_valid;
    logic       tx_ready;
    logic       tx_serial;
    logic       tx_busy;

    // Instantiate DUT
    uart_transmitter #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .tx_data   (tx_data),
        .tx_valid  (tx_valid),
        .tx_ready  (tx_ready),
        .tx_serial (tx_serial),
        .tx_busy   (tx_busy)
    );

    // Clock generation: 1 MHz -> period = 1000 ns
    initial clk = 0;
    always #500 clk = ~clk; // 1 MHz clock

    // Test sequence
    initial begin
        // Dump waves for GTKWave / QuestaSim
        $dumpfile("uart_transmitter_tb.vcd");
        $dumpvars(0, uart_transmitter_tb);

        // Reset
        rst_n = 0;
        tx_valid = 0;
        tx_data  = 8'h00;
        #2000; // hold reset
        rst_n = 1;
        #2000;

        // Send first byte (0x55) if tx_ready
        if (tx_ready) begin
            tx_data  = 8'h55;
            tx_valid = 1;
            #1000; // one cycle
            tx_valid = 0;
        end

        // Small gap
        #20000;

        // Send second byte (0xA3)
        if (tx_ready) begin
            tx_data  = 8'hA3;
            tx_valid = 1;
            #1000;
            tx_valid = 0;
        end

        // Small gap
        #20000;

        // Send third byte (0xFF)
        if (tx_ready) begin
            tx_data  = 8'hFF;
            tx_valid = 1;
            #1000;
            tx_valid = 0;
        end

        // Wait for transmission to finish
        #200000;

        $display("Simulation complete.");
        $finish;
    end

endmodule

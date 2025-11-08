`timescale 1ns/1ps

module uart_tx_controller_tb;

    // Parameters
    parameter int CLK_FREQ   = 50_000_000;   // 50 MHz
    parameter int BAUD_RATE  = 115200;
    parameter int FIFO_DEPTH = 16;
    localparam int BAUD_DIV  = CLK_FREQ / BAUD_RATE;

    // DUT signals
    logic clk, reset;
    logic [7:0] tx_data;
    logic [11:0] baud_divisor;
    logic data_available;
    logic [1:0] parity_sel;
    logic tx_valid;
    logic tx_done, tx_ready, tx_serial, tx_busy;

    // Instantiate DUT
    uart_tx_controller #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .baud_divisor(baud_divisor),
        .data_available(data_available),
        .parity_sel(parity_sel),
        .tx_valid(tx_valid),
        .tx_done(tx_done),
        .tx_ready(tx_ready),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy)
    );

    // Clock generation: 20ns -> 50MHz
    always #10 clk = ~clk;

    // Task to send a byte
    task send_byte(input [7:0] data, input [1:0] parity);
        begin
            @(posedge clk);
            tx_data        = data;
            parity_sel     = parity;
            data_available = 1;
            tx_valid       = 1;
            @(posedge clk);
            data_available = 0;
            tx_valid       = 0;

            // Wait for transmission to finish
            wait (tx_done);
            @(posedge clk);
            $display("Time=%0t Sent Byte=0x%0h ParityMode=%0b tx_serial=%b",
                     $time, data, parity, tx_serial);
        end
    endtask

    // Testbench sequence
    initial begin
        // Init signals
        clk = 0;
        reset = 1;
        tx_data = 0;
        data_available = 0;
        tx_valid = 0;
        parity_sel = 2'b00;
        baud_divisor = BAUD_DIV;

        // Apply reset
        repeat (5) @(posedge clk);
        reset = 0;  // 🔹 active low reset
        repeat (5) @(posedge clk);
        reset = 1;  // release reset

        // Send test bytes
        send_byte(8'hA5, 2'b00); // No parity
        send_byte(8'h3C, 2'b01); // Even parity
        send_byte(8'h55, 2'b10); // Odd parity
        send_byte(8'hF0, 2'b11); // Mark parity

        // Finish simulation
        repeat (50) @(posedge clk);
        $finish;
    end

    // Monitor important signals
    initial begin
        $monitor("T=%0t | tx_serial=%b tx_done=%b tx_ready=%b tx_busy=%b state=%0d",
                  $time, tx_serial, tx_done, tx_ready, tx_busy, dut.current_state);
    end

endmodule

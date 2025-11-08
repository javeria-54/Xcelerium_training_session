`timescale 1ns/1ps

module Rx_shift_reg_tb;

    // Parameters
    parameter int CLK_FREQ  = 50_000_000;   // 50 MHz
    parameter int BAUD_RATE = 115200;
    localparam int BAUD_DIV = CLK_FREQ / BAUD_RATE;

    // DUT signals
    logic clk, reset;
    logic rx_serial;
    logic [11:0] baud_divisor;
    logic [1:0] parity_sel;
    logic [7:0] rx_data;
    logic rx_valid, rx_error, rx_busy;

    // Instantiate DUT
    Rx_shift_reg #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .rx_serial(rx_serial),
        .baud_divisor(baud_divisor),
        .parity_sel(parity_sel),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error),
        .rx_busy(rx_busy)
    );

    // Clock generation (20 ns = 50 MHz)
    always #10 clk = ~clk;

    // Task: send one UART frame (start + 8 data bits + parity + stop)
    task send_uart_byte(input [7:0] data, input [1:0] parity_mode);
        int i;
        logic parity;
        begin
            // Start bit
            rx_serial = 0;
            #(BAUD_DIV * 20);

            // Data bits (LSB first)
            for (i = 0; i < 8; i++) begin
                rx_serial = data[i];
                #(BAUD_DIV * 20);
            end

            // Parity bit (if enabled)
            case (parity_mode)
                2'b01: parity = ^data;    // Even
                2'b10: parity = ~^data;   // Odd
                2'b11: parity = 1'b1;     // Mark
                default: parity = 1'b0;   // No parity (ignored)
            endcase

            if (parity_mode != 2'b00) begin
                rx_serial = parity;
                #(BAUD_DIV * 20);
            end

            // Stop bit
            rx_serial = 1;
            #(BAUD_DIV * 20);
        end
    endtask

    // Test sequence
    initial begin
        // Init signals
        clk = 0;
        reset = 1;
        rx_serial = 1;   // Idle line = 1
        parity_sel = 2'b00;
        baud_divisor = BAUD_DIV;

        // Reset
        repeat (5) @(posedge clk);
        reset = 0;
        repeat (5) @(posedge clk);
        reset = 1;

        // Test 1: Send byte without parity
        parity_sel = 2'b00;
        send_uart_byte(8'hA5, parity_sel);
        wait(rx_valid);
        $display("T=%0t RX=0x%0h Valid=%b Error=%b", $time, rx_data, rx_valid, rx_error);

        // Test 2: Even parity
        parity_sel = 2'b01;
        send_uart_byte(8'h3C, parity_sel);
        wait(rx_valid);
        $display("T=%0t RX=0x%0h Valid=%b Error=%b", $time, rx_data, rx_valid, rx_error);

        // Test 3: Odd parity
        parity_sel = 2'b10;
        send_uart_byte(8'h55, parity_sel);
        wait(rx_valid);
        $display("T=%0t RX=0x%0h Valid=%b Error=%b", $time, rx_data, rx_valid, rx_error);

        // Test 4: Wrong stop bit → should trigger framing error
        parity_sel = 2'b00;
        rx_serial = 0;  // Force invalid stop
        #(BAUD_DIV * 20);
        wait(rx_valid);
        $display("T=%0t RX=0x%0h Valid=%b Error=%b (Expected framing error)", 
                 $time, rx_data, rx_valid, rx_error);

        // Finish
        repeat (100) @(posedge clk);
        $finish;
    end

    // Monitor
    initial begin
        $monitor("T=%0t | rx_serial=%b rx_data=0x%0h rx_valid=%b rx_error=%b rx_busy=%b state=%0d",
                  $time, rx_serial, rx_data, rx_valid, rx_error, rx_busy, dut.current_state);
    end

endmodule

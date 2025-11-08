`timescale 1ns/1ps

module tb_uart_top;

    logic clk, rst_n;
    logic [7:0] tx_data;
    logic tx_valid, tx_ready;
    logic [7:0] rx_data;
    logic rx_valid, rx_error, rx_busy;

    // Instantiate UART top module
    uart_top #(
        .CLK_FREQ(50_000_000),
        .BAUD_RATE(115200)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error),
        .rx_busy(rx_busy)
    );

    // Clock generation
    initial clk = 0;
    always #10 clk = ~clk; // 50MHz

    initial begin
        rst_n = 0;
        tx_data = 0;
        tx_valid = 0;
        #100;
        rst_n = 1;

        // Send multiple bytes
        repeat (50) begin
            @(posedge clk);
            wait (tx_ready);
            tx_data = $urandom_range(0,255);
            tx_valid = 1;
            @(posedge clk);
            tx_valid = 0;
            wait (rx_valid);
            $display("[%0t] TX=%02h --> RX=%02h", $time, tx_data, rx_data);
        end

        #100000;
        $finish;
    end

endmodule

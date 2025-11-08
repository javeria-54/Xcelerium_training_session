`timescale 1ns/1ps

module uart_rx_datapath_tb;

  // Parameters
  localparam int CLK_FREQ   = 50_000_000;
  localparam int BAUD_RATE  = 115200;
  localparam int DATA_WIDTH = 8;
  localparam int FIFO_DEPTH = 8;

  // Clock and reset
  logic clk;
  logic rst_n;
  logic rx_serial;
  logic [7:0] rx_data;
  logic rx_valid, rx_error, rx_busy;

  // Bit time calculation
  real clk_period = 20.0; // 50 MHz = 20 ns
  real bit_time   = 1e9 / BAUD_RATE; // ns per bit

  // DUT
  uart_rx_datapath #(
      .CLK_FREQ(CLK_FREQ),
      .BAUD_RATE(BAUD_RATE),
      .FIFO_DEPTH(FIFO_DEPTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .rx_serial(rx_serial),
      .rx_error(rx_error),
      .rx_busy(rx_busy),
      .rx_data(rx_data),
      .rx_valid(rx_valid)
  );

  // Clock gen
  always #(clk_period/2) clk = ~clk;

  // Task to send 1 byte
  task send_byte(input [7:0] data);
    int i;
    begin
      // Start bit
      rx_serial = 0;
      #(bit_time);

      // Data bits LSB first
      for (i = 0; i < 8; i++) begin
        rx_serial = data[i];
        #(bit_time);
      end

      // Stop bit
      rx_serial = 1;
      #(bit_time);
    end
  endtask

  // Test sequence
  initial begin
    clk = 0;
    rst_n = 0;
    rx_serial = 1; // idle line = high

    #200;
    rst_n = 1;

    // Send A5
    send_byte(8'hA5);
    #(bit_time*5);

    // Send 3C
    send_byte(8'h3C);
    #(bit_time*5);

    #1000;
    $finish;
  end

  // Monitor
  initial begin
    $monitor("T=%0t ns : rx_data=%h, rx_valid=%b, rx_error=%b", 
              $time, rx_data, rx_valid, rx_error);
  end

endmodule

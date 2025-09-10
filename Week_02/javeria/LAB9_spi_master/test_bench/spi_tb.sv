`timescale 1ns/1ps

module tb_spi_master;

  // Parameters
  localparam DATA_WIDTH = 8;
  localparam NUM_SLAVES = 4;

  // DUT signals
  logic clk, rst_n;
  logic [DATA_WIDTH-1:0] tx_data, rx_data;
  logic [$clog2(NUM_SLAVES)-1:0] slave_sel;
  logic start_transfer, transfer_done, busy;
  logic cpol, cpha;
  logic [15:0] clk_div;

  logic spi_clk, spi_mosi, spi_miso;
  logic [NUM_SLAVES-1:0] spi_cs_n;

  // Clock generation (100 MHz)
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset generation
  initial begin
    rst_n = 0;
    #20;
    rst_n = 1;
  end

  // Instantiate DUT
  spi_master #(
    .NUM_SLAVES(NUM_SLAVES),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .tx_data(tx_data),
    .slave_sel(slave_sel),
    .start_transfer(start_transfer),
    .cpol(cpol),
    .cpha(cpha),
    .clk_div(clk_div),
    .rx_data(rx_data),
    .transfer_done(transfer_done),
    .busy(busy),
    .spi_clk(spi_clk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    .spi_cs_n(spi_cs_n)
  );

  // ----------------------------
  // Simple SPI slave model
  // ----------------------------
  logic [DATA_WIDTH-1:0] slave_shift;
  initial slave_shift = 8'hA5;  // fixed pattern

  always @(posedge spi_clk  or negedge spi_clk or negedge rst_n) begin
    if (!rst_n) begin
      slave_shift <= 8'hA5;
    end else if (!spi_cs_n[slave_sel]) begin
      slave_shift <= {slave_shift[DATA_WIDTH-2:0], 1'b0};
    end
  end

  assign spi_miso = slave_shift[DATA_WIDTH-1];

  // ----------------------------
  // Stimulus
  // ----------------------------
  initial begin
    tx_data = 0;
    start_transfer = 0;
    slave_sel = 0;
    clk_div = 4;   // SCLK slow for simulation

    @(posedge rst_n);

    // Test all SPI modes for slave 0
    test_mode(0, 0, 8'h3C);  // Mode 0 (CPOL=0, CPHA=0)
    test_mode(0, 1, 8'h5A);  // Mode 1 (CPOL=0, CPHA=1)
    test_mode(1, 0, 8'hC3);  // Mode 2 (CPOL=1, CPHA=0)
    test_mode(1, 1, 8'hA5);  // Mode 3 (CPOL=1, CPHA=1)

    $display("All SPI mode tests completed.");
    #100 $stop;
  end

  // ----------------------------
  // Task: Run transfer for one mode
  // ----------------------------
  task test_mode(input bit CPOL, input bit CPHA, input [7:0] data);
    begin
      cpol = CPOL;
      cpha = CPHA;
      slave_sel = 0;
      tx_data = data;

      @(posedge clk);
      start_transfer = 1;
      @(posedge clk);
      start_transfer = 0;

      wait(transfer_done);

      $display("CPOL=%0d, CPHA=%0d | Sent=0x%0h | Received=0x%0h", 
                cpol, cpha, tx_data, rx_data);

      #50;
    end
  endtask

endmodule

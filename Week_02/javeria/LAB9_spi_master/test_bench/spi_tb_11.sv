`timescale 1ns/1ps
module tb_spi_master_mode11;

  localparam DATA_WIDTH = 8;
  logic clk, rst_n, start_transfer;
  logic [DATA_WIDTH-1:0] tx_data, rx_data;
  logic transfer_done, busy;
  logic sclk, mosi, miso;
  logic [0:0] cs_n;

  spi_master #(.NUM_SLAVES(1), .DATA_WIDTH(DATA_WIDTH)) dut (
    .clk(clk), .rst_n(rst_n),
    .tx_data(tx_data), .slave_sel(0),
    .start_transfer(start_transfer),
    .cpol(1'b1), .cpha(1'b1),
    .clk_div(4),
    .rx_data(rx_data), .transfer_done(transfer_done), .busy(busy),
    .spi_clk(sclk), .spi_mosi(mosi), .spi_miso(miso), .spi_cs_n(cs_n)
  );

  initial clk=0; always #5 clk=~clk;
  initial begin rst_n=0; #20; rst_n=1; end

  reg [7:0] slave_shift=8'hA5;
  always @(posedge sclk or posedge cs_n[0]) begin
    if(cs_n[0]) slave_shift<=8'hA5;
    else begin
      miso <= slave_shift[7];
      slave_shift <= {slave_shift[6:0],1'b0};
    end
  end

  initial begin
    start_transfer=0; tx_data=8'hA5;
    @(posedge rst_n); @(posedge clk);
    start_transfer=1; @(posedge clk); start_transfer=0;
    wait(transfer_done);
    $display("Mode 11 | Sent=0x%0h | Received=0x%0h",tx_data,rx_data);
    #100; $stop;
  end
endmodule

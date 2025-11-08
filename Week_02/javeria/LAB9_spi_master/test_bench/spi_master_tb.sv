module spi_master_tb;

  // Parameters
  localparam int NUM_SLAVES = 4;
  localparam int DATA_WIDTH = 8;

  // DUT signals
  logic clk;
  logic rst_n;
  logic [DATA_WIDTH-1:0] tx_data;
  logic [$clog2(NUM_SLAVES)-1:0] slave_sel;
  logic start_transfer;
  logic cpol;
  logic cpha;
  logic [15:0] clk_div;
  logic [DATA_WIDTH-1:0] rx_data;
  logic transfer_done;
  logic busy;
  logic spi_clk;
  logic spi_mosi;
  logic spi_miso;
  logic [NUM_SLAVES-1:0] spi_cs_n;

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

  // Clock generation: 50MHz
  initial clk = 0;
  always #10 clk = ~clk; // 20ns period -> 50MHz

  // Reset
  initial begin
    rst_n = 0;
    #10;
    rst_n = 1;
  end

  // Simple loopback for test: connect MISO = MOSI
  assign spi_miso = spi_mosi;

  // Test sequence
  initial begin
    // init
    tx_data = 8'h00;
    slave_sel = 0;
    start_transfer = 0;
    cpol = 0;
    cpha = 0;
    clk_div = 4; // slow SCK for sim (period = 2*4*20ns = 160ns)

    @(posedge rst_n);
    @(posedge clk);

    // Test mode 0 (CPOL=0, CPHA=0)
    cpol = 0; cpha = 1;
    tx_data = 8'hA5;
    slave_sel = 2;
    $display("=== Starting transfer in MODE0 (CPOL=0,CPHA=0) ===");
    start_transfer_pulse();
    wait(transfer_done);
    $display("MODE0: Sent %h, Received %h", tx_data, rx_data);

    #100;
    $display("All tests done!");
    $finish;
  end

  // Task to generate single-cycle start_transfer pulse
  task start_transfer_pulse();
    begin
      @(posedge clk);
      start_transfer <= 1;
      @(posedge clk);
      start_transfer <= 0;
    end
  endtask

endmodule


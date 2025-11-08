module async_fifo_tb;
 
  parameter DATA_WIDTH = 16;
  parameter FIFO_DEPTH = 8;
 
  logic wr_clk, rd_clk;
  logic wr_rst, rd_rst;
  logic wr_en, rd_en;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic full, empty;
 
  async_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH)
  ) dut (
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .wr_rst(wr_rst),
    .rd_rst(rd_rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );
 
  always #5  wr_clk = ~wr_clk;   // write clock 100 MHz
  always #7  rd_clk = ~rd_clk;   // read clock 71 MHz  
 
  initial begin
    
    wr_clk = 0;
    rd_clk = 0;
    wr_rst = 1;
    rd_rst = 1;
    wr_en  = 0;
    rd_en  = 0;
    data_in = 0;
 
    #20;
    wr_rst = 0;
    rd_rst = 0;
   
    // Write a few words
    @(posedge wr_clk);
    wr_en = 1; data_in = 16'd111;

    @(posedge wr_clk);
    data_in = 16'd222;

    @(posedge wr_clk);
    data_in = 16'd333;

    @(posedge wr_clk);
    wr_en = 0;

    // Start reading
    @(posedge rd_clk);
    rd_en = 1;

    @(posedge rd_clk);

    @(posedge rd_clk);

    @(posedge rd_clk);

    @(posedge rd_clk);
    rd_en = 0;

    // Fill FIFO completely
    @(posedge wr_clk);
    wr_en = 1; data_in = 16'd444;

    @(posedge wr_clk);
    data_in = 16'd555;

    @(posedge wr_clk);
    data_in = 16'd666;
  
    @(posedge wr_clk);
    data_in = 16'd777;

    @(posedge wr_clk);
    data_in = 16'd888;

    @(posedge wr_clk);
    wr_en = 0;

    // Read until empty
    @(posedge rd_clk);
    rd_en = 1;

    repeat (6) begin
      @(posedge rd_clk);
    end

    rd_en = 0;
    #50;
    $finish;
  end

endmodule
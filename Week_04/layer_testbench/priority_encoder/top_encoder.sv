// tb_top.sv (CORRECTED)
`include "interface_encoder.sv"
`include "test_encoder.sv"

module tb_top;
  // Clock generator
  bit clk;
  initial begin
    clk = 1'b0;
    forever #20 clk = ~clk;
  end

  // Bind interface to clock
  alu_if ainf(clk);

  // Simple reset pulse
  initial begin
    ainf.reset = 1'b1;
    ainf.enable = 1'b0;
    ainf.data_in = 8'b0;
    repeat (1) @(posedge clk);
    ainf.reset = 1'b0;
  end

  // DUT instance - valid is OUTPUT only!
  priority_encoder_8to3 dut (
    .data_in       (ainf.data_in),
    .enable        (ainf.enable),
    .encoded_out   (ainf.encoded_out),
    .valid         (ainf.valid)         // DUT OUTPUT
  );

  // Hook the program to the interface
  test t0(ainf);
  
  // Optional: Dump waveforms
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end
endmodule
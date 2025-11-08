// tb_top.sv (CORRECTED)
`include "interface_bs.sv"
`include "test_bs.sv"

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
    ainf.shift_rotate = 1'b0;
    ainf.data_in = 31'b0;
    ainf.shift_amt = 5'b0;
    ainf.left_right = 1'b0;
    repeat (1) @(posedge clk);
    ainf.reset = 1'b0;
  end

  // DUT instance - valid is OUTPUT only!
  barrel_shifter dut (
    .data_in       (ainf.data_in),
    .shift_rotate  (ainf.shift_rotate),
    .shift_amt     (ainf.shift_amt),
    .left_right    (ainf.left_right),
    .data_out      (ainf.data_out)        
  );

  // Hook the program to the interface
  test t0(ainf);
  
  // Optional: Dump waveforms
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end
endmodule
// tb_top.sv
`include "interface_alu.sv"     // interface type name: alu_if
`include "test_alu.sv"   // program automatic test(alu_if ainf);

module tb_top;
  // Clock generator (same style as PDF)
  bit clk;
  initial begin
    clk = 1'b0;
    forever #20 clk = ~clk;
  end

  // Bind interface to this clock
  alu_if ainf(clk);

  // Simple reset pulse (keep if your monitor checks reset)
  initial begin
    ainf.reset = 1'b1;
    ainf.valid = 1'b0;
    repeat (3) @(posedge clk);
    ainf.reset = 1'b0;
  end

  // ===== DUT INSTANCE =====
  // Rename ports to match YOUR ALU if different.
  // top_a.sv (only the DUT instance shown)
alu_8bit dut (
  .a       (ainf.a),
  .b       (ainf.b),
  .op_sel  (ainf.op_sel),
  .result  (ainf.result),
  .zero    (ainf.zero),
  .carry   (ainf.carry),
  .overflow(ainf.overflow)
);

  // Hook the program to the same interface
  test t0(ainf);
endmodule

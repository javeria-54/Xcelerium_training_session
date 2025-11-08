// alu_if.sv (CORRECTED - valid removed from driver outputs)
interface alu_if (input logic clk);
  // Control signals
  logic reset;   // active-high

  // ALU inputs (what driver controls)
  logic [31:0] data_in;
  logic [4:0]  shift_amt;
  logic        left_right;
  logic        shift_rotate;

  // ALU outputs (what DUT produces)
  logic [31:0] data_out;     

  // Driver modport: drives ONLY inputs
  modport drv (
    input  clk, reset, data_out,  // valid is INPUT to driver (read from DUT)
    output data_in, shift_amt, left_right, shift_rotate   // Only these are driven
  );

  // Monitor modport: read-only
  modport mon (
    input clk, reset, data_in, shift_amt, left_right, shift_rotate, data_out
  );
endinterface
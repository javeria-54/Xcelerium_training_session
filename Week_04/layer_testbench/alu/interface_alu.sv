// alu_if.sv  (minimal, with modports)
interface alu_if (input logic clk);
  // control
  logic reset;   // active-high
  logic valid;   // 1-cycle strobe from driver

  // ALU inputs
  logic signed [7:0] a, b;
  logic        [2:0] op_sel;

  // ALU outputs
  logic signed [7:0] result;
  logic              zero, carry, overflow;

  // driver: drives a,b,op_sel,valid; reads the rest
  modport drv (
    input  clk, reset, result, zero, carry, overflow,
    output a, b, op_sel, valid
  );

  // monitor: read-only
  modport mon (
    input clk, reset, valid, a, b, op_sel, result, zero, carry, overflow
  );
endinterface

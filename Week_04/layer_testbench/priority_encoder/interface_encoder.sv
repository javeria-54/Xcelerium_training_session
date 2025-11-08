// alu_if.sv (CORRECTED - valid removed from driver outputs)
interface alu_if (input logic clk);
  // Control signals
  logic reset;   // active-high

  // ALU inputs (what driver controls)
  logic [7:0] data_in;
  logic       enable;

  // ALU outputs (what DUT produces)
  logic [2:0] encoded_out;
  logic       valid;        // This is DUT OUTPUT, not driver input!

  // Driver modport: drives ONLY inputs
  modport drv (
    input  clk, reset, encoded_out, valid,  // valid is INPUT to driver (read from DUT)
    output data_in, enable                   // Only these are driven
  );

  // Monitor modport: read-only
  modport mon (
    input clk, reset, data_in, enable, encoded_out, valid
  );
endinterface
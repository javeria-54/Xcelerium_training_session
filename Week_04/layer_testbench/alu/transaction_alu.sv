`ifndef TRANSACTION_A_SV
`define TRANSACTION_A_SV
class Transaction;
  static int count;   // static variable
  int id;             // nonstatic variable

  // ALU inputs
  rand bit signed [7:0] a;
  rand bit signed [7:0] b;
  rand bit        [2:0] op_sel;

  // ALU outputs
  bit signed [7:0] result;
  bit              zero;
  bit              carry;
  bit              overflow;

  function new(bit signed [7:0] a,
               bit signed [7:0] b,
               bit        [2:0] op_sel);
    this.a      = a;
    this.b      = b;
    this.op_sel = op_sel;
    id = count;
    count = count + 1;
  endfunction

  function void display();
    $display("-------------------------------------------");
    $display("count=%0d, ID=%0d, a=%0d, b=%0d, op_sel=%0d, result=%0d, zero=%0b, carry=%0b, overflow=%0b",
             count, id, a, b, op_sel, result, zero, carry, overflow);
    $display("-------------------------------------------");
  endfunction
endclass
`endif // TRANSACTION_A_SV
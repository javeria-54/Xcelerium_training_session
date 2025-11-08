`ifndef TRANSACTION_A_SV
`define TRANSACTION_A_SV
class Transaction;
  static int count;   // static variable
  int id;             // nonstatic variable

  // ALU inputs
  rand bit [31:0] data_in;
  rand bit        shift_rotate;
  rand bit        left_right;
  rand bit [4:0]  shift_amt;

  // ALU outputs
  bit      [31:0] data_out;


  function new(bit [31:0] data_in,
               bit        shift_rotate,
               bit        left_right,
               bit [4:0]  shift_amt
               );
    this.data_in      = data_in;
    this.shift_rotate = shift_rotate;
    this.left_right   = left_right;
    this.shift_amt    = shift_amt;
    id = count;
    count = count + 1;
  endfunction

  function void display();
    $display("-------------------------------------------");
    $display("count=%0d, ID=%0d, data_in=%0d, shift_rotate=%0d, left_right=%0b, shift_amt=%0b, data_out=%0d",
             count, id, data_in, shift_rotate, left_right, shift_amt, data_out);
    $display("-------------------------------------------");
  endfunction
endclass
`endif // TRANSACTION_A_SV
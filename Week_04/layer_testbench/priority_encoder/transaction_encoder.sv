`ifndef TRANSACTION_A_SV
`define TRANSACTION_A_SV
class Transaction;
  static int count;   // static variable
  int id;             // nonstatic variable

  // ALU inputs
  rand bit [7:0] data_in;
  rand bit       enable;

  // ALU outputs
  bit [2:0] encoded_out;
  bit              valid;

  function new(bit [7:0] data_in,
               bit       enable);
    this.data_in      = data_in;
    this.enable       = enable;
    id = count;
    count = count + 1;
  endfunction

  function void display();
    $display("-------------------------------------------");
    $display("count=%0d, ID=%0d, data_in=%0d, enable=%0d, encoded_out=%0b, valid=%0b",
             count, id, data_in, enable, encoded_out, valid);
    $display("-------------------------------------------");
  endfunction
endclass
`endif // TRANSACTION_A_SV
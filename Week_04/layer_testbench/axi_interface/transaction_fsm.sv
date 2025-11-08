`ifndef TRANSACTION_AXI_SV
`define TRANSACTION_AXI_SV

class Transaction;
  static int count = 0;   // static variable
  int cycle;              // cycle identifier for scoreboard matching
  
  // AXI inputs
  rand bit        start_write;
  rand bit        start_read;
  rand bit [31:0] write_address;
  rand bit [31:0] write_data;
  rand bit [31:0] read_address; 

  // AXI outputs
  logic [31:0] read_data;
  logic        write_done;
  logic        read_done;

  function new(int cycle);
    this.cycle = cycle;
    count = count + 1;
  endfunction

  function void display();
    $display("-------------------------------------------");
    $display("Txn count=%0d, cycle=%0d, start_write=%0b, start_read=%0b, write_address=%0b, write_data=%0b, read_address=%0b ", 
             count, cycle, start_write, start_read, write_address, write_data, read_address);
    $display("  read_data=%03b, erite_done=%03b, read_done=%0b, ",
             read_data, write_done, read_done);
    $display("-------------------------------------------");
  endfunction
endclass

`endif // TRANSACTION_FSM_SV
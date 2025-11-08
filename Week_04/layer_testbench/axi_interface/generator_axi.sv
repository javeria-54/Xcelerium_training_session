`ifndef GENERATOR_AXI_SV
`define GENERATOR_AXI_SV

`include "transaction_axi.sv"

class generator;
  int     repeat_count;
  mailbox gen2drv;
  mailbox gen2scb;

  function new(mailbox gen2drv, mailbox gen2scb, int repeat_count);
    this.repeat_count = repeat_count;
    this.gen2drv      = gen2drv;
    this.gen2scb      = gen2scb;
  endfunction

  task run();
    Transaction trans, trans_copy;
    
    for (int i = 0; i < repeat_count; i++) begin
      trans = new(i);

      trans.start_read       = $urandom_range(0, 1);     // Random 0 or 1
      trans.start_write      = $urandom_range(0, 1);     // Random 0 or 1
      trans.write_address    = $urandom_range(0, 1);     // Random 0 or 1
      trans.write_data       = $urandom_range(0, 1);     // Random 0 or 1
      trans.read_address     = $urandom_range(0, 1);     // Random 0 or 1

      trans.display();
      
      // Send to driver
      gen2drv.put(trans);
      
      // Send copy to scoreboard
      trans_copy = new(i);
      trans_copy.start_read       = trans.start_read;
      trans_copy.start_write      = trans.start_write;
      trans_copy.write_address    = trans.write_address;
      trans_copy.write_data       = trans.write_data;
      trans_copy.read_address     = trans.read_address;
      gen2scb.put(trans_copy);
    end
    
    $display("[GEN] Generated %0d transactions", repeat_count);
  endtask
endclass

`endif // GENERATOR_FSM_SV

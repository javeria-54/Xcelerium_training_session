`ifndef GENERATOR_FSM_SV
`define GENERATOR_FSM_SV

`include "transaction_fsm.sv"

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

      trans.emergency       = $urandom_range(0, 1);     // Random 0 or 1
      trans.pedestrian_req  = $urandom_range(0, 1);     // Random 0 or 1

      trans.display();
      
      // Send to driver
      gen2drv.put(trans);
      
      // Send copy to scoreboard
      trans_copy = new(i);
      trans_copy.emergency       = trans.emergency;
      trans_copy.pedestrian_req  = trans.pedestrian_req;
      gen2scb.put(trans_copy);
    end
    
    $display("[GEN] Generated %0d transactions", repeat_count);
  endtask
endclass

`endif // GENERATOR_FSM_SV

`include "transaction_encoder.sv"

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
    Transaction trans, trans1;
    repeat (repeat_count) begin
      // ctor needs a,b,op_sel — pass placeholders, then randomize
      trans = new(0,0);      // safe initialization
      assert(trans.randomize());  // if you want random values

      trans.display();
      gen2drv.put(trans);

      // copy for scoreboard (same pattern as your PDF)
      trans1 = new(trans.data_in, trans.enable);
      gen2scb.put(trans1);
    end
  endtask
endclass

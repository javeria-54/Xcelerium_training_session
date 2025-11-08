// generator_bs.sv (FIXED - correct parameter order)
`include "transaction_bs.sv"

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
      // Create with proper parameter order: data_in, shift_rotate, left_right, shift_amt
      trans = new(0, 0, 0, 0);
      assert(trans.randomize());

      trans.display();
      gen2drv.put(trans);

      // Copy for scoreboard with CORRECT parameter order
      trans1 = new(trans.data_in, trans.shift_rotate, trans.left_right, trans.shift_amt);
      gen2scb.put(trans1);
    end
  endtask
endclass
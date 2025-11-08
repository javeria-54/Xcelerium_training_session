`include "transaction_alu.sv"

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
      trans = new(0, 0, 0);

      // randomize the rand fields (adjust opcode range for your ALU)
      assert( trans.randomize() with { op_sel inside {[0:5]}; } )
        else $fatal("Generator randomize() failed");

      trans.display();
      gen2drv.put(trans);

      // copy for scoreboard (same pattern as your PDF)
      trans1 = new(trans.a, trans.b, trans.op_sel);
      gen2scb.put(trans1);
    end
  endtask
endclass

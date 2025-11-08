`include "transaction_alu.sv"

class driver;
  mailbox gen2drv;
  int     repeat_count;
  virtual alu_if.drv ainf;

  function new(mailbox gen2drv, int repeat_count, virtual alu_if.drv ainf);
    this.gen2drv      = gen2drv;
    this.repeat_count = repeat_count;
    this.ainf         = ainf;
  endfunction

  task run();
    Transaction trans;
    reset_bus();
    repeat (repeat_count) begin
      gen2drv.get(trans);
      // optional: trans.display();
      drive_one(trans.a, trans.b, trans.op_sel);
    end
  endtask

  task reset_bus();
    @(posedge ainf.clk);
    ainf.valid  = 0;
    ainf.a      = '0;
    ainf.b      = '0;
    ainf.op_sel = '0;
  endtask

  // Drive data BEFORE the sampling edge (posedge) and keep valid high for one cycle
  task drive_one(input bit signed [7:0] a,
                 input bit signed [7:0] b,
                 input bit        [2:0] op_sel);
    @(negedge ainf.clk);
      ainf.a      = a;   // blocking assignments are fine in TB
      ainf.b      = b;
      ainf.op_sel = op_sel;
      ainf.valid  = 1;
      $display("[%0t DRV] a=%0d  b=%0d  op=%0d  valid=%0b",
               $time, ainf.a, ainf.b, ainf.op_sel, ainf.valid);

    // monitor samples at this posedge
    @(posedge ainf.clk);

    // drop valid on next negedge (exactly one-cycle pulse)
    @(negedge ainf.clk);
      ainf.valid = 0;
  endtask
endclass


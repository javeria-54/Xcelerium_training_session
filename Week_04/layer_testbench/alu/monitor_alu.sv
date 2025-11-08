`include "transaction_alu.sv"

class monitor;
  mailbox mon2scb;
  int     repeat_count;
  virtual alu_if.mon ainf;

  function new(mailbox mon2scb, int repeat_count, virtual alu_if.mon ainf);
    this.mon2scb      = mon2scb;
    this.repeat_count = repeat_count;
    this.ainf         = ainf;
  endfunction

  task run();
    Transaction trans;
    int ncount = 0;
    while (ncount < repeat_count) begin
      @(posedge ainf.clk);
      if (!ainf.reset && ainf.valid) begin
        // data and valid are already stable here
        trans = new(ainf.a, ainf.b, ainf.op_sel);
        trans.result   = ainf.result;
        trans.zero     = ainf.zero;
        trans.carry    = ainf.carry;
        trans.overflow = ainf.overflow;

        mon2scb.put(trans);
        trans.display();

        // readable one-line summary
        $display("[%0t MON] a=%0d  b=%0d  op=%0d  -> result=%0d  Z=%0b C=%0b V=%0b",
                 $time, trans.a, trans.b, trans.op_sel,
                 trans.result, trans.zero, trans.carry, trans.overflow);

        ncount++;
      end
    end
  endtask
endclass


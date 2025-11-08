// monitor_bs.sv (FIXED - proper sampling of combinational outputs)
`include "transaction_bs.sv"

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
      #2;  // Wait for driver to apply inputs + combinational settling
      
      if (!ainf.reset) begin
        // Sample current inputs and outputs
        trans = new(ainf.data_in, ainf.shift_rotate, ainf.left_right, ainf.shift_amt);
        trans.data_out = ainf.data_out;

        mon2scb.put(trans);

        $display("[%0t MON] data_in=0x%08h shift_rotate=%0d left_right=%0d shift_amt=%0b -> data_out=0x%08h",
                 $time, trans.data_in, trans.shift_rotate, trans.left_right, trans.shift_amt,
                 trans.data_out);

        ncount++;
      end
    end
    
    $display("[MON] Monitoring complete: %0d transactions captured", ncount);
  endtask
endclass
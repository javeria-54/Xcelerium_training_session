// monitor_alu.sv (CORRECTED - samples combinational outputs)
`include "transaction_encoder.sv"

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
      
      // Since DUT is purely combinational, sample after inputs are stable
      // Wait small delta for combinational logic to settle
      #1;
      
      if (!ainf.reset) begin
        trans = new(ainf.data_in, ainf.enable);
        trans.valid       = ainf.valid;        // Read DUT output
        trans.encoded_out = ainf.encoded_out;  // Read DUT output

        mon2scb.put(trans);
        trans.display();

        $display("[%0t MON] data_in=%0b enable=%0d -> enc=%0d valid=%0b",
                 $time, trans.data_in, trans.enable, 
                 trans.encoded_out, trans.valid);

        ncount++;
      end
    end
    
    $display("[MON] Monitoring complete: %0d transactions captured", ncount);
  endtask
endclass
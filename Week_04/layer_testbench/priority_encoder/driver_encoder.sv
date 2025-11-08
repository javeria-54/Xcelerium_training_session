// driver_alu.sv (CORRECTED - removed valid signal driving)
`include "transaction_encoder.sv"

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
      drive_one(trans.data_in, trans.enable);
    end
  endtask

  task reset_bus();
    @(posedge ainf.clk);
    ainf.data_in = '0;
    ainf.enable  = '0;
  endtask

  // Drive only the INPUTS (data_in, enable)
  // valid is DUT output, we don't drive it!
  task drive_one(input bit [7:0] data_in, input bit enable);
    @(negedge ainf.clk);
    ainf.data_in = data_in;
    ainf.enable  = enable;
    
    $display("[%0t DRV] Drove data_in=%0b enable=%0d", 
             $time, data_in, enable);
    
    // Wait for DUT to process (give it one full cycle)
    @(posedge ainf.clk);
  endtask
endclass

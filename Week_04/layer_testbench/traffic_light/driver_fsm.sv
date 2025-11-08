`ifndef DRIVER_FSM_SV
`define DRIVER_FSM_SV

`include "transaction_fsm.sv"

class driver;
  mailbox gen2drv;
  int     repeat_count;
  virtual traffic_if.drv tif;

  function new(mailbox gen2drv, int repeat_count, virtual traffic_if.drv tif);
    this.gen2drv      = gen2drv;
    this.repeat_count = repeat_count;
    this.tif          = tif;
  endfunction

  task run();
    Transaction trans;
    
    // Apply reset
    reset_dut();
    
    // Drive transactions
    repeat (repeat_count) begin
      gen2drv.get(trans);
      drive_one(trans);
    end
    
    $display("[DRV] Completed driving %0d transactions", repeat_count);
  endtask

  task reset_dut();
    @(posedge tif.clk);
    tif.rst_n = 1'b0;
    tif.emergency = 1'b0;
    tif.pedestrian_req = 1'b0;
    
    repeat(2) @(posedge tif.clk);
    tif.rst_n = 1'b1;
    
    $display("[DRV] Reset applied");
  endtask

  task drive_one(input Transaction trans);
    @(posedge tif.clk);
    #1ns;  // Small delay to avoid race conditions
    
    tif.emergency = trans.emergency;
    tif.pedestrian_req = trans.pedestrian_req;
    
    $display("[%0t DRV] cycle=%0d emergency=%0b pedestrian_req=%0b",
             $time, trans.cycle, trans.emergency, trans.pedestrian_req);
  endtask
endclass

`endif // DRIVER_FSM_SV
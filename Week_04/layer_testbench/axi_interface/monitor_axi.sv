`ifndef MONITOR_AXI_SV
`define MONITOR_AXI_SV

`include "transaction_axi.sv"

class monitor;
  mailbox mon2scb;
  int     repeat_count;
  virtual traffic_if.mon tif;

  function new(mailbox mon2scb, int repeat_count, virtual traffic_if.mon tif);
    this.mon2scb      = mon2scb;
    this.repeat_count = repeat_count;
    this.tif          = tif;
  endfunction

  task run();
    Transaction trans;
    int cycle_count = 0;
    
    // Wait for reset to complete
    wait(tif.rst_n === 1'b1);
    
    while (cycle_count < repeat_count) begin
      @(posedge tif.clk);
      #2ns;  // Wait for outputs to settle after clock edge
      
      trans = new(cycle_count);
      
      // Sample inputs
      trans.emergency = tif.emergency;
      trans.pedestrian_req = tif.pedestrian_req;
      
      // Sample outputs
      trans.ns_lights = tif.ns_lights;
      trans.ew_lights = tif.ew_lights;
      trans.ped_walk = tif.ped_walk;
      trans.emergency_active = tif.emergency_active;
      
      mon2scb.put(trans);
      
      $display("[%0t MON] cycle=%0d ns=%03b ew=%03b ped=%0b emg=%0b",
               $time, cycle_count, trans.ns_lights, trans.ew_lights, 
               trans.ped_walk, trans.emergency_active);
      
      cycle_count++;
    end
    
    $display("[MON] Monitoring complete: %0d transactions", cycle_count);
  endtask
endclass

`endif // MONITOR_FSM_SV
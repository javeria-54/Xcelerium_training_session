`ifndef TOP_FSM_SV
`define TOP_FSM_SV

`include "interface_fsm.sv"
`include "test_fsm.sv"

module tb_top;
  // Clock generator - 25MHz (40ns period)
  bit clk;
  initial begin
    clk = 1'b0;
    forever #20ns clk = ~clk;
  end

  // Interface instance
  traffic_if tif(clk);

  // DUT instance
  traffic_controller dut (
    .clk              (tif.clk),
    .rst_n            (tif.rst_n),
    .emergency        (tif.emergency),
    .pedestrian_req   (tif.pedestrian_req),
    .ns_lights        (tif.ns_lights),
    .ew_lights        (tif.ew_lights),
    .ped_walk         (tif.ped_walk),
    .emergency_active (tif.emergency_active)
  );

  // Test program instance
  test t0(tif);
  
  // Waveform dump
  initial begin
    $dumpfile("traffic_tb.vcd");
    $dumpvars(0, tb_top);
  end
  
  // Timeout watchdog
  initial begin
    #100us;
    $display("[TIMEOUT] Simulation timeout reached");
    $finish;
  end
endmodule

`endif // TOP_FSM_SVs
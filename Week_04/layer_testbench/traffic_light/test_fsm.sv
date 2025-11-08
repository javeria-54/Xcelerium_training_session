`ifndef TEST_FSM_SV
`define TEST_FSM_SV

`include "environment_fsm.sv"

// Changed from 'program automatic test' → 'module test'
module test (traffic_if tif);
  initial begin
    environment env;
    
    $display("[TEST] Starting test with 50 transactions");
    env = new(tif, 5);
    env.run();
    
    #100ns;  // Allow time for final processing
    $display("[TEST] Test completed");
    $finish;
  end
endmodule

`endif // TEST_FSM_SV

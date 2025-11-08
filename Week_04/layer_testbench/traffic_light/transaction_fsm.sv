`ifndef TRANSACTION_FSM_SV
`define TRANSACTION_FSM_SV

class Transaction;
  static int count = 0;   // static variable
  int cycle;              // cycle identifier for scoreboard matching
  
  // Traffic controller inputs
  rand bit        emergency;
  rand bit        pedestrian_req;

  // Traffic controller outputs
  logic [2:0]     ns_lights;
  logic [2:0]     ew_lights;
  logic           ped_walk;
  logic           emergency_active;

  function new(int cycle);
    this.cycle = cycle;
    count = count + 1;
  endfunction

  function void display();
    $display("-------------------------------------------");
    $display("Txn count=%0d, cycle=%0d, emergency=%0b, pedestrian_req=%0b", 
             count, cycle, emergency, pedestrian_req);
    $display("  ns_lights=%03b, ew_lights=%03b, ped_walk=%0b, emergency_active=%0b",
             ns_lights, ew_lights, ped_walk, emergency_active);
    $display("-------------------------------------------");
  endfunction
endclass

`endif // TRANSACTION_FSM_SV
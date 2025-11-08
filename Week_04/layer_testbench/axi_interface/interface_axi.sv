`ifndef INTERFACE_AXI_SV
`define INTERFACE_AXI_SV

interface traffic_if (input logic clk);
  // Traffic controller inputs (driven by driver)
  logic       rst_n;
  logic       emergency;
  logic       pedestrian_req;

  // Traffic controller outputs (monitored)
  logic [2:0] ns_lights;
  logic [2:0] ew_lights;
  logic       ped_walk;
  logic       emergency_active;

  // Driver modport: drives inputs, reads outputs
  modport drv (
    input  clk, ns_lights, ew_lights, ped_walk, emergency_active,
    output rst_n, emergency, pedestrian_req
  );

  // Monitor modport: reads everything
  modport mon (
    input clk, rst_n, emergency, pedestrian_req,
          ns_lights, ew_lights, ped_walk, emergency_active
  );
endinterface

`endif // INTERFACE_FSM_SV
`ifndef ENVIRONMENT_FSM_SV
`define ENVIRONMENT_FSM_SV

`include "interface_fsm.sv"
`include "transaction_fsm.sv"
`include "generator_fsm.sv"
`include "driver_fsm.sv"
`include "monitor_fsm.sv"
`include "scoreboard_fsm.sv"

class environment;
  // Mailboxes
  mailbox gen2drv, mon2scb, gen2scb;

  // Components
  generator           gen;
  driver              drv;
  monitor             mon;
  traffic_scoreboard  scb;

  function new(virtual traffic_if tif, int repeat_count);
    virtual traffic_if.drv drv_if;
    virtual traffic_if.mon mon_if;

    // Allocate mailboxes
    gen2drv = new();
    mon2scb = new();
    gen2scb = new();

    // Derive modport views
    drv_if = tif;
    mon_if = tif;

    // Build components
    gen = new(gen2drv, gen2scb, repeat_count);
    drv = new(gen2drv, repeat_count, drv_if);
    mon = new(mon2scb, repeat_count, mon_if);
    scb = new(gen2scb, mon2scb, repeat_count);
  endfunction

  task run();
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join
  endtask
endclass

`endif // ENVIRONMENT_FSM_SV
// environment_alu.sv
`include "interface_alu.sv"
`include "transaction_alu.sv"
`include "generator_alu.sv"
`include "driver_alu.sv"
`include "monitor_alu.sv"
`include "scoreboard_alu.sv"

class environment;
  // mailboxes
  mailbox gen2drv, mon2scb, gen2scb;

  // components
  generator  gen;
  driver     drv;
  monitor    mon;
  scoreboard scb;

  // pass base interface; derive drv/mon views (modports)
  function new(virtual interface alu_if ainf, int repeat_count);
    // --- declare locals BEFORE any statements ---
    virtual alu_if.drv drv_if;
    virtual alu_if.mon mon_if;

    // allocate mailboxes
    gen2drv = new();
    mon2scb = new();
    gen2scb = new();

    // derive modport views
    drv_if = ainf;
    mon_if = ainf;

    // build components
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

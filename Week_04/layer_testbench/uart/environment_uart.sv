`ifndef ENVIRONMENT_UART_SV
`define ENVIRONMENT_UART_SV

`include "interface_uart.sv"
`include "transaction_uart.sv"
`include "generator_uart.sv"
`include "driver_uart.sv"
`include "monitor_uart.sv"
`include "scoreboard_uart.sv"

class environment;
  // Fixed: Mailboxes with proper parameterization
  mailbox #(Transaction) gen2drv, mon2scb, gen2scb;

  // Components
  generator          gen;
  driver             drv;
  monitor            mon;
  uart_scoreboard    scb;

  // UART timing parameters
  parameter int CLK_FREQ = 50_000_000;
  parameter int BAUD_RATE = 115200;
  parameter int BAUD_TICKS_PER_BIT = CLK_FREQ / BAUD_RATE; // ~434 ticks

  function new(virtual uart_if uif, int repeat_count);
    virtual uart_if.drv drv_if;
    virtual uart_if.mon mon_if;

    // Fixed: Allocate parameterized mailboxes
    gen2drv = new();
    mon2scb = new();
    gen2scb = new();

    // Derive modport views
    drv_if = uif;
    mon_if = uif;

    // Build components
    gen = new(gen2drv, gen2scb, repeat_count);
    drv = new(gen2drv, repeat_count, drv_if);
    mon = new(mon2scb, repeat_count, mon_if);
    // Fixed: Added BAUD_TICKS_PER_BIT parameter to scoreboard constructor
    scb = new(gen2scb, mon2scb, repeat_count, BAUD_TICKS_PER_BIT);
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

`endif // ENVIRONMENT_UART_SV
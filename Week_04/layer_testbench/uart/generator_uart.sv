`ifndef GENERATOR_UART_SV
`define GENERATOR_UART_SV

`include "transaction_uart.sv"

class generator;
  int     repeat_count;
  // Fixed: Parameterized mailboxes
  mailbox #(Transaction) gen2drv;
  mailbox #(Transaction) gen2scb;

  function new(mailbox #(Transaction) gen2drv, mailbox #(Transaction) gen2scb, int repeat_count);
    this.repeat_count = repeat_count;
    this.gen2drv      = gen2drv;
    this.gen2scb      = gen2scb;
  endfunction

  task run();
    Transaction trans, trans_copy;

    $display("\n========================================");
    $display("[GEN] Starting generation of %0d UART transactions", repeat_count);
    $display("========================================\n");

    for (int i = 0; i < repeat_count; i++) begin
      trans = new(i);

      // Generate realistic 8-bit UART data
      trans.tx_data  = $urandom_range(0, 255);
      trans.tx_valid = 1'b1;

      $display("[%0t][GEN] Generated Transaction #%0d: data=0x%02h, valid=%0b", 
               $time, i+1, trans.tx_data, trans.tx_valid);

      // Send to driver
      gen2drv.put(trans);
      $display("[%0t][GEN] --> Sent to Driver mailbox", $time);

      // Also send a copy to scoreboard
      trans_copy = new(i);
      trans_copy.tx_data  = trans.tx_data;
      trans_copy.tx_valid = trans.tx_valid;
      gen2scb.put(trans_copy);
      $display("[%0t][GEN] --> Sent to Scoreboard mailbox\n", $time);

      // Critical: Must wait for previous transmission to complete
      // Each UART transmission takes ~87us (10 bits @ 115200 baud)
      // Driver adds 90us delay, so we need to sync with that
      if (i == 0) begin
        #200us;  // Extra delay for first transaction (init + transmission)
      end else begin
        #100us;  // Wait for previous transmission to complete
      end
    end

    $display("========================================");
    $display("[GEN] Completed generation of %0d transactions", repeat_count);
    $display("========================================\n");
  endtask
endclass

`endif // GENERATOR_UART_SV
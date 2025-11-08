`ifndef MONITOR_UART_SV
`define MONITOR_UART_SV

`include "transaction_uart.sv"

//========================================================
// UART Monitor Class
//========================================================
class monitor;

  //========================================
  // Handles and parameters
  //========================================
  // Fixed: Parameterized mailbox
  mailbox #(Transaction) mon2scb;
  int     repeat_count;
  virtual uart_if.mon uif;

  //========================================
  // Constructor
  //========================================
  function new(mailbox #(Transaction) mon2scb, int repeat_count, virtual uart_if.mon uif);
    this.mon2scb      = mon2scb;
    this.repeat_count = repeat_count;
    this.uif          = uif;
  endfunction


  //========================================
  // Main Run Task
  //========================================
  task run();
    Transaction trans;
    int cycle_count = 0;
    bit rx_valid_prev = 1'b0;

    $display("\n========================================");
    $display("[MON] Monitor started");
    $display("========================================\n");

    // Wait for reset to be deasserted
    wait (uif.rst_n === 1'b1);
    $display("[%0t][MON] Reset detected, waiting for UART to stabilize...\n", $time);

    // Critical: Wait for first complete transmission cycle
    // UART needs: reset time + first TX drive + full transmission time
    // Reset: ~90ns, TX drive: ~110ns, Transmission: ~87us, Driver delay: 100us
    // Total: ~190us minimum, adding safety margin
    #200us;

    forever begin
      @(posedge uif.clk);
      #1ns; // Small delay for stability

      // Detect rising edge of rx_valid
      if (uif.rx_valid && !rx_valid_prev) begin
        trans = new(cycle_count);

        // TX-side info (optional, for debug)
        trans.tx_data   = uif.tx_data;
        trans.tx_valid  = uif.tx_valid;
        trans.tx_ready  = uif.tx_ready;

        // RX-side info
        trans.rx_data   = uif.rx_data;
        trans.rx_valid  = uif.rx_valid;
        trans.rx_error  = uif.rx_error;
        trans.rx_busy   = uif.rx_busy;

        $display("[%0t][MON] Captured RX Transaction #%0d:", $time, cycle_count+1);
        $display("[%0t][MON]   RX: data=0x%02h, valid=%0b, error=%0b, busy=%0b",
                 $time, trans.rx_data, trans.rx_valid, trans.rx_error, trans.rx_busy);

        mon2scb.put(trans);
        $display("[%0t][MON] --> Sent to Scoreboard mailbox\n", $time);

        cycle_count++;
        if (cycle_count >= repeat_count) begin
          $display("========================================");
          $display("[MON] Monitoring complete: %0d packets captured", cycle_count);
          $display("========================================\n");
          break;
        end
      end

      rx_valid_prev = uif.rx_valid;
      
      // Add timeout check to prevent infinite wait
      if ($time > 2000us && cycle_count < repeat_count) begin
        $display("\n[%0t][MON] ERROR: Timeout waiting for transaction #%0d", $time, cycle_count+1);
        $display("[MON] Only %0d/%0d packets received", cycle_count, repeat_count);
        $display("[MON] Current signals: rx_valid=%0b, rx_data=0x%02h, rx_error=%0b, rx_busy=%0b\n",
                 uif.rx_valid, uif.rx_data, uif.rx_error, uif.rx_busy);
        break;
      end
    end
  endtask

endclass

`endif // MONITOR_UART_SV
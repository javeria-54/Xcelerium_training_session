`ifndef UART_SCOREBOARD_SV
`define UART_SCOREBOARD_SV

`include "transaction_uart.sv"

class uart_scoreboard;

  mailbox #(Transaction) gen2scb;
  mailbox #(Transaction) mon2scb;
  int repeat_count;
  int BAUD_TICKS_PER_BIT;

  int compared = 0;
  int pass = 0;
  int fail = 0;

  byte exp_byte;
  Transaction tx_trans;
  Transaction rx_trans;
  byte expected_queue[$];
  Transaction received_queue[$];

  function new(mailbox #(Transaction) gen2scb,
               mailbox #(Transaction) mon2scb,
               int repeat_count,
               int BAUD_TICKS_PER_BIT);
    this.gen2scb = gen2scb;
    this.mon2scb = mon2scb;
    this.repeat_count = repeat_count;
    this.BAUD_TICKS_PER_BIT = BAUD_TICKS_PER_BIT;
  endfunction

  task run();
    // Declare all variables at the beginning
    int actual_received;
    int missing;
    
    $display("========================================");
    $display("[SCB] UART Scoreboard Started...");
    $display("========================================\n");

    // Collect all expected and received values FIRST, then compare
    fork
      // Thread 1: Collect expected values
      begin
        for (int i = 0; i < repeat_count; i++) begin
          gen2scb.get(tx_trans);
          expected_queue.push_back(tx_trans.tx_data);
          $display("[%0t][SCB] <-- Expected #%0d = 0x%02h", $time, i+1, tx_trans.tx_data);
        end
        $display("\n[SCB] All expected values collected\n");
      end

      // Thread 2: Collect received values
      begin
        for (int i = 0; i < repeat_count; i++) begin
          fork
            begin
              mon2scb.get(rx_trans);
              received_queue.push_back(rx_trans);
              $display("[%0t][SCB] <-- Received #%0d = 0x%02h (stored for comparison)", 
                       $time, i+1, rx_trans.rx_data);
            end
            begin
              #2000us;  // Increased timeout from 1500us
              $display("[%0t][SCB] WARNING: Timeout waiting for RX transaction #%0d", $time, i+1);
            end
          join_any
          disable fork;
        end
        $display("\n[SCB] All received values collected (got %0d/%0d)\n", 
                 received_queue.size(), repeat_count);
      end
    join

    // Now compare all at once
    $display("========================================");
    $display("[SCB] Starting Comparison...");
    $display("========================================\n");

    // Only compare what we received - CRITICAL FIX
    actual_received = received_queue.size();
    compared = (actual_received < repeat_count) ? actual_received : repeat_count;

    $display("[SCB] Expected: %0d transactions, Received: %0d transactions\n", 
             repeat_count, actual_received);

    for (int i = 0; i < compared; i++) begin
      exp_byte = expected_queue[i];
      rx_trans = received_queue[i];  // Safe because i < compared <= actual_received
      
      $display("[%0t][SCB] Comparing Transaction #%0d", $time, i+1);
      
      if (rx_trans.rx_valid && !rx_trans.rx_error) begin
        if (rx_trans.rx_data === exp_byte) begin
          pass++;
          $display("[%0t][SCB] ✓ PASS | Expected=0x%02h | Got=0x%02h", 
                   $time, exp_byte, rx_trans.rx_data);
        end else begin
          fail++;
          $display("[%0t][SCB] ✗ FAIL | Expected=0x%02h | Got=0x%02h", 
                   $time, exp_byte, rx_trans.rx_data);
        end
      end else begin
        fail++;
        $display("[%0t][SCB] ✗ FAIL | RX Error or Invalid: Expected=0x%02h | Got=0x%02h | valid=%0b | error=%0b", 
                 $time, exp_byte, rx_trans.rx_data, rx_trans.rx_valid, rx_trans.rx_error);
      end
    end

    // Check for missing transactions
    if (actual_received < repeat_count) begin
      missing = repeat_count - actual_received;
      fail += missing;
      $display("\n[%0t][SCB] ✗ ERROR: Missing %0d transaction(s)!", $time, missing);
      
      // Show which transactions are missing
      for (int i = actual_received; i < repeat_count; i++) begin
        $display("[SCB]   Missing Transaction #%0d: Expected=0x%02h", 
                 i+1, expected_queue[i]);
      end
    end

    $display("\n========================================");
    $display("[SCB] Verification Complete");
    $display("[SCB] Total: %0d | Pass: %0d | Fail: %0d", compared, pass, fail);
    if (pass == repeat_count) begin
      $display("[SCB] ✓✓✓ ALL TESTS PASSED ✓✓✓");
    end else begin
      $display("[SCB] ✗✗✗ SOME TESTS FAILED ✗✗✗");
    end
    $display("========================================\n");
  endtask

endclass

`endif
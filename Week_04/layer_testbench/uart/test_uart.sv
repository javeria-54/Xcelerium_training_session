`ifndef TEST_UART_SV
`define TEST_UART_SV

`include "environment_uart.sv"

module test (uart_if uif);
  initial begin
    environment env;
    
    $display("\n");
    $display("================================================");
    $display("       UART TESTBENCH STARTED");
    $display("       Transaction Count: 5");
    $display("       Baud Rate: 115200");
    $display("       Clock Frequency: 50MHz");
    $display("================================================");
    
    env = new(uif, 5);
    env.run();
    
    // Wait for all transactions to complete
    // Transaction 1: 200us (init) + 100us (transmission) = 300us
    // Transactions 2-5: 4 * (100us + 100us) = 800us
    // Driver final delay: 200us (increased)
    // Total: ~1300us + scoreboard processing margin
    #2000us;  // Increased for safety
    
    $display("\n");
    $display("================================================");
    $display("       UART TESTBENCH COMPLETED");
    $display("       Simulation Time: %0t", $time);
    $display("================================================");
    $finish;
  end
endmodule

`endif // TEST_UART_SV
`ifndef TOP_UART_SV
`define TOP_UART_SV

`include "interface_uart.sv"
`include "test_uart.sv"

module tb_top;
  // Clock generator - 50MHz (20ns period)
  bit clk;
  initial begin
    clk = 1'b0;
    forever #10ns clk = ~clk;  // 50MHz = 20ns period = 10ns half-period
  end

  // Interface instance
  uart_if uif(clk);

  // DUT instance
  uart_top dut (
    .clk              (uif.clk),
    .rst_n            (uif.rst_n),
    .tx_valid         (uif.tx_valid),
    .tx_data          (uif.tx_data),
    .tx_ready         (uif.tx_ready),
    .rx_busy          (uif.rx_busy),
    .rx_data          (uif.rx_data),
    .rx_valid         (uif.rx_valid),
    .rx_error         (uif.rx_error)
  );

  // Test program instance
  test t0(uif);
  
  // Debug monitors
  initial begin
    @(posedge uif.rst_n);
    #250us;
    
    $display("\n========================================");
    $display("DEBUG: Monitoring RX signals continuously");
    $display("========================================\n");
    
    forever begin
      @(posedge clk);
      if (uif.rx_valid) begin
        $display("[%0t][DEBUG-RX] RX Valid! data=0x%02h, error=%0b, busy=%0b", 
                 $time, uif.rx_data, uif.rx_error, uif.rx_busy);
      end
    end
  end

  // Monitor TX acceptance
  initial begin
    @(posedge uif.rst_n);
    
    forever begin
      @(posedge clk);
      if (uif.tx_valid && uif.tx_ready) begin
        $display("[%0t][DEBUG-TX] TX Accepted! data=0x%02h", 
                 $time, uif.tx_data);
      end
    end
  end
  
  // Waveform dump
  initial begin
    $dumpfile("uart_tb.vcd");
    $dumpvars(0, tb_top);
  end
  
  // Timeout watchdog - Fixed for UART timing
  // Transaction 1: ~300us, Transactions 2-5: ~800us
  // Total: ~1100us + margin
  initial begin
    #3ms;  // Safe timeout with good margin
    $display("\n[TIMEOUT] Simulation timeout reached at %0t", $time);
    $display("This may indicate a hang in the testbench or DUT.\n");
    $finish;
  end
endmodule

`endif // TOP_UART_SV
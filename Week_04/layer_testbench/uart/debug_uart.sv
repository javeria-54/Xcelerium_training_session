// Add this debug code inside tb_top module in top_uart.sv
// This will help us see what's happening with RX signals

initial begin
  // Wait for reset
  @(posedge uif.rst_n);
  #250us;  // After monitor starts
  
  $display("\n========================================");
  $display("DEBUG: Monitoring RX signals continuously");
  $display("========================================\n");
  
  forever begin
    @(posedge clk);
    if (uif.rx_valid) begin
      $display("[%0t][DEBUG] RX Valid! data=0x%02h, error=%0b, busy=%0b", 
               $time, uif.rx_data, uif.rx_error, uif.rx_busy);
    end
  end
end

// Monitor TX side too
initial begin
  @(posedge uif.rst_n);
  
  forever begin
    @(posedge clk);
    if (uif.tx_valid && uif.tx_ready) begin
      $display("[%0t][DEBUG] TX Accepted! data=0x%02h", 
               $time, uif.tx_data);
    end
  end
end
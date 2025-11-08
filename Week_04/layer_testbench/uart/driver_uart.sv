`ifndef DRIVER_UART_SV
`define DRIVER_UART_SV

`include "transaction_uart.sv"

class driver;
    // Fixed: Parameterized mailbox
    mailbox #(Transaction) gen2drv;
    int     repeat_count;
    virtual uart_if.drv uif;

    function new(mailbox #(Transaction) gen2drv, int repeat_count, virtual uart_if.drv uif);
        this.gen2drv      = gen2drv;
        this.repeat_count = repeat_count;
        this.uif          = uif;
    endfunction

    task run();
        Transaction trans;
        
        $display("\n========================================");
        $display("[DRV] Driver started");
        $display("========================================\n");
        
        reset_dut();
        
        repeat (repeat_count) begin
            gen2drv.get(trans);
            $display("[%0t][DRV] <-- Received from Generator mailbox", $time);
            drive_one(trans);
        end
        
        // Extra delay after last transmission to ensure RX completes
        $display("[%0t][DRV] Waiting for final RX to complete...", $time);
        #200us;  // Increased from 150us to 200us
        
        $display("\n========================================");
        $display("[DRV] Completed driving %0d transactions", repeat_count);
        $display("========================================\n");
    endtask

    task reset_dut();
        @(posedge uif.clk);
        uif.rst_n     = 1'b0;
        uif.tx_data   = 8'h00;
        uif.tx_valid  = 1'b0;
        repeat (2) @(posedge uif.clk);
        uif.rst_n     = 1'b1;
        repeat (2) @(posedge uif.clk);  // Extra cycle for stability
        $display("[%0t][DRV] Reset completed\n", $time);
    endtask

    task drive_one(input Transaction trans);
        // Wait until UART is ready to accept new data
        $display("[%0t][DRV] Waiting for tx_ready...", $time);
        wait (uif.tx_ready == 1'b1);
        $display("[%0t][DRV] tx_ready is HIGH", $time);

        @(posedge uif.clk);
        uif.tx_data  = trans.tx_data;
        uif.tx_valid = trans.tx_valid;

        $display("[%0t][DRV] Driving: data=0x%02h, valid=%0b", 
                 $time, trans.tx_data, trans.tx_valid);

        @(posedge uif.clk);
        uif.tx_valid = 1'b0;  // De-assert after one cycle
        $display("[%0t][DRV] De-asserted tx_valid", $time);
        
        // Wait for transmission to complete before next transaction
        // UART takes ~87us per byte (10 bits @ 115200 baud)
        #90us;
        $display("[%0t][DRV] Transmission complete\n", $time);
    endtask
endclass

`endif // DRIVER_UART_SV
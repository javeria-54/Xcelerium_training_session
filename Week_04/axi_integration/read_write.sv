`timescale 1ns/1ps

module tb_top;

    // ------------------------------------------------------------
    // clock & reset
    // ------------------------------------------------------------
    logic clk;
    logic rst_n;

    // DUT inputs
    logic start_write, start_read;
    logic [31:0] write_address, write_data, read_address;
    logic rx_serial;
    logic [1:0] parity_sel;
    logic rx_ready;

    // DUT outputs
    logic tx_done, tx_ready, tx_serial, tx_busy;
    logic [31:0] read_data;
    logic write_done, read_done;

    // clock generation (50 MHz → 20 ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // ------------------------------------------------------------
    // DUT instance
    // ------------------------------------------------------------
    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .start_write(start_write),
        .start_read(start_read),
        .write_address(write_address),
        .write_data(write_data),
        .read_address(read_address),
        .rx_serial(rx_serial),
        .parity_sel(parity_sel),
        .rx_ready(rx_ready),
        .tx_done(tx_done),
        .tx_ready(tx_ready),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy),
        .read_data(read_data),
        .write_done(write_done),
        .read_done(read_done)
    );

    // ------------------------------------------------------------
    // UART stimulus (for RX path)
    // ------------------------------------------------------------
    localparam int BIT_TIME = 434; // 50MHz/115200 ≈ 434 cycles

    initial rx_serial = 1'b1;  // idle line is high

    task send_uart_byte(input [7:0] data);
        int i;
        begin
            // start bit
            rx_serial = 1'b0;
            repeat(BIT_TIME) @(posedge clk);

            // data bits (LSB first)
            for (i = 0; i < 8; i++) begin
                rx_serial = data[i];
                repeat(BIT_TIME) @(posedge clk);
            end

            // stop bit
            rx_serial = 1'b1;
            repeat(BIT_TIME) @(posedge clk);
        end
    endtask

    // ------------------------------------------------------------
    // Stimulus process: First write, then read
    // ------------------------------------------------------------
    initial begin
        // init inputs
        start_write   = 0;
        start_read    = 0;
        write_address = 32'h0;
        write_data    = 32'h0;
        read_address  = 32'h0;
        parity_sel    = 2'b00;   // no parity
        rx_ready      = 1'b1;    // RX always ready

        // reset
        rst_n = 0;
        #50;
        rst_n = 1;
        #50;

        // --------------------------------------------------------
        // AXI Write transaction
        // --------------------------------------------------------
        $display("[%0t] Starting AXI write...", $time);
        write_address = 32'h0000_0020;
        write_data    = 32'h0000_0004;   // sending 0x04
        start_write   = 1;
        @(posedge clk);
        start_write   = 0;
        
        wait(write_done)
        $display("[%0t] Write completed on status reg.", $time);

        write_address = 32'h0000_0004;
        write_data    = 32'h0000_00A5;   // sending 0xA5
        start_write   = 1;
        @(posedge clk);
        start_write   = 0;

        // wait for write_done
        wait(write_done);
        $display("[%0t] Write completed on transmitter reg.", $time);

        // --------------------------------------------------------
        // Send byte via UART RX line
        // --------------------------------------------------------
        $display("[%0t] Sending UART byte 0xA5...", $time);
        send_uart_byte(8'hA5);

        // wait for RX to latch data
        repeat(1000) @(posedge clk);

        // --------------------------------------------------------
        // AXI Read transaction
        // --------------------------------------------------------
        $display("[%0t] Starting AXI read...", $time);
        read_address = 32'h0000_0028; // assume RX register mapped here
        start_read   = 1;
        @(posedge clk);
        start_read   = 0;

        wait(read_done);
        $display("[%0t] Read completed. Data = 0x%0h", $time, read_data);

        if (read_data[7:0] == 8'hA5)
            $display("TEST PASSED: Received data matches sent byte");
        else
            $display("TEST FAILED: Expected 0xA5, got 0x%0h", read_data[7:0]);

        #100;
        $finish;
    end

endmodule

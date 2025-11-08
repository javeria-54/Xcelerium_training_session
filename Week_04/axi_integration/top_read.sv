`timescale 1ns/1ps

module tb_top_read;

    // clock & reset
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

    // clock generation (50 MHz)
    initial clk = 0;
    always #10 clk = ~clk;   // 20 ns period → 50 MHz

    // DUT instance
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

    // ------------------------------------------------------------------
    // UART stimulus: bit-bang a byte on rx_serial
    // ------------------------------------------------------------------
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

    // ------------------------------------------------------------------
    // Stimulus process
    // ------------------------------------------------------------------
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
        #10;
        rst_n = 1;
        #10;

        // send one byte into RX
        $display("[%0t] Sending UART byte 0xA5...", $time);
        send_uart_byte(8'hA5);

        // give RX some time to finish
        @(posedge clk);

        // trigger AXI read
        $display("[%0t] Starting AXI read...", $time);
        read_address = 32'h0000_0028; // assume this maps to RX register
        start_read   = 1;
        @(posedge clk);
        start_read   = 0;

        // wait for read_done
        wait(read_done);
        $display("[%0t] Read completed. Data = 0x%0h", $time, read_data);

        if (read_data[7:0] == 8'hA5)
            $display("TEST PASSED: Received data matches sent byte");
        else
            $display("TEST FAILED: Expected 0xA5, got 0x%0h", read_data[7:0]);

        #50;
        $finish;
    end

endmodule

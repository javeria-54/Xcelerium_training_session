module uart_rx_datapath #(
    parameter int CLK_FREQ             = 50_000_000,
    parameter int BAUD_RATE            = 115200,
    parameter int FIFO_DEPTH           = 8,
    parameter int DATA_WIDTH           = 8,
    parameter int ALMOST_FULL_THRESH   = 6,
    parameter int ALMOST_EMPTY_THRESH  = 2
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx_serial,      // incoming serial data
    output logic       rx_error,       // error (framing/parity)
    output logic       rx_busy,        // receiver busy
    output logic [7:0] rx_data,        // received data output
    output logic       rx_valid        // valid pulse when data is ready
);

    // Internal signals
    logic [7:0]   fifo_data_int;
    logic         rx_valid_int;
    logic         rx_error_int;
    logic         rx_busy_int;
    logic         fifo_wr_en;
    logic         fifo_rd_en;
    logic         fifo_full;
    logic         fifo_empty;
    logic         fifo_almost_full;
    logic         fifo_almost_empty;
    logic [$clog2(FIFO_DEPTH):0] fifo_count;
    
    // Parity selection - can be parameterized if needed
    logic [1:0]   parity_sel = 2'b00;  // No parity by default
    logic         stop_bits = 1'b1;    // 1 stop bit by default
    logic         start_bit_en = 1'b1; // Start bit enabled by default
    
    // Baud divisor calculation
    logic [11:0]  baud_divisor;
    assign baud_divisor = CLK_FREQ / BAUD_RATE;
    
    // Assign outputs
    assign rx_valid = ~fifo_empty;     // data available in FIFO
    assign rx_error = rx_error_int;    // error propagated
    assign rx_busy  = rx_busy_int;     // busy flag from FSM
    
    // FIFO read enable - read when not empty and external logic is ready
    assign fifo_rd_en = ~fifo_empty;   // Always read when data is available
    
    // FIFO write enable - write when Rx_Datapath has valid data and FIFO is not full
    assign fifo_wr_en = rx_valid_int && ~fifo_full;
    
    // Rx_Datapath instance
    Rx_shift_reg #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_rx_datapath (
        .clk(clk),
        .reset(~rst_n),           // Active high reset
        .rx_serial(rx_serial), // Use LSB of rx_serial
        .baud_divisor(baud_divisor),
        .parity_sel(parity_sel),
        .rx_data(fifo_data_int),
        .rx_valid(rx_valid_int),
        .rx_error(rx_error_int),
        .rx_busy(rx_busy_int)
    );
    
    // FIFO instance
    uart_rx_sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_THRESH(ALMOST_FULL_THRESH),
        .ALMOST_EMPTY_THRESH(ALMOST_EMPTY_THRESH)
    ) u_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(fifo_wr_en),
        .wr_data(fifo_data_int),
        .rd_en(fifo_rd_en),
        .rd_data(rx_data),        // Connected directly to output
        .full(fifo_full),
        .empty(fifo_empty),
        .almost_full(fifo_almost_full),
        .almost_empty(fifo_almost_empty),
        .count(fifo_count)
    );

endmodule
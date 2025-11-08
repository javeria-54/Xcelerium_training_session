module uart_top #(
    parameter int CLK_FREQ             = 50_000_000,
    parameter int BAUD_RATE            = 115200,
    parameter int FIFO_DEPTH           = 8,
    parameter int DATA_WIDTH           = 8,
    parameter int ALMOST_FULL_THRESH   = 6,
    parameter int ALMOST_EMPTY_THRESH  = 2
)(
    input  logic              clk,
    input  logic              rst_n,

    // Transmit-side interface (user inputs)
    input  logic [DATA_WIDTH-1:0] tx_data,
    input  logic                  tx_valid,
    output logic                  tx_ready,

    // Receive-side interface (user outputs)
    output logic [DATA_WIDTH-1:0] rx_data,
    output logic                  rx_valid,
    output logic                  rx_error,
    output logic                  rx_busy
);

    // -----------------------------------------
    // Internal connection between Tx and Rx
    // -----------------------------------------
    logic tx_serial;
    logic tx_busy_int;

    // -----------------------------------------
    // Instantiate UART Transmitter
    // -----------------------------------------
    uart_transmitter #(
        .CLK_FREQ   (CLK_FREQ),
        .BAUD_RATE  (BAUD_RATE),
        .FIFO_DEPTH (FIFO_DEPTH),
        .DATA_WIDTH (DATA_WIDTH),
        .ALMOST_FULL_THRESH (ALMOST_FULL_THRESH),
        .ALMOST_EMPTY_THRESH (ALMOST_EMPTY_THRESH)
    ) u_tx (
        .clk        (clk),
        .rst_n      (rst_n),
        .tx_data    (tx_data),
        .tx_valid   (tx_valid),
        .tx_ready   (tx_ready),
        .tx_serial  (tx_serial),   // output line
        .tx_busy    (tx_busy_int)
    );

    // -----------------------------------------
    // Instantiate UART Receiver
    // -----------------------------------------
    uart_rx_datapath #(
        .CLK_FREQ   (CLK_FREQ),
        .BAUD_RATE  (BAUD_RATE),
        .FIFO_DEPTH (FIFO_DEPTH),
        .DATA_WIDTH (DATA_WIDTH),
        .ALMOST_FULL_THRESH (ALMOST_FULL_THRESH),
        .ALMOST_EMPTY_THRESH (ALMOST_EMPTY_THRESH)
    ) u_rx (
        .clk        (clk),
        .rst_n      (rst_n),
        .rx_serial  (tx_serial),   // loopback connection
        .rx_error   (rx_error),
        .rx_busy    (rx_busy),
        .rx_data    (rx_data),
        .rx_valid   (rx_valid)
    );



endmodule

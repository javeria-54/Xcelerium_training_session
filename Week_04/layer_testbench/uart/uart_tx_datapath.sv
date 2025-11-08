module uart_transmitter #(
    parameter int CLK_FREQ   = 50_000_000,
    parameter int BAUD_RATE  = 115200,
    parameter int FIFO_DEPTH = 8,
    parameter int DATA_WIDTH           = 8,
    parameter int ALMOST_FULL_THRESH   = 6,
    parameter int ALMOST_EMPTY_THRESH  = 2
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] tx_data,
    input  logic       tx_valid,
    output logic       tx_ready,
    output logic       tx_serial,
    output logic       tx_busy
);

    // ----------------------------
    // Internal signals
    // ----------------------------
    logic              fifo_wr_en, fifo_rd_en;
    logic [7:0]        fifo_wr_data, fifo_rd_data;
    logic              fifo_full, fifo_empty;
    logic [$clog2(FIFO_DEPTH):0] fifo_count;

    logic              ctrl_tx_ready, ctrl_tx_done;
    logic              data_available,almost_full,almost_empty;

    // ----------------------------
    // FIFO Instance
    // ----------------------------
    uart_tx_sync_fifo #(
        .DATA_WIDTH (8),
        .FIFO_DEPTH (FIFO_DEPTH),
        .ALMOST_FULL_THRESH (FIFO_DEPTH-1),
        .ALMOST_EMPTY_THRESH(1)
    ) fifo_inst (
        .clk         (clk),
        .rst_n       (rst_n),
        .wr_en       (fifo_wr_en),
        .wr_data     (fifo_wr_data),
        .rd_en       (fifo_rd_en),
        .rd_data     (fifo_rd_data),
        .full        (fifo_full),
        .empty       (fifo_empty),
        .almost_full (almost_full),
        .almost_empty(almost_empty),
        .count       (fifo_count)
    );

    // ----------------------------
    // Controller Instance
    // ----------------------------
    uart_tx_controller #(
        .CLK_FREQ   (CLK_FREQ),
        .BAUD_RATE  (BAUD_RATE),
        .FIFO_DEPTH (FIFO_DEPTH)
    ) ctrl_inst (
        .clk            (clk),
        .reset          (~rst_n),
        .tx_data        (fifo_rd_data),
        .baud_divisor   (CLK_FREQ/BAUD_RATE), // fixed divisor
        .data_available (data_available),
        .parity_sel     (2'b00),    // no parity (configurable if needed)
        .tx_valid       (!fifo_empty),
        .tx_done        (ctrl_tx_done),
        .tx_ready       (ctrl_tx_ready),
        .tx_serial      (tx_serial),
        .tx_busy        (tx_busy)
    );

    // ----------------------------
    // FIFO Write Logic
    // ----------------------------
    assign fifo_wr_en   = tx_valid & !fifo_full;
    assign fifo_wr_data = tx_data;
    assign tx_ready     = !fifo_full;

    // ----------------------------
    // FIFO Read Logic
    // ----------------------------
    assign data_available = !fifo_empty;
    assign fifo_rd_en = (ctrl_tx_ready ) & (!fifo_empty);

endmodule

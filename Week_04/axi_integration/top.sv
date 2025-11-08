module top(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start_write,     // New: Trigger write transaction
    input  logic        start_read,      // New: Trigger read transaction
    input  logic [31:0] write_address,
    input  logic [31:0] write_data,
    input  logic [31:0] read_address,    // New: Separate read address
    input  logic        rx_serial,  
    input  logic [1:0]  parity_sel,
    input  logic        rx_ready,

    output logic        tx_done,     
    output logic        tx_ready, 
    output logic        tx_serial, 
    output logic        tx_busy,
    output logic [31:0] read_data,       // New: Output for read data
    output logic        write_done,      // New: Write completion indicator
    output logic        read_done       // New: Read completion indicator 

);
    // internal wires
    logic [7:0]  tx_data;
    logic        data_available,tx_valid;
    logic [7:0]  rx_data;
    logic        rx_error, rx_busy, rx_done, rx_valid;

    // AXI interface
    axi4_lite_if axi_if();

    uart_tx_controller #(
        .CLK_FREQ (50000000),
        .BAUD_RATE (115200)
    )u_tx(
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),  
        .data_available(data_available), 
        .parity_sel(parity_sel), 
        .tx_valid(tx_valid),
        .tx_done(tx_done),     
        .tx_ready(tx_ready), 
        .tx_serial(tx_serial), 
        .tx_busy(tx_busy)
    ); 
    
    uart_rx_controller #(
        .CLK_FREQ (50000000),
        .BAUD_RATE (115200) 
    )u_rx(
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(rx_serial),  
        .parity_sel(parity_sel), 
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error),
        .rx_busy(rx_busy),
        .rx_done(rx_done),
        .rx_ready(rx_ready)
    );
    
    axi4_lite_master u_master(
        .clk(clk),
        .rst_n(rst_n),
        .start_write(start_write),     
        .start_read(start_read),     
        .write_address(write_address),
        .write_data(write_data),
        .read_address(read_address),    
        .read_data(read_data),       
        .write_done(write_done),     
        .read_done(read_done),      
        .axi_if(axi_if.master)
    );
    
    axi4_lite_slave u_slave(
        .clk(clk),
        .rst_n(rst_n),
        .tx_done(tx_done),
        .tx_ready(tx_ready),
        .tx_busy(tx_busy),
        .rx_valid(rx_valid),
        .rx_error(rx_error),
        .rx_done(rx_done),
        .rx_busy(rx_busy),
        .rx_ready(rx_ready),
        .parity_sel(parity_sel),
        .tx_valid(tx_valid),
        .tx_start(tx_start),
        .rx_data(rx_data),
        .tx_data(tx_data),
        .data_available(data_available),
        .axi_if(axi_if.slave)
    );

endmodule
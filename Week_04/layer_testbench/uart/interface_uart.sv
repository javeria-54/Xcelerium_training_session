`ifndef INTERFACE_UART_SV
`define INTERFACE_UART_SV

interface uart_if (input logic clk);
  // UART inputs (driven by driver)
  logic       rst_n;
  logic [7:0] tx_data;
  logic       tx_valid;

  // UART outputs (monitored)
  logic       tx_ready;
  logic [7:0] rx_data;
  logic       rx_valid;
  logic       rx_error;
  logic       rx_busy;

  // Driver modport: drives inputs, reads outputs
  modport drv (
    input  clk, tx_ready, rx_data, rx_valid, rx_error, rx_busy,
    output rst_n, tx_data, tx_valid
  );

  // Monitor modport: reads everything
  modport mon (
    input clk, rst_n, tx_data, tx_valid,
          tx_ready, rx_data, rx_valid, rx_error, rx_busy
  );
endinterface

`endif // INTERFACE_UART_SV


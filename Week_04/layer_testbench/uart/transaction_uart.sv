`ifndef TRANSACTION_UART_SV
`define TRANSACTION_UART_SV

class Transaction;
    static int count = 0;   // static variable
    int cycle;              // cycle identifier for scoreboard matching
  
  // Traffic controller inputs
    rand bit [7:0]        tx_data;
    rand bit              tx_valid;

  // Traffic controller outputs
    logic           tx_ready;
    logic [7:0]     rx_data;
    logic           rx_valid;
    logic           rx_error;
    logic           rx_busy;

    function new(int cycle);
        this.cycle = cycle;
        count = count + 1;
    endfunction

    function void display();
        $display("--------------------------------------------------");
        $display("Txn[%0d]  Cycle=%0d", count, cycle);
        $display("TX: data=%02h  valid=%0b  ready=%0b", tx_data, tx_valid, tx_ready);
        $display("RX: data=%02h  valid=%0b  error=%0b  busy=%0b",
                 rx_data, rx_valid, rx_error, rx_busy);
        $display("--------------------------------------------------");
    endfunction

endclass

`endif // TRANSACTION_FSM_SV
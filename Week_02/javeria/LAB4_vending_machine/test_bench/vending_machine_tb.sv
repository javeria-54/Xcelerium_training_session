`timescale 1ns/1ps

module tb_vending_machine;

    // DUT inputs
    logic clk;
    logic rst_n;
    logic coin_5, coin_10, coin_25, coin_return;

    // DUT outputs
    logic dispense_item;
    logic return_5, return_10, return_25;
    logic [5:0] amount_display;

    // Instantiate DUT
    vending_machine dut (
        .clk(clk),
        .rst_n(rst_n),
        .coin_5(coin_5),
        .coin_10(coin_10),
        .coin_25(coin_25),
        .coin_return(coin_return),
        .dispense_item(dispense_item),
        .return_5(return_5),
        .return_10(return_10),
        .return_25(return_25),
        .amount_display(amount_display)
    );

    // Clock generation (10ns period = 100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset task
    task reset_dut();
        begin
            rst_n = 0;
            coin_5 = 0;
            coin_10 = 0; 
            coin_25 = 0; 
            coin_return = 0;
            #20;   // hold reset
            rst_n = 1;
        end
    endtask

    // Stimulus
    initial begin
        $dumpfile("tb_vending_machine.vcd");
        $dumpvars(0, tb_vending_machine);

        reset_dut();

        // Case 1: Insert 5 + 10 + 15 -> 30 (dispense)
        @(posedge clk);
        coin_5 = 1; 
        #10; 
        coin_5 = 0;  
        @(posedge clk);
        coin_10 = 1; 
        #10; 
        coin_10 = 0;
        @(posedge clk);
        coin_10 = 1; 
        #10; 
        coin_10 = 0;  
        @(posedge clk);
        #20;

        // Case 2: Insert 25 + 10 = 35 (should dispense + return 5¢)
        @(posedge clk);
        coin_25 = 1; 
        #10; 
        coin_25 = 0;
        @(posedge clk);
        coin_10 = 1; 
        #10; 
        coin_10 = 0;
        @(posedge clk);
        #20;

        // Case 3: Insert 25 + 25 = 50 (should dispense + return 20¢ as two 10¢)
        @(posedge clk);
        coin_25 = 1; 
        #10; 
        coin_25 = 0;
        @(posedge clk);
        coin_25 = 1; 
        #10; 
        coin_25 = 0;
        @(posedge clk);
        #20;

        // Case 4: Insert 10, then press coin_return (should return 10¢)
        @(posedge clk);
        coin_10 = 1; 
        #10; 
        coin_10 = 0;
        @(posedge clk);
        coin_return = 1; 
        #10; 
        coin_return = 0;
        @(posedge clk);
        #20;

        $finish;
    end

    // Monitor DUT
    initial begin
        $monitor("T=%0t | amount=%0d | dispense=%b | return5=%b return10=%b return25=%b",
                 $time, amount_display, dispense_item, return_5, return_10, return_25);
    end

endmodule

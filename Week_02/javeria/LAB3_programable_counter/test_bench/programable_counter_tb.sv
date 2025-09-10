`timescale 1ns/1ps

module tb_programmable_counter;

    // DUT inputs
    logic clk;
    logic rst_n;
    logic load;
    logic enable;
    logic up_down;
    logic [7:0] load_value;
    logic [7:0] max_count;

    // DUT outputs
    logic [7:0] count;
    logic tc;
    logic zero;

    // Instantiate DUT
    programmable_counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .enable(enable),
        .up_down(up_down),
        .load_value(load_value),
        .max_count(max_count),
        .count(count),
        .tc(tc),
        .zero(zero)
    );

    // Clock generation
    always #5 clk = ~clk;  // 100MHz clock → period = 10ns

    // Task to display counter status
    task show_status(string msg);
        $display("%0t | %s | count=%0d, tc=%b, zero=%b",
                 $time, msg, count, tc, zero);
    endtask

    initial begin
        // Initialize
        clk = 0;
        rst_n = 0;
        load = 0;
        enable = 0;
        up_down = 0;
        load_value = 8'd0;
        max_count = 8'd10;

        // Apply reset
        #12;
        rst_n = 1;
        show_status("After reset");

        // Scenario 1: Load with enable=0, up_down=0
        load_value = 8'd7;
        load = 1;
        enable = 0;
        up_down = 0;
        #10; load = 0;
        show_status("Scenario 1: load=1, enable=0, up_down=0");

        // Scenario 2: Load with enable=1
        load_value = 8'd5;
        load = 1;
        enable = 1;
        up_down = 1;
        #10; load = 0;
        show_status("Scenario 2: load=1, enable=1");

        // Scenario 3: Count UP
        enable = 1;
        up_down = 1;
        repeat (12) begin
            #10; show_status("Counting UP");
        end

        // Scenario 4: Count DOWN
        enable = 1;
        up_down = 0;
        repeat (8) begin
            #10; show_status("Counting DOWN");
        end

        // Scenario 5: Hold (enable=0)
        enable = 0;
        load = 0;
        #20; show_status("Scenario 5: HOLD");

        // Scenario 6: Wrap-around UP
        enable = 1;
        up_down = 1;
        max_count = 8'd5;
        repeat (8) begin
            #10; show_status("Wrap-around UP");
        end

        // Scenario 7: Reset
        rst_n = 0;
        #10;
        rst_n = 1;
        #10; show_status("Scenario 7: RESET");

        $finish;
    end

endmodule

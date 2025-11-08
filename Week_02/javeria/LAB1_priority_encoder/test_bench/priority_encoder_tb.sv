`timescale 1ns/1ps

module tb_priority_encoder_8to3;

    // Testbench signals
    logic       enable;
    logic [7:0] data_in;
    logic [2:0] encoded_out;
    logic       valid;

    // Instantiate DUT
    priority_encoder_8to3 dut (
        .enable(enable),
        .data_in(data_in),
        .encoded_out(encoded_out),
        .valid(valid)
    );

    // Task to display results
    task automatic check_output(input [7:0] din, input en);
        begin
            #5; // small delay for comb logic
            $display("Time=%0t | enable=%b data_in=%b -> encoded_out=%b valid=%b",
                      $time, en, din, encoded_out, valid);
        end
    endtask

    // Stimulus
    initial begin
        $display("---- Starting Priority Encoder 8-to-3 Test ----");

        // Case 0: Disabled
        enable = 0; data_in = 8'b10000000; check_output(data_in, enable);

        // Case 1: Enabled, single input at MSB (In7)
        enable = 1; data_in = 8'b10000000; check_output(data_in, enable);

        // Case 2: Enabled, multiple inputs high (In7, In5) -> highest = In7
        data_in = 8'b10100000; check_output(data_in, enable);

        // Case 3: Enabled, In6 only
        data_in = 8'b01000000; check_output(data_in, enable);

        // Case 4: Enabled, In3 only
        data_in = 8'b00001000; check_output(data_in, enable);

        // Case 5: Enabled, In0 only
        data_in = 8'b00000001; check_output(data_in, enable);

        // Case 6: Enabled, no input active
        data_in = 8'b00000000; check_output(data_in, enable);

        // Random tests
        repeat(5) begin
            data_in = $random;
            enable  = 1;
            check_output(data_in, enable);
        end

        $display("---- Test Completed ----");
        $finish;
    end

endmodule

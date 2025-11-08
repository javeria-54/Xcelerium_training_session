`timescale 1ns/1ps

module tb_binary_to_bcd;

    logic [7:0]  binary_in;
    logic [11:0] bcd_out;

    // Instantiate DUT
    binary_to_bcd dut (
        .binary_in(binary_in),
        .bcd_out(bcd_out)
    );

    // Task to display results nicely
    task print_result(input [7:0] bin);
        $display("Binary: %0d (%08b) --> BCD: %0d%0d%0d", 
                 bin, bin, bcd_out[11:8], bcd_out[7:4], bcd_out[3:0]);
    endtask

    initial begin
        $display("==== Binary to BCD Testbench ====");
        
        // Apply test vectors
        binary_in = 8'd0;   #10; print_result(binary_in);
        binary_in = 8'd9;   #10; print_result(binary_in);
        binary_in = 8'd10;  #10; print_result(binary_in);
        binary_in = 8'd45;  #10; print_result(binary_in);
        binary_in = 8'd99;  #10; print_result(binary_in);
        binary_in = 8'd123; #10; print_result(binary_in);
        binary_in = 8'd200; #10; print_result(binary_in);
        binary_in = 8'd255; #10; print_result(binary_in);

        $display("==== Test Completed ====");
        $finish;
    end

endmodule

`timescale 1ns/1ps

module tb_alu_8bit;
    // Testbench signals
    logic signed [7:0] a, b;
    logic signed [2:0] op_sel;
    logic signed [7:0] result;
    logic zero, carry, overflow;

    // Instantiate DUT
    alu_8bit dut (
        .a(a),
        .b(b),
        .op_sel(op_sel),
        .result(result),
        .zero(zero),
        .carry(carry),
        .overflow(overflow)
    );

    task display_result;
        input string op_name;
        begin
            $display("Time=%0t | op=%s | a=%0d | b=%0d | result=%0d | zero=%b | carry=%b | overflow=%b",
                      $time, op_name, a, b, result, zero, carry, overflow);
        end
    endtask

    initial begin
        // Case 1: ADD
        a = 8'd50; b = 8'd60; op_sel = 3'b000; 
        #10;
        display_result("ADD");

        // Case 2: SUB
        a = 8'd80; b = 8'd100; op_sel = 3'b001; 
        #10;
        display_result("SUB");

        // Case 3: AND
        a = 8'b10101010; b = 8'b11001100; op_sel = 3'b010; 
        #10;
        display_result("AND");

        // Case 4: OR
        a = 8'b10101010; b = 8'b11001100; op_sel = 3'b011; 
        #10;
        display_result("OR");

        // Case 5: XOR
        a = 8'b11110000; b = 8'b10101010; op_sel = 3'b100; 
        #10;
        display_result("XOR");

        // Case 6: NOT
        a = 8'b00001111; b = 8'b0; op_sel = 3'b101; 
        #10;
        display_result("NOT");

        // Case 7: SHIFT LEFT
        a = 8'b00001111; b = 2; op_sel = 3'b110; 
        #10;
        display_result("SHIFT LEFT");

        // Case 8: SHIFT RIGHT
        a = 8'b10000000; b = 2; op_sel = 3'b111; 
        #10;
        display_result("SHIFT RIGHT");

        $finish;
    end
endmodule

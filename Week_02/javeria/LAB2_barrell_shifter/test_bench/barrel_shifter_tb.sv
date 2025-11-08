module tb_barrel_shifter;

    logic [31:0] data_in;
    logic [4:0]  shift_amt;
    logic        left_right;
    logic        shift_rotate;
    logic [31:0] data_out;

    // DUT instantiation
    barrel_shifter dut (
        .data_in(data_in),
        .shift_amt(shift_amt),
        .left_right(left_right),
        .shift_rotate(shift_rotate),
        .data_out(data_out)
    );

    initial begin
        $display("---- Barrel Shifter Test ----");
        data_in = 32'hA5A5_F0F0;

        // No shift
        shift_amt = 5'd0; left_right = 0; shift_rotate = 0; #10;
        $display("No Shift       : in=%h out=%h", data_in, data_out);

        // Shift left by 1
        shift_amt = 5'd1; left_right = 0; shift_rotate = 0; #10;
        $display("Left Shift 1   : in=%h out=%h", data_in, data_out);

        // Shift right by 1
        shift_amt = 5'd1; left_right = 1; shift_rotate = 0; #10;
        $display("Right Shift 1  : in=%h out=%h", data_in, data_out);

        // Shift left by 4
        shift_amt = 5'd4; left_right = 0; shift_rotate = 0; #10;
        $display("Left Shift 4   : in=%h out=%h", data_in, data_out);

        // Shift right by 4
        shift_amt = 5'd4; left_right = 1; shift_rotate = 0; #10;
        $display("Right Shift 4  : in=%h out=%h", data_in, data_out);

        // Rotate left by 8
        shift_amt = 5'd8; left_right = 0; shift_rotate = 1; #10;
        $display("Rotate Left 8  : in=%h out=%h", data_in, data_out);

        // Rotate right by 16
        shift_amt = 5'd16; left_right = 1; shift_rotate = 1; #10;
        $display("Rotate Right16 : in=%h out=%h", data_in, data_out);

        // Shift left by 31
        shift_amt = 5'd31; left_right = 0; shift_rotate = 0; #10;
        $display("Left Shift 31  : in=%h out=%h", data_in, data_out);

        // Rotate left by 31
        shift_amt = 5'd31; left_right = 0; shift_rotate = 1; #10;
        $display("Rotate Left31  : in=%h out=%h", data_in, data_out);

        // Rotate right by 32 (effectively no rotation)
        shift_amt = 5'd0; left_right = 1; shift_rotate = 1; #10;
        $display("Rotate Right32 : in=%h out=%h", data_in, data_out);

        // Try with all 1s
        data_in = 32'hFFFF_FFFF;
        shift_amt = 5'd8; left_right = 1; shift_rotate = 0; #10;
        $display("All 1s Right8  : in=%h out=%h", data_in, data_out);

        // Try with alternating bits
        data_in = 32'hAAAA_5555;
        shift_amt = 5'd12; left_right = 0; shift_rotate = 1; #10;
        $display("Alt Bits Rot12 : in=%h out=%h", data_in, data_out);

        $finish;
    end

endmodule

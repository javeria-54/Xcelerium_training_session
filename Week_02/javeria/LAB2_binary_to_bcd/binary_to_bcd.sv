module binary_to_bcd (
    input  logic [7:0]  binary_in,
    output logic [11:0] bcd_out   // {hundreds, tens, ones}
);
    integer i;
    logic [19:0] shift_reg;  
    // [19:16] hundreds, [15:12] tens, [11:8] ones, [7:0] binary_in

    always_comb begin
        // initialize: BCD = 0, binary_in at LSB side
        shift_reg = {12'd0, binary_in};

        // perform 8 shifts (for 8-bit input)
        for (i = 0; i < 8; i++) begin
            // check hundreds, tens, ones digits and add 3 if >=5
            if (shift_reg[19:16] >= 5)
                shift_reg[19:16] += 3;  // hundreds
            if (shift_reg[15:12] >= 5) 
                shift_reg[15:12] += 3;  // tens
            if (shift_reg[11:8]  >= 5) 
                shift_reg[11:8]  += 3;  // ones

            // shift left by 1
            shift_reg = shift_reg << 1;
        end

        // output result
        bcd_out = shift_reg[19:8];  
    end
endmodule

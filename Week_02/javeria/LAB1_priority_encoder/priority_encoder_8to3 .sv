module priority_encoder_8to3 (
    input  logic       enable,
    input  logic [7:0] data_in,
    output logic [2:0] encoded_out,
    output logic       valid
);
    always_comb begin
        encoded_out = 3'b000;  
        valid       = 0;    

        if (enable) begin
            casex (data_in)
                8'b1xxxxxxx: encoded_out = 3'b111; // In7 
                8'b01xxxxxx: encoded_out = 3'b110; // In6
                8'b001xxxxx: encoded_out = 3'b101; // In5
                8'b0001xxxx: encoded_out = 3'b100; // In4
                8'b00001xxx: encoded_out = 3'b011; // In3
                8'b000001xx: encoded_out = 3'b010; // In2
                8'b0000001x: encoded_out = 3'b001; // In1
                8'b00000001: encoded_out = 3'b000; // In0
                default    : encoded_out = 3'b000; 
            endcase

            if (data_in != 8'b00000000) begin
                valid = 1'b1;
            end else begin 
                valid = 1'b0;
            end
        end
    end
endmodule


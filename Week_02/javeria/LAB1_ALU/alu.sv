module alu_8bit (
    input  logic signed [7:0] a, b,
    input  logic signed [2:0] op_sel,
    output logic signed [7:0] result,
    output logic zero, carry, overflow
);
    logic [8:0] temp;

    always_comb begin
        carry = 1'b0;
        overflow = 1'b0;
        result = 8'b0;
        zero = 8'b0;

        unique case (op_sel)
        3'b000: begin
            temp = a + b;
            result = temp[7:0];
            carry = temp[8];
            overflow = (a[7]==b[7]) && (result[7] != a[7]);
        end
        3'b001: begin
            temp = a - b;
            result = temp[7:0];
            carry = temp[8];
            overflow = (a[7] != b[7]) && (result[7] != a[7]);
        end
        3'b010: begin
            result = a & b;
        end
        3'b011: begin
            result = a | b;
        end
        3'b100: begin
            result = a ^ b;
        end
        3'b101: begin
            result = ~a;
        end
        3'b110: begin
            result = a >> b[3:0];
        end
        3'b111: begin
            result = a << b[3:0]; 
        end
        endcase
        if (result == 8'b0)begin
            zero = 1'b1;
        end else begin
            zero = 1'b0;
        end
        end
endmodule

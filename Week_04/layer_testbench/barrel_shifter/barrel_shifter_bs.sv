module barrel_shifter (
    input  logic [31:0] data_in,
    input  logic [4:0]  shift_amt,
    input  logic        left_right,   // 0=left, 1=right
    input  logic        shift_rotate, // 0=shift, 1=rotate
    output logic [31:0] data_out
);

    logic [31:0] stage0, stage1, stage2, stage3, stage4;

    // Stage 0: shift by 1
    always_comb begin
        if (shift_amt[0]) begin
            if (!left_right) begin   // left
                stage0 = shift_rotate ? {data_in[30:0], data_in[31]} : {data_in[30:0], 1'b0};
            end else begin    // right
                stage0 = shift_rotate ? {data_in[0], data_in[31:1]} : {1'b0, data_in[31:1]};
            end
        end else begin
            stage0 = data_in;
        end 
    end

    // Stage 1: shift by 2 (USE STAGE0, NOT data_in!)
    always_comb begin
        if (shift_amt[1]) begin
            if (!left_right) begin
                stage1 = shift_rotate ? {stage0[29:0], stage0[31:30]} : {stage0[29:0], 2'b0};
            end else begin 
                stage1 = shift_rotate ? {stage0[1:0], stage0[31:2]} : {2'b0, stage0[31:2]};
            end
        end else begin
            stage1 = stage0;
        end
    end

    // Stage 2: shift by 4 (USE STAGE1!)
    always_comb begin
        if (shift_amt[2]) begin
            if (!left_right) begin
                stage2 = shift_rotate ? {stage1[27:0], stage1[31:28]} : {stage1[27:0], 4'b0};
            end else begin
                stage2 = shift_rotate ? {stage1[3:0], stage1[31:4]} : {4'b0, stage1[31:4]};
            end 
        end else begin
            stage2 = stage1;
        end
    end

    // Stage 3: shift by 8 (USE STAGE2!)
    always_comb begin
        if (shift_amt[3]) begin
            if (!left_right) begin
                stage3 = shift_rotate ? {stage2[23:0], stage2[31:24]} : {stage2[23:0], 8'b0};
            end else begin
                stage3 = shift_rotate ? {stage2[7:0], stage2[31:8]} : {8'b0, stage2[31:8]};
            end
        end else begin
            stage3 = stage2;
        end
    end

    // Stage 4: shift by 16 (USE STAGE3!)
    always_comb begin 
        if (shift_amt[4]) begin 
            if (!left_right) begin
                stage4 = shift_rotate ? {stage3[15:0], stage3[31:16]} : {stage3[15:0], 16'b0};
            end else begin
                stage4 = shift_rotate ? {stage3[15:0], stage3[31:16]} : {16'b0, stage3[31:16]};
            end 
        end else begin
            stage4 = stage3;
        end
    end
    
    assign data_out = stage4;

endmodule
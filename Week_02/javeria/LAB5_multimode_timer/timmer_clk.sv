`timescale 1ns/1ps

module tb_clk_1hz;

    // Testbench signals
    logic in_clk;
    logic rst_n;
    logic out_clk;

    // Instantiate DUT
    clk_1hz dut (
        .in_clk(in_clk),
        .rst_n(rst_n),
        .out_clk(out_clk)
    );

    // Clock generation: 50 MHz
    initial begin
        in_clk = 0;
        forever #10 in_clk = ~in_clk;  // period = 20 ns → 50 MHz
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #100;       // hold reset for 100 ns
        rst_n = 1;
    end

    // Monitor output
    initial begin
        $display("Time\tin_clk\tout_clk");
        $monitor("%0t\t%b\t%b", $time, in_clk, out_clk);
    end

    // Run simulation
    initial begin
        #50_000_000; // simulate ~1 ms (enough to see several toggles)
        $display("Simulation finished");
        $finish;
    end

endmodule

module clk_1hz(
    input  logic in_clk,
    input  logic rst_n,      // active-low reset
    output logic out_clk
);

logic [24:0] counter;

always_ff @(posedge in_clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 25'd0;
        out_clk <= 1'b0;
    end else begin
        if (counter < 25_000_000 - 1)
            counter <= counter + 1;
        else begin
            counter <= 25'd0;
            out_clk <= ~out_clk; // Toggle every 0.5 sec -> 1 Hz
        end
    end
end

endmodule

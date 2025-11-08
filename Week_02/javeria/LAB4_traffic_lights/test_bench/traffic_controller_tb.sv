`timescale 1ns/1ps

module tb_traffic_controller;

    // DUT signals
    logic clk;
    logic rst_n;
    logic emergency;
    logic pedestrian_req;
    logic [2:0] ns_lights;
    logic [2:0] ew_lights;
    logic ped_walk;
    logic emergency_active;

    // DUT instantiation
    traffic_controller dut (
        .clk(clk),
        .rst_n(rst_n),
        .emergency(emergency),
        .pedestrian_req(pedestrian_req),
        .ns_lights(ns_lights),
        .ew_lights(ew_lights),
        .ped_walk(ped_walk),
        .emergency_active(emergency_active)
    );

    // Clock generation (simulate 1 Hz with 10ns period for speed)
    initial clk = 0;
    always #5 clk = ~clk;   // 10ns clock

    // Task to display state info
    task show_status;
        $display("[%0t] NS=%b EW=%b Ped=%b Emergency=%b", 
                 $time, ns_lights, ew_lights, ped_walk, emergency_active);
    endtask

    // Test sequence
    initial begin
        $display("---- Traffic Controller Test ----");

        // Reset
        rst_n = 0;
        emergency = 0;
        pedestrian_req = 0;
        #20;
        rst_n = 1;

        // Let startup flash finish
        repeat(7) begin
            @(posedge clk);
            show_status();
        end

        // Normal operation
        $display("-- Normal cycle --");
        repeat(40) begin
            @(posedge clk);
            show_status();
        end

        // Pedestrian request during NS_YELLOW
        $display("-- Pedestrian request --");
        pedestrian_req = 1;
        repeat(5) @(posedge clk);
        pedestrian_req = 0;
        repeat(20) begin
            @(posedge clk);
            show_status();
        end

        // Emergency during green
        $display("-- Emergency triggered --");
        emergency = 1;
        repeat(12) begin
            @(posedge clk);
            show_status();
        end
        emergency = 0;  // Release emergency
        repeat(20) begin
            @(posedge clk);
            show_status();
        end

        $display("---- Test Completed ----");
        $finish;
    end

endmodule

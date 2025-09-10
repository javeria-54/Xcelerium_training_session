module timer_tb;
    reg clk;
    reg reset;
    reg enable;
    reg [1:0] mode;
    reg [31:0] load;
    reg [31:0] compare;
    reg [3:0] prescale;
    
    wire timeout;
    wire pwm_out;
    wire interrupt;
    
    // Instantiate the timer
    timer uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .mode(mode),
        .load(load),
        .compare(compare),
        .prescale(prescale),
        .timeout(timeout),
        .pwm_out(pwm_out),
        .interrupt(interrupt)
    );
    
    // Clock generation
    always #5 clk = ~clk; // 1 MHz clock (1000 ns period)
    
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        enable = 0;
        mode = 0;
        load = 0;
        compare = 0;
        prescale = 0;
        
        // Apply reset
        #20 reset = 0;
        
        // Test One-shot mode
        $display("=== Testing One-shot mode ===");
        mode = 2'b00;
        load = 32'd5; // Count 5 cycles
        enable = 1;
        #60 enable = 0;
        #100;
        
        // Test Periodic mode
        $display("=== Testing Periodic mode ===");
        reset = 1;
        #20 reset = 0;
        mode = 2'b01;
        load = 32'd3; // Count 3 cycles periodically
        enable = 1;
        #100;
        enable = 0;
        #50;
        
        // Test PWM mode
        $display("=== Testing PWM mode ===");
        reset = 1;
        #20 reset = 0;
        mode = 2'b10;
        load = 32'd10; // PWM period = 10 cycles
        compare = 32'd4; // 40% duty cycle
        enable = 1;
        #200;
        enable = 0;
        
        // Test with prescaler
        $display("=== Testing with Prescaler ===");
        reset = 1;
        #20 reset = 0;
        mode = 2'b01;
        load = 32'd3;
        prescale = 4'd2; // Divide by 3
        enable = 1;
        #200;
        
        $display("=== Simulation Complete ===");
        $finish;
    end
    
    // Monitor outputs
    always @(posedge clk) begin
        $display("t=%t mode=%b enable=%b counter=%d timeout=%b pwm_out=%b interrupt=%b", 
                 $time, mode, enable, uut.counter, timeout, pwm_out, interrupt);
    end

endmodule
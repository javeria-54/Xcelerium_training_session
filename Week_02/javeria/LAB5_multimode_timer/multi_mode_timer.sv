module timer (
    input wire clk,           
    input wire rst_n,         
    input wire enable,        
    input wire [1:0] mode,    // 00: One-shot, 01: Periodic, 10: PWM
    input wire [31:0] load,   
    input wire [31:0] compare,
    input wire [3:0] prescale,
    
    output reg timeout,       
    output reg pwm_out,       
    output reg interrupt      
);

    // Internal registers
    reg [31:0] counter;
    reg [31:0] prescale_counter;
    reg [3:0] prescale_value;
    reg running;
    reg pwm_direction; // 0: counting down, 1: counting up
    
    // Prescaler logic
    always @(posedge clk or negedge rst_n) begin
        if (!reset) begin
            prescale_counter <= 0;
            prescale_value <= 0;
        end else begin
            prescale_value <= prescale;
            if (prescale_counter >= prescale_value) begin
                prescale_counter <= 0;
            end else begin
                prescale_counter <= prescale_counter + 1;
            end
        end
    end
    
    // Clock enable generation
    wire clock_enable = (prescale_counter == prescale_value);
    
    // Main counter logic
    always @(posedge clk or posedge reset) begin
        if (!reset) begin
            counter <= 0;
            running <= 0;
            timeout <= 0;
            pwm_out <= 0;
            interrupt <= 0;
            pwm_direction <= 0;
        end else if (enable && clock_enable) begin
            if (!running && enable) begin
                // Start timer
                counter <= load;
                running <= 1;
                timeout <= 0;
                interrupt <= 0;
                pwm_direction <= 0; // Start counting down
            end else if (running) begin
                case (mode)
                    2'b00: begin // One-shot mode
                        if (counter == 0) begin
                            timeout <= 1;
                            interrupt <= 1;
                            running <= 0;
                        end else begin
                            counter <= counter - 1;
                        end
                    end
                    
                    2'b01: begin // Periodic mode
                        if (counter == 0) begin
                            timeout <= 1;
                            interrupt <= 1;
                            counter <= load;
                        end else begin
                            counter <= counter - 1;
                            timeout <= 0;
                            interrupt <= 0;
                        end
                    end
                    
                    2'b10: begin // PWM mode
                        // Up/down counter for PWM generation
                        if (pwm_direction == 0) begin // Counting down
                            if (counter == 0) begin
                                pwm_direction <= 1; // Switch to counting up
                                counter <= counter + 1;
                                timeout   <= 1;          // Timeout when reaching 0
                                interrupt <= 1;
                            end else begin
                                counter <= counter - 1;
                                timeout   <= 0;          // Timeout when reaching 0
                                interrupt <= 0;
                            end
                        end else begin // Counting up
                            if (counter == load) begin
                                pwm_direction <= 0; // Switch to counting down
                                counter <= counter - 1;
                                timeout   <= 1;          // Timeout when reaching 0
                                interrupt <= 1;
                            end else begin
                                counter <= counter + 1;
                                timeout   <= 0;          // Timeout when reaching 0
                                interrupt <= 0;
                            end
                        end
                        
                        // Generate PWM output
                        if (counter < compare) begin
                            pwm_out <= 1;
                        end else begin
                            pwm_out <= 0;
                        end
                    end
                    
                    default: begin
                        counter <= counter;
                    end
                endcase
            end
        end else if (!enable) begin
            // Timer disabled
            running <= 0;
            timeout <= 0;
            interrupt <= 0;
        end
    end

endmodule
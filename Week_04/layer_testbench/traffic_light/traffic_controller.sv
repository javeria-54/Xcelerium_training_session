module traffic_controller (
    input  logic       clk,          
    input  logic       rst_n,
    input  logic       emergency,
    input  logic       pedestrian_req,
    output logic [2:0] ns_lights,     // [Red, Yellow, Green]
    output logic [2:0] ew_lights,
    output logic       ped_walk,
    output logic       emergency_active
);

    // ---- STATE MACHINE ----
    typedef enum logic [2:0] {
        STARTUP_FLASH,
        NS_GREEN_EW_RED,
        NS_YELLOW_EW_RED,
        NS_RED_EW_GREEN,
        NS_RED_EW_YELLOW,
        PEDESTRIAN_CROSSING,
        EMERGENCY_ALL_RED
    } state_t;

    state_t state, next_state;
    logic [5:0] timer;        // 6-bit counter = up to 63 seconds
    logic ped_latched;        // stores pedestrian request until served
    logic last_served_ns;     // 1 = NS was last green, 0 = EW was last green

    // ---- Sequential: state + timer update ----
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state         <= STARTUP_FLASH;
        timer         <= 6'd5;         // startup flash
        ped_latched   <= 1'b0;
        last_served_ns<= 1'b0;
    end else begin
        state <= next_state;

        // Timer handling
        if (state != next_state) begin
            // Reload timer when state changes
            case (next_state)
                STARTUP_FLASH:       timer <= 6'd5;
                NS_GREEN_EW_RED:     timer <= 6'd30;
                NS_YELLOW_EW_RED:    timer <= 6'd5;
                NS_RED_EW_GREEN:     timer <= 6'd30;
                NS_RED_EW_YELLOW:    timer <= 6'd5;
                PEDESTRIAN_CROSSING: timer <= 6'd10;
                EMERGENCY_ALL_RED:   timer <= 6'd10;
                default:             timer <= 6'd0;
            endcase
        end else if (state != EMERGENCY_ALL_RED && timer > 0) begin
            // Countdown if staying in same state
            timer <= timer - 1;
        end

        // Latch pedestrian request
        if (pedestrian_req && state != PEDESTRIAN_CROSSING) begin
            ped_latched <= 1'b1;
        end

        // Clear latch when served
        if (state == PEDESTRIAN_CROSSING && timer == 1) begin
            ped_latched <= 1'b0;
        end

        // Update last served direction
        if (state == NS_GREEN_EW_RED && timer == 1) begin
            last_served_ns <= 1'b1;
        end else if (state == NS_RED_EW_GREEN && timer == 1) begin
            last_served_ns <= 1'b0;
        end
    end
end


    // ---- Combinational: next state + timer reload ----
    always_comb begin
        next_state = state;
        case (state)

            STARTUP_FLASH: begin
                if (emergency) begin
                    next_state = EMERGENCY_ALL_RED;
                end else if (timer == 0) begin
                    next_state = NS_GREEN_EW_RED;
                end else begin
                    next_state = state;
                end
            end

            NS_GREEN_EW_RED: begin
                if (emergency) begin
                    next_state = EMERGENCY_ALL_RED;
                end else if (timer == 0) begin
                    next_state = NS_YELLOW_EW_RED;
                end else  begin
                    next_state = state;
                end 
            end

            NS_YELLOW_EW_RED: begin
                if (emergency) begin
                    next_state = EMERGENCY_ALL_RED;
                end else if (timer == 0) begin
                    if (ped_latched) begin
                        next_state = PEDESTRIAN_CROSSING;
                    end else begin
                        next_state = NS_RED_EW_GREEN;
                    end
                end else  begin
                    next_state = state;
                end
            end

            NS_RED_EW_GREEN: begin
                if (emergency) begin
                    next_state = EMERGENCY_ALL_RED;
                end else if (timer == 0) begin 
                    next_state = NS_RED_EW_YELLOW;
                end else begin
                    next_state = state;
                end
            end

            NS_RED_EW_YELLOW: begin
                if (emergency)begin
                    next_state = EMERGENCY_ALL_RED;
                end else if (timer == 0) begin
                    if (ped_latched) begin
                        next_state = PEDESTRIAN_CROSSING;
                    end else begin
                        next_state = NS_GREEN_EW_RED;
                    end
                end else  begin
                    next_state = state;
                end 
            end

            PEDESTRIAN_CROSSING: begin
                if (emergency) begin
                    if (timer == 0)
                        next_state = EMERGENCY_ALL_RED;
                    else 
                        next_state = PEDESTRIAN_CROSSING;
                end else if (timer == 0) begin
                    if (last_served_ns) begin
                        next_state = NS_RED_EW_GREEN;
                    end else begin
                        next_state = NS_GREEN_EW_RED;
                    end 
                end else begin 
                    next_state = state;
                end
            end

            EMERGENCY_ALL_RED: begin
                if (!emergency && last_served_ns) begin
                    next_state = NS_RED_EW_GREEN;
                end else if (!emergency && !last_served_ns) begin
                    next_state = NS_GREEN_EW_RED;
                end
            end
            default: begin
                next_state = STARTUP_FLASH;
            end 
            
        endcase
    end

    

    // ---- Outputs ----
    always_comb begin
        ns_lights        = 3'b100; // default red
        ew_lights        = 3'b100;
        ped_walk         = 0;
        emergency_active = 0;

        case (state)
            STARTUP_FLASH: begin
                // Flashing yellow for both directions
                ns_lights = (timer[2]) ? 3'b010 : 3'b000; // Yellow flash
                ew_lights = (timer[2]) ? 3'b010 : 3'b000; // Yellow flash
            end

            NS_GREEN_EW_RED: begin
                ns_lights = 3'b001; // Green
                ew_lights = 3'b100; // Red
                ped_walk         = 0;
                emergency_active = 0;
            end

            NS_YELLOW_EW_RED: begin
                ns_lights = 3'b010; // Yellow
                ew_lights = 3'b100; // Red
                ped_walk         = 0;
                emergency_active = 0;
            end

            NS_RED_EW_GREEN: begin
                ns_lights = 3'b100; // Red
                ew_lights = 3'b001; // Green
                ped_walk         = 0;
                emergency_active = 0;
            end

            NS_RED_EW_YELLOW: begin
                ns_lights = 3'b100; // Red
                ew_lights = 3'b010; // Yellow
                ped_walk         = 0;
                emergency_active = 0;
            end

            PEDESTRIAN_CROSSING: begin
                ns_lights = 3'b100; // Red
                ew_lights = 3'b100; // Red
                ped_walk = 1'b1;    // Walk signal
                emergency_active = 1'b0;
            end

            EMERGENCY_ALL_RED: begin
                ns_lights = 3'b100; // Red
                ew_lights = 3'b100; // Red
                emergency_active = 1'b1;
                ped_walk = 1'b0;
            end
        endcase
    end

endmodule

module vending_machine (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       coin_5,      // 5-cent coin inserted
    input  logic       coin_10,     // 10-cent coin inserted
    input  logic       coin_25,     // 25-cent coin inserted
    input  logic       coin_return,
    output logic       dispense_item,
    output logic       return_5,    // Return 5-cent
    output logic       return_10,   // Return 10-cent
    output logic       return_25,   // Return 25-cent
    output logic [5:0] amount_display 
);
    logic  [1:0] counter; 
    logic trigger;
    logic return_flag;

    typedef enum logic [2:0] {
        COIN_0   = 3'b000,
        COIN_5   = 3'b001,
        COIN_10  = 3'b010,
        COIN_15  = 3'b011,
        COIN_20  = 3'b100,
        COIN_25  = 3'b101
    } state_t;

    state_t current_state, next_state;

    assign trigger = (current_state == COIN_25 && coin_25 == 1 ) || (current_state == COIN_20 && coin_return == 1);

    // Sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= COIN_0;
        end else begin
            current_state <= next_state;
        end 

        if (!rst_n) begin
            counter   <= 0;
            return_flag <= 0;
        end else begin
            if (trigger) begin
                counter <= 2;                 // load for 2 cycles
            end else if (counter > 0) begin
                counter <= counter - 1;       // countdown
            end
            return_flag <= (counter > 0);       // output high jab tak counter > 0
        end
    end

    // Next state logic - FIXED
    always_comb begin 
        next_state = current_state;  // default

        case(current_state)
            COIN_0: begin
                if (coin_return) begin
                    next_state = COIN_0;
                end else if (coin_5) begin
                    next_state = COIN_5;
                end else if (coin_10) begin
                    next_state = COIN_10;
                end else if (coin_25) begin
                    next_state = COIN_25;
                end else if (return_flag) begin
                    next_state = COIN_0;
                end 
            end

            COIN_5: begin
                if (coin_return) begin
                    next_state = COIN_0;
                end else if (coin_5) begin
                    next_state = COIN_10;
                end else if (coin_10) begin
                    next_state = COIN_15;
                end else if (coin_25) begin
                    next_state = COIN_0;
                end else if (return_flag) begin
                    next_state = COIN_0;
                end
            end

            COIN_10: begin
                if (coin_return) begin
                    next_state = COIN_0;
                end else if (coin_5) begin
                    next_state = COIN_15;
                end else if (coin_10) begin
                    next_state = COIN_25;
                end else if (coin_25) begin
                    next_state = COIN_5;
                end else if (return_flag) begin
                    next_state = COIN_0;
                end
            end

            COIN_15: begin
                if (coin_return) begin
                    next_state = COIN_0;
                end else if (coin_5) begin
                    next_state = COIN_20;
                end else if (coin_10) begin
                    next_state = COIN_25;
                end else if (coin_25) begin
                    next_state = COIN_10;
                end else if (return_flag) begin
                    next_state = COIN_0;
                end
            end

            COIN_20: begin
                if (coin_return) begin
                    next_state = COIN_0;
                end else if (coin_5) begin
                    next_state = COIN_25;
                end else if (coin_10) begin
                    next_state = COIN_0;
                end else if (coin_25) begin
                    next_state = COIN_15;
                end else if (return_flag) begin
                    next_state = COIN_0;
                end
            end

            COIN_25: begin
                if (coin_return) begin
                    next_state = COIN_0;
                end else if (coin_5) begin
                    next_state = COIN_0;
                end else if (coin_10) begin
                    next_state = COIN_5;
                end else if (coin_25) begin
                    next_state = COIN_20;
                end else if (return_flag) begin
                    next_state = COIN_0;
                end
            end

            default: next_state = COIN_0;
        endcase
    end

   // Output logic - COMPLETE with proper change calculations
    always_comb begin
        return_5 = 0;
        return_10 = 0;
        return_25 = 0; 
        dispense_item = 0;
        amount_display = 0;

        case (current_state)
            COIN_0: begin
                amount_display = 0;
                if (return_flag) begin
                    return_10 = 1;
                end else if (coin_return) begin
                // Nothing to return from 0 state
                end else if (return_flag) begin
                    return_10 = 1;
                end
            end

            COIN_5: begin
                amount_display = 5;
                if (coin_return) begin
                    dispense_item = 0;
                    amount_display = 5;
                    return_5 = 1;  // Return the 5¢
                end else if (coin_25) begin
                        // 5 + 25 = 30, exact amount - no change
                        dispense_item = 1;
                        amount_display = 0;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                end else if (coin_5) begin
                        // 5 + 25 = 30, exact amount - no change
                        dispense_item = 0;
                        amount_display = 10;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                end else if (coin_10) begin
                        // 5 + 25 = 30, exact amount - no change
                        dispense_item = 0;
                        amount_display = 15;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                end else if (return_flag) begin
                    return_10 = 1;
                end
            end

            COIN_10: begin
                amount_display = 10;
                if (coin_return) begin
                    dispense_item = 0;
                    amount_display = 10;
                    return_10 = 1;  // Return 10¢
                end else if (coin_25) begin
                        // 10 + 25 = 35, return 5¢ change
                        dispense_item = 1;
                        amount_display = 5;
                        return_5 = 1;
                        return_10 = 0;
                        return_25 = 0;
                end else if (coin_10) begin
                        // 5 + 25 = 30, exact amount - no change
                        dispense_item = 0;
                        amount_display = 20;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                end else if (coin_5) begin
                        // 5 + 25 = 30, exact amount - no change
                        dispense_item = 0;
                        amount_display = 15;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                end else if (return_flag) begin
                    return_10 = 1;
                end
            end

            COIN_15: begin
                amount_display = 15;
                if (coin_return) begin
                    dispense_item = 0;
                    amount_display = 0;
                    return_5 = 1;   // Return 5¢ + 10¢
                    return_10 = 1;
                end else if (coin_25) begin
                        // 15 + 25 = 40, return 10¢ change
                        dispense_item = 1;
                        amount_display = 10;
                        return_5 = 0;
                        return_10 = 1;
                        return_25 = 0;
                end else if (coin_5) begin
                        // 5 + 25 = 30, exact amount - no change
                        dispense_item = 0;
                        amount_display = 20;
                        return_5 = 0;
                        return_10 = 1;
                        return_25 = 0;
                    end else if (coin_10) begin
                        // 5 + 25 = 30, exact amount - no change
                        dispense_item = 0;
                        amount_display = 25;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                    end else if (return_flag) begin
                        return_10 = 1;
                end
            end

            COIN_20: begin
                amount_display = 20;
                if (coin_return) begin
                    dispense_item = 0;
                    amount_display = 0;
                    return_10 = 1;  // Return 20¢ as two 10¢ coins
                end else if (coin_10) begin
                        // 20 + 10 = 30, exact amount
                        dispense_item = 1;
                        amount_display = 30;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                end else if (coin_25) begin
                        // 20 + 25 = 45, return 15¢ (10¢ + 5¢)
                        dispense_item = 1;
                        amount_display = 15;
                        return_5 = 1;
                        return_10 = 1;
                        return_25 = 0;
                end else if (coin_5) begin
                        // 5 + 25 = 30, exact amount - no change
                        dispense_item = 0;
                        amount_display = 25;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                end else if (return_flag) begin
                    return_10 = 1;
                end
            end

            COIN_25: begin
                amount_display = 25;
                if (coin_return) begin
                    dispense_item = 0;
                    amount_display = 25;
                    return_25 = 1;  // Return 25¢ coin
                end else if (coin_5) begin
                        // 25 + 5 = 30, exact amount
                        dispense_item = 1;
                        amount_display = 0;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                end else if (coin_10) begin
                        // 25 + 10 = 35, return 5¢ change
                        dispense_item = 1;
                        amount_display = 5;
                        return_5 = 1;
                        return_10 = 0;
                        return_25 = 0;
                end else if (coin_25) begin
                        // 25 + 25 = 50, return 20¢ (two 10¢ coins)
                        dispense_item = 1;
                        amount_display = 20;
                        return_5 = 0;
                        return_10 = 1;
                        return_25 = 0;
                end else if (return_flag) begin
                    return_10 = 1;
                end
            end
                            
            default: begin
                    // Default: return excess as 5¢ coins (safe fallback)
                    amount_display = 0;
                    dispense_item = 0; 
                    return_5 = 0;
                    return_10 = 0;
                    return_25 = 0;
                end
         
            endcase 
        end
endmodule
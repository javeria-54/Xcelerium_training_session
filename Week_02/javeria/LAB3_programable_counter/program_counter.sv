module programmable_counter (
    input  logic        clk,         // clock
    input  logic        rst_n,       // active-low synchronous reset
    input  logic        load,        // load new value
    input  logic        enable,      // enable counting
    input  logic        up_down,     // 1 = up, 0 = down
    input  logic [7:0]  load_value,  // value to load
    input  logic [7:0]  max_count,   // programmable maximum
    output logic [7:0]  count,       // current counter value
    output logic        tc,          // terminal count flag
    output logic        zero         // zero detect flag
);
                
    logic load_pending;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            count        <= 0;
            load_pending <= 0;
        end
        else begin
            if (load) begin
                load_pending <= 1;  // next cycle mein load hoga
            end
            else begin
                load_pending <= 0;
            end

            if (load_pending) begin
                count <= load_value;  // next cycle mein load karega
            end
            else if (enable) begin
                if (count == 0 && load_value != 0) begin
                    count <= load_value;
                end  
                else if (up_down) begin  // Count Up
                    if (count < max_count)
                        count <= count + 1;
                    else 
                        count <= 0;
                end
                else begin          // Count Down
                    if (count > load_value)
                        count <= count - 1;
                    else 
                        count <= 0;
                    end
                end
            end
        end

    // Status flag outputs
    assign tc   = (up_down && (count == max_count)) ||   // Up reached max
                  (!up_down && (count == 0));            // Down reached zero

    assign zero = (count == 0);

endmodule  
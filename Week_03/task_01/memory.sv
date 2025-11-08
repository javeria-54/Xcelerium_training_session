// ============ Fixed RAM Module ============
module ram #(
    parameter SIZE = 65536,
    parameter ADDRESS_BITS = 16,
    parameter LINE_SIZE = 256
)(
    input   logic                           clk,
    input   logic                           reset,

    // Handshake Interface with Cache
    input   logic                           mem_req,  // Request
    input   logic                           mem_write_en,
    input   logic                           mem_read_en,
    output  logic                           mem_ack,  // Acknowledge

    // Address/Data buses
    input   logic   [ADDRESS_BITS - 1:0]    address,
    input   logic   [LINE_SIZE - 1:0]       data,
    output  logic   [LINE_SIZE - 1:0]       read_data
);

    // Memory storage
    logic [LINE_SIZE - 1 : 0] mem [0 : SIZE-1];

    // Initialize memory
    integer k;

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            mem_ack <= 0;
            read_data <= 0;
            for (k = 0; k < SIZE; k++) begin
                mem[k] <= 1;
        end
        end 
        else if  begin
            // Default: no acknowledgment
            mem_ack <= 0;
            
            if (mem_req) begin
                if (mem_write_en) begin
                    // Write operation
                    mem[address] <= write_data;
                end 
                else if (mem_read_en) begin
                    // Read operation
                    read_data <= mem[address];
                end
                mem_ack <= 1;
            end
        end
    end

endmodule
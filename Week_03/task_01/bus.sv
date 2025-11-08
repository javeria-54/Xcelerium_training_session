// ============ Bus Module ============
module bus #(
    parameter SIZE = 256,
    parameter ADDRESS_BITS = 16
)(
    input   logic                           clk,
    input   logic                           reset,
    input   logic                           bus_req,
    input   logic                           bus_read_en,
    input   logic                           bus_write_en,
    input   logic   [ADDRESS_BITS - 1:0]    bus_address,
    input   logic   [SIZE - 1 :0]           bus_write_data,
    output  logic   [SIZE - 1:0]            bus_read_data,
    input   logic                           ack_i,

    // Connection to mem
    output  logic                           mem_read_en,
    output  logic                           mem_write_en,
    output  logic   [ADDRESS_BITS - 1:0]    mem_address,
    output  logic   [SIZE - 1:0]            mem_write_data,
    input   logic   [SIZE - 1:0]            mem_read_data,
    output  logic                           bus_ack
);

    initial begin
        mem_read_en = 0;
        mem_write_en = 0;
        mem_address = 0;
        mem_write_data = 0;
        bus_read_data = 0;
    end

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            mem_read_en  <= 0;
            mem_write_en <= 0;
            mem_address  <= 0;
            mem_write_data <= 0;
            bus_read_data <= 0;
        end 
        else if (bus_req) begin
            mem_read_en  <= 0;
            mem_write_en <= 0;
            if(mem_write_en) begin
                mem_address    <= bus_address;
                mem_write_data <= bus_write_data;
                mem_write_en  <= bus_write_en;
                bus_ack <=  ack_i;
            end
            else if (mem_read_req) begin
                mem_address    <= bus_address;
                mem_read_en   <= bus_read_en;
                bus_ack <= ack_i;
            end
        end
        else begin
            mem_read_en  <= 0;
            mem_write_en <= 0;
            mem_address  <= 0;
            mem_write_data <= 0;
            bus_read_data <= 0;
        end
            bus_read_data <= mem_read_data;           
        end
    
endmodule

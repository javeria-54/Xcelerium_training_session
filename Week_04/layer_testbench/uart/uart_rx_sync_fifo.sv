module uart_rx_sync_fifo #(
    parameter int DATA_WIDTH ,
    parameter int FIFO_DEPTH ,
    parameter int ALMOST_FULL_THRESH ,
    parameter int ALMOST_EMPTY_THRESH 
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    full,
    output logic                    empty,
    output logic                    almost_full,
    output logic                    almost_empty,
    output logic [$clog2(FIFO_DEPTH):0] count
);
    
    logic [$clog2(FIFO_DEPTH)-1 : 0] wr_ptr , rd_ptr;
    logic [DATA_WIDTH-1 : 0] fifo [0 : FIFO_DEPTH-1];


    always_ff @(posedge clk or negedge rst_n) begin    
        if (!rst_n) begin
            wr_ptr <= 0;
        end 
        else begin
            if (wr_en && !full) begin 
                fifo[wr_ptr] <=  wr_data;
                wr_ptr <= wr_ptr + 1;
                end            
            end
        end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0; 
        end 
        else begin 
            if (rd_en && !empty) begin
                rd_data <= fifo[rd_ptr];
                rd_ptr <= rd_ptr + 1;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 0;
        else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1; 
                2'b01: count <= count - 1; 
                default: count <= count;   
            endcase
        end
    end

    assign full = (count == FIFO_DEPTH - 1) ? 1'b1 : 1'b0;
    assign empty = (count == 0 ) ? 1'b1 : 1'b0;
    assign almost_full = (count == ALMOST_FULL_THRESH) ? 1'b1 : 1'b0;
    assign almost_empty = (count == ALMOST_EMPTY_THRESH) ? 1'b1 : 1'b0;

endmodule

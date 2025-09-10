module async_fifo #( 
    parameter int DATA_WIDTH = 16,
    parameter int FIFO_DEPTH = 8
)(
    input  logic                 wr_clk, rd_clk,
    input  logic                 wr_rst, rd_rst,
    input  logic                 wr_en,
    input  logic                 rd_en,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                 full,
    output logic                 empty
);
     
    logic [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

    // Binary poin 
    logic [$clog2(FIFO_DEPTH):0] wr_ptr_bin, rd_ptr_bin;
    logic [$clog2(FIFO_DEPTH):0] wr_ptr_bin_next, rd_ptr_bin_next;

    // Gray poin 
    logic [$clog2(FIFO_DEPTH):0] wr_ptr_gray, rd_ptr_gray;
    logic [$clog2(FIFO_DEPTH):0] wr_ptr_gray_next, rd_ptr_gray_next;

    // Synchronized pointers across domains
    logic [$clog2(FIFO_DEPTH):0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
    logic [$clog2(FIFO_DEPTH):0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;

    
    // Next poin 
    assign wr_ptr_bin_next  = wr_ptr_bin + (wr_en && !full);
    assign rd_ptr_bin_next  = rd_ptr_bin + (rd_en && !empty);

    assign wr_ptr_gray_next = (wr_ptr_bin_next >> 1) ^ wr_ptr_bin_next; // bin2gray
    assign rd_ptr_gray_next = (rd_ptr_bin_next >> 1) ^ rd_ptr_bin_next; // bin2gray

    // Write clock domain
    always_ff @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            wr_ptr_bin  <= '0;
            wr_ptr_gray <= '0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr_bin[$clog2(FIFO_DEPTH)-1:0]] <= data_in;
            end
            wr_ptr_bin  <= wr_ptr_bin_next;
            wr_ptr_gray <= wr_ptr_gray_next;
        end
    end
 
    // Read clock domain
    always_ff @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            rd_ptr_bin  <= '0;
            rd_ptr_gray <= '0;
            data_out    <= '0;
        end else begin
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr_bin[$clog2(FIFO_DEPTH)-1:0]];
            end
            rd_ptr_bin  <= rd_ptr_bin_next;
            rd_ptr_gray <= rd_ptr_gray_next;
        end
    end

    
    // Synchronizers
    always_ff @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) {rd_ptr_gray_sync2, rd_ptr_gray_sync1} <= '0;
        else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <=rd_ptr_gray_sync1;
        end
    end

    always_ff @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) {wr_ptr_gray_sync2, wr_ptr_gray_sync1} <= '0;
        else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end
 
    // Full / Empty generation
    // Empty: when read and write pointers (gray) equal
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);

    // Full: when next write pointer = read pointer with MSB inverted
    assign full = (wr_ptr_gray_next == {~rd_ptr_gray_sync2[$clog2(FIFO_DEPTH)],rd_ptr_gray_sync2[$clog2(FIFO_DEPTH)-1:0]});

endmodule
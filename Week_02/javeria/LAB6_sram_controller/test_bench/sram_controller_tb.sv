module sram_controller_tb;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic read_req;
    logic write_req;
    logic [14:0] address;
    logic [15:0] write_data;
    logic [15:0] read_data;
    logic ready;

    // SRAM interface
    logic [14:0] sram_addr;
    tri   [15:0] sram_data;    // Bidirectional bus
    logic        sram_ce_n;
    logic        sram_oe_n; 
    logic        sram_we_n;

    // Internal memory model for SRAM (16-bit wide, 32K deep)
    logic [15:0] mem [0:(1<<15)-1];
    logic [15:0] sram_data_drv;

    // SRAM bidirectional bus
    assign sram_data = (!sram_we_n && !sram_ce_n) ? write_data : 
                   ((!sram_oe_n && !sram_ce_n) ? sram_data_drv : 16'bz);
    

    // SRAM behavior model
    always_ff @(posedge clk) begin
        if (!sram_ce_n && !sram_we_n) begin
            mem[sram_addr] <= sram_data;   // Write Jab we_n = 0 aur ce_n = 0 ho, SRAM apne array me sram_addr par sram_data store karegi.
        end
    end

    always_comb begin
        if (!sram_ce_n && !sram_oe_n) begin
            sram_data_drv = mem[sram_addr]; // Read
        end else begin
            sram_data_drv = 16'bz;
        end
    end

    // DUT instance
    sram_controller dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .read_req   (read_req),
        .write_req  (write_req),
        .address    (address),
        .write_data (write_data),
        .read_data  (read_data),
        .ready      (ready),
        .sram_addr  (sram_addr),
        .sram_data  (sram_data),
        .sram_ce_n  (sram_ce_n),
        .sram_oe_n  (sram_oe_n),
        .sram_we_n  (sram_we_n)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // Initialize
        rst_n = 0;
        read_req = 0;
        write_req = 0;
        address = 0;
        write_data = 0;

        // Apply reset
        #20;
        rst_n = 1;
        @(posedge clk); @(posedge clk);

        // --- Write 0xABCD to address 5 ---
        address = 15'd5;
        write_data = 16'hABCD;
        write_req = 1;

        // Wait until ready goes high
        wait (ready == 1);
        write_req = 0;
        $display("Write Done at addr=5");

        // Small delay
        @(posedge clk);
        // --- Read from address 5 ---
        read_req = 1;
        address = 15'd5;
        $display("Read Data = %h", read_data);

        #20;
        $finish;

    end

endmodule
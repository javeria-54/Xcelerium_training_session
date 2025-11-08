// Top-level integration: CPU -> Cache -> AXI Master -> AXI Slave (Memory)
module cache_axi_system_top (
    input logic clk,
    input logic rst_n,
    
    // CPU interface
    input logic cpu_read,
    input logic cpu_write,
    input logic cpu_valid,
    input logic [27:0] cpu_addr,
    input logic [31:0] cpu_write_data,
    output logic [31:0] cpu_read_data,
    output logic cpu_ready
);

    // Internal signals between cache and memory controller
    logic [27:0] cache_mem_addr;
    logic [127:0] cache_mem_write_data;
    logic cache_mem_write_req;
    logic cache_mem_read_req;
    logic [127:0] cache_mem_read_data;
    logic cache_mem_ready;
    
    // AXI interface
    axi4_lite_if axi_bus();
    
    // Cache instantiation
    simpleCache cache_inst (
        .clk(clk),
        .reset(!rst_n), // Cache uses active-high reset
        .read(cpu_read),
        .write(cpu_write),
        .valid(cpu_valid),
        .cpuAddr(cpu_addr),
        .word_to_cache(cpu_write_data),
        .word_to_cpu(cpu_read_data),
        .ready(cpu_ready),
        
        // Memory interface
        .mem_addr(cache_mem_addr),
        .mem_write_data(cache_mem_write_data),
        .mem_write_req(cache_mem_write_req),
        .mem_read_req(cache_mem_read_req),
        .mem_read_data(cache_mem_read_data),
        .mem_ready(cache_mem_ready)
    );
    
    // AXI Memory Controller
    axi_memory_controller mem_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        
        // Cache interface
        .cache_addr(cache_mem_addr),
        .cache_write_data(cache_mem_write_data),
        .cache_write_req(cache_mem_write_req),
        .cache_read_req(cache_mem_read_req),
        .cache_read_data(cache_mem_read_data),
        .cache_ready(cache_mem_ready),
        
        // AXI Master interface
        .axi_if(axi_bus.master)
    );
    
    // AXI Memory Slave (256MB Main Memory)
    axi_memory_slave #(
        .ADDR_WIDTH(28),
        .DATA_WIDTH(32)
    ) main_memory (
        .clk(clk),
        .rst_n(rst_n),
        .axi_if(axi_bus.slave)
    );

endmodule

// Testbench for the integrated system
module cache_axi_system_tb;
    logic clk;
    logic rst_n;
    logic cpu_read;
    logic cpu_write;
    logic cpu_valid;
    logic [27:0] cpu_addr;
    logic [31:0] cpu_write_data;
    logic [31:0] cpu_read_data;
    logic cpu_ready;
    
    // Instantiate DUT
    cache_axi_system_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .cpu_read(cpu_read),
        .cpu_write(cpu_write),
        .cpu_valid(cpu_valid),
        .cpu_addr(cpu_addr),
        .cpu_write_data(cpu_write_data),
        .cpu_read_data(cpu_read_data),
        .cpu_ready(cpu_ready)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize
        rst_n = 0;
        cpu_read = 0;
        cpu_write = 0;
        cpu_valid = 0;
        cpu_addr = 0;
        cpu_write_data = 0;
        
        // Reset
        repeat(3) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);
        
        $display("=== Test 1: Write to address 0x00000000 ===");
        write_cpu(28'h0000000, 32'hDEADBEEF);
        
        $display("=== Test 2: Read from address 0x00000000 (Cache hit expected) ===");
        read_cpu(28'h0000000);
        $display("Read data: 0x%h", cpu_read_data);
        
        $display("=== Test 3: Write to address 0x00000010 ===");
        write_cpu(28'h0000010, 32'hCAFEBABE);
        
        $display("=== Test 4: Read from address 0x00000010 ===");
        read_cpu(28'h0000010);
        $display("Read data: 0x%h", cpu_read_data);
        
        $display("=== Test 5: Write to different cache line ===");
        write_cpu(28'h0001000, 32'h12345678);
        
        $display("=== Test 6: Read back ===");
        read_cpu(28'h0001000);
        $display("Read data: 0x%h", cpu_read_data);
        
        repeat(10) @(posedge clk);
        $display("=== All tests completed ===");
        $finish;
    end
    
    // Write task
    task write_cpu(input [27:0] addr, input [31:0] data);
        @(posedge clk);
        cpu_addr = addr;
        cpu_write_data = data;
        cpu_write = 1;
        cpu_read = 0;
        cpu_valid = 1;
        
        // Wait for ready
        wait(cpu_ready);
        @(posedge clk);
        cpu_valid = 0;
        cpu_write = 0;
        $display("Write complete: Addr=0x%h, Data=0x%h", addr, data);
    endtask
    
    // Read task
    task read_cpu(input [27:0] addr);
        @(posedge clk);
        cpu_addr = addr;
        cpu_read = 1;
        cpu_write = 0;
        cpu_valid = 1;
        
        // Wait for ready
        wait(cpu_ready);
        @(posedge clk);
        cpu_valid = 0;
        cpu_read = 0;
        $display("Read complete: Addr=0x%h, Data=0x%h", addr, cpu_read_data);
    endtask
    
    // Monitor
    initial begin
        $monitor("Time=%0t rst_n=%b cpu_ready=%b cpu_addr=0x%h", 
                 $time, rst_n, cpu_ready, cpu_addr);
    end
    
endmodule
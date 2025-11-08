// Testbench for RISC-V Sv32 Virtual Memory Page Walker

`timescale 1ns/1ps

module sv32_page_walker_tb;

    // Clock and reset
    logic        clk;
    logic        rst_n;
    
    // DUT inputs
    logic        walk_req;
    logic [31:0] virtual_addr;
    logic [21:0] satp_ppn;
    logic        privilege_mode;
    logic        mxr;
    logic        sum;
    logic        access_type;
    logic [1:0]  access_mode;
    
    // Memory interface
    logic        mem_req;
    logic [31:0] mem_addr;
    logic        mem_valid;
    logic [31:0] mem_data;
    
    // DUT outputs
    logic        walk_done;
    logic        walk_success;
    logic [31:0] physical_addr;
    logic [3:0]  page_fault_type;
    logic        is_superpage;

    // Memory model - simple associative array
    logic [31:0] page_table_mem [logic [31:0]];
    
    // Test statistics
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // DUT instantiation
    sv32_page_walker dut (
        .clk(clk),
        .rst_n(rst_n),
        .walk_req(walk_req),
        .virtual_addr(virtual_addr),
        .satp_ppn(satp_ppn),
        .privilege_mode(privilege_mode),
        .mxr(mxr),
        .sum(sum),
        .access_type(access_type),
        .access_mode(access_mode),
        .mem_req(mem_req),
        .mem_addr(mem_addr),
        .mem_valid(mem_valid),
        .mem_data(mem_data),
        .walk_done(walk_done),
        .walk_success(walk_success),
        .physical_addr(physical_addr),
        .page_fault_type(page_fault_type),
        .is_superpage(is_superpage)
    );

    // Memory model - responds to memory requests
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_valid <= 1'b0;
            mem_data <= 32'h0;
        end else begin
            if (mem_req) begin
                mem_valid <= 1'b1;
                if (page_table_mem.exists(mem_addr)) begin
                    mem_data <= page_table_mem[mem_addr];
                end else begin
                    mem_data <= 32'h0;  // Invalid PTE
                end
            end else begin
                mem_valid <= 1'b0;
            end
        end
    end

    // Helper function to create PTE
    function automatic logic [31:0] create_pte(
        logic [21:0] ppn,
        logic d,
        logic a,
        logic g,
        logic u,
        logic x,
        logic w,
        logic r,
        logic v
    );
        return {ppn, 2'b00, d, a, g, u, x, w, r, v};
    endfunction

    // Task to initialize page tables
    task setup_page_tables();
        // Clear memory
        page_table_mem.delete();
        
        // Root page table at PPN 0x80000 (physical addr 0x80000000)
        // Level 1 entry for VPN[1]=0x001 (VA 0x00400000-0x007FFFFF)
        // Points to level 0 page table at PPN 0x80001
        page_table_mem[32'h80000004] = create_pte(
            22'h80001,  // ppn
            1'b0,       // d
            1'b1,       // a
            1'b0,       // g
            1'b0,       // u
            1'b0,       // x
            1'b0,       // w
            1'b0,       // r (pointer, not leaf)
            1'b1        // v
        );

        // Level 1 entry for VPN[1]=0x002 - 4MB superpage
        // Maps to physical PPN 0x81000
        page_table_mem[32'h80000008] = create_pte(
            22'h81000,  // ppn (aligned for superpage)
            1'b1,       // d
            1'b1,       // a
            1'b0,       // g
            1'b0,       // u
            1'b1,       // x
            1'b1,       // w
            1'b1,       // r (leaf - superpage)
            1'b1        // v
        );

        // Level 1 entry for VPN[1]=0x003 - User accessible superpage
        page_table_mem[32'h8000000C] = create_pte(
            22'h82000,  // ppn
            1'b1,       // d
            1'b1,       // a
            1'b0,       // g
            1'b1,       // u (user accessible)
            1'b0,       // x
            1'b1,       // w
            1'b1,       // r
            1'b1        // v
        );

        // Level 0 page table at PPN 0x80001 (physical addr 0x80001000)
        // Entry for VPN[0]=0x010 (within VA range 0x00400000-0x007FFFFF)
        page_table_mem[32'h80001040] = create_pte(
            22'h90000,  // ppn
            1'b1,       // d
            1'b1,       // a
            1'b0,       // g
            1'b0,       // u
            1'b1,       // x
            1'b1,       // w
            1'b1,       // r
            1'b1        // v
        );

        // Entry for VPN[0]=0x011 - Execute only page
        page_table_mem[32'h80001044] = create_pte(
            22'h90001,  // ppn
            1'b0,       // d
            1'b1,       // a
            1'b0,       // g
            1'b0,       // u
            1'b1,       // x (execute only)
            1'b0,       // w
            1'b0,       // r
            1'b1        // v
        );

        // Entry for VPN[0]=0x012 - User page
        page_table_mem[32'h80001048] = create_pte(
            22'h90002,  // ppn
            1'b1,       // d
            1'b1,       // a
            1'b0,       // g
            1'b1,       // u (user)
            1'b0,       // x
            1'b1,       // w
            1'b1,       // r
            1'b1        // v
        );

        // Entry for VPN[0]=0x013 - Page without accessed bit
        page_table_mem[32'h8000104C] = create_pte(
            22'h90003,  // ppn
            1'b1,       // d
            1'b0,       // a (not accessed)
            1'b0,       // g
            1'b0,       // u
            1'b0,       // x
            1'b1,       // w
            1'b1,       // r
            1'b1        // v
        );

        // Entry for VPN[0]=0x014 - Page without dirty bit
        page_table_mem[32'h80001050] = create_pte(
            22'h90004,  // ppn
            1'b0,       // d (not dirty)
            1'b1,       // a
            1'b0,       // g
            1'b0,       // u
            1'b0,       // x
            1'b1,       // w
            1'b1,       // r
            1'b1        // v
        );

        $display("[INFO] Page tables initialized");
    endtask

    // Task to perform a translation test
    task test_translation(
        string test_name,
        logic [31:0] va,
        logic [21:0] satp,
        logic priv,
        logic [1:0] acc_mode,
        logic mxr_bit,
        logic sum_bit,
        logic expect_success,
        logic [31:0] expect_pa,
        logic expect_superpage
    );
        test_count++;
        $display("\n[TEST %0d] %s", test_count, test_name);
        $display("  VA: 0x%08h, SATP_PPN: 0x%06h, Priv: %s, Access: %s",
                 va, satp, priv ? "S" : "U", 
                 acc_mode == 2'b00 ? "LOAD" : acc_mode == 2'b01 ? "STORE" : "FETCH");

        @(posedge clk);
        walk_req <= 1'b1;
        virtual_addr <= va;
        satp_ppn <= satp;
        privilege_mode <= priv;
        access_mode <= acc_mode;
        mxr <= mxr_bit;
        sum <= sum_bit;

        @(posedge clk);
        walk_req <= 1'b0;

        // Wait for completion
        wait(walk_done);
        @(posedge clk);

        // Check results
        if (walk_success == expect_success) begin
            if (expect_success) begin
                if (physical_addr == expect_pa && is_superpage == expect_superpage) begin
                    $display("  [PASS] PA: 0x%08h, Superpage: %b", physical_addr, is_superpage);
                    pass_count++;
                end else begin
                    $display("  [FAIL] Expected PA: 0x%08h, Got: 0x%08h", expect_pa, physical_addr);
                    $display("         Expected Superpage: %b, Got: %b", expect_superpage, is_superpage);
                    fail_count++;
                end
            end else begin
                $display("  [PASS] Page fault detected as expected. Type: %0d", page_fault_type);
                pass_count++;
            end
        end else begin
            $display("  [FAIL] Expected success: %b, Got: %b", expect_success, walk_success);
            if (!walk_success) $display("         Fault type: %0d", page_fault_type);
            fail_count++;
        end

        repeat(2) @(posedge clk);
    endtask

    // Main test sequence
    initial begin
        $display("========================================");
        $display("RISC-V Sv32 Page Walker Testbench");
        $display("========================================");

        // Initialize
        rst_n = 0;
        walk_req = 0;
        virtual_addr = 0;
        satp_ppn = 0;
        privilege_mode = 0;
        mxr = 0;
        sum = 0;
        access_type = 0;
        access_mode = 0;

        // Setup page tables
        setup_page_tables();

        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        // Test 1: Basic 4KB page translation (two-level walk)
        test_translation(
            "Basic 4KB page - Load",
            32'h00410ABC,      // VA: VPN[1]=1, VPN[0]=0x10, offset=0xABC
            22'h80000,         // Root page table
            1'b1,              // Supervisor mode
            2'b00,             // Load
            1'b0,              // MXR
            1'b0,              // SUM
            1'b1,              // Expect success
            32'h90000ABC,      // Expected PA
            1'b0               // Not superpage
        );

        // Test 2: 4MB Superpage translation
        test_translation(
            "4MB Superpage - Load",
            32'h00812345,      // VA: VPN[1]=2, VPN[0]=0x12, offset=0x345
            22'h80000,
            1'b1,              // Supervisor
            2'b00,             // Load
            1'b0,
            1'b0,
            1'b1,              // Success
            32'h81012345,      // PA includes VPN[0] in superpage
            1'b1               // Is superpage
        );

        // Test 3: Store to 4KB page
        test_translation(
            "4KB page - Store",
            32'h00410FFF,      // Same page as Test 1
            22'h80000,
            1'b1,
            2'b01,             // Store
            1'b0,
            1'b0,
            1'b1,
            32'h90000FFF,
            1'b0
        );

        // Test 4: Instruction fetch from execute-only page
        test_translation(
            "Execute-only page - Fetch",
            32'h00411000,      // VPN[1]=1, VPN[0]=0x11
            22'h80000,
            1'b1,
            2'b10,             // Fetch
            1'b0,
            1'b0,
            1'b1,
            32'h90001000,
            1'b0
        );

        // Test 5: Load from execute-only page with MXR
        test_translation(
            "Execute-only page - Load with MXR",
            32'h00411100,
            22'h80000,
            1'b1,
            2'b00,             // Load
            1'b1,              // MXR enabled
            1'b0,
            1'b1,
            32'h90001100,
            1'b0
        );

        // Test 6: User page access from supervisor with SUM
        test_translation(
            "User page - Supervisor with SUM",
            32'h00412500,      // VPN[0]=0x12 (user page)
            22'h80000,
            1'b1,              // Supervisor
            2'b00,
            1'b0,
            1'b1,              // SUM enabled
            1'b1,
            32'h90002500,
            1'b0
        );

        // Test 7: User page from user mode
        test_translation(
            "User page - User mode",
            32'h00C00123,      // VPN[1]=3 (user superpage)
            22'h80000,
            1'b0,              // User mode
            2'b00,
            1'b0,
            1'b0,
            1'b1,
            32'h82000123,
            1'b1
        );

        // Test 8: Invalid PTE (not present)
        test_translation(
            "Invalid PTE - Not present",
            32'h00420000,      // Unmapped address
            22'h80000,
            1'b1,
            2'b00,
            1'b0,
            1'b0,
            1'b0,              // Expect failure
            32'h0,
            1'b0
        );

        // Test 9: Page without accessed bit
        test_translation(
            "Page fault - Not accessed",
            32'h00413000,      // VPN[0]=0x13 (no A bit)
            22'h80000,
            1'b1,
            2'b00,
            1'b0,
            1'b0,
            1'b0,              // Expect failure
            32'h0,
            1'b0
        );

        // Test 10: Store to page without dirty bit
        test_translation(
            "Page fault - Not dirty on store",
            32'h00414000,      // VPN[0]=0x14 (no D bit)
            22'h80000,
            1'b1,
            2'b01,             // Store
            1'b0,
            1'b0,
            1'b0,              // Expect failure
            32'h0,
            1'b0
        );

        // Test 11: Supervisor access to user page without SUM
        test_translation(
            "Privilege violation - User page, no SUM",
            32'h00412000,      // User page
            22'h80000,
            1'b1,              // Supervisor
            2'b00,
            1'b0,
            1'b0,              // No SUM
            1'b0,              // Expect failure
            32'h0,
            1'b0
        );

        // Test 12: User access to supervisor page
        test_translation(
            "Privilege violation - Supervisor page from user",
            32'h00410000,      // Supervisor page
            22'h80000,
            1'b0,              // User mode
            2'b00,
            1'b0,
            1'b0,
            1'b0,              // Expect failure
            32'h0,
            1'b0
        );

        // Wait and finish
        repeat(20) @(posedge clk);

        $display("\n========================================");
        $display("Test Summary");
        $display("========================================");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        $display("========================================");

        if (fail_count == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED!");
        end

        $finish;
    end

    // Timeout watchdog
    initial begin
        #100000;
        $display("\n[ERROR] Simulation timeout!");
        $finish;
    end

    // Optional: Waveform dump
    initial begin
        $dumpfile("sv32_page_walker.vcd");
        $dumpvars(0, sv32_page_walker_tb);
    end

endmodule
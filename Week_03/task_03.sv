// RISC-V Sv32 Virtual Memory Page Walker
// Implements two-level page table walk with superpage support

module sv32_page_walker (
    input  logic        clk,
    input  logic        rst_n,
    
    // Control signals
    input  logic        walk_req,          // Start page walk
    input  logic [31:0] virtual_addr,      // Virtual address to translate
    input  logic [21:0] satp_ppn,          // SATP PPN field (root page table)
    input  logic        privilege_mode,    // 0=User, 1=Supervisor
    input  logic        mxr,               // Make eXecutable Readable
    input  logic        sum,               // permit Supervisor User Memory access
    input  logic        access_type,       // 0=Load, 1=Store, 2=Instruction fetch (encoded)
    input  logic [1:0]  access_mode,       // 00=Load, 01=Store, 10=Fetch
    
    // Memory interface (for reading PTEs)
    output logic        mem_req,
    output logic [31:0] mem_addr,
    input  logic        mem_valid,
    input  logic [31:0] mem_data,
    
    // Output
    output logic        walk_done,
    output logic        walk_success,      // Translation successful
    output logic [31:0] physical_addr,     // Translated physical address
    output logic [3:0]  page_fault_type,   // Type of page fault if any
    output logic        is_superpage       // Indicates 4MB superpage
);

    // Page Table Entry structure
    typedef struct packed {
        logic [21:0] ppn;      // Physical Page Number [31:10]
        logic [1:0]  rsw;      // Reserved for supervisor software [9:8]
        logic        d;        // Dirty [7]
        logic        a;        // Accessed [6]
        logic        g;        // Global [5]
        logic        u;        // User [4]
        logic        x;        // eXecute [3]
        logic        w;        // Write [2]
        logic        r;        // Read [1]
        logic        v;        // Valid [0]
    } pte_t;

    // FSM States
    typedef enum logic [2:0] {
        IDLE,
        LEVEL_1_READ,
        LEVEL_1_CHECK,
        LEVEL_0_READ,
        LEVEL_0_CHECK,
        DONE
    } state_t;

    state_t current_state, next_state;

    // Internal registers
    logic [31:0] va_reg;           // Stored virtual address
    logic [9:0]  vpn1, vpn0;       // Virtual page numbers
    logic [11:0] page_offset;      // Page offset
    pte_t        pte_level1;       // Level 1 PTE
    pte_t        pte_level0;       // Level 0 PTE
    logic [31:0] pte_addr;         // Current PTE address
    logic        priv_mode_reg;
    logic        mxr_reg, sum_reg;
    logic [1:0]  access_mode_reg;
    
    // Page fault types
    localparam PF_NONE           = 4'b0000;
    localparam PF_INVALID_PTE    = 4'b0001;
    localparam PF_ACCESS_DENIED  = 4'b0010;
    localparam PF_MISALIGNED     = 4'b0011;
    localparam PF_PRIVILEGE      = 4'b0100;
    localparam PF_NOT_ACCESSED   = 4'b0101;
    localparam PF_NOT_DIRTY      = 4'b0110;

    // Extract VPN fields from virtual address
    assign vpn1 = va_reg[31:22];   // Level 1 VPN
    assign vpn0 = va_reg[21:12];   // Level 0 VPN
    assign page_offset = va_reg[11:0];

    // Sequential logic - State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Sequential logic - Data registers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            va_reg <= 32'h0;
            priv_mode_reg <= 1'b0;
            mxr_reg <= 1'b0;
            sum_reg <= 1'b0;
            access_mode_reg <= 2'b00;
            pte_level1 <= 32'h0;
            pte_level0 <= 32'h0;
        end else begin
            if (walk_req && current_state == IDLE) begin
                va_reg <= virtual_addr;
                priv_mode_reg <= privilege_mode;
                mxr_reg <= mxr;
                sum_reg <= sum;
                access_mode_reg <= access_mode;
            end
            
            if (mem_valid && current_state == LEVEL_1_READ) begin
                pte_level1 <= mem_data;
            end
            
            if (mem_valid && current_state == LEVEL_0_READ) begin
                pte_level0 <= mem_data;
            end
        end
    end

    // Combinational logic - Next state and control
    always_comb begin
        next_state = current_state;
        mem_req = 1'b0;
        mem_addr = 32'h0;
        walk_done = 1'b0;
        walk_success = 1'b0;
        physical_addr = 32'h0;
        page_fault_type = PF_NONE;
        is_superpage = 1'b0;
        pte_addr = 32'h0;

        case (current_state)
            IDLE: begin
                if (walk_req) begin
                    next_state = LEVEL_1_READ;
                end
            end

            LEVEL_1_READ: begin
                // Calculate PTE address: (satp.ppn × PAGESIZE) + (va.vpn[1] × PTESIZE)
                pte_addr = {satp_ppn, 12'h0} + {20'h0, vpn1, 2'b00};
                mem_addr = pte_addr;
                mem_req = 1'b1;
                
                if (mem_valid) begin
                    next_state = LEVEL_1_CHECK;
                end
            end

            LEVEL_1_CHECK: begin
                // Check if PTE is valid
                if (!pte_level1.v || (!pte_level1.r && pte_level1.w)) begin
                    // Invalid PTE or W=1,R=0 (reserved)
                    next_state = DONE;
                    walk_done = 1'b1;
                    page_fault_type = PF_INVALID_PTE;
                end
                // Check if this is a leaf PTE (superpage)
                else if (pte_level1.r || pte_level1.x) begin
                    // This is a leaf PTE - 4MB superpage
                    // Check alignment: pte.ppn[0] must be zero
                    if (pte_level1.ppn[9:0] != 10'h0) begin
                        next_state = DONE;
                        walk_done = 1'b1;
                        page_fault_type = PF_MISALIGNED;
                    end else begin
                        // Perform access checks on superpage
                        next_state = DONE;
                        walk_done = 1'b1;
                        is_superpage = 1'b1;
                        
                        if (check_access_permissions(pte_level1, priv_mode_reg, 
                                                    mxr_reg, sum_reg, access_mode_reg)) begin
                            walk_success = 1'b1;
                            // Physical addr: {pte.ppn[1], va.vpn[0], va.offset}
                            physical_addr = {pte_level1.ppn[21:10], vpn0, page_offset};
                        end else begin
                            page_fault_type = get_fault_type(pte_level1, priv_mode_reg, 
                                                           sum_reg, access_mode_reg);
                        end
                    end
                end
                // Pointer to next level
                else begin
                    next_state = LEVEL_0_READ;
                end
            end

            LEVEL_0_READ: begin
                // Calculate PTE address: (pte_level1.ppn × PAGESIZE) + (va.vpn[0] × PTESIZE)
                pte_addr = {pte_level1.ppn, 12'h0} + {20'h0, vpn0, 2'b00};
                mem_addr = pte_addr;
                mem_req = 1'b1;
                
                if (mem_valid) begin
                    next_state = LEVEL_0_CHECK;
                end
            end

            LEVEL_0_CHECK: begin
                // Check if PTE is valid
                if (!pte_level0.v || (!pte_level0.r && pte_level0.w)) begin
                    next_state = DONE;
                    walk_done = 1'b1;
                    page_fault_type = PF_INVALID_PTE;
                end
                // Must be a leaf PTE at level 0
                else if (pte_level0.r || pte_level0.x) begin
                    next_state = DONE;
                    walk_done = 1'b1;
                    
                    if (check_access_permissions(pte_level0, priv_mode_reg, 
                                                mxr_reg, sum_reg, access_mode_reg)) begin
                        walk_success = 1'b1;
                        // Physical addr: {pte.ppn, va.offset}
                        physical_addr = {pte_level0.ppn, page_offset};
                    end else begin
                        page_fault_type = get_fault_type(pte_level0, priv_mode_reg, 
                                                       sum_reg, access_mode_reg);
                    end
                end
                // Pointer at leaf level is invalid
                else begin
                    next_state = DONE;
                    walk_done = 1'b1;
                    page_fault_type = PF_INVALID_PTE;
                end
            end

            DONE: begin
                walk_done = 1'b1;
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Function to check access permissions
    function automatic logic check_access_permissions(
        pte_t pte,
        logic priv_mode,
        logic mxr_bit,
        logic sum_bit,
        logic [1:0] access_type_in
    );
        logic access_ok;
        access_ok = 1'b1;

        // Check Accessed bit
        if (!pte.a) begin
            return 1'b0;
        end

        // Check privilege level
        if (priv_mode == 1'b1) begin  // Supervisor mode
            // If U=1 and SUM=0, supervisor cannot access
            if (pte.u && !sum_bit) begin
                return 1'b0;
            end
        end else begin  // User mode
            // User can only access pages with U=1
            if (!pte.u) begin
                return 1'b0;
            end
        end

        // Check based on access type
        case (access_type_in)
            2'b00: begin  // Load
                // Read permission required, or execute with MXR
                access_ok = pte.r || (mxr_bit && pte.x);
            end
            2'b01: begin  // Store
                // Write permission required, and Dirty bit must be set
                access_ok = pte.w && pte.d;
            end
            2'b10: begin  // Instruction fetch
                // Execute permission required
                access_ok = pte.x;
            end
            default: access_ok = 1'b0;
        endcase

        return access_ok;
    endfunction

    // Function to determine fault type
    function automatic logic [3:0] get_fault_type(
        pte_t pte,
        logic priv_mode,
        logic sum_bit,
        logic [1:0] access_type_in
    );
        if (!pte.a) begin
            return PF_NOT_ACCESSED;
        end
        
        if ((access_type_in == 2'b01) && !pte.d) begin
            return PF_NOT_DIRTY;
        end

        if (priv_mode == 1'b1 && pte.u && !sum_bit) begin
            return PF_PRIVILEGE;
        end

        if (priv_mode == 1'b0 && !pte.u) begin
            return PF_PRIVILEGE;
        end

        return PF_ACCESS_DENIED;
    endfunction

endmodule
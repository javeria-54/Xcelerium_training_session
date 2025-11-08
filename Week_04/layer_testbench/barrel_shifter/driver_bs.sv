// driver_bs.sv (FIXED - synchronization with combinational DUT)
`include "transaction_bs.sv"

class driver;
  mailbox gen2drv;
  int     repeat_count;
  virtual alu_if.drv ainf;

  function new(mailbox gen2drv, int repeat_count, virtual alu_if.drv ainf);
    this.gen2drv      = gen2drv;
    this.repeat_count = repeat_count;
    this.ainf         = ainf;
  endfunction

  task run();
    Transaction trans;
    reset_bus();
    repeat (repeat_count) begin
      gen2drv.get(trans);
      drive_one(trans.data_in, trans.shift_rotate, trans.left_right, trans.shift_amt);
    end
  endtask

  task reset_bus();
    @(posedge ainf.clk);
    ainf.data_in = '0;
    ainf.shift_rotate  = '0;
    ainf.left_right  = '0;
    ainf.shift_amt  = '0;
  endtask

  // Drive inputs and hold them stable
  task drive_one(input bit [31:0] data_in, input bit shift_rotate, 
                 input bit left_right, input bit [4:0] shift_amt);
    @(posedge ainf.clk);  // Wait for clock edge
    #1;  // Small delta delay to avoid race
    
    // Apply inputs
    ainf.data_in = data_in;
    ainf.shift_rotate = shift_rotate;
    ainf.left_right = left_right;
    ainf.shift_amt = shift_amt;
    
    $display("[%0t DRV] Drove data_in=0x%08h shift_rotate=%0d left_right=%0d shift_amt=%0b",
             $time, data_in, shift_rotate, left_right, shift_amt);
  endtask
endclass
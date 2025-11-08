`include "environment_bs.sv"

program automatic test(alu_if ainf);
  initial begin
    environment env;
    env = new(ainf, 5);   // 20 transactions (change as you like)
    env.run();
    $stop;                 // or $finish;
  end
endprogram

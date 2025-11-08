`include "environment_encoder.sv"

program automatic test(alu_if ainf);
  initial begin
    environment env;
    env = new(ainf, 5);   // 5 transactions (change as you like)
    env.run();
    $stop;                 // or $finish;
  end
endprogram

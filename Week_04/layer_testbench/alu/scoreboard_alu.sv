`include "transaction_alu.sv"

class scoreboard;
  mailbox gen2scb, mon2scb;
  int     repeat_count;

  function new(mailbox gen2scb, mailbox mon2scb, int repeat_count);
    this.gen2scb      = gen2scb;
    this.mon2scb      = mon2scb;
    this.repeat_count = repeat_count;
  endfunction

  // Key for associative match
  function string key_of(input bit signed [7:0] a,
                         input bit signed [7:0] b,
                         input bit        [2:0] op);
    return $sformatf("%0d|%0d|%0d", a, b, op);
  endfunction

  // Reference model (matches your alu_8bit)
  function void ref_model(input  Transaction t,
                          output bit signed [7:0] exp_res,
                          output bit              exp_z,
                          output bit              exp_c,
                          output bit              exp_v);
    bit signed [8:0] wide;
    exp_c = 0; exp_v = 0;
    unique case (t.op_sel)
      3'b000: begin // ADD
        wide   = {1'b0,t.a} + {1'b0,t.b};
        exp_res= wide[7:0];
        exp_c  = wide[8];
        exp_v  = (t.a[7]==t.b[7]) && (exp_res[7]!=t.a[7]);
      end
      3'b010: exp_res = t.a & t.b;           // AND
      3'b011: exp_res = t.a | t.b;           // OR
      3'b100: exp_res = t.a ^ t.b;           // XOR
      3'b001: begin // SUB
        wide   = {1'b0,t.a} - {1'b0,t.b};
        exp_res= wide[7:0];
        exp_c  = wide[8]; // borrow bit, same as your DUT
        exp_v  = (t.a[7]!=t.b[7]) && (exp_res[7]!=t.a[7]);
      end
      3'b101: exp_res = ~t.a;                // NOT
      3'b110: exp_res = t.a << t.b;          // shift by full b
      3'b111: exp_res = t.a >> t.b;          // logical right
      default: exp_res = '0;
    endcase
    exp_z = (exp_res == 0);
  endfunction

  task run();
    // associative caches until a matching partner shows up
    Transaction exp_map[string];
    Transaction act_map[string];

    int compared = 0, pass = 0, fail = 0;
    $display("[SCB] start, repeat_count=%0d", repeat_count);

    while (compared < repeat_count) begin
      Transaction e, m;

      // pull whatever is available without blocking
      if (gen2scb.try_get(e)) begin
        string k = key_of(e.a, e.b, e.op_sel);
        if (act_map.exists(k)) begin
          // compare immediately
          m = act_map[k]; act_map.delete(k);
          do_compare(e, m, compared, pass, fail);
          compared++;
        end else begin
          exp_map[k] = e;
          $display("[SCB] got GEN: a=%0d b=%0d op=%0d", e.a, e.b, e.op_sel);
        end
      end

      if (mon2scb.try_get(m)) begin
        string k = key_of(m.a, m.b, m.op_sel);
        if (exp_map.exists(k)) begin
          e = exp_map[k]; exp_map.delete(k);
          do_compare(e, m, compared, pass, fail);
          compared++;
        end else begin
          act_map[k] = m;
          $display("[SCB] got MON: a=%0d b=%0d op=%0d -> res=%0d ZCV=%0b%0b%0b",
                   m.a, m.b, m.op_sel, m.result, m.zero, m.carry, m.overflow);
        end
      end

      #1ns; // avoid a busy loop
    end

    $display("[SCB] Done. PASS=%0d FAIL=%0d (compared=%0d)", pass, fail, compared);
  endtask

  task do_compare(input Transaction exp, input Transaction act,
                  input int idx, inout int pass, inout int fail);
    bit signed [7:0] r; bit z,c,v;
    ref_model(exp, r, z, c, v);
    if (act.result!==r || act.zero!==z || act.carry!==c || act.overflow!==v) begin
      $error("[SCB][%0d] FAIL a=%0d b=%0d op=%0d | exp=%0d ZCV=%0b%0b%0b  got=%0d ZCV=%0b%0b%0b",
             idx, act.a, act.b, act.op_sel,
             r, z, c, v, act.result, act.zero, act.carry, act.overflow);
      fail++;
    end else begin
      $display("[SCB][%0d] PASS a=%0d b=%0d op=%0d -> %0d  ZCV=%0b%0b%0b",
               idx, act.a, act.b, act.op_sel,
               act.result, act.zero, act.carry, act.overflow);
      pass++;
    end
  endtask
endclass


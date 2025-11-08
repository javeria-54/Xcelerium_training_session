`timescale 1ns/1ps
`include "transaction_bs.sv"

class scoreboard;
  mailbox gen2scb, mon2scb;
  int repeat_count;

  function new(mailbox gen2scb, mailbox mon2scb, int repeat_count);
    this.gen2scb      = gen2scb;
    this.mon2scb      = mon2scb;
    this.repeat_count = repeat_count;
  endfunction

  // Key generator for associative arrays
  function string key_of(input bit [31:0] data_in,
                         input bit [4:0]  shift_amt,
                         input bit        left_right,
                         input bit        shift_rotate);
    return $sformatf("%0h|%0d|%0d|%0d", data_in, shift_amt, left_right, shift_rotate);
  endfunction

  // === Reference Model (same as RTL) ===
  function void ref_model(input Transaction t,
                          output bit [31:0] expected_out);
    bit [31:0] stage0, stage1, stage2, stage3, stage4;

    // Stage0 (shift by 1)
    if (t.shift_amt[0]) begin
      if (!t.left_right)
        stage0 = t.shift_rotate ? {t.data_in[30:0], t.data_in[31]} : {t.data_in[30:0], 1'b0};
      else
        stage0 = t.shift_rotate ? {t.data_in[0], t.data_in[31:1]} : {1'b0, t.data_in[31:1]};
    end else stage0 = t.data_in;

    // Stage1 (shift by 2)
    if (t.shift_amt[1]) begin
      if (!t.left_right)
        stage1 = t.shift_rotate ? {stage0[29:0], stage0[31:30]} : {stage0[29:0], 2'b0};
      else
        stage1 = t.shift_rotate ? {stage0[1:0], stage0[31:2]} : {2'b0, stage0[31:2]};
    end else stage1 = stage0;

    // Stage2 (shift by 4)
    if (t.shift_amt[2]) begin
      if (!t.left_right)
        stage2 = t.shift_rotate ? {stage1[27:0], stage1[31:28]} : {stage1[27:0], 4'b0};
      else
        stage2 = t.shift_rotate ? {stage1[3:0], stage1[31:4]} : {4'b0, stage1[31:4]};
    end else stage2 = stage1;

    // Stage3 (shift by 8)
    if (t.shift_amt[3]) begin
      if (!t.left_right)
        stage3 = t.shift_rotate ? {stage2[23:0], stage2[31:24]} : {stage2[23:0], 8'b0};
      else
        stage3 = t.shift_rotate ? {stage2[7:0], stage2[31:8]} : {8'b0, stage2[31:8]};
    end else stage3 = stage2;

    // Stage4 (shift by 16)
    if (t.shift_amt[4]) begin
      if (!t.left_right)
        stage4 = t.shift_rotate ? {stage3[15:0], stage3[31:16]} : {stage3[15:0], 16'b0};
      else
        stage4 = t.shift_rotate ? {stage3[15:0], stage3[31:16]} : {16'b0, stage3[31:16]};
    end else stage4 = stage3;

    expected_out = stage4;
  endfunction

  // === Run task (matches gen & mon) ===
  task run();
    Transaction exp_map[string];
    Transaction act_map[string];

    int compared = 0, pass = 0, fail = 0;
    $display("[SCB] Starting scoreboard, count=%0d", repeat_count);

    while (compared < repeat_count) begin
      Transaction e, m;

      if (gen2scb.try_get(e)) begin
        string k = key_of(e.data_in, e.shift_amt, e.left_right, e.shift_rotate);
        if (act_map.exists(k)) begin
          m = act_map[k]; act_map.delete(k);
          do_compare(e, m, compared, pass, fail);
          compared++;
        end else exp_map[k] = e;
      end

      if (mon2scb.try_get(m)) begin
        string k = key_of(m.data_in, m.shift_amt, m.left_right, m.shift_rotate);
        if (exp_map.exists(k)) begin
          e = exp_map[k]; exp_map.delete(k);
          do_compare(e, m, compared, pass, fail);
          compared++;
        end else act_map[k] = m;
      end

      #1ns;
    end

    $display("[SCB] Done. PASS=%0d FAIL=%0d", pass, fail);
  endtask

  // === Compare ===
  task do_compare(input Transaction exp, input Transaction act,
                  input int idx, inout int pass, inout int fail);
    bit [31:0] expected;
    ref_model(exp, expected);

    if (act.data_out !== expected) begin
      $error("[SCB][%0d] FAIL data_in=0x%08h shift=%0d L/R=%0d R/SH=%0d | exp=0x%08h got=0x%08h",
             idx, exp.data_in, exp.shift_amt, exp.left_right, exp.shift_rotate,
             expected, act.data_out);
      fail++;
    end else begin
      $display("[SCB][%0d] PASS data_in=0x%08h shift=%0d L/R=%0d R/SH=%0d -> out=0x%08h",
               idx, exp.data_in, exp.shift_amt, exp.left_right, exp.shift_rotate,
               act.data_out);
      pass++;
    end
  endtask

endclass

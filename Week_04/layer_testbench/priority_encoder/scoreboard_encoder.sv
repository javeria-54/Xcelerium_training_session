`include "transaction_encoder.sv"

class scoreboard;
  mailbox gen2scb, mon2scb;
  int     repeat_count;

  function new(mailbox gen2scb, mailbox mon2scb, int repeat_count);
    this.gen2scb      = gen2scb;
    this.mon2scb      = mon2scb;
    this.repeat_count = repeat_count;
  endfunction

  // Key for associative match
  function string key_of(input bit [7:0] data_in,
                         input bit       enable
                         );
    return $sformatf("%0d|%0d", data_in, enable);
  endfunction

  // Reference model (priority_encoder_8to3)
  function void ref_model(input  Transaction t,
                          output bit [2:0] encoded_out,
                          output bit       valid
                         );

    encoded_out = 3'b000;
    valid       = 1'b0;

    if (t.enable) begin
      casex (t.data_in)
        8'b1xxxxxxx: encoded_out = 3'b111; // In7 
        8'b01xxxxxx: encoded_out = 3'b110; // In6
        8'b001xxxxx: encoded_out = 3'b101; // In5
        8'b0001xxxx: encoded_out = 3'b100; // In4
        8'b00001xxx: encoded_out = 3'b011; // In3
        8'b000001xx: encoded_out = 3'b010; // In2
        8'b0000001x: encoded_out = 3'b001; // In1
        8'b00000001: encoded_out = 3'b000; // In0
        default    : encoded_out = 3'b000;
      endcase

      if (t.data_in != 8'b00000000)
        valid = 1'b1;
    end
  endfunction

  task run();
    // associative caches until a matching partner shows up
    Transaction exp_map[string];
    Transaction act_map[string];

    int compared = 0, pass = 0, fail = 0;
    $display("[SCB] start, repeat_count=%0d", repeat_count);

    while (compared < repeat_count) begin
      Transaction e, m;

      if (gen2scb.try_get(e)) begin
        string k = key_of(e.data_in, e.enable);
        if (act_map.exists(k)) begin
          m = act_map[k]; act_map.delete(k);
          do_compare(e, m, compared, pass, fail);
          compared++;
        end else begin
          exp_map[k] = e;
          $display("[SCB] got GEN: data_in=%0b enable=%0b",
                   e.data_in, e.enable);
        end
      end

      if (mon2scb.try_get(m)) begin
        string k = key_of(m.data_in, m.enable);
        if (exp_map.exists(k)) begin
          e = exp_map[k]; exp_map.delete(k);
          do_compare(e, m, compared, pass, fail);
          compared++;
        end else begin
          act_map[k] = m;
          $display("[SCB] got MON: data_in=%0b enable=%0b -> enc=%0d valid=%0b",
                   m.data_in, m.enable, m.encoded_out, m.valid);
        end
      end

      #1ns; // avoid busy loop
    end

    $display("[SCB] Done. PASS=%0d FAIL=%0d (compared=%0d)", pass, fail, compared);
  endtask

  task do_compare(input Transaction exp, input Transaction act,
                  input int idx, inout int pass, inout int fail);
    bit [2:0] r_enc; bit v;

    // generate expected result
    ref_model(exp, r_enc, v);

    if (act.encoded_out !== r_enc || act.valid !== v) begin
      $error("[SCB][%0d] FAIL data_in=%0b enable=%0b | exp enc=%0d valid=%0b  got enc=%0d valid=%0b",
             idx, exp.data_in, exp.enable,
             r_enc, v, act.encoded_out, act.valid);
      fail++;
    end else begin
      $display("[SCB][%0d] PASS data_in=%0b enable=%0b -> enc=%0d valid=%0b",
               idx, exp.data_in, exp.enable,
               act.encoded_out, act.valid);
      pass++;
    end
  endtask
endclass


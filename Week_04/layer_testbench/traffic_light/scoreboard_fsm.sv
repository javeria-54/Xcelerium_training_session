`ifndef SCOREBOARD_FSM_SV
`define SCOREBOARD_FSM_SV

`include "transaction_fsm.sv"

class traffic_scoreboard;
  mailbox gen2scb, mon2scb;
  int repeat_count;

  typedef enum logic [2:0] {
    STARTUP_FLASH,
    NS_GREEN_EW_RED,
    NS_YELLOW_EW_RED,
    NS_RED_EW_GREEN,
    NS_RED_EW_YELLOW,
    PEDESTRIAN_CROSSING,
    EMERGENCY_ALL_RED
  } state_t;

  state_t model_state;
  int unsigned model_timer;
  bit model_ped_latched;
  bit model_last_served_ns;

  function new(mailbox gen2scb, mailbox mon2scb, int repeat_count);
    this.gen2scb      = gen2scb;
    this.mon2scb      = mon2scb;
    this.repeat_count = repeat_count;

    // Initialize model to reset state
    model_state = STARTUP_FLASH;
    model_timer = 6'd5;
    model_ped_latched = 1'b0;
    model_last_served_ns = 1'b0;
  endfunction

  function string key_of(input int cycle);
    return $sformatf("%0d", cycle);
  endfunction

  function void ref_model(input Transaction t,
                          output logic [2:0] exp_ns_lights,
                          output logic [2:0] exp_ew_lights,
                          output logic       exp_ped_walk,
                          output logic       exp_emergency_active);
    state_t next_state;
    int unsigned next_timer;
    bit next_ped_latched;
    bit next_last_served_ns;

    // Initialize locals
    next_state = model_state;
    next_timer = model_timer;
    next_ped_latched = model_ped_latched;
    next_last_served_ns = model_last_served_ns;

    // Combinational next state logic
    unique case (model_state)
      STARTUP_FLASH: begin
        if (t.emergency) next_state = EMERGENCY_ALL_RED;
        else if (model_timer == 0) next_state = NS_GREEN_EW_RED;
      end

      NS_GREEN_EW_RED: begin
        if (t.emergency) next_state = EMERGENCY_ALL_RED;
        else if (model_timer == 0) next_state = NS_YELLOW_EW_RED;
      end

      NS_YELLOW_EW_RED: begin
        if (t.emergency) next_state = EMERGENCY_ALL_RED;
        else if (model_timer == 0) begin
          if (model_ped_latched) next_state = PEDESTRIAN_CROSSING;
          else next_state = NS_RED_EW_GREEN;
        end
      end

      NS_RED_EW_GREEN: begin
        if (t.emergency) next_state = EMERGENCY_ALL_RED;
        else if (model_timer == 0) next_state = NS_RED_EW_YELLOW;
      end

      NS_RED_EW_YELLOW: begin
        if (t.emergency) next_state = EMERGENCY_ALL_RED;
        else if (model_timer == 0) begin
          if (model_ped_latched) next_state = PEDESTRIAN_CROSSING;
          else next_state = NS_GREEN_EW_RED;
        end
      end

      PEDESTRIAN_CROSSING: begin
        if (t.emergency) begin
          if (model_timer == 0) next_state = EMERGENCY_ALL_RED;
        end else if (model_timer == 0) begin
          if (model_last_served_ns) next_state = NS_RED_EW_GREEN;
          else next_state = NS_GREEN_EW_RED;
        end
      end

      EMERGENCY_ALL_RED: begin
        if (!t.emergency && model_last_served_ns) next_state = NS_RED_EW_GREEN;
        else if (!t.emergency && !model_last_served_ns) next_state = NS_GREEN_EW_RED;
      end

      default: next_state = STARTUP_FLASH;
    endcase

    // Timer update
    if (model_state != next_state) begin
      case (next_state)
        STARTUP_FLASH:       next_timer = 6'd5;
        NS_GREEN_EW_RED:     next_timer = 6'd30;
        NS_YELLOW_EW_RED:    next_timer = 6'd5;
        NS_RED_EW_GREEN:     next_timer = 6'd30;
        NS_RED_EW_YELLOW:    next_timer = 6'd5;
        PEDESTRIAN_CROSSING: next_timer = 6'd10;
        EMERGENCY_ALL_RED:   next_timer = 6'd10;
        default:             next_timer = 6'd0;
      endcase
    end else begin
      if (model_state != EMERGENCY_ALL_RED && model_timer > 0)
        next_timer = model_timer - 1;
    end

    // Pedestrian latch
    if (t.pedestrian_req && model_state != PEDESTRIAN_CROSSING)
      next_ped_latched = 1'b1;
    if (model_state == PEDESTRIAN_CROSSING && model_timer == 1)
      next_ped_latched = 1'b0;

    // Last served
    if (model_state == NS_GREEN_EW_RED && model_timer == 1)
      next_last_served_ns = 1'b1;
    else if (model_state == NS_RED_EW_GREEN && model_timer == 1)
      next_last_served_ns = 1'b0;

    // Commit updates
    model_state = next_state;
    model_timer = next_timer;
    model_ped_latched = next_ped_latched;
    model_last_served_ns = next_last_served_ns;

    // Calculate outputs (defaults)
    exp_ns_lights = 3'b100;
    exp_ew_lights = 3'b100;
    exp_ped_walk = 0;
    exp_emergency_active = 0;

    case (model_state)
      STARTUP_FLASH: begin
        if (model_timer[2]) begin
          exp_ns_lights = 3'b010;
          exp_ew_lights = 3'b010;
        end else begin
          exp_ns_lights = 3'b000;
          exp_ew_lights = 3'b000;
        end
      end

      NS_GREEN_EW_RED: begin
        exp_ns_lights = 3'b001;
        exp_ew_lights = 3'b100;
      end

      NS_YELLOW_EW_RED: begin
        exp_ns_lights = 3'b010;
        exp_ew_lights = 3'b100;
      end

      NS_RED_EW_GREEN: begin
        exp_ns_lights = 3'b100;
        exp_ew_lights = 3'b001;
      end

      NS_RED_EW_YELLOW: begin
        exp_ns_lights = 3'b100;
        exp_ew_lights = 3'b010;
      end

      PEDESTRIAN_CROSSING: begin
        exp_ns_lights = 3'b100;
        exp_ew_lights = 3'b100;
        exp_ped_walk = 1'b1;
      end

      EMERGENCY_ALL_RED: begin
        exp_ns_lights = 3'b100;
        exp_ew_lights = 3'b100;
        exp_emergency_active = 1'b1;
      end
    endcase
  endfunction

  task run();
    Transaction exp_map[string];
    Transaction act_map[string];
    int compared = 0, pass = 0, fail = 0;

    Transaction exp_trans, mon_trans;
    string k;
    logic [2:0] exp_ns, exp_ew;
    logic exp_ped, exp_emg;
    Transaction expected;

    $display("[SCB] Starting traffic scoreboard, count=%0d", repeat_count);

    while (compared < repeat_count) begin
      // Try to get from generator
      if (gen2scb.try_get(exp_trans)) begin
        k = key_of(exp_trans.cycle);

        ref_model(exp_trans, exp_ns, exp_ew, exp_ped, exp_emg);

        expected = new(exp_trans.cycle);
        expected.emergency = exp_trans.emergency;
        expected.pedestrian_req = exp_trans.pedestrian_req;
        expected.ns_lights = exp_ns;
        expected.ew_lights = exp_ew;
        expected.ped_walk = exp_ped;
        expected.emergency_active = exp_emg;

        if (act_map.exists(k)) begin
          mon_trans = act_map[k];
          act_map.delete(k);
          do_compare(expected, mon_trans, compared, pass, fail);
          compared++;
        end else begin
          exp_map[k] = expected;
        end
      end

      // Try to get from monitor
      if (mon2scb.try_get(mon_trans)) begin
        k = key_of(mon_trans.cycle);
        if (exp_map.exists(k)) begin
          exp_trans = exp_map[k];
          exp_map.delete(k);
          do_compare(exp_trans, mon_trans, compared, pass, fail);
          compared++;
        end else begin
          act_map[k] = mon_trans;
        end
      end

      #1ns;
    end

    $display("[SCB] Done. PASS=%0d FAIL=%0d", pass, fail);
  endtask

  task do_compare(input Transaction exp, input Transaction act,
                  input int idx, inout int pass, inout int fail);
    bit mismatch = 0;

    if (act.ns_lights !== exp.ns_lights) mismatch = 1;
    if (act.ew_lights !== exp.ew_lights) mismatch = 1;
    if (act.ped_walk !== exp.ped_walk) mismatch = 1;
    if (act.emergency_active !== exp.emergency_active) mismatch = 1;

    if (mismatch) begin
      $error("[SCB][%0d] FAIL cycle=%0d | inputs(em=%0b ped=%0b) | exp ns=%03b ew=%03b ped=%0b emg=%0b | got ns=%03b ew=%03b ped=%0b emg=%0b",
             idx, exp.cycle, exp.emergency, exp.pedestrian_req,
             exp.ns_lights, exp.ew_lights, exp.ped_walk, exp.emergency_active,
             act.ns_lights, act.ew_lights, act.ped_walk, act.emergency_active);
      fail++;
    end else begin
      $display("[SCB][%0d] PASS cycle=%0d ns=%03b ew=%03b ped=%0b emg=%0b",
               idx, exp.cycle, act.ns_lights, act.ew_lights, act.ped_walk, act.emergency_active);
      pass++;
    end
  endtask
endclass

`endif // SCOREBOARD_FSM_SV

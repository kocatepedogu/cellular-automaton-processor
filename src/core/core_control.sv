// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

/* The main responsibility of core control is to decide whether the core
   is locally active and whether it will be active or not in the next cycle.
   It also informs the global control about the branch decisions of the core. */

import isa::*;

module core_control (
    input clk,
    input rst,

    input value_t target_value,
    input instruction_t instruction,
    input pc_t next_program_counter,
    input sp_t next_stack_pointer,
    input global_enable,

    output local_enable,
    output diverge
);
  reg  divergence_state = 0;

  pc_reg_t local_program_counter = 0;
  sp_reg_t local_stack_pointer = 0;

  wire opcode_t opcode = get_opcode(instruction);
  wire target_reg_t target = get_target_reg(instruction);
  wire immediate_t immediate = get_immediate(instruction);

  assign diverge = (is_conditional_branch(opcode) && (~|target_value)) || divergence_state;
  assign local_enable = global_enable && (~diverge) && (~is_unconditional_branch(opcode));

  always @(posedge clk) begin
      if (rst)
      begin
        local_program_counter <= 0;
        divergence_state <= 0;
      end else if (divergence_state)
      begin
        if (next_program_counter == local_program_counter && next_stack_pointer == local_stack_pointer)
          divergence_state <= 0;
      end else if (diverge)
      begin
        local_program_counter <= (program_counter_length)'(immediate);
        if (next_program_counter != (program_counter_length)'(immediate))
          divergence_state <= 1;
      end else
      begin
        local_program_counter <= next_program_counter;
        local_stack_pointer <= next_stack_pointer;
      end
    end
endmodule

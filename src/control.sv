// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

import isa::*;

module control (
    input clk,
    input rst,

    input instruction_t instruction,
    output pc_reg_t program_counter,
    output pc_reg_t next_program_counter,
    output sp_reg_t next_stack_pointer,
    input diverge_consensus
);

  pc_reg_t call_stack [32];
  sp_reg_t stack_pointer;

  wire opcode_t opcode = get_opcode(instruction);
  wire jump_addr_t jump_addr = get_jump_addr(instruction);
  wire relative_branch_address_t rel_branch_addr = get_relative_branch_addr(instruction);
  wire jump_addr_t branch_addr = program_counter +
    {{(program_counter_length - relative_branch_address_length){rel_branch_addr[relative_branch_address_length-1]}},
      rel_branch_addr};

  always_comb begin
    case (opcode)
      JUMP: begin
        next_program_counter = jump_addr;
        next_stack_pointer = stack_pointer;
      end
      UNL: begin
        next_program_counter = diverge_consensus ? branch_addr : program_counter + 2;
        next_stack_pointer = stack_pointer;
      end
      CALL: begin
        next_program_counter = jump_addr;
        next_stack_pointer = stack_pointer + 2;
      end
      RET: begin
        next_program_counter = call_stack[stack_pointer - 2];
        next_stack_pointer = stack_pointer - 2;
      end
      default: begin
        next_program_counter = program_counter + 2;
        next_stack_pointer = stack_pointer;
      end
    endcase
  end

  always @(posedge clk) begin
    if (rst) begin
      program_counter <= (program_counter_length)'(0);
      stack_pointer <= (stack_pointer_length)'(0);
    end else begin
      if (opcode == CALL)
        call_stack[stack_pointer] <= program_counter + 2;

      program_counter <= next_program_counter;
      stack_pointer <= next_stack_pointer;
    end
  end
endmodule

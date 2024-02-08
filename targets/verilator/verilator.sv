// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

import isa::*;

module top (
    input clk,
    input rst,

    input  instruction_t instruction,
    output pc_t program_counter
);
  wire diverge_consensus;

  wire pc_t next_program_counter;
  wire sp_t next_stack_pointer;

  control cntrl (
    .clk(clk),
    .rst(rst),
    .instruction(instruction),
    .program_counter(program_counter),
    .next_program_counter(next_program_counter),
    .next_stack_pointer(next_stack_pointer),
    .diverge_consensus(diverge_consensus)
  );

  multiprocessor mp (
    .clk(clk),
    .rst(rst),

    .next_program_counter(next_program_counter),
    .next_stack_pointer(next_stack_pointer),
    .instruction(instruction),
    .global_enable(1),
    .diverge_consensus(diverge_consensus)
  );
endmodule

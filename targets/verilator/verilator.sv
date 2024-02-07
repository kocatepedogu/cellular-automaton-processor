// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

`include "isa.sv"

module top (
    input clk,
    input rst,

    input  [15:0] instruction,
    output [11:0] program_counter
);
  parameter REGISTER_LENGTH /*verilator public*/ = 32;
  parameter WIDTH /*verilator public*/ = 25;
  parameter HEIGHT /*verilator public*/ = 25;

  wire diverge_consensus;

  wire [11:0] next_program_counter;
  wire [4 :0] next_stack_pointer;

  control cntrl (
    .clk(clk),
    .rst(rst),
    .instruction(instruction),
    .program_counter(program_counter),
    .next_program_counter(next_program_counter),
    .next_stack_pointer(next_stack_pointer),
    .diverge_consensus(diverge_consensus)
  );

  multiprocessor #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.REGISTER_LENGTH(REGISTER_LENGTH)) mp (
    .clk(clk),
    .rst(rst),

    .next_program_counter(next_program_counter),
    .next_stack_pointer(next_stack_pointer),
    .instruction(instruction),
    .execution_enable(1),
    .diverge_consensus(diverge_consensus)
  );
endmodule

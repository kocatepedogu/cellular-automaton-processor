// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

`include "isa.sv"

module cell_core_alu #(parameter REGISTER_LENGTH = 8) (
    input  [3:0] opcode,
    input  signed [7:0] immediate,
    input  signed [REGISTER_LENGTH-1:0] first_operand_value,
    input  signed [REGISTER_LENGTH-1:0] second_operand_value,
    output signed [REGISTER_LENGTH-1:0] result
);
    wire signed  [REGISTER_LENGTH-1:0] results [16];

    wire signed [REGISTER_LENGTH-1:0] add_result = first_operand_value + second_operand_value;
    wire signed [REGISTER_LENGTH-1:0] sub_result = first_operand_value - second_operand_value;
    wire [REGISTER_LENGTH-1:0] and_result = first_operand_value & second_operand_value;
    wire [REGISTER_LENGTH-1:0] or_result = first_operand_value | second_operand_value;
    wire [REGISTER_LENGTH-1:0] nor_result = ~or_result;
    wire [REGISTER_LENGTH-1:0] seq_result = {(REGISTER_LENGTH-1)'(0), ~|sub_result};
    wire [REGISTER_LENGTH-1:0] slt_result = {(REGISTER_LENGTH-1)'(0), sub_result[REGISTER_LENGTH-1]};
    wire signed [REGISTER_LENGTH-1:0] mul_result = first_operand_value * second_operand_value;
    wire signed [REGISTER_LENGTH-1:0] shr_result = first_operand_value >>> second_operand_value;
    wire signed [REGISTER_LENGTH*2-1:0] fmul_result = first_operand_value * second_operand_value;

    assign results[`LI] = (REGISTER_LENGTH)'(immediate);
    assign results[`ADD] = add_result;
    assign results[`SUB] = sub_result;
    assign results[`AND] = and_result;
    assign results[`OR] = or_result;
    assign results[`NOR] = nor_result;
    assign results[`SEQ] = seq_result;
    assign results[`SLT] = slt_result;
    assign results[`MUL] = mul_result;
    assign results[`SHR] = shr_result;
    assign results[`FMUL] = fmul_result[47:16];

    assign result = results[opcode];
endmodule

// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

import isa::*;

module cell_core_alu (
    input  opcode_t opcode,
    input  immediate_t immediate,
    input  value_t first_operand_value,
    input  value_t second_operand_value,
    output value_t result
);
    wire value_t results [16];

    wire value_t add_result = first_operand_value + second_operand_value;
    wire value_t sub_result = first_operand_value - second_operand_value;
    wire value_t and_result = first_operand_value & second_operand_value;
    wire value_t or_result = first_operand_value | second_operand_value;
    wire value_t nor_result = ~or_result;
    wire value_t seq_result = {(register_length-1)'(0), ~|sub_result};
    wire value_t slt_result = {(register_length-1)'(0), sub_result[register_length-1]};
    wire value_t mul_result = first_operand_value * second_operand_value;
    wire value_t shr_result = first_operand_value >>> second_operand_value;
    wire double_value_t fmul_result = first_operand_value * second_operand_value;

    assign results[LI] = (register_length)'(immediate);
    assign results[ADD] = add_result;
    assign results[SUB] = sub_result;
    assign results[AND] = and_result;
    assign results[OR] = or_result;
    assign results[NOR] = nor_result;
    assign results[SEQ] = seq_result;
    assign results[SLT] = slt_result;
    assign results[MUL] = mul_result;
    assign results[SHR] = shr_result;
    assign results[FMUL] = fmul_result[3*register_length/2-1:register_length/2];

    assign result = results[opcode];
endmodule

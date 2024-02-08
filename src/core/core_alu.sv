// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

import isa::*;

module core_alu (
    input  [4:0] aluop,
    input  immediate_t immediate,
    input  value_t first_operand_value,
    input  value_t second_operand_value,
    input  [4:0] precision,
    output register_t result
);
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

    always_comb begin
      case(aluop)
        LI: result = (register_length)'(immediate);
        ADD: result = add_result;
        SUB: result = sub_result;
        AND: result = and_result;
        OR: result = or_result;
        NOR: result = nor_result;
        SEQ: result = seq_result;
        SLT: result = slt_result;
        MUL: result = mul_result;
        SHR: result = shr_result;
        FMUL: result /* verilator lint_off WIDTHTRUNC */
                     /* verilator lint_off WIDTHEXPAND */ = fmul_result[precision +: register_length];
        FIX: result = second_operand_value <<< precision;
        UNFIX: result = second_operand_value >>> precision;
      endcase
    end
endmodule

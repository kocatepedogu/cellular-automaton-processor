// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

import isa::*;

module core #(parameter X = 0, parameter Y = 0) (
    input  clk,
    input  rst,
    input  global_enable,

    input  instruction_t instruction,
    input  pc_t next_program_counter,
    input  sp_t next_stack_pointer,

    input  value_t i01,
    input  value_t i10,
    output value_t i11,
    input  value_t i12,
    input  value_t i21,

    output value_t video,
    output diverge
);
    register_t regs [10];

    wire value_t inputs [16];

    assign inputs[REG_MY] = regs[REG_MY];
    assign inputs[REG_R1] = regs[REG_R1];
    assign inputs[REG_R2] = regs[REG_R2];
    assign inputs[REG_R3] = regs[REG_R3];
    assign inputs[REG_R4] = regs[REG_R4];
    assign inputs[REG_R5] = regs[REG_R5];
    assign inputs[REG_R6] = regs[REG_R6];
    assign inputs[REG_R7] = regs[REG_R7];
    assign inputs[REG_R8] = regs[REG_R8];
    assign inputs[REG_ZERO] = 0;
    assign inputs[REG_X] = (register_length)'(X);
    assign inputs[REG_Y] = (register_length)'(Y);
    assign inputs[REG_XMINUS] = i10;
    assign inputs[REG_XPLUS] = i12;
    assign inputs[REG_YMINUS] = i01;
    assign inputs[REG_YPLUS] = i21;

    wire opcode_t opcode = get_opcode(instruction);
    wire target_reg_t target = get_target_reg(instruction);
    wire source_reg_t first_operand = get_first_source(instruction);
    wire source_reg_t second_operand = get_second_source(instruction);
    wire immediate_t immediate = get_immediate(instruction);

    wire value_t target_value = inputs[target];
    wire value_t first_operand_value = inputs[first_operand];
    wire value_t second_operand_value = inputs[second_operand];
    wire value_t alu_result;

    wire local_enable;
    wire state_change_enable;

    core_alu alu (
      .opcode(opcode),
      .immediate(immediate),
      .first_operand_value(first_operand_value),
      .second_operand_value(second_operand_value),
      .result(alu_result)
    );

    core_control cntrl (
      .clk(clk),
      .rst(rst),
      .target_value(target_value),
      .instruction(instruction),
      .next_program_counter(next_program_counter),
      .next_stack_pointer(next_stack_pointer),
      .global_enable(global_enable),
      .local_enable(local_enable),
      .diverge(diverge)
    );

    integer i;
    always @(posedge clk) begin
      if (rst) begin
        for (i=0; i < 10; i=i+1) begin
          regs[i] <= 0;
        end
      end else if (local_enable) begin
          regs[target] <= alu_result;
      end
    end

    assign i11 = regs[REG_MY];
    assign video = regs[REG_VIDEO];
endmodule

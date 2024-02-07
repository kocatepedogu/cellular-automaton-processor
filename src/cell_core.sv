// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

`include "isa.sv"

module cell_core #(parameter X = 0, parameter Y = 0, parameter REGISTER_LENGTH = 8) (
    input clk,
    input rst,
    input  [15:0] instruction,
    input  [11:0] next_program_counter,
    input  [4 :0] next_stack_pointer,
    input         execution_enable,
    input  [REGISTER_LENGTH-1:0] i01,
    input  [REGISTER_LENGTH-1:0] i10,
    input  [REGISTER_LENGTH-1:0] i11,
    input  [REGISTER_LENGTH-1:0] i12,
    input  [REGISTER_LENGTH-1:0] i21,
    output [REGISTER_LENGTH-1:0] nextState,
    output reg [REGISTER_LENGTH-1:0] nextVideo,
    output diverge
);
    reg  [REGISTER_LENGTH-1:0] regs [9];
    wire [REGISTER_LENGTH-1:0] inputs [16];

    assign inputs[`REG_MY] = i11;
    assign inputs[`REG_R1] = regs[`REG_R1];
    assign inputs[`REG_R2] = regs[`REG_R2];
    assign inputs[`REG_R3] = regs[`REG_R3];
    assign inputs[`REG_R4] = regs[`REG_R4];
    assign inputs[`REG_R5] = regs[`REG_R5];
    assign inputs[`REG_R6] = regs[`REG_R6];
    assign inputs[`REG_R7] = regs[`REG_R7];
    assign inputs[`REG_R8] = regs[`REG_R8];
    assign inputs[`REG_ZERO] = 0;
    assign inputs[`REG_X] = (REGISTER_LENGTH)'(X);
    assign inputs[`REG_Y] = (REGISTER_LENGTH)'(Y);
    assign inputs[`REG_XMINUS] = i10;
    assign inputs[`REG_XPLUS] = i12;
    assign inputs[`REG_YMINUS] = i01;
    assign inputs[`REG_YPLUS] = i21;

    wire [3:0] opcode = instruction[15:12];
    wire [3:0] target = instruction[11:8];
    wire [3:0] first_operand = instruction[7:4];
    wire [3:0] second_operand = instruction[3:0];
    wire [7:0] immediate = instruction[7:0];

    wire [REGISTER_LENGTH-1:0] target_value = inputs[target];
    wire [REGISTER_LENGTH-1:0] first_operand_value = inputs[first_operand];
    wire [REGISTER_LENGTH-1:0] second_operand_value = inputs[second_operand];
    wire [REGISTER_LENGTH-1:0] alu_result;

    cell_core_alu #(.REGISTER_LENGTH(REGISTER_LENGTH)) alu (
      .opcode(opcode), .immediate(immediate),
      .first_operand_value(first_operand_value),
      .second_operand_value(second_operand_value),
      .result(alu_result)
    );

    wire enable;
    wire state_change_enable;

    cell_core_control #(.REGISTER_LENGTH(REGISTER_LENGTH)) cntrl (
      .clk(clk), .rst(rst), .target_value(target_value),
      .instruction(instruction), .next_program_counter(next_program_counter),
      .next_stack_pointer(next_stack_pointer), .execution_enable(execution_enable),
      .enable(enable), .state_change_enable(state_change_enable),
      .diverge(diverge)
    );

    integer i;
    always @(posedge clk) begin
      if (rst) begin
        for (i=0; i < 9; i=i+1) begin
          regs[i] <= 0;
        end
      end else if (enable) begin
        case (target)
          `REG_VIDEO: nextVideo <= alu_result;
          default: regs[target] <= alu_result;
        endcase
      end
    end

    assign nextState = state_change_enable ? alu_result : i11;
endmodule

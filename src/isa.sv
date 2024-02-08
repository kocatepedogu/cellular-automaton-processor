// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

package isa;
  parameter REG_MY = 0;
  parameter REG_R1 = 1;
  parameter REG_R2 = 2;
  parameter REG_R3 = 3;
  parameter REG_R4 = 4;
  parameter REG_R5 = 5;
  parameter REG_R6 = 6;
  parameter REG_R7 = 7;
  parameter REG_R8 = 8;
  parameter REG_ZERO = 9;
  parameter REG_VIDEO = 9;
  parameter REG_X = 10;
  parameter REG_Y = 11;
  parameter REG_XMINUS = 12;
  parameter REG_XPLUS = 13;
  parameter REG_YMINUS = 14;
  parameter REG_YPLUS = 15;

  parameter LI = 4'd0;
  parameter UNL = 4'd1;
  parameter ADD = 4'd2;
  parameter SUB = 4'd3;
  parameter AND = 4'd4;
  parameter OR = 4'd5;
  parameter NOR = 4'd6;
  parameter SEQ = 4'd7;
  parameter SLT = 4'd8;
  parameter MUL = 4'd9;
  parameter SHR = 4'd10;
  parameter FMUL = 4'd11;
  parameter JUMP = 4'd12;
  parameter CALL = 4'd13;
  parameter RET = 4'd14;

  parameter register_length = 32;
  parameter program_counter_length = 12;
  parameter stack_pointer_length = 5;
  parameter immediate_length = 8;

  typedef logic [11:0] pc_t;
  typedef logic [ 4:0] sp_t;
  typedef reg   [11:0] pc_reg_t;
  typedef reg   [ 4:0] sp_reg_t;

  typedef logic        [15:0] instruction_t;
  typedef logic        [3 :0] opcode_t;
  typedef logic        [3 :0] target_reg_t;
  typedef logic        [3 :0] source_reg_t;
  typedef logic        [11:0] jump_addr_t;
  typedef logic signed [7 :0] immediate_t;

  typedef logic signed [31:0] value_t;
  typedef logic signed [63:0] double_value_t;
  typedef reg   signed [31:0] register_t;

  function opcode_t get_opcode (input instruction_t instr);
    get_opcode = instr[15:12];
  endfunction

  function target_reg_t get_target_reg (input instruction_t instr);
    get_target_reg = instr[11:8];
  endfunction

  function source_reg_t get_first_source (input instruction_t instr);
    get_first_source = instr[7:4];
  endfunction

  function source_reg_t get_second_source (input instruction_t instr);
    get_second_source = instr[3:0];
  endfunction

  function immediate_t get_immediate (input instruction_t instr);
    get_immediate = instr[7:0];
  endfunction

  function jump_addr_t get_jump_addr (input instruction_t instr);
    get_jump_addr = instr[11:0];
  endfunction

  function bit is_unconditional_branch (input opcode_t opcode);
    is_unconditional_branch = (opcode == JUMP) || (opcode == CALL) || (opcode == RET);
  endfunction

  function bit is_conditional_branch (input opcode_t opcode);
    is_conditional_branch = (opcode == UNL);
  endfunction
endpackage

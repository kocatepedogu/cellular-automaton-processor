// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

package isa;
  parameter REG_RS = 0;
  parameter REG_R1 = 1;
  parameter REG_R2 = 2;
  parameter REG_R3 = 3;
  parameter REG_R4 = 4;
  parameter REG_R5 = 5;
  parameter REG_R6 = 6;
  parameter REG_R7 = 7;
  parameter REG_R8 = 8;
  parameter REG_ZERO = 9;
  parameter REG_X = 10;
  parameter REG_Y = 11;
  parameter REG_XMINUS = 12;
  parameter REG_XPLUS = 13;
  parameter REG_YMINUS = 14;
  parameter REG_YPLUS = 15;
  parameter REG_VIDEO = 9;
  parameter REG_PRECISION = 10;

  parameter LI = 0;
  parameter UNL = 1;
  parameter ADD = 2;
  parameter SUB = 3;
  parameter AND = 4;
  parameter OR = 5;
  parameter NOR = 6;
  parameter SEQ = 7;
  parameter SLT = 8;
  parameter MUL = 9;
  parameter SHR = 10;
  parameter FMUL = 11;
  parameter JUMP = 12;
  parameter CALL = 13;
  parameter RET = 14;
  parameter EXT = 15;
  parameter FIX = 16;
  parameter UNFIX = 17;

  parameter register_length = 32;
  parameter program_counter_length = 12;
  parameter stack_pointer_length = 5;
  parameter immediate_length = 8;
  parameter relative_branch_address_length = 8;

  typedef logic [program_counter_length-1:0] pc_t;
  typedef logic [stack_pointer_length-1:0] sp_t;
  typedef reg   [program_counter_length-1:0] pc_reg_t;
  typedef reg   [stack_pointer_length-1:0] sp_reg_t;

  typedef logic        [15:0] instruction_t;
  typedef logic        [3 :0] opcode_t;
  typedef logic        [3 :0] function_code_t;
  typedef logic        [3 :0] target_reg_t;
  typedef logic        [3 :0] condition_reg_t;
  typedef logic        [3 :0] source_reg_t;
  typedef logic        [11:0] jump_addr_t;
  typedef logic signed [7 :0] immediate_t;
  typedef logic signed [7 :0] relative_branch_address_t;

  typedef logic signed [register_length-1  :0] value_t;
  typedef logic signed [2*register_length-1:0] double_value_t;
  typedef reg   signed [register_length-1  :0] register_t;

  function opcode_t get_opcode (input instruction_t instr);
    get_opcode = instr[15:12];
  endfunction

  function function_code_t get_function_code (input instruction_t instr);
    get_function_code = instr[11:8];
  endfunction

  function target_reg_t get_target_reg (input instruction_t instr);
    get_target_reg = instr[11:8];
  endfunction

  function condition_reg_t get_condition_reg (input instruction_t instr);
    get_condition_reg = instr[11:8];
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

  function relative_branch_address_t get_relative_branch_addr(input instruction_t instr);
    get_relative_branch_addr = instr[7:0];
  endfunction

  function bit is_unconditional_branch (input opcode_t opcode);
    is_unconditional_branch = (opcode == JUMP) || (opcode == CALL) || (opcode == RET);
  endfunction

  function bit is_conditional_branch (input opcode_t opcode);
    is_conditional_branch = (opcode == UNL);
  endfunction
endpackage

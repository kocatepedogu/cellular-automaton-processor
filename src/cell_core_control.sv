// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

module cell_core_control #(parameter REGISTER_LENGTH = 8) (
    input clk,
    input rst,

    input [REGISTER_LENGTH-1:0] target_value,

    input [15:0] instruction,
    input [11:0] next_program_counter,
    input [4 :0] next_stack_pointer,
    input        execution_enable,

    output enable,
    output state_change_enable,
    output diverge
);

  reg  diverged = 0;

  reg  [11:0] local_program_counter = 0;
  reg  [4: 0] local_stack_pointer = 0;

  wire [3:0 ] opcode = instruction[15:12];
  wire [3:0 ] target = instruction[11:8];
  wire [7:0 ] immediate = instruction[7:0];
  wire [11:0] jump_addr = instruction[11:0];

  // True if the current instruction is a conditional branch instruction
  // and the condition evaluates to false
  //
  // In addition, the cell must also output a diverge signal if it has already
  // diverged and not currently in sync with the other cells. Otherwise it would
  // prevent a consensus required for other cells to exit a loop, meaning that
  // the execution will never reach this cell leading to a deadlock.
  assign diverge = ((opcode == `UNL) && (~|target_value)) || diverged;

  // True if the current instruction is going to cause an unconditional branch.
  wire unconditional_jump = opcode == `JUMP;

  /* If the cell is synchronized and it is not going to diverge or jump, then
     it is allowed to change its state, or write to its registers. */
  assign enable = execution_enable && (~diverge) && (~unconditional_jump);

  /* If the target of the current operation is the "my" register and it is enabled,
     the cell is going to change its state */
  assign state_change_enable = enable && target == `REG_MY;

  /* Sequential logic to decide the next local program counter value */
  always @(posedge clk) begin
      if (rst) begin
        local_program_counter <= 0;
        diverged <= 0;
      end else if (diverged) begin
        // Activate the core in the next cycle if everyone else
        // will be at the same program address.
        if (next_program_counter == local_program_counter && next_stack_pointer == local_stack_pointer)
          diverged <= 0;
      end else if (diverge) begin
        local_program_counter <= {4'b0, immediate};
        // Deactivate the core if an unconditional branch
        // is encountered and other cores are not going to
        // follow us. (there is no global branch consensus)
        if (next_program_counter != {4'b0, immediate})
          diverged <= 1;
      end else begin
        local_program_counter <= next_program_counter;
        local_stack_pointer <= next_stack_pointer;
      end
    end
endmodule

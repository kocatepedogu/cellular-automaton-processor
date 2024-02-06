module cell_core_control #(parameter REGISTER_LENGTH = 8) (
    input clk,
    input rst,

    input [REGISTER_LENGTH-1:0] target_value,

    input [15:0] instruction,
    input [11:0] program_counter,
    input        execution_enable,

    output enable,
    output state_change_enable
);

  reg  [11:0] local_program_counter = 0;

  wire [3:0 ] opcode = instruction[15:12];
  wire [3:0 ] target = instruction[11:8];
  wire [7:0 ] immediate = instruction[7:0];
  wire [11:0] jump_addr = instruction[11:0];

  // True if the current instruction is a conditional branch instruction
  // and the condition evaluates to false.
  wire diverge = (opcode == `UNL) && (~|target_value);

  // True if the current instruction is going to cause an unconditional branch.
  wire unconditional_jump = opcode == `JUMP;

  /* A cell is said to be synchronized if its local program counter is
     in sync with the global one (there is currently no divergence) */
  wire synchronized = local_program_counter == program_counter;

  /* If the cell is synchronized and it is not going to diverge or jump, then
     it is allowed to change its state, or write to its registers. */
  assign enable = execution_enable && synchronized && (~diverge) && (~unconditional_jump);

  /* If the target of the current operation is the "my" register and it is enabled,
     the cell is going to change its state */
  assign state_change_enable = enable && target == `REG_MY;

  /* Sequential logic to decide the next local program counter value */
  always @(posedge clk) begin
      if (rst) begin
        local_program_counter <= 0;
      end else if (synchronized && execution_enable) begin
        if (diverge) begin
          local_program_counter <= {4'b0,immediate};
        end else if (unconditional_jump) begin
          local_program_counter <= jump_addr;
        end else begin
          local_program_counter <= local_program_counter + 2;
        end
      end
    end
endmodule

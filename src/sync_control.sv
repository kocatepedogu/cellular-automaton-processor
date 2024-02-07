`include "isa.sv"

module sync_control (
    input clk,
    input rst,

    input      [15:0] instruction,
    output reg [11:0] program_counter,
    output reg [11:0] next_program_counter,
    output reg [4 :0] next_stack_pointer,
    input             diverge_consensus
);

  reg  [11:0] call_stack [32];
  reg  [4: 0] stack_pointer;

  wire [3: 0] opcode = instruction[15:12];
  wire [11:0] jump_addr = instruction[11:0];
  wire [7:0 ] immediate = instruction[7:0];

  always_comb begin
    case (opcode)
      `JUMP: begin
        next_program_counter = jump_addr;
        next_stack_pointer = stack_pointer;
      end
      `UNL: begin
        next_program_counter = diverge_consensus ? {4'b0,immediate} : program_counter + 2;
        next_stack_pointer = stack_pointer;
      end
      `CALL: begin
        next_program_counter = jump_addr;
        next_stack_pointer = stack_pointer + 2;
      end
      `RET: begin
        next_program_counter = call_stack[stack_pointer - 2];
        next_stack_pointer = stack_pointer - 2;
      end
      default: begin
        next_program_counter = program_counter + 2;
        next_stack_pointer = stack_pointer;
      end
    endcase
  end

  always @(posedge clk) begin
    if (rst) begin
      program_counter <= 12'd0;
      stack_pointer <= 5'd0;
    end else begin
      if (opcode == `CALL)
        call_stack[stack_pointer] <= program_counter + 2;

      program_counter <= next_program_counter;
      stack_pointer <= next_stack_pointer;
    end
  end
endmodule

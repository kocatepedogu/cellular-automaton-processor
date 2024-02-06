`include "isa.sv"

module sync_control (
    input clk,
    input rst,

    input      [15:0] instruction,
    output reg [11:0] program_counter
);

  wire [3: 0] opcode = instruction[15:12];
  wire [11:0] jump_addr = instruction[11:0];

  always @(posedge clk) begin
    if (rst) begin
      program_counter <= 12'd0;
    end else begin
      case (opcode)
        `JUMP: program_counter <= jump_addr;
        default: program_counter <= program_counter + 2;
      endcase
    end
  end
endmodule

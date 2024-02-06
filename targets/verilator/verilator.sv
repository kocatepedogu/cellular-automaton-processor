`include "isa.sv"

module top (
    input clk,
    input rst,

    input  [15:0] instruction,
    output [11:0] program_counter
);
  parameter REGISTER_LENGTH /*verilator public*/ = 32;
  parameter WIDTH /*verilator public*/ = 25;
  parameter HEIGHT /*verilator public*/ = 25;

  sync_control cntrl (
    .clk(clk),
    .rst(rst),
    .instruction(instruction),
    .program_counter(program_counter)
  );

  multiprocessor #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.REGISTER_LENGTH(REGISTER_LENGTH)) mp (
    .clk(clk),
    .rst(rst),

    .program_counter(program_counter),
    .instruction(instruction),
    .execution_enable(1)
  );
endmodule

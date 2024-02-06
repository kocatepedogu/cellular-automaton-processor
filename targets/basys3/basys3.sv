module top (
    input clk,
    input rst,

    output [3:0] vgaRed,
    output [3:0] vgaBlue,
    output [3:0] vgaGreen,
    output Hsync,
    output Vsync,

    input  [7:0] instruction_input,
    output [7:0] instruction_address_output,
    output       transmit_signal,
    input        receive_signal,

    output [7:0] leds,
    output test
);
  localparam REGISTER_LENGTH = 8;
  localparam WIDTH = 5;
  localparam HEIGHT = 5;

  wire [9:0] X;
  wire [9:0] Y;
  wire [REGISTER_LENGTH-1:0] state_output;

  wire        program_counter_clock;
  wire [11:0] pc;
  reg  [15:0] instruction;
  wire        execution_enable;
  wire        execution_reset;

  wire bufg;
  BUFG bufgctrl (
      .I(clk),
      .O(bufg)
  );

  async_control cntrl (
    .clk(bufg),
    .rst(rst),
    .instruction_input(instruction_input),
    .instruction_address_output(instruction_address_output),
    .transmit_signal(transmit_signal),
    .receive_signal(receive_signal),
    .program_counter_clock(program_counter_clock),
    .pc(pc),
    .instruction(instruction),
    .execution_enable(execution_enable),
    .execution_reset(execution_reset)
  );

  multiprocessor #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.REGISTER_LENGTH(REGISTER_LENGTH)) mp (
    .clk(program_counter_clock),
    .rst(execution_reset),

    .program_counter(pc),
    .instruction(instruction),
    .execution_enable(execution_enable),

    .states_x_addr(X >> 4),
    .states_y_addr(Y >> 4),
    .state_output(state_output)
  );

  vga #(.REGISTER_LENGTH(REGISTER_LENGTH), .WIDTH(WIDTH), .HEIGHT(HEIGHT)) vga_m (
    .clk(bufg),
    .rst(0),
    .state(state_output),
    .X(X),
    .Y(Y),
    .Hsync(Hsync),
    .Vsync(Vsync),
    .vgaRed(vgaRed),
    .vgaGreen(vgaGreen),
    .vgaBlue(vgaBlue)
  );

  assign leds[0] = execution_enable;
  assign leds[1] = program_counter_clock;
endmodule

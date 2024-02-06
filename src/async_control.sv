`include "isa.sv"

module async_control (
    input clk,
    input rst,

    input  [7:0] instruction_input,
    output [7:0] instruction_address_output,
    output reg   transmit_signal = 1,
    input        receive_signal,

    output            program_counter_clock,
    output     [11:0] pc,
    output reg [15:0] instruction,
    output            execution_enable,
    output            execution_reset
);
    reg  [11:0] program_counter = 0;
    wire [3: 0] opcode = instruction[15:12];
    wire [11:0] jump_addr = instruction[11:0];

    /* Code for detecting edges in input signal */
    localparam PROCESSED_NEGEDGE = 0;
    localparam PROCESSED_POSEDGE = 1;

    reg reset_previous_value = 0;
    reg reset_posedge = 0;
    reg reset_negedge = 0;
    reg reset_process_stage = PROCESSED_NEGEDGE;

    reg receive_previous_value = 0;
    reg receive_posedge = 0;
    reg receive_negedge = 0;
    reg receive_process_stage = PROCESSED_NEGEDGE;

    always @(posedge clk) begin
      if ((~reset_previous_value) & rst)
        reset_posedge <= 1;
      else if (reset_previous_value & (~rst))
        reset_negedge <= 1;
      else begin
        case (reset_process_stage)
          PROCESSED_NEGEDGE: reset_negedge <= 0;
          PROCESSED_POSEDGE: reset_posedge <= 0;
        endcase
      end

      if ((~receive_previous_value) & receive_signal) begin
        receive_posedge <= 1;
      end else if (receive_previous_value & (~receive_signal))
        receive_negedge <= 1;
      else begin
        case (receive_process_stage)
          PROCESSED_NEGEDGE: receive_negedge <= 0;
          PROCESSED_POSEDGE: receive_posedge <= 0;
        endcase
      end

      reset_previous_value <= rst;
      receive_previous_value <= receive_signal;
    end

    /* Slow clock used for communication state machine */
    reg [16:0] communication_clock_counter = 0; //22
    reg        communication_clock = 0;
    always @(posedge clk) begin
        if (communication_clock_counter == 0)
            communication_clock <= ~communication_clock;
        communication_clock_counter <= communication_clock_counter + 1;
    end

    localparam STATE_TRANSMITTED_RESET = 0;
    localparam STATE_RECEIVED_RESET = 1;
    localparam STATE_TRANSMITTED_DATA = 2;
    localparam STATE_RECEIVED_DATA = 3;

    localparam TIMEOUT = 100;

    reg  [1:0] communication_state = STATE_TRANSMITTED_DATA;
    reg  [7:0] timeout_counter = 0;
    wire       timeout = timeout_counter == TIMEOUT;

    always @(posedge communication_clock) begin
      case (communication_state)
        STATE_TRANSMITTED_RESET: begin
            transmit_signal <= 1;
            communication_state <= STATE_TRANSMITTED_DATA;
            timeout_counter <= 0;
            receive_process_stage <= PROCESSED_NEGEDGE;
          end

        STATE_RECEIVED_RESET: begin
            if (reset_negedge) begin
              transmit_signal <= 0;
              communication_state <= STATE_TRANSMITTED_RESET;
              reset_process_stage <= PROCESSED_NEGEDGE;
            end
          end

        STATE_TRANSMITTED_DATA: begin
            if (reset_posedge) begin
              program_counter <= 0;
              transmit_signal <= 1;
              communication_state <= STATE_RECEIVED_RESET;
              reset_process_stage <= PROCESSED_POSEDGE;
            end else if (receive_posedge | timeout) begin
              transmit_signal <= 0;
              communication_state <= timeout ? STATE_TRANSMITTED_RESET : STATE_RECEIVED_DATA;
              receive_process_stage <= timeout ? PROCESSED_NEGEDGE : PROCESSED_POSEDGE;
              timeout_counter <= 0;

              case (program_counter[0])
                0: instruction[15:8] <= instruction_input;
                1: instruction[7:0] <= instruction_input;
              endcase
            end else begin
              timeout_counter <= timeout_counter + 1;
            end
          end

        STATE_RECEIVED_DATA: begin
            if (reset_posedge) begin
              program_counter <= 0;
              transmit_signal <= 1;
              communication_state <= STATE_RECEIVED_RESET;
              reset_process_stage <= PROCESSED_POSEDGE;
            end else if (timeout) begin
              communication_state <= STATE_TRANSMITTED_RESET;
              receive_process_stage <= PROCESSED_NEGEDGE;
              timeout_counter <= 0;
              program_counter <= program_counter;
            end else if (receive_negedge) begin
              communication_state <= STATE_TRANSMITTED_DATA;
              receive_process_stage <= PROCESSED_NEGEDGE;
              timeout_counter <= 0;
              transmit_signal <= 1;

              // Actual control logic
              case (program_counter[0])
                0: program_counter <= program_counter + 1;
                1: begin
                  case (opcode)
                      `JUMP: program_counter <= jump_addr;
                      default: program_counter <= program_counter + 1;
                  endcase
                end
              endcase
            end else begin
              timeout_counter <= timeout_counter + 1;
            end
          end
      endcase
    end

    // either make pc smaller or make bus larger
    assign instruction_address_output = program_counter[7:0];

    assign pc = {program_counter[11:1], 1'b0};
    assign program_counter_clock = communication_clock;
    assign execution_enable = communication_state == STATE_RECEIVED_DATA &
                              (~reset_posedge) & (~timeout) &
                              receive_negedge & program_counter[0];
    assign execution_reset = reset_posedge;
endmodule

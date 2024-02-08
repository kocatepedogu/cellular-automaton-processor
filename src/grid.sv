// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

module grid (
    input clk,
    input rst,

    input pc_t next_program_counter,
    input sp_t next_stack_pointer,
    input instruction_t instruction,
    input global_enable,

    output reg diverge_consensus
);
    // Grid Dimensions

    localparam integer width /*verilator public*/ = 50;
    localparam integer height /*verilator public*/ = 50;

    wire value_t states[height][width];
    wire value_t video[height][width] /*verilator public*/;

    wire diverge[height][width];

    // Helper functions to arrange the grid as a toroidal array.

    function integer x_idx (input integer x);
      x_idx = ((x % width) + width) % width;
    endfunction

    function integer y_idx (input integer y);
      y_idx = ((y % height) + height) % height;
    endfunction

    // Define the cells in the grid and connect them to each other

    genvar i;
    genvar j;

    generate
      for (i=0; i < width; i=i+1) begin
        for (j=0; j < height; j=j+1) begin
          core #(.X(i),.Y(j)) cellInside (
            .clk(clk),
            .rst(rst),
            .global_enable(global_enable),
            .instruction(instruction),
            .next_program_counter(next_program_counter),
            .next_stack_pointer(next_stack_pointer),
            .i01(states[y_idx(j-1)][x_idx(i  )]),
            .i10(states[y_idx(j  )][x_idx(i-1)]),
            .i11(states[y_idx(j  )][x_idx(i  )]),
            .i12(states[y_idx(j  )][x_idx(i+1)]),
            .i21(states[y_idx(j+1)][x_idx(i  )]),
            .video(video[j][i]),
            .diverge(diverge[j][i])
          );
        end
      end
    endgenerate

    // Inform the global control about whether there is a branch consensus or not

    integer x;
    integer y;

    always_comb begin
      diverge_consensus = 1;
      for (x=0; x < width; x=x+1) begin
        for (y=0; y < height; y=y+1) begin
          diverge_consensus = diverge_consensus & diverge[y][x];
        end
      end
    end
endmodule

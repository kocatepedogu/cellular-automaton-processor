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
    localparam integer width /*verilator public*/ = 25;
    localparam integer height /*verilator public*/ = 25;

    register_t states[height][width];

    wire value_t nextstates[height][width];
    wire value_t nextvideo[height][width] /*verilator public*/;

    wire diverge[height][width];

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

    genvar i;
    genvar j;
    generate
        // Top-Left Corner
        core #(.X(0),.Y(0)) cellTopLeft (
            .clk(clk),
            .rst(rst),
            .global_enable(global_enable),
            .instruction(instruction),
            .next_program_counter(next_program_counter),
            .next_stack_pointer(next_stack_pointer),
            .i01(states[height-1][0]),
            .i10(states[0][width-1]),
            .i11(states[0][0]),
            .i12(states[0][1]),
            .i21(states[1][0]),
            .nextState(nextstates[0][0]),
            .nextVideo(nextvideo[0][0]),
            .diverge(diverge[0][0])
        );

        // Top-Right Corner
        core #(.X(width-1),.Y(0)) cellTopRight (
            .clk(clk),
            .rst(rst),
            .global_enable(global_enable),
            .instruction(instruction),
            .next_program_counter(next_program_counter),
            .next_stack_pointer(next_stack_pointer),
            .i01(states[height-1][width-1]),
            .i10(states[0][width-2]),
            .i11(states[0][width-1]),
            .i12(states[0][0]),
            .i21(states[1][width-1]),
            .nextState(nextstates[0][width-1]),
            .nextVideo(nextvideo[0][width-1]),
            .diverge(diverge[0][width-1])
        );

        // Top Line
        for (i=1; i <= width - 2; i=i+1) begin
            core #(.X(i),.Y(0)) cellTopLine (
                .clk(clk),
                .rst(rst),
                .global_enable(global_enable),
                .instruction(instruction),
                .next_program_counter(next_program_counter),
                .next_stack_pointer(next_stack_pointer),
                .i01(states[height-1][i]),
                .i10(states[0][i-1]),
                .i11(states[0][i]),
                .i12(states[0][i+1]),
                .i21(states[1][i]),
                .nextState(nextstates[0][i]),
                .nextVideo(nextvideo[0][i]),
                .diverge(diverge[0][i])
            );
        end

        // Bottom-Left Corner
        core #(.X(0),.Y(height-1)) cellBottomLeft (
            .clk(clk),
            .rst(rst),
            .global_enable(global_enable),
            .instruction(instruction),
            .next_program_counter(next_program_counter),
            .next_stack_pointer(next_stack_pointer),
            .i01(states[height-2][0]),
            .i10(states[height-1][width-1]),
            .i11(states[height-1][0]),
            .i12(states[height-1][1]),
            .i21(states[0][0]),
            .nextState(nextstates[height-1][0]),
            .nextVideo(nextvideo[height-1][0]),
            .diverge(diverge[height-1][0])
        );

        // Bottom-Right Corner
        core #(.X(width-1),.Y(height-1)) cellBottomRight (
            .clk(clk),
            .rst(rst),
            .global_enable(global_enable),
            .instruction(instruction),
            .next_program_counter(next_program_counter),
            .next_stack_pointer(next_stack_pointer),
            .i01(states[height-2][width-1]),
            .i10(states[height-1][width-2]),
            .i11(states[height-1][width-1]),
            .i12(states[height-1][0]),
            .i21(states[0][width-1]),
            .nextState(nextstates[height-1][width-1]),
            .nextVideo(nextvideo[height-1][width-1]),
            .diverge(diverge[height-1][width-1])
        );

        // Bottom Line
        for (i=1; i <= width - 2; i=i+1) begin
            core #(.X(i),.Y(height-1)) cellBottomLine (
                .clk(clk),
                .rst(rst),
                .global_enable(global_enable),
                .instruction(instruction),
                .next_program_counter(next_program_counter),
                .next_stack_pointer(next_stack_pointer),
                .i01(states[height-2][i]),
                .i10(states[height-1][i-1]),
                .i11(states[height-1][i]),
                .i12(states[height-1][i+1]),
                .i21(states[0][i]),
                .nextState(nextstates[height-1][i]),
                .nextVideo(nextvideo[height-1][i]),
                .diverge(diverge[height-1][i])
            );
        end

        // Left Line
        for (i=1; i <= height - 2; i=i+1) begin
            core #(.X(0),.Y(i)) cellLeftLine (
                .clk(clk),
                .rst(rst),
                .global_enable(global_enable),
                .instruction(instruction),
                .next_program_counter(next_program_counter),
                .next_stack_pointer(next_stack_pointer),
                .i01(states[i-1][0]),
                .i10(states[i][width-1]),
                .i11(states[i][0]),
                .i12(states[i][1]),
                .i21(states[i+1][0]),
                .nextState(nextstates[i][0]),
                .nextVideo(nextvideo[i][0]),
                .diverge(diverge[i][0])
            );
        end

        // Right Line
        for (i=1; i <= height - 2; i=i+1) begin
            core #(.X(width-1),.Y(i)) cellRightLine (
                .clk(clk),
                .rst(rst),
                .global_enable(global_enable),
                .instruction(instruction),
                .next_program_counter(next_program_counter),
                .next_stack_pointer(next_stack_pointer),
                .i01(states[i-1][width-1]),
                .i10(states[i][width-2]),
                .i11(states[i][width-1]),
                .i12(states[i][0]),
                .i21(states[i+1][width-1]),
                .nextState(nextstates[i][width-1]),
                .nextVideo(nextvideo[i][width-1]),
                .diverge(diverge[i][width-1])
            );
        end

        // Inside
        for (i=1; i <= width - 2; i=i+1) begin
            for (j=1; j <= height - 2; j=j+1) begin
                core #(.X(i),.Y(j)) cellInside (
                    .clk(clk),
                    .rst(rst),
                    .global_enable(global_enable),
                    .instruction(instruction),
                    .next_program_counter(next_program_counter),
                    .next_stack_pointer(next_stack_pointer),
                    .i01(states[j-1][i]),
                    .i10(states[j][i-1]),
                    .i11(states[j][i]),
                    .i12(states[j][i+1]),
                    .i21(states[j+1][i]),
                    .nextState(nextstates[j][i]),
                    .nextVideo(nextvideo[j][i]),
                    .diverge(diverge[j][i])
                );
            end
        end

        for (i = 0; i < width; i=i+1) begin
            for (j = 0; j < height; j=j+1) begin
                always @(posedge clk) begin
                    if (rst) begin
                        states[j][i] <= 0;
                    end else begin
                        if (global_enable)
                          states[j][i] <= nextstates[j][i];
                    end
                end
            end
        end
    endgenerate
endmodule

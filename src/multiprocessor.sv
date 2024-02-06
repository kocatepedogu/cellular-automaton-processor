module multiprocessor #(
    parameter WIDTH = 10,
    parameter HEIGHT = 8,
    parameter REGISTER_LENGTH = 8
) (
    input clk,
    input rst,

`ifdef VGA_OUTPUT
    input  [9:0] vga_x_idx,
    input  [9:0] vga_y_idx,
    output [REGISTER_LENGTH-1:0] vga_output,
`endif

    input  [11:0] program_counter,
    input  [15:0] instruction,
    input         execution_enable
);
    reg  [REGISTER_LENGTH-1:0] states[HEIGHT][WIDTH];

    wire [REGISTER_LENGTH-1:0] nextstates[HEIGHT][WIDTH];
    wire [REGISTER_LENGTH-1:0] nextvideo[HEIGHT][WIDTH] /*verilator public*/;

    genvar i;
    genvar j;

    generate
        // Top-Left Corner
        cell_core #(.X(0),.Y(0),.REGISTER_LENGTH(REGISTER_LENGTH)) cellTopLeft (
            .clk(clk),
            .rst(rst),
            .instruction(instruction),
            .program_counter(program_counter),
            .execution_enable(execution_enable),
            .i01(states[HEIGHT-1][0]),
            .i10(states[0][WIDTH-1]),
            .i11(states[0][0]),
            .i12(states[0][1]),
            .i21(states[1][0]),
            .nextState(nextstates[0][0]),
            .nextVideo(nextvideo[0][0])
        );

        // Top-Right Corner
        cell_core #(.X(WIDTH-1),.Y(0),.REGISTER_LENGTH(REGISTER_LENGTH)) cellTopRight (
            .clk(clk),
            .rst(rst),
            .instruction(instruction),
            .program_counter(program_counter),
            .execution_enable(execution_enable),
            .i01(states[HEIGHT-1][WIDTH-1]),
            .i10(states[0][WIDTH-2]),
            .i11(states[0][WIDTH-1]),
            .i12(states[0][0]),
            .i21(states[1][WIDTH-1]),
            .nextState(nextstates[0][WIDTH-1]),
            .nextVideo(nextvideo[0][WIDTH-1])
        );

        // Top Line
        for (i=1; i <= WIDTH - 2; i=i+1) begin
            cell_core #(.X(i),.Y(0),.REGISTER_LENGTH(REGISTER_LENGTH)) cellTopLine (
                .clk(clk),
                .rst(rst),
                .instruction(instruction),
                .program_counter(program_counter),
                .execution_enable(execution_enable),
                .i01(states[HEIGHT-1][i]),
                .i10(states[0][i-1]),
                .i11(states[0][i]),
                .i12(states[0][i+1]),
                .i21(states[1][i]),
                .nextState(nextstates[0][i]),
                .nextVideo(nextvideo[0][i])
            );
        end

        // Bottom-Left Corner
        cell_core #(.X(0),.Y(HEIGHT-1),.REGISTER_LENGTH(REGISTER_LENGTH)) cellBottomLeft (
            .clk(clk),
            .rst(rst),
            .instruction(instruction),
            .program_counter(program_counter),
            .execution_enable(execution_enable),
            .i01(states[HEIGHT-2][0]),
            .i10(states[HEIGHT-1][WIDTH-1]),
            .i11(states[HEIGHT-1][0]),
            .i12(states[HEIGHT-1][1]),
            .i21(states[0][0]),
            .nextState(nextstates[HEIGHT-1][0]),
            .nextVideo(nextvideo[HEIGHT-1][0])
        );

        // Bottom-Right Corner
        cell_core #(.X(WIDTH-1),.Y(HEIGHT-1),.REGISTER_LENGTH(REGISTER_LENGTH)) cellBottomRight (
            .clk(clk),
            .rst(rst),
            .instruction(instruction),
            .program_counter(program_counter),
            .execution_enable(execution_enable),
            .i01(states[HEIGHT-2][WIDTH-1]),
            .i10(states[HEIGHT-1][WIDTH-2]),
            .i11(states[HEIGHT-1][WIDTH-1]),
            .i12(states[HEIGHT-1][0]),
            .i21(states[0][WIDTH-1]),
            .nextState(nextstates[HEIGHT-1][WIDTH-1]),
            .nextVideo(nextvideo[HEIGHT-1][WIDTH-1])
        );

        // Bottom Line
        for (i=1; i <= WIDTH - 2; i=i+1) begin
            cell_core #(.X(i),.Y(HEIGHT-1),.REGISTER_LENGTH(REGISTER_LENGTH)) cellBottomLine (
                .clk(clk),
                .rst(rst),
                .instruction(instruction),
                .program_counter(program_counter),
                .execution_enable(execution_enable),
                .i01(states[HEIGHT-2][i]),
                .i10(states[HEIGHT-1][i-1]),
                .i11(states[HEIGHT-1][i]),
                .i12(states[HEIGHT-1][i+1]),
                .i21(states[0][i]),
                .nextState(nextstates[HEIGHT-1][i]),
                .nextVideo(nextvideo[HEIGHT-1][i])
            );
        end

        // Left Line
        for (i=1; i <= HEIGHT - 2; i=i+1) begin
            cell_core #(.X(0),.Y(i),.REGISTER_LENGTH(REGISTER_LENGTH)) cellLeftLine (
                .clk(clk),
                .rst(rst),
                .instruction(instruction),
                .program_counter(program_counter),
                .execution_enable(execution_enable),
                .i01(states[i-1][0]),
                .i10(states[i][WIDTH-1]),
                .i11(states[i][0]),
                .i12(states[i][1]),
                .i21(states[i+1][0]),
                .nextState(nextstates[i][0]),
                .nextVideo(nextvideo[i][0])
            );
        end

        // Right Line
        for (i=1; i <= HEIGHT - 2; i=i+1) begin
            cell_core #(.X(WIDTH-1),.Y(i),.REGISTER_LENGTH(REGISTER_LENGTH)) cellRightLine (
                .clk(clk),
                .rst(rst),
                .instruction(instruction),
                .program_counter(program_counter),
                .execution_enable(execution_enable),
                .i01(states[i-1][WIDTH-1]),
                .i10(states[i][WIDTH-2]),
                .i11(states[i][WIDTH-1]),
                .i12(states[i][0]),
                .i21(states[i+1][WIDTH-1]),
                .nextState(nextstates[i][WIDTH-1]),
                .nextVideo(nextvideo[i][WIDTH-1])
            );
        end

        // Inside
        for (i=1; i <= WIDTH - 2; i=i+1) begin
            for (j=1; j <= HEIGHT - 2; j=j+1) begin
                cell_core #(.X(i),.Y(j),.REGISTER_LENGTH(REGISTER_LENGTH)) cellInside (
                    .clk(clk),
                    .rst(rst),
                    .instruction(instruction),
                    .program_counter(program_counter),
                    .execution_enable(execution_enable),
                    .i01(states[j-1][i]),
                    .i10(states[j][i-1]),
                    .i11(states[j][i]),
                    .i12(states[j][i+1]),
                    .i21(states[j+1][i]),
                    .nextState(nextstates[j][i]),
                    .nextVideo(nextvideo[j][i])
                );
            end
        end

        for (i = 0; i < WIDTH; i=i+1) begin
            for (j = 0; j < HEIGHT; j=j+1) begin
                always @(posedge clk) begin
                    if (rst) begin
                        states[j][i] <= 0;
                    end else begin
                        if (execution_enable)
                          states[j][i] <= nextstates[j][i];
                    end
                end
            end
        end
    endgenerate

`ifdef VGA_OUTPUT
    assign vga_output = (states_y_addr < HEIGHT && states_x_addr < WIDTH) ?
                        nextvideo[states_y_addr[3:0]][states_x_addr[3:0]] : 0;
`endif

endmodule

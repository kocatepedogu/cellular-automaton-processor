module vga #(parameter REGISTER_LENGTH = 8, parameter WIDTH = 10, parameter HEIGHT = 8) (
    input clk,
    input rst,
    input [REGISTER_LENGTH-1:0] state,
    output reg [9:0] X,
    output reg [9:0] Y,
    output Hsync,
    output Vsync,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue
);
    reg clock50MHz = 0;
    always @(posedge clk) begin
        clock50MHz = !clock50MHz;
    end

    reg clock25MHz = 0;
    always @(posedge clock50MHz) begin
        clock25MHz = !clock25MHz;
    end

    wire CounterXmaxed = (X == 800); // 16 + 48 + 96 + 640
    wire CounterYmaxed = (Y == 525); // 10 + 2 + 33 + 480

    always @(posedge clock25MHz)
    if (CounterXmaxed | rst)
        X = 0;
    else
        X = X + 1;

    always @(posedge clock25MHz)
    begin
      if (CounterXmaxed | rst)
      begin
        if(CounterYmaxed | rst)
          Y = 0;
        else
          Y = Y + 1;
      end
    end

    reg vga_HS, vga_VS;

    always @(posedge clock25MHz)
    begin
        vga_HS = (X > (640 + 16) && (X < (640 + 16 + 96)));   // active for 96 clocks
        vga_VS = (Y > (480 + 10) && (Y < (480 + 10 + 2)));   // active for 2 clocks
    end

    always @(posedge clock25MHz) begin
        if (X < 640 && Y < 480) begin
            vgaRed <= state[3:0];
            vgaGreen <= state[3:0];
            vgaBlue <= state[3:0];
        end else begin
            vgaRed <= 4'b0000;
            vgaGreen <= 4'b0000;
            vgaBlue <= 4'b0000;
        end
    end

    assign Hsync = ~vga_HS;
    assign Vsync = ~vga_VS;
endmodule

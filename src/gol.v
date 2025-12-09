module aut(
	input wire clk,
	input reg [7:0] neighbors,
	output reg state
);
	always @(posedge clk) begin
		state <= (state && $countones(neighbors) == 2) || $countones(neighbors) == 3;
	end
endmodule

module gol(
	input wire clk,
	input wire pxl_clk,

	input logic [9:0] x,
	input logic [9:0] y,
	output logic [7:0] r,
	output logic [7:0] g,
	output logic [7:0] b
);
	parameter WIDTH  = 10;
	parameter HEIGHT = 9;

	logic board[HEIGHT][WIDTH];

	reg [24:0] delay_counter = 0;
	always @(posedge clk) begin
		delay_counter <= delay_counter[24] ? 0 : delay_counter + 1;
	end

	initial begin
		for (int i = 0; i < HEIGHT; i++) begin
			for (int j = 0; j < WIDTH; j++) begin
				board[i][j] =
                                       // glider
                                       (i == 6 && j == 6) ||
                                       (i == 7 && j == 7) ||
                                       (i == 8 && j == 5) ||
                                       (i == 8 && j == 6) ||
                                       (i == 8 && j == 7);

			end
		end
	end


	`include "auts.v"

	always_comb begin
		if (x % 32 == 0 || y % 32 == 0) begin
			r = 8'h00;
			g = 8'h00;
			b = 8'h00;
		end else if (x < 32 * 5 || x > 32 * 15 || y < 32 * 3 || y > 32 * 12) begin
			r = 8'h11;
			g = 8'h11;
			b = 8'h11;
		end else begin
			r = board[y / 32 - 3][x / 32 - 5] ? 0 : 8'hff;
			g = board[y / 32 - 3][x / 32 - 5] ? 0 : 8'hff;
			b = board[y / 32 - 3][x / 32 - 5] ? 0 : 8'hff;
		end
	end
endmodule

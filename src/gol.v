module gol(
	input wire clk,

	input wire [2:0] left,
	input wire [2:0] right,

	input logic [9:0] x,
	input logic [9:0] y,
	output logic [7:0] r,
	output logic [7:0] g,
	output logic [7:0] b
);
	parameter WIDTH  = 10;
	parameter HEIGHT = 9;

	logic board[HEIGHT][WIDTH];

	assign board[3][0] = left[0];
	assign board[4][0] = left[1];
	assign board[5][0] = left[2];

	assign board[3][WIDTH - 1] = right[0];
	assign board[4][WIDTH - 1] = right[1];
	assign board[5][WIDTH - 1] = right[2];

	logic [9:0] l_score;
	logic [9:0] r_score;

	reg [24:0] delay_counter = 0;
	always @(posedge clk) begin
		delay_counter <= delay_counter[24] ? 0 : delay_counter + 1;
	end

	always @(posedge delay_counter[24]) begin
		r_score <= r_score + $countones({
			board[0][0],
			board[1][0],
			board[2][0],
			board[6][0],
			board[7][0],
			board[8][0]
		});

		l_score <= l_score + $countones({
			board[0][9],
			board[1][9],
			board[2][9],
			board[6][9],
			board[7][9],
			board[8][9]
		});
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
			{r, g, b} = 24'h180802;
		end else if (x > 32 * 1 && x < 32 * 2 && y < 32 * 12 && y > 32 * 3) begin
			{r, g, b} = l_score[y / 32 - 3] ? 24'h8d479b : 0;
		end else if (x > 32 * 18 && x < 32 * 19 && y < 32 * 12 && y > 32 * 3) begin
			{r, g, b} = r_score[y / 32 - 3] ? 24'h479b7c : 0;
		end else if (x < 32 * 5 || x > 32 * 15 || y < 32 * 3 || y > 32 * 12) begin
			{r, g, b} = 24'h000000;
		end else begin
			{r, g, b} = board[y / 32 - 3][x / 32 - 5] ? 0 : 24'hffffff;
		end
	end
endmodule

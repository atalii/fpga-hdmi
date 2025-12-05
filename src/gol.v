module gol(
	input wire clk,
	input wire pxl_clk,

	input logic [9:0] x,
	input logic [9:0] y,
	output logic [7:0] r,
	output logic [7:0] g,
	output logic [7:0] b
);

	function logic signed [31:0] countones(input logic [7:0] in);
		countones = 0;
		for (int i = 0; i < 7; i++) begin
			countones = countones + {31'b0, in[i]};
		end
	endfunction

	// Alive cells are true.
	logic board[20][15];

	// Set the board up initially.
	initial begin
		for (int i = 0; i < 20; i++) begin
			for (int j = 0; j < 15; j++) begin
				board[i][j] =
					// square
					(i == 4 && j == 4) ||
					(i == 5 && j == 4) ||
					(i == 4 && j == 5) ||
					(i == 5 && j == 5) ||
					// blinker
					(i == 8 && j == 8) ||
					(i == 8 && j == 9) ||
					(i == 8 && j == 10) ||
					// glider
					(i == 15 && j == 3) ||
					(i == 16 && j == 4) ||
					(i == 14 && j == 5) ||
					(i == 15 && j == 5) ||
					(i == 16 && j == 5);
			end
		end
	end

	// Update the cells.
	logic [24:0] delay_counter = 0;
	always @(posedge clk) begin
		delay_counter <= delay_counter + 1;
	end

	always @(posedge clk) begin
		logic [7:0] neighbors_bitmap;
		int count; 
		for (int i = 0; i < 20; i++) begin
			for (int j = 0; j < 24; j++) begin
				if (delay_counter == 28'hffffff) begin
					count = $countones(
						{board[i + 1][j - 1],
						board[i + 1][j],
						board[i + 1][j + 1],
						board[i][j - 1],
						board[i][j + 1],
						board[i - 1][j - 1],
						board[i - 1][j],
						board[i - 1][j + 1]});

					board[i][j] <= (board[i][j] && count == 2) || count == 3;
				end
			end
		end
	end
	always @(posedge pxl_clk) begin
		r <= x % 32 == 0 || y % 32 == 0 ? 8'h27 :
			board[x / 32][y / 32] ? 8'h00 : 8'hea;

		g <= x % 32 == 0 || y % 32 == 0 ? 8'h0f :
			board[x / 32][y / 32] ? 8'h00 : 8'hea;

		b <= x % 32 == 0 || y % 32 == 0 ? 8'h3f :
			board[x / 32][y / 32] ? 8'h00 : 8'hea;
	end
endmodule

module gol(
	input wire clk,

	input logic [9:0] x,
	input logic [9:0] y,
	output logic [7:0] r,
	output logic [7:0] g,
	output logic [7:0] b
);
	always @(posedge clk) begin
		r <= x % 32 == 0 || y % 32 == 0 ? 8'h00 : 8'hed;
		g <= x % 32 == 0 || y % 32 == 0 ? 8'h00 : 8'he1;
		b <= x % 32 == 0 || y % 32 == 0 ? 8'h00 : 8'he5;
	end
endmodule

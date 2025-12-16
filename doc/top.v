module top(
	input wire clk,
	input wire [7:0] neighbors,
	output wire alive,
);
	logic alive = 0;

	always @(posedge clk) begin
		alive <= (alive && $countones(neighbors) == 2) || $countones(neighbors) == 3;
	end
endmodule

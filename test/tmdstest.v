`timescale 1ns / 1ns
module tdms_test ();
	reg clk;
	logic [7:0] din;
	logic [9:0] encoded;

	tmds encoder(
		.clk(clk),
		.din(din),
		.encoded(encoded)
	);

	initial begin
		clk = 1'b0;
		forever #1 clk = ~clk;
	end

	initial begin
		$monitor("time=%t, input=%b, encoded=%b", $time, din, encoded);
		for (int i = 0; i < 256; i = i + 1) begin
			din = i[7:0];
			#2;
		end

		$finish;
	end
endmodule

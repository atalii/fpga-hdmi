module tmds(
	input wire clk,
	input reg [7:0] din,
	output reg [9:0] encoded
);
	logic [8:0] q_m;
	logic [9:0] q_out;
	logic signed [7:0] n1, n0, n1q7, n0q7;
	logic signed [31:0] cnt = 0;

	// Just do what the spec says, except that we're doing control signals
	// at a higher level and don't need to worry about that here.
	always @(posedge clk) begin
		n1 = din[0] + din[1] + din[2] + din[3] + din[4] + din[5] + din[6] + din[7];
		n0 = !din[0] + !din[1] + !din[2] + !din[3] + !din[4] + !din[5] + !din[6] + !din[7];

		if (n1 > 4 || n1 == 4 && din[0]) begin
			q_m[0] = din[0];
			q_m[1] = q_m[0] ^ din[1];
			q_m[2] = q_m[1] ^ din[2];
			q_m[3] = q_m[2] ^ din[3];
			q_m[4] = q_m[3] ^ din[4];
			q_m[5] = q_m[4] ^ din[5];
			q_m[6] = q_m[5] ^ din[6];
			q_m[7] = q_m[6] ^ din[7];
			q_m[8] = 1;
		end else begin
			q_m[0] = din[0];
			q_m[1] = !(q_m[0] ^ din[1]);
			q_m[2] = !(q_m[1] ^ din[2]);
			q_m[3] = !(q_m[2] ^ din[3]);
			q_m[4] = !(q_m[3] ^ din[4]);
			q_m[5] = !(q_m[4] ^ din[5]);
			q_m[6] = !(q_m[5] ^ din[6]);
			q_m[7] = !(q_m[6] ^ din[7]);
			q_m[8] = 0;
		end

		n1q7 = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7];
		n0q7 = !q_m[0] + !q_m[1] + !q_m[2] + !q_m[3] + !q_m[4] + !q_m[5] + !q_m[6] + !q_m[7];

		if (cnt == 0 || n1q7 == n0q7) begin
			q_out[9] = ~q_m[8];
			q_out[8] = q_m[8];
			q_out[7:0] = q_m[8] ? q_m[7:0] : ~q_m[7:0];

			if (q_m[8] == 0) begin
				cnt = cnt + (n0q7 - n1q7);
			end else begin
				cnt = cnt + (n1q7 - n0q7);
			end
		end else begin
			if ((cnt > 0 && n1q7 > n0q7) || (cnt < 0 && n0q7 > n1q7)) begin
				q_out[9] = 1;
				q_out[8] = q_m[8];
				q_out[7:0] = ~q_m[7:0];
				cnt = cnt + 2 * q_m[8] + (n0q7 - n1q7);
			end else begin
				q_out[9] = 0;
				q_out[8] = q_m[8];
				q_out[7:0] = q_m[7:0];
				cnt = cnt - 2 * !q_m[8] + (n1q7 - n0q7);
			end
		end

		encoded = q_out;
	end
endmodule

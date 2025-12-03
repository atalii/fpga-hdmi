`default_nettype none

module top(
	input wire clk,

	output wire [2:0] tmds_tx_n,
	output wire [2:0] tmds_tx_p,
	output wire tmds_clk_n,
	output wire tmds_clk_p,
);

	reg [0:7372808] bg[1];

	initial $readmemh("image.bmp.hex", bg);

	// Take these parameters directly from Apicula's example.
	localparam [9:0] FRAME_WIDTH = 800;
	localparam [9:0] FRAME_HEIGHT = 525;
	localparam [9:0] SCREEN_WIDTH = 640;
	localparam [9:0] SCREEN_HEIGHT = 480;
	localparam [9:0] HSYNC_PULSE_START = 16;
	localparam [9:0] HSYNC_PULSE_SIZE = 96;
	localparam [9:0] VSYNC_PULSE_START = 10;
	localparam [9:0] VSYNC_PULSE_SIZE = 2;

	wire rst;
	assign rst = 0;

	wire pxl_clk, pxl_clk5, pxl_clk5p, pxl_clk5d, pxl_clk5d3, pllclk_lock;

	rPLL #(
		.FCLKIN("27"),
		.IDIV_SEL(2),
		.FBDIV_SEL(13),
		.ODIV_SEL(4),
	) pll (
		.CLKIN(clk),
		.CLKFB(0),
		.RESET(0),
		.RESET_P(0),
		.FBDSEL(0),
		.IDSEL(0),
		.ODSEL(0),
		.DUTYDA(0),
		.PSDA(0),
		.FDLY(0),
		.CLKOUT(pxl_clk5),
		.LOCK(pllclk_lock),
		.CLKOUTP(pxl_clk5p),
		.CLKOUTD(pxl_clk5d),
		.CLKOUTD3(pxl_clk5d3),
	);

	CLKDIV #(.DIV_MODE("5")) clk_div (
		.CLKOUT(pxl_clk),
		.HCLKIN(pxl_clk5),
		.RESETN(pllclk_lock)
	);

	// Keep track of coordinates.
	logic [9:0] x = 0;
	logic [9:0] y = 0;
	logic hsync, vsync;
	logic data_enable = 0;

	always @(posedge pxl_clk) begin
		if (!rst) begin
			if (x == FRAME_WIDTH - 1) begin
				x <= 0;
				y <= y == FRAME_HEIGHT - 1 ? 0 : y + 1;
			end else x <= x + 1;
		end
	end

	always @(posedge pxl_clk) begin
		hsync <= !(SCREEN_WIDTH + HSYNC_PULSE_START <= x && x < SCREEN_WIDTH + HSYNC_PULSE_START + HSYNC_PULSE_SIZE);

		// Special-case the start and end of the vsync as per
		// Apicula's example.
		if (y == SCREEN_HEIGHT + VSYNC_PULSE_START) vsync <= !(x >= SCREEN_WIDTH + HSYNC_PULSE_START);
		else if (y == SCREEN_HEIGHT + VSYNC_PULSE_START + VSYNC_PULSE_SIZE) vsync <= !(SCREEN_WIDTH + HSYNC_PULSE_START);
		else vsync <= !(y >= SCREEN_HEIGHT + VSYNC_PULSE_START && y < SCREEN_HEIGHT + VSYNC_PULSE_START + VSYNC_PULSE_SIZE);
	end

	always @(posedge pxl_clk) begin
		if (!rst) begin
			data_enable <= x < SCREEN_WIDTH && y < SCREEN_HEIGHT; 
		end
	end

	reg [7:0] r;
	reg [7:0] g;
	reg [7:0] b;
	logic [10:0] r_enc, g_enc, b_enc;

	always @(posedge pxl_clk) begin
		if (data_enable) begin
			r <= bg[0][(x + y * 640):(x + y * 640 + 7)];
			g <= bg[0][(x + y * 640 + 8):(x + y * 640 + 15)];
			b <= bg[0][(x + y * 640 + 16):(x + y * 640 + 23)];
		end
	end

	tmds r_t(pxl_clk, r, r_enc);
	tmds g_t(pxl_clk, g, g_enc);
	tmds b_t(pxl_clk, b, b_enc);

	reg [9:0] tmds_logical_vals[2:0];
	reg [2:0] tmds_phys_vals;
	
	always @(posedge pxl_clk) begin
		if (data_enable) begin
			tmds_logical_vals[0] <= b_enc;
		end else begin
		    unique case({vsync, hsync})
			2'b00: tmds_logical_vals[0] <= 10'b1101010100;
			2'b01: tmds_logical_vals[0] <= 10'b0010101011;
			2'b10: tmds_logical_vals[0] <= 10'b0101010100;
			2'b11: tmds_logical_vals[0] <= 10'b1010101011;
		    endcase
		end

		tmds_logical_vals[1] <= data_enable ? g_enc : 10'b1101010100;
		tmds_logical_vals[2] <= data_enable ? r_enc : 10'b1101010100;
	end

	OSER10 gwSer0( 
		.Q(tmds_phys_vals[0]),
		.D0(tmds_logical_vals[0][0]),
		.D1(tmds_logical_vals[0][1]),
		.D2(tmds_logical_vals[0][2]),
		.D3(tmds_logical_vals[0][3]),
		.D4(tmds_logical_vals[0][4]),
		.D5(tmds_logical_vals[0][5]),
		.D6(tmds_logical_vals[0][6]),
		.D7(tmds_logical_vals[0][7]),
		.D8(tmds_logical_vals[0][8]),
		.D9(tmds_logical_vals[0][9]),
		.PCLK(pxl_clk),
		.FCLK(pxl_clk5),
		.RESET(rst)
	);

	OSER10 gwSer1( 
		.Q(tmds_phys_vals[1]),
		.D0(tmds_logical_vals[1][0]),
		.D1(tmds_logical_vals[1][1]),
		.D2(tmds_logical_vals[1][2]),
		.D3(tmds_logical_vals[1][3]),
		.D4(tmds_logical_vals[1][4]),
		.D5(tmds_logical_vals[1][5]),
		.D6(tmds_logical_vals[1][6]),
		.D7(tmds_logical_vals[1][7]),
		.D8(tmds_logical_vals[1][8]),
		.D9(tmds_logical_vals[1][9]),
		.PCLK(pxl_clk),
		.FCLK(pxl_clk5),
		.RESET(rst)
	);

	OSER10 gwSer2( 
		.Q(tmds_phys_vals[2]),
		.D0(tmds_logical_vals[2][0]),
		.D1(tmds_logical_vals[2][1]),
		.D2(tmds_logical_vals[2][2]),
		.D3(tmds_logical_vals[2][3]),
		.D4(tmds_logical_vals[2][4]),
		.D5(tmds_logical_vals[2][5]),
		.D6(tmds_logical_vals[2][6]),
		.D7(tmds_logical_vals[2][7]),
		.D8(tmds_logical_vals[2][8]),
		.D9(tmds_logical_vals[2][9]),
		.PCLK(pxl_clk),
		.FCLK(pxl_clk5),
		.RESET(rst)
	);


	ELVDS_OBUF tmds_bufds [3:0] (
		.I({pxl_clk, tmds_phys_vals}),
		.O({tmds_clk_p, tmds_tx_p}),
		.OB({tmds_clk_n, tmds_tx_n})
	);

endmodule

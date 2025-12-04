synth:
	yosys \
		-D LEDS_NR=6 -D OSC_TYPE_OSC -D INV_BTN=0 \
		-D CPU_FREQ=27 -D BAUD_RATE=115200 -D NUM_HCLK=5 \
		-D HAS_FLASH608K -D RISCV_MEM_48K \
		-p "read_verilog -sv src/top.v src/tmds.v src/gol.v; synth_gowin -json top.json"

	nextpnr-himbaechel \
		--json top.json \
		--write pnrtop.json \
		--device GW1NR-LV9QN88PC6/I5 \
		--vopt family=GW1N-9C \
		--vopt cst=csts.cst

	gowin_pack -d GW1N-9C -o top.fs pnrtop.json

flash:
	openFPGALoader top.fs

//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab62 (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;

// collision variables
logic [3:0] l_dirX, l_dirY;
logic [4:0] mapL, mapR, mapB, mapT;
logic [4:0] RGmapL, RGmapR, RGmapB, RGmapT;
logic [4:0] OGmapL, OGmapR, OGmapB, OGmapT;
logic [4:0] BGmapL, BGmapR, BGmapB, BGmapT;
logic [7:0] randomkeycode1;
logic [7:0] randomkeycode2;
logic [7:0] randomkeycode3;
logic [7:0] lfsr_out;

// game state variables
logic win, lose, pause, lifeDown;
logic [3:0] fruits;
logic [9:0] score;

logic Load_score;
logic Load_fruits;
logic Load_lives;
logic [9:0] score_from_reg, score_to_reg;
logic [3:0] fruits_from_reg, fruits_to_reg;
logic [7:0] lives_from_reg, lives_to_reg;

// dots
logic [31:0] dl;
logic [9:0] dX [0:31];
logic [9:0] dY [0:31];

// timer
logic sec;
logic [31:0] counter;

//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0, hex_num5, hex_num6; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig;
	logic [9:0] ballxsig, ballysig, ballsizesig;
	logic [9:0] redghostxsig, redghostysig, redghostsizesig;
	logic [9:0] orangeghostxsig, orangeghostysig, orangeghostsizesig;
	logic [9:0] blueghostxsig, blueghostysig, blueghostsizesig;
	
	logic [7:0] Red, Blue, Green;
	logic [7:0] keycode;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (randomkeycode1[7:4], HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 ({sec, sec, sec, sec}, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (lfsr_out[7:4], HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (lfsr_out[3:0], HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];
	
	
	lab62soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
//		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n																			

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode)
		
	 );


	// initialize modules

	vga_controller vga(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .hs(VGA_HS), .vs(VGA_VS), .pixel_clk(VGA_Clk), .blank(blank), .sync(sync), .DrawX(drawxsig), .DrawY(drawysig));
	
	color_mapper cm(.Clk(MAX10_CLK1_50), .VGA_Clk(VGA_Clk), .blueghostX(blueghostxsig), .blueghostY(blueghostysig), .blueghost_size(blueghostsizesig), .redghostX(redghostxsig), .redghostY(redghostysig), .redghost_size(redghostsizesig), .orangeghostX(orangeghostxsig), .orangeghostY(orangeghostysig), .orangeghost_size(orangeghostsizesig), .BallX(ballxsig), .BallY(ballysig), .DrawX(drawxsig), .DrawY(drawysig), .Ball_size(ballsizesig), .Red(Red), .Green(Green), .Blue(Blue), .blank(blank), .l_dirX(l_dirX), .l_dirY(l_dirY), .score(score_from_reg), .fruits(fruits_from_reg), .lives(lives_from_reg), .counter(counter), .dX(dX), .dY(dY), .lose(lose), .win(win), .dots_left(dl));
	
	game_logic gl(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .dots_left(dl), .counter(counter), .keycode(keycode), .pX(ballxsig), .pY(ballysig), .pSize(ballsizesig), .gSize(redghostsizesig), .rgX(redghostxsig), .rgY(redghostysig), .ogX(orangeghostxsig), .ogY(orangeghostysig), .bgX(blueghostxsig), .bgY(blueghostysig), .win(win), .lose(lose), .lifeDown(lifeDown), .pause(pause), .fruits_to_reg(fruits_to_reg), .fruits_from_reg(fruits_from_reg), .Load_F(Load_fruits), .score_to_reg(score_to_reg), .Load_S(Load_score), .score_from_reg(score_from_reg), .lives_from_reg(lives_from_reg), .Load_L(Load_lives), .lives_to_reg(lives_to_reg));
	
	ball b(.Reset(Reset_h), .pause(pause), .lifeDown(lifeDown), .frame_clk(VGA_VS) , .keycode(keycode), .mapL(mapL), .mapR(mapR), .mapB(mapB), .mapT(mapT), .BallX(ballxsig), .BallY(ballysig), .BallS(ballsizesig), .last_dirX(l_dirX), .last_dirY(l_dirY));

	redghost rg(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .frame_clk(VGA_VS), .sec(sec), .randomkeycode(randomkeycode1), .redghostX(redghostxsig), .redghostY(redghostysig), .redghostS(redghostsizesig), .pause(pause), .mapL(RGmaskL), .mapR(RGmaskR), .mapT(RGmaskT), .mapB(RGmaskB));
	
	orangeghost og(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .frame_clk(VGA_VS) , .sec(sec), .randomkeycode(randomkeycode2), .orangeghostX(orangeghostxsig), .orangeghostY(orangeghostysig), .orangeghostS(orangeghostsizesig), .pause(pause), .mapL(OGmaskL), .mapR(OGmaskR), .mapT(OGmaskT), .mapB(OGmaskB));
	
	blueghost bg(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .frame_clk(VGA_VS) , .sec(sec), .randomkeycode(randomkeycode3), .blueghostX(blueghostxsig), .blueghostY(blueghostysig), .blueghostS(blueghostsizesig), .pause(pause), .mapL(BGmaskL), .mapR(BGmaskR), .mapT(BGmaskT), .mapB(BGmaskB));
	
	map_mask mmTop(.x(ballxsig), .y(ballysig), .rgx(redghostxsig), .rgy(redghostysig), .ogx(orangeghostxsig), .ogy(orangeghostysig), .bgx(blueghostxsig), .bgy(blueghostysig), .maskL(mapL), .maskR(mapR), .maskT(mapT), .maskB(mapB), .RGmaskL(RGmaskL), .RGmaskR(RGmaskR), .RGmaskT(RGmaskT), .RGmaskB(RGmaskB), .OGmaskL(OGmaskL), .OGmaskR(OGmaskR), .OGmaskT(OGmaskT), .OGmaskB(OGmaskB), .BGmaskL(BGmaskL), .BGmaskR(BGmaskR), .BGmaskT(BGmaskT), .BGmaskB(BGmaskB));
	
	dots d(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .pX(ballxsig), .pY(ballysig), .pS(ballsizesig), .dX(dX), .dY(dY), .dots_left(dl));
	
	second_counter sc(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .sec(sec), .counter_out(counter));
	
	random_dir rd(.Clk(MAX10_CLK1_50), .sec(sec), .Reset(Reset), .dir1(randomkeycode1), .dir2(randomkeycode2), .dir3(randomkeycode3));
	
	lfsr_reg lf(.Clk(sec), .LFSR(lfsr_out));
	
	// regs to store current score and fruits left
	score_reg sr(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .Load(Load_score), .Data_in(score_to_reg), .Data_out(score_from_reg));
	fruits_reg fr(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .Load(Load_fruits), .Data_in(fruits_to_reg), .Data_out(fruits_from_reg));
	lives_reg lr(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .Load(Load_lives), .Data_in(lives_to_reg), .Data_out(lives_from_reg));
	
endmodule

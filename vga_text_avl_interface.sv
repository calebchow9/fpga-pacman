/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

logic [31:0] palette [8]; // 601 registers - control register at index 600
//put other local variables here
logic VGA_Clk, sync, blank;
logic [9:0] DrawX, DrawY;

// sprite
logic [10:0] sprite_addr;
logic [7:0] sprite_data;
logic [3:0] fgd_idx;
logic [3:0] bkg_idx;
logic [7:0] code;
logic inverse;

logic [11:0] vram_addr;
logic [31:0] vram_data;

// on-chip memory
logic [31:0] ocm_data_out_b;
logic [10:0] ocm_address_b;

//Declare submodules..e.g. VGA controller, ROMS, etc
font_rom fr(.addr(sprite_addr), .data(sprite_data));
vga_controller ctrl(.Clk(CLK), .Reset(RESET), .hs(hs), .vs(vs), .pixel_clk(VGA_Clk), .blank(blank), .sync(sync), .DrawX(DrawX), .DrawY(DrawY));
ram ram0(.clock(CLK), .byteena_a(AVL_BYTE_EN), .data_a(AVL_WRITEDATA), .data_b(), .address_a(AVL_ADDR), .address_b(ocm_address_b), .rden_a(AVL_CS & AVL_READ), .wren_a(AVL_CS & AVL_WRITE), .rden_b(1'b1), .wren_b(1'b0), .q_a(AVL_READDATA), .q_b(ocm_data_out_b));

// logic for writing into FPGA palette
always_ff @(posedge CLK)
	begin
		if(AVL_CS == 1)
			begin
				if(AVL_WRITE == 1)
					begin
						if(AVL_ADDR[11] == 1)
							begin
								palette[AVL_ADDR[2:0]] <= AVL_WRITEDATA;
							end
					end
//				if(AVL_READ == 1)
//					begin
//						if(AVL_ADDR[11] == 1)
//							begin
//								AVL_READDATA <= palette[AVL_ADDR[3:0]];
//							end
//					end
			end
	end

//handle drawing (may either be combinational or sequential - or both).
always_comb
	begin: Sprite_outline
	sprite_addr = 0;
	vram_addr = 0;
	vram_data = 0;
	code = 0;
	inverse = 0;
	// gets address of register in VRAM
	vram_addr = DrawY[9:4] * 80 + (DrawX[9:3]);
	
	// vram_data
	ocm_address_b = vram_addr[11:1]; // /2
	vram_data = ocm_data_out_b;

	// find which character in the VRAM data
	case(vram_addr[0])
		1 : 
			begin
				code = vram_data[31:24];
				fgd_idx = vram_data[23:20];
				bkg_idx = vram_data[19:16];
			end
		0 : 
			begin
				code = vram_data[15:8];
				fgd_idx = vram_data[7:4];
				bkg_idx = vram_data[3:0];
			end
	endcase
	sprite_addr = 16 * code[6:0] + (DrawY[3:0]); 
	inverse = code[7];			
	end

always_ff @(posedge VGA_Clk)
	begin: RGB_Display
			begin
//				palette[0] <= 32'b00000000110011000111000110010110;
//				palette[1] <= 32'b00000000110011000111000110010110;
//				palette[2] <= 32'b00000000110011000111000110010110;
//				palette[3] <= 32'b00000000110011000111000110010110;
//				palette[4] <= 32'b00000000110011000111000110010110;
//				palette[5] <= 32'b00000000110011000111000110010110;
//				palette[6] <= 32'b00000000110011000111000110010110;
//				palette[7] <= 32'b00000000110011000111000110010110;
				if(blank == 0)
					begin
						red <= 4'b0000;
						green <= 4'b0000;
						blue <= 4'b0000;
					end
				else
				begin
				// foreground
				if(sprite_data[7 - DrawX[2:0]] == 1'b1)
					begin
						if(fgd_idx[0] == 0)
							begin
								red <= (inverse == 0) ? palette[fgd_idx[3:1]][12:9] : palette[bkg_idx[3:1]][12:9];
								green <= (inverse == 0) ? palette[fgd_idx[3:1]][8:5] : palette[bkg_idx[3:1]][8:5];
								blue <= (inverse == 0) ? palette[fgd_idx[3:1]][4:1] : palette[bkg_idx[3:1]][4:1];
							end
						else
							begin
								red <= (inverse == 0) ? palette[fgd_idx[3:1]][24:21] : palette[bkg_idx[3:1]][24:21];
								green <= (inverse == 0) ? palette[fgd_idx[3:1]][20:17] : palette[bkg_idx[3:1]][20:17];
								blue <= (inverse == 0) ? palette[fgd_idx[3:1]][16:13] : palette[bkg_idx[3:1]][16:13];
							end
//						red <= (inverse == 0) ? 4'b1111 : 4'b0000;
//						green <= (inverse == 0) ? 4'b1111 : 4'b0000;
//						blue <= (inverse == 0) ? 4'b1111 : 4'b0000;
						
					end
				// background
				else
					begin
						if(bkg_idx[0] == 0)
							begin
								red <= (inverse == 1) ? palette[fgd_idx[3:1]][12:9] : palette[bkg_idx[3:1]][12:9];
								green <= (inverse == 1) ? palette[fgd_idx[3:1]][8:5] : palette[bkg_idx[3:1]][8:5];
								blue <= (inverse == 1) ? palette[fgd_idx[3:1]][4:1] : palette[bkg_idx[3:1]][4:1];
							end
						else
							begin
								red <= (inverse == 1) ? palette[fgd_idx[3:1]][24:21] : palette[bkg_idx[3:1]][24:21];
								green <= (inverse == 1) ? palette[fgd_idx[3:1]][20:17] : palette[bkg_idx[3:1]][20:17];
								blue <= (inverse == 1) ? palette[fgd_idx[3:1]][16:13] : palette[bkg_idx[3:1]][16:13];
							end
//						red <= (inverse == 0) ? 4'b0000 : 4'b1111;
//						green <= (inverse == 0) ? 4'b0000 : 4'b1111;
//						blue <= (inverse == 0) ? 4'b0000: 4'b1111;
					end
				end
			end
	end
		
endmodule

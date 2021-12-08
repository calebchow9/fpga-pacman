module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;


logic Clk, Reset;
logic [9:0] pX, pY, pS;
logic [9:0] dX [0:31];
logic [9:0] dY [0:31];
logic [31:0] dots_left;
logic [9:0] DrawX, DrawY;
logic [7:0] Red, Green, Blue;

logic [9:0] redghostxsig, redghostysig, redghostsizesig;
logic lifeDown, restart;
logic [7:0] gkeycode;
logic [31:0] counter;

logic sec;

//dots d(.Clk(Clk), .Reset(Reset), .pX(pX), .pY(pY), .pS(pS), .dX(dX), .dY(dY), .dots_left(dots_left));
redghost rg(.Clk(Clk), .sec(sec), .Reset(Reset), .frame_clk(Clk) , .redghostX(redghostxsig), .redghostY(redghostysig), .redghostS(redghostsizesig), .randomkeycode(gkeycode), .lifeDown(lifeDown), .restart(restart), .mapL(5'b00000), .mapR(5'b00000), .mapT(5'b00000), .mapB(5'b00000));
second_counter secc(.Clk(Clk), .Reset(Reset), .sec(sec), .counter_out(counter));
//dots_test dt(.Clk(Clk), .Reset(Reset), .pX(pX), .pY(pY), .pS(pS), .DrawX(DrawX), .DrawY(DrawY), .dots_mask(dots_mask), .dots_left(dots_left));
random_dir rd(.Clk(Clk), .Reset(Reset), .sec(sec), .dir(gkeycode));

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

initial begin: TEST_VECTORS
#1 pS = 10'd13;
pX = 10'd90;
pY = 10'd20;

//dX[0] = 10'd90;
//dY[0] = 10'd20;
//
//#3 pS = 10'd13;
//#2 pX = 10'd80;
//#2 pY = 10'd20;
//
//for(int i = 0; i < 90; i++)
//	begin
//		#5 pX += 1;
//	end

//#2 for(int i = 0; i < 448; i++)
//	begin
//		#1 DrawY += 10'd1;
//		for(int j = 0; j < 445; j++)
//			begin
//				#1 DrawX += 10'd1;
//			end
//	
//	end


end










endmodule
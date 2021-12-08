module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;


logic Clk, Reset;
logic [9:0] pX, pY, pS;
logic [9:0] dX [0:31];
logic [9:0] dY [0:31];
logic [31:0] dots_left;

logic [9:0] redghostxsig, redghostysig, redghostsizesig;
logic lifeDown, restart;
logic [7:0] gkeycode;

logic sec;

//dots d(.Clk(Clk), .Reset(Reset), .pX(pX), .pY(pY), .pS(pS), .dX(dX), .dY(dY), .dots_left(dots_left));
redghost rg(.Clk(Clk), .sec(sec), .Reset(Reset), .frame_clk(Clk) , .redghostX(redghostxsig), .redghostY(redghostysig), .redghostS(redghostsizesig), .lifeDown(lifeDown), .restart(restart), .keycode(gkeycode), .mapL(5'b00000), .mapR(5'b00000), .mapT(5'b00000), .mapB(5'b00000));
//second_counter secc(.Clk(Clk), .Reset(Reset), .sec(sec));

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

initial begin: TEST_VECTORS
Reset = 1'b1;
#2 Reset = 1'b0;
lifeDown = 1'b0;
restart = 1'b0;

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

#200 restart = 1'b1;
#1 restart = 1'b0;


end










endmodule
module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;


logic Clk, Reset;
logic [7:0] keycode;
logic [9:0] BallX, BallY, BallS;
logic [3:0] last_dirX, last_dirY;

ball top(.Reset(Reset), .frame_clk(Clk), .keycode(keycode), .BallX(BallX), .BallY(BallY), .BallS(BallS), .last_dirX(last_dirX), .last_dirY(last_dirY));

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

initial begin: TEST_VECTORS
Reset = 1'b0;
#2 Reset = 1'b1;
#2 Reset = 1'b0;
#2 keycode = 8'h04;

end










endmodule
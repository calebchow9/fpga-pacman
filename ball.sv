//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input Reset, frame_clk,
					input [7:0] keycode,
					input mapTL, mapTR, mapBL, mapBR,
               output [9:0]  BallX, BallY, BallS,
					output [3:0] last_dirX, last_dirY
);
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 
    parameter [9:0] Ball_X_Center=202;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=253;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // left border of maze
    parameter [9:0] Ball_X_Max=404;     // right border of maze
    parameter [9:0] Ball_Y_Min=0;       // top border of maze
    parameter [9:0] Ball_Y_Max=447;     // bottom border of maze
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    assign Ball_Size = 13;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 
	 initial
		begin
			// default up mouth
			last_dirX <= 0;
			last_dirY <= 0;
		end
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
				begin 
					Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
						Ball_X_Motion <= 10'd0; //Ball_X_Step;
						Ball_Y_Pos <= Ball_Y_Center;
						Ball_X_Pos <= Ball_X_Center;
				end  
        else 
				begin
					// default, if no keys pressed then PacMan doesn't move
					Ball_Y_Motion <= 0;
					Ball_X_Motion <= 0;
					
					case (keycode)
						// LEFT
						8'h04 : begin
									Ball_Y_Motion <= 0;
									// edge check
									// left wall
									if(Ball_X_Pos - Ball_Size <= Ball_X_Min)
										begin
											Ball_X_Motion <= 0;
										end
									else
										begin
											if(mapTL == 0 && mapBL == 0)
												Ball_X_Motion <= -1;
											else
												Ball_X_Motion <= 0;
										end
								  end
						// RIGHT
						8'h07 : begin
									Ball_Y_Motion <= 0;
									// edge check
									// right wall
									if(Ball_X_Pos + Ball_Size >= Ball_X_Max)
										begin
											Ball_X_Motion <= 0;
										end
									else
										begin
											if(mapTR == 0 && mapBR == 0)
												Ball_X_Motion <= 1;
											else
												Ball_X_Motion <= 0;
										end
								  end
						// DOWN		  
						8'h16 : begin
									Ball_X_Motion <= 0;
									// edge checks
									// bottom wall
									if(Ball_Y_Pos + Ball_Size >= Ball_Y_Max)
										begin
											Ball_Y_Motion <= 0;
										end
									else
										begin
											if(mapBL == 0 && mapBR == 0)
												Ball_Y_Motion <= 1;
											else
												Ball_Y_Motion <= 0;
										end
								 end
						// UP		  
						8'h1A : begin
									Ball_X_Motion <= 0;
									// edge checks
									// top wall
									if(Ball_Y_Pos - Ball_Size <= Ball_Y_Min)
										Ball_Y_Motion <= 0;
									else
										begin
											if(mapTL == 0 && mapTR == 0)
												Ball_Y_Motion <= -1;
											else
												Ball_Y_Motion <= 0;
										end
								 end	  
						default: ;
					endcase
					
					// Update PacMan position
					 Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);
					 Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
					 
					 // wrap around cases
					 // left -> right
					 if(Ball_X_Pos <= 10 && Ball_Y_Pos >= 195 && Ball_Y_Pos <= 223)
						begin
							Ball_X_Pos <= 385;
						end
					 else if(Ball_X_Pos >= 390 && Ball_Y_Pos >= 195 && Ball_Y_Pos <= 223)
						begin
							Ball_X_Pos <= 15;
						end
					 
					 
					 // set last direction - if not moving, then don't update
					 if(Ball_X_Motion != 0 || Ball_Y_Motion != 0)
						begin
							last_dirX <= Ball_X_Motion + 2;
							last_dirY <= Ball_Y_Motion + 2;
						end
				end
			
		end  
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;


endmodule

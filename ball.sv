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
               output [9:0]  BallX, BallY, BallS );
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 logic wall;
	 
    parameter [9:0] Ball_X_Center=202;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=253;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=7;       // left border of maze
    parameter [9:0] Ball_X_Max=396;     // right border of maze
    parameter [9:0] Ball_Y_Min=7;       // top border of maze
    parameter [9:0] Ball_Y_Max=440;     // bottom border of maze
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    assign Ball_Size = 13;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
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
					case (keycode)
						// LEFT
						8'h04 : begin
										Ball_Y_Motion <= 0;
										// edge checks
										// left wall
										if(Ball_X_Pos - Ball_Size <= Ball_X_Min)
											begin
												Ball_X_Motion <= 0;
												Ball_Y_Motion <= 0;
											end
										else
											Ball_X_Motion <= -1;
										
								  end
						// RIGHT
						8'h07 : begin
									Ball_Y_Motion <= 0;
									// edge checks
									// left wall
									if(Ball_X_Pos - Ball_Size <= Ball_X_Min)
										begin
											Ball_X_Motion <= 0;
											Ball_Y_Motion <= 0;
										end
									// right wall
									else if(Ball_X_Pos + Ball_Size >= Ball_X_Max)
										begin
											Ball_X_Motion <= 0;
											Ball_Y_Motion <= 0;
										end
									// top wall
									else if(Ball_Y_Pos - Ball_Size <= Ball_Y_Min)
										begin
											Ball_Y_Motion <= 0;
										end
									else if(Ball_Y_Pos + Ball_Size >= Ball_Y_Max)
										begin
											Ball_Y_Motion <= 0;
										end
									else
										Ball_X_Motion <= 1;
								  end
						// DOWN		  
						8'h16 : begin
									Ball_X_Motion <= 0;
									// edge checks
									// left wall
									if(Ball_X_Pos - Ball_Size <= Ball_X_Min)
										begin
											Ball_X_Motion <= 0;
										end
									// right wall
									else if(Ball_X_Pos + Ball_Size >= Ball_X_Max)
										begin
											Ball_X_Motion <= 0;
										end
									// top wall
									else if(Ball_Y_Pos - Ball_Size <= Ball_Y_Min)
										begin
											Ball_X_Motion <= 0;
											Ball_Y_Motion <= 0;
										end
									else if(Ball_Y_Pos + Ball_Size >= Ball_Y_Max)
										begin
											Ball_X_Motion <= 0;
											Ball_Y_Motion <= 0;
										end
									else
										Ball_Y_Motion <= 1;
								 end
						// UP		  
						8'h1A : begin
									Ball_X_Motion <= 0;
									// edge checks
									// left wall
									if(Ball_X_Pos - Ball_Size <= Ball_X_Min)
										begin
											Ball_X_Motion <= 0;
										end
									// right wall
									else if(Ball_X_Pos + Ball_Size >= Ball_X_Max)
										begin
											Ball_X_Motion <= 0;
										end
									// top wall
									else if(Ball_Y_Pos - Ball_Size <= Ball_Y_Min)
										begin
											Ball_X_Motion <= 0;
											Ball_Y_Motion <= 0;
										end
									else if(Ball_Y_Pos + Ball_Size >= Ball_Y_Max)
										begin
											Ball_X_Motion <= 0;
											Ball_Y_Motion <= 0;
										end
									else
										Ball_Y_Motion <= -1;
								 end	  
						default: ;
					endcase
					
					 Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
					 Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
				end
			
		end  
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
    

endmodule

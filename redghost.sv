//-------------------------------------------------------------------------
//    redghost.sv                                                            --
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


module  redghost ( input Reset, frame_clk,
					input [7:0] keycode,
               output [9:0]  redghostX, redghostY, redghostS,
					output logic last_dirX, last_dirY
);
    
    logic [9:0] redghost_X_Pos, redghost_X_Motion, redghost_Y_Pos, redghost_Y_Motion, redghost_Size;
	 
    parameter [9:0] redghost_X_Center=50;  // Center position on the X axis
    parameter [9:0] redghost_Y_Center=50;  // Center position on the Y axis
    parameter [9:0] redghost_X_Min=7;       // left border of maze
    parameter [9:0] redghost_X_Max=396;     // right border of maze
    parameter [9:0] redghost_Y_Min=7;       // top border of maze
    parameter [9:0] redghost_Y_Max=440;     // bottom border of maze
    parameter [9:0] redghost_X_Step=1;      // Step size on the X axis
    parameter [9:0] redghost_Y_Step=1;      // Step size on the Y axis

    assign redghost_Size = 10;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_redghost
        if (Reset)  // Asynchronous Reset
				begin 
					redghost_Y_Motion <= 10'd0; //redghost_Y_Step;
						redghost_X_Motion <= 10'd0; //redghost_X_Step;
						redghost_Y_Pos <= redghost_Y_Center;
						redghost_X_Pos <= redghost_X_Center;
				end  
        else 
				begin
					// default, if no keys pressed then PacMan doesn't move
					redghost_Y_Motion <= 0;
					redghost_X_Motion <= 0;
					
					case (keycode)
						// LEFT
						8'h04 : begin
									redghost_Y_Motion <= 0;
									// edge check
									// left wall
									if(redghost_X_Pos - redghost_Size <= redghost_X_Min)
										begin
											redghost_X_Motion <= 0;
											redghost_Y_Motion <= 0;
										end
									else
										redghost_X_Motion <= -1;
										
								  end
						// RIGHT
						8'h07 : begin
									redghost_Y_Motion <= 0;
									// edge check
									// right wall
									if(redghost_X_Pos + redghost_Size >= redghost_X_Max)
										begin
											redghost_X_Motion <= 0;
											redghost_Y_Motion <= 0;
										end
									else
										redghost_X_Motion <= 1;
								  end
						// DOWN		  
						8'h16 : begin
									redghost_X_Motion <= 0;
									// edge checks
									// bottom wall
									if(redghost_Y_Pos + redghost_Size >= redghost_Y_Max)
										begin
											redghost_X_Motion <= 0;
											redghost_Y_Motion <= 0;
										end
									else
										redghost_Y_Motion <= 1;
								 end
						// UP		  
						8'h1A : begin
									redghost_X_Motion <= 0;
									// edge checks
									// top wall
									if(redghost_Y_Pos - redghost_Size <= redghost_Y_Min)
										redghost_Y_Motion <= 0;
									else
										redghost_Y_Motion <= -1;
								 end	  
						default: ;
					endcase
					
					// Update red ghost position
					 redghost_Y_Pos <= (redghost_Y_Pos + redghost_Y_Motion);
					 redghost_X_Pos <= (redghost_X_Pos + redghost_X_Motion);
					 
				end
			
		end  
       
    assign redghostX = redghost_X_Pos;
   
    assign redghostY = redghost_Y_Pos;
   
    assign redghostS = redghost_Size;


endmodule

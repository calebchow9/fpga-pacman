module  orangeghost ( input Clk, Reset, frame_clk, restart, sec,
						 input [4:0] mapL, mapR, mapB, mapT,
						 input [7:0] randomkeycode,
               output logic [9:0]  orangeghostX, orangeghostY, orangeghostS
);
    
    logic [9:0] orangeghost_X_Pos, orangeghost_X_Motion, orangeghost_Y_Pos, orangeghost_Y_Motion, orangeghost_Size;
	 
    parameter [9:0] orangeghost_X_Center=264;  // Center position on the X axis
    parameter [9:0] orangeghost_Y_Center=166;  // Center position on the Y axis
    parameter [9:0] orangeghost_X_Min=7;       // left border of maze
    parameter [9:0] orangeghost_X_Max=396;     // right border of maze
    parameter [9:0] orangeghost_Y_Min=7;       // top border of maze
    parameter [9:0] orangeghost_Y_Max=440;     // bottom border of maze
    parameter [9:0] orangeghost_X_Step=1;      // Step size on the X axis
    parameter [9:0] orangeghost_Y_Step=1;      // Step size on the Y axis

    assign orangeghost_Size = 13;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_orangeghost
        if (Reset)  // Asynchronous Reset
				begin 
					orangeghost_Y_Motion <= 10'd0; //orangeghost_Y_Step;
					orangeghost_X_Motion <= 10'd0; //orangeghost_X_Step;
					orangeghost_Y_Pos <= orangeghost_Y_Center;
					orangeghost_X_Pos <= orangeghost_X_Center;
				end 
		  else if (restart)
				begin 
					orangeghost_Y_Motion <= 10'd0; //orangeghost_Y_Step;
					orangeghost_X_Motion <= 10'd0; //orangeghost_X_Step;
					orangeghost_Y_Pos <= orangeghost_Y_Center;
					orangeghost_X_Pos <= orangeghost_X_Center;
				end 
        else 
				begin
					case (randomkeycode)
						// LEFT
						8'h1A : begin
									orangeghost_Y_Motion <= 0;
									// edge check
									// left wall
									if(orangeghost_X_Pos - orangeghost_Size <= orangeghost_X_Min)
										begin
											orangeghost_X_Motion <= 0;
										end
									else
										begin
											if(mapL == 0)
												orangeghost_X_Motion <= -1;
											else
												orangeghost_X_Motion <= 0;
										end
										
								  end
						// RIGHT
						8'h04 : begin
									orangeghost_Y_Motion <= 0;
									// edge check
									// right wall
									if(orangeghost_X_Pos + orangeghost_Size >= orangeghost_X_Max)
										begin
											orangeghost_X_Motion <= 0;
										end
									else
										begin
											if(mapR == 0)
												orangeghost_X_Motion <= 1;
											else
												orangeghost_X_Motion <= 0;
										end
								  end
						// DOWN		  
						8'h07 : begin
									orangeghost_X_Motion <= 0;
									// edge checks
									// bottom wall
									if(orangeghost_Y_Pos + orangeghost_Size >= orangeghost_Y_Max)
										begin
											orangeghost_Y_Motion <= 0;
										end
									else
										begin
											if(mapB == 0)
												orangeghost_Y_Motion <= 1;
											else
												orangeghost_Y_Motion <= 0;
										end
								 end
						// UP		  
						8'h16 : begin
									orangeghost_X_Motion <= 0;
									// edge checks
									// top wall
									if(orangeghost_Y_Pos - orangeghost_Size <= orangeghost_Y_Min)
										orangeghost_Y_Motion <= 0;
									else
										begin
											if(mapT == 0)
												orangeghost_Y_Motion <= -1;
											else
												orangeghost_Y_Motion <= 0;
										end
								 end	  
						default: ;
					endcase
					
					// Update red ghost position
					 orangeghost_Y_Pos <= (orangeghost_Y_Pos + orangeghost_Y_Motion);
					 orangeghost_X_Pos <= (orangeghost_X_Pos + orangeghost_X_Motion);
					 
					 // wrap around cases
					 // left -> right
					 if(orangeghost_X_Pos <= 10 && orangeghost_Y_Pos >= 195 && orangeghost_Y_Pos <= 223)
						begin
							orangeghost_X_Pos <= 385;
						end
					 else if(orangeghost_X_Pos >= 390 && orangeghost_Y_Pos >= 195 && orangeghost_Y_Pos <= 223)
						begin
							orangeghost_X_Pos <= 15;
						end
					 
				end
			
		end  
       
    assign orangeghostX = orangeghost_X_Pos;
   
    assign orangeghostY = orangeghost_Y_Pos;
   
    assign orangeghostS = orangeghost_Size;


endmodule

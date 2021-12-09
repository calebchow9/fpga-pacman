module  blueghost ( input Clk, Reset, frame_clk, pause, sec,
						 input [4:0] mapL, mapR, mapB, mapT,
						 input [7:0] randomkeycode,
               output logic [9:0]  blueghostX, blueghostY, blueghostS
);
    
    logic [9:0] blueghost_X_Pos, blueghost_X_Motion, blueghost_Y_Pos, blueghost_Y_Motion, blueghost_Size;
	 
    parameter [9:0] blueghost_X_Center=204;  // Center position on the X axis
    parameter [9:0] blueghost_Y_Center=80;  // Center position on the Y axis
    parameter [9:0] blueghost_X_Min=7;       // left border of maze
    parameter [9:0] blueghost_X_Max=396;     // right border of maze
    parameter [9:0] blueghost_Y_Min=7;       // top border of maze
    parameter [9:0] blueghost_Y_Max=440;     // bottom border of maze
    parameter [9:0] blueghost_X_Step=1;      // Step size on the X axis
    parameter [9:0] blueghost_Y_Step=1;      // Step size on the Y axis

    assign blueghost_Size = 13;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_blueghost
        if (Reset)  // Asynchronous Reset
				begin 
					blueghost_Y_Motion <= 10'd0; //blueghost_Y_Step;
					blueghost_X_Motion <= 10'd0; //blueghost_X_Step;
					blueghost_Y_Pos <= blueghost_Y_Center;
					blueghost_X_Pos <= blueghost_X_Center;
				end 
		  else if (pause)
				begin 
					blueghost_Y_Motion <= 10'd0; //blueghost_Y_Step;
					blueghost_X_Motion <= 10'd0; //blueghost_X_Step;
				end 
        else 
				begin
					case (randomkeycode)
						// LEFT
						8'h07 : begin
									blueghost_Y_Motion <= 0;
									// edge check
									// left wall
									if(blueghost_X_Pos - blueghost_Size <= blueghost_X_Min)
										begin
											blueghost_X_Motion <= 0;
										end
									else
										begin
											if(mapL == 0)
												blueghost_X_Motion <= -1;
											else
												blueghost_X_Motion <= 0;
										end
										
								  end
						// RIGHT
						8'h16: begin
									blueghost_Y_Motion <= 0;
									// edge check
									// right wall
									if(blueghost_X_Pos + blueghost_Size >= blueghost_X_Max)
										begin
											blueghost_X_Motion <= 0;
										end
									else
										begin
											if(mapR == 0)
												blueghost_X_Motion <= 1;
											else
												blueghost_X_Motion <= 0;
										end
								  end
						// DOWN		  
						8'h1A : begin
									blueghost_X_Motion <= 0;
									// edge checks
									// bottom wall
									if(blueghost_Y_Pos + blueghost_Size >= blueghost_Y_Max)
										begin
											blueghost_Y_Motion <= 0;
										end
									else
										begin
											if(mapB == 0)
												blueghost_Y_Motion <= 1;
											else
												blueghost_Y_Motion <= 0;
										end
								 end
						// UP		  
						8'h04 : begin
									blueghost_X_Motion <= 0;
									// edge checks
									// top wall
									if(blueghost_Y_Pos - blueghost_Size <= blueghost_Y_Min)
										blueghost_Y_Motion <= 0;
									else
										begin
											if(mapT == 0)
												blueghost_Y_Motion <= -1;
											else
												blueghost_Y_Motion <= 0;
										end
								 end	  
						default: ;
					endcase
					
					// Update red ghost position
					 blueghost_Y_Pos <= (blueghost_Y_Pos + blueghost_Y_Motion);
					 blueghost_X_Pos <= (blueghost_X_Pos + blueghost_X_Motion);
					 
					 // wrap around cases
					 // left -> right
					 if(blueghost_X_Pos <= 10 && blueghost_Y_Pos >= 195 && blueghost_Y_Pos <= 223)
						begin
							blueghost_X_Pos <= 385;
						end
					 else if(blueghost_X_Pos >= 390 && blueghost_Y_Pos >= 195 && blueghost_Y_Pos <= 223)
						begin
							blueghost_X_Pos <= 15;
						end
					 
				end
			
		end  
       
    assign blueghostX = blueghost_X_Pos;
   
    assign blueghostY = blueghost_Y_Pos;
   
    assign blueghostS = blueghost_Size;


endmodule

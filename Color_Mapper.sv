//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

module  color_mapper ( input        [9:0] BallX, BallY, DrawX, DrawY, Ball_size,
								input blank,
								input logic [23:0] data_out,
							  output logic	[18:0] addr,
                       output logic [7:0]  Red, Green, Blue );
    
    logic ball_on;
	  
    int DistX, DistY, Size;
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
	 
	 logic [23:0] hex_color;
	 logic mask;
	 
    always_comb
    begin:Ball_on_proc
        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 

	 map_mask(.x(DrawX), .y(DrawY), .mask(mask));
		 
    always_comb
    begin:RGB_Display
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
		if(blank == 0)
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
		else
			begin
				 // draw PacMan
//				if(DrawX < 300 && DrawY < 328)
//					begin
					  if ((ball_on == 1'b1)) 
					  begin 
							Red = 8'hff;
							Green = 8'h55;
							Blue = 8'h00;
					  end
				 // draw background maze
					  else if((mask == 1'b1))
					  begin 
							Red = 8'h00; 
							Green = 8'h00;
							Blue = 8'hff;
						end
//					end
			end
    end 
    
endmodule

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
								input logic blank, Clk, VGA_Clk,
								input logic [23:0] data_out,
							  output logic	[18:0] addr,
                       output logic [7:0]  Red, Green, Blue );
    
    logic ball_on;
	  
    int DistX, DistY, Size;

	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;

	 // MAP SIZE: x: 405, y: 448
	 logic map_mask;
	 
	 // font logic
	 logic [7:0] font_data_out;
	 logic [7:0] font_read_addr;
	 logic text_mask;
	 logic [10:0] sprite_addr;
	 logic [7:0] sprite_data;
	 logic [9:0] font_y;
	 
	 // modules here
	 score_ram sr(.data_In(), .write_address(), .read_address(font_read_addr), .we(1'b0), .Clk(Clk), .data_Out(font_data_out));
	 map_mask mm(.x(DrawX), .y(DrawY), .mask(map_mask));
	 font_rom fr(.addr(sprite_addr), .data(sprite_data));
	 
    always_comb
    begin:PacMan_outline
        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end
	 
	always_comb
	begin: Text_outline
		font_y = 10'b0;
		font_read_addr = 6'b0;
		sprite_addr = 11'b0;
		text_mask = 1'b0;
		
		if(DrawY > 447)
			begin
				font_y = DrawY-447;
				// text size is 480 (width) x 32 (height)
				font_read_addr = font_y[9:4] * 80 + DrawX[9:3];
				sprite_addr = 16 * font_data_out + (DrawY[3:0]);
				if(sprite_data[7 - DrawX[2:0]] == 1'b1)
					text_mask = 1'b1;
			end
	end
		 
    always_ff @(posedge VGA_Clk)
    begin:RGB_Display
		Red <= 8'h00;
		Green <= 8'h00;
		Blue <= 8'h00;
		if(blank == 0)
			begin
				Red <= 8'h00;
				Green <= 8'h00;
				Blue <= 8'h00;
			end
		else
			begin
				if(DrawX > 404)
					begin
						Red <= 8'h00;
						Green <= 8'h00;
						Blue <= 8'h00;
					end
				else
					begin
					// draw PacMan
					if ((ball_on == 1'b1)) 
						begin 
							Red <= 8'hff;
							Green <= 8'hff;
							Blue <= 8'h00;
						end
					else if ((text_mask == 1'b1))
						begin
							Red <= 8'hff;
							Green <= 8'hff;
							Blue <= 8'hff;
						end
					// draw background maze
					else if((map_mask == 1'b1))
						begin 
							Red <= 8'h47; 
							Green <= 8'hb7;
							Blue <= 8'hae;
						end
					end
			end
    end 
    
endmodule

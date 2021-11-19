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
							  input 			[9:0] redghostX, redghostY, redghost_size,
								input logic blank, Clk, VGA_Clk,
								input logic [3:0] l_dirX, l_dirY,
								input logic [23:0] data_out,
							  output logic	[18:0] addr,
                       output logic [7:0]  Red, Green, Blue);
    
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
	 
	 // pacman logic
	 logic [23:0] pacman_color;
	 logic [11:0] pacman_addr;
	 
	 // items logic
	 logic [23:0] items_color;
	 logic [11:0] items_addr;
	 logic apple_mask;
	 logic peas_mask;
	 logic grapes_mask;
	 logic drink_mask;
	 
	 // redghost logic
	 logic [23:0] redghost_color;
	 logic [8:0] redghost_addr;
	 logic redghost_mask;

	 
	 // modules here
	 score_ram sr(.data_In(), .write_address(), .read_address(font_read_addr), .we(1'b0), .Clk(Clk), .data_Out(font_data_out));
	 map_mask mm(.x(DrawX), .y(DrawY), .mask(map_mask));
	 font_rom fr(.addr(sprite_addr), .data(sprite_data));
	 pacman_ram pr(.data_In(), .write_address(), .read_address(pacman_addr), .we(1'b0), .Clk(Clk), .data_Out(pacman_color));
	 items_ram ir(.data_In(), .write_address(), .read_address(items_addr), .we(1'b0), .Clk(Clk), .data_Out(items_color));
	 redghost_ram rr(.data_In(), .write_address(), .read_address(redghost_addr), .we(1'b0), .Clk(Clk), .data_Out(redghost_color));
	 
    always_comb
    begin:PacMan_outline
        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end
	  
	  always_comb
	  begin:Ghost_outline
		if(DrawX-redghostX <= redghost_size && DrawX-redghostX >= -1*redghost_size // [-10, 10]
			&& DrawY-redghostY <= redghost_size && DrawY-redghostY >= -1*redghost_size)
				redghost_mask = 1'b1;
		else
			redghost_mask = 1'b0;
	  end

	 // draw items
	 always_comb
	 begin
		if(DrawX >= 12 && DrawX <= 37 && DrawY >= 10 && DrawY <= 35)
			apple_mask = 1'b1;
		else
			apple_mask = 1'b0;

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
		
	// actually draw here. order of if statements is the priority of z-layering
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
							if(l_dirX == 0 && l_dirY == 0)
								// start, draw up mouth
								pacman_addr <= (DrawY-(BallY-Ball_size)) * 26 + DrawX-(BallX-Ball_size) + (2*676);
							if(l_dirX == 1 || l_dirX == 3)
								begin
									// right mouth
									if(l_dirX == 3)
										begin
										pacman_addr <= (DrawY-(BallY-Ball_size)) * 26 + DrawX-(BallX-Ball_size);
										end
									// left mouth
									else
										begin
										pacman_addr <= (DrawY-(BallY-Ball_size)) * 26 + DrawX-(BallX-Ball_size) + 676 + 1;
										end
								end
							if(l_dirY == 1 || l_dirY == 3)
								begin
									// down mouth
									if(l_dirY == 3)
										begin
										pacman_addr <= (DrawY-(BallY-Ball_size)) * 26 + DrawX-(BallX-Ball_size) + (3*676);
										end
									else
									// up mouth
										begin
										pacman_addr <= (DrawY-(BallY-Ball_size) - 1) * 26 + DrawX-(BallX-Ball_size) + (2*676);
										end
								end
							
							Red <= pacman_color[23:16];
							Green <= pacman_color[15:8];
							Blue <= pacman_color[7:0];
						end
					else if ((redghost_mask == 1'b1))
						begin
							redghost_addr <= (DrawY-(redghostY-redghost_size)) * 26 + DrawX-(redghostX-redghost_size);
							
							Red <= redghost_color[23:16];
							Green <= redghost_color[15:8];
							Blue <= redghost_color[7:0];
						end
					else if ((apple_mask == 1'b1))
						begin
							items_addr <= (DrawY-10) * 26 + (DrawX-12);
							
							Red <= items_color[23:16];
							Green <= items_color[15:8];
							Blue <= items_color[7:0];
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

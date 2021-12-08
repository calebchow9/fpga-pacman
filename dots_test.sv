module dots_test(input Clk, Reset, 
					  input [9:0] pX, pY,pS, DrawX, DrawY,

					  output logic dots_mask, 
					  output logic [31:0] dots_left);
					  
	logic [9:0] dX [0:31];
	logic [9:0] dY [0:31];
	dots d(.Clk(Clk), .Reset(Reset), .pX(pX), .pY(pY), .pS(pS), .dX(dX), .dY(dY), .dots_left(dots_left));
	
	logic [7:0] Red, Green, Blue;
	
	 // draw dots
	always_comb
	begin
		dots_mask = 1'b0;
		for(int dots_i = 0; dots_i < 32; dots_i++)
			begin
				if(DrawX <= dX[dots_i] + 5 && DrawX >= dX[dots_i] && 
					DrawY <= dY[dots_i] + 5 && DrawY >= dY[dots_i] && dots_left[dots_i] == 1'b0)
					begin
						if((DrawX == dX[dots_i] && DrawY == dY[dots_i]) || // top left
						   (DrawX == dX[dots_i] + 5 && DrawY == dY[dots_i]) || // top right
							(DrawX == dX[dots_i] && DrawY == dY[dots_i] + 5) || // bottom left
							(DrawX == dX[dots_i] + 5 && DrawY == dY[dots_i] + 5)) // bottom right
							dots_mask = 1'b0;
						else
							dots_mask = 1'b1;					
					end
			end
	end
	
	always_comb
	begin
		if ((dots_mask == 1'b1))
			begin
			Red <= 8'hff;
			Green <= 8'hff;
			Blue <= 8'h00;
			end
		else
			begin
			Red <= 8'h00;
			Green <= 8'h00;
			Blue <= 8'h00;
			end
	end
					  
					  
endmodule
module dot(input [9:0] x, y, pX, pY,
			  input Clk, Reset,

			  output logic eaten
);
			  
	logic Load_D, data_to_load;
			  
	dot_reg dr(.Clk(Clk), .Reset(Reset), .Load(Load_D), .Data_in(data_to_load), .Data_out(eaten));
	
	always_comb
	begin
		if(x == pX && y == pY)
			begin
				//PacMan hit dot -> remove
				data_to_load = 1'b1;
				Load_D = 1'b1;
			end
		else
			begin
				data_to_load = eaten;
				Load_D = 1'b0;
			end
	end	  
endmodule

module dots(input Clk, Reset,
				input [9:0] pX, pY,
				
				output logic [9:0] dX [0:31],
				output logic [9:0] dY [0:31],
				output logic [31:0] dots_left
);
	// 4 4 4 2 2 2 2 4 4 4
	assign dX = '{
		10'd90,    
		10'd175,
		10'd220,
		10'd302,
		// first row
		10'd18,
		10'd85,
		10'd302,
		10'd375,
		// second row
		10'd18,
		10'd135,
		10'd258,
		10'd375,
		// third row
		10'd90,
		10'd307,
		10'd90,
		10'd307,
		10'd90,
		10'd307,
		10'd90,
		10'd307,
		// third last row
		10'd18,
		10'd135,
		10'd292,
		10'd375,
		// second last row
		10'd68,
		10'd135,
		10'd258,
		10'd376,
		// last row
		10'd85,    
		10'd175,
		10'd220,
		10'd302
	};
	
	assign dY = '{
		10'd20,
		10'd20,
		10'd20,
		10'd20,
		// first row
		10'd48,
		10'd48,
		10'd48,
		10'd48,
		// second row
		10'd120,
		10'd120,
		10'd120,
		10'd120,
		// third row
		10'd148,
		10'd148,
		10'd186,
		10'd186,
		10'd228,
		10'd228,
		10'd258,
		10'd258,
		// third last row
		10'd292,
		10'd292,
		10'd292,
		10'd292,
		// second last row
		10'd380,
		10'd380,
		10'd380,
		10'd380,
		// last row
		10'd421,
		10'd421,
		10'd421,
		10'd421
	};

	dot d0(.Clk(Clk), .Reset(Reset), .x(dX[0]), .y(dY[0]), .pX(pX), .pY(pY), .eaten(dots_left[0]));
	dot d1(.Clk(Clk), .Reset(Reset), .x(dX[1]), .y(dY[1]), .pX(pX), .pY(pY), .eaten(dots_left[1]));
	dot d2(.Clk(Clk), .Reset(Reset), .x(dX[2]), .y(dY[2]), .pX(pX), .pY(pY), .eaten(dots_left[2]));
	dot d3(.Clk(Clk), .Reset(Reset), .x(dX[3]), .y(dY[3]), .pX(pX), .pY(pY), .eaten(dots_left[3]));
	dot d4(.Clk(Clk), .Reset(Reset), .x(dX[4]), .y(dY[4]), .pX(pX), .pY(pY), .eaten(dots_left[4]));
	dot d5(.Clk(Clk), .Reset(Reset), .x(dX[5]), .y(dY[5]), .pX(pX), .pY(pY), .eaten(dots_left[5]));
	dot d6(.Clk(Clk), .Reset(Reset), .x(dX[6]), .y(dY[6]), .pX(pX), .pY(pY), .eaten(dots_left[6]));
	dot d7(.Clk(Clk), .Reset(Reset), .x(dX[7]), .y(dY[7]), .pX(pX), .pY(pY), .eaten(dots_left[7]));
	dot d8(.Clk(Clk), .Reset(Reset), .x(dX[8]), .y(dY[8]), .pX(pX), .pY(pY), .eaten(dots_left[8]));
	dot d9(.Clk(Clk), .Reset(Reset), .x(dX[9]), .y(dY[9]), .pX(pX), .pY(pY), .eaten(dots_left[9]));
	dot d10(.Clk(Clk), .Reset(Reset), .x(dX[10]), .y(dY[10]), .pX(pX), .pY(pY), .eaten(dots_left[10]));
	dot d11(.Clk(Clk), .Reset(Reset), .x(dX[11]), .y(dY[11]), .pX(pX), .pY(pY), .eaten(dots_left[11]));
	dot d12(.Clk(Clk), .Reset(Reset), .x(dX[12]), .y(dY[12]), .pX(pX), .pY(pY), .eaten(dots_left[12]));
	dot d13(.Clk(Clk), .Reset(Reset), .x(dX[13]), .y(dY[13]), .pX(pX), .pY(pY), .eaten(dots_left[13]));
	dot d14(.Clk(Clk), .Reset(Reset), .x(dX[14]), .y(dY[14]), .pX(pX), .pY(pY), .eaten(dots_left[14]));
	dot d15(.Clk(Clk), .Reset(Reset), .x(dX[15]), .y(dY[15]), .pX(pX), .pY(pY), .eaten(dots_left[15]));
	dot d16(.Clk(Clk), .Reset(Reset), .x(dX[16]), .y(dY[16]), .pX(pX), .pY(pY), .eaten(dots_left[16]));
	dot d17(.Clk(Clk), .Reset(Reset), .x(dX[17]), .y(dY[17]), .pX(pX), .pY(pY), .eaten(dots_left[17]));
	dot d18(.Clk(Clk), .Reset(Reset), .x(dX[18]), .y(dY[18]), .pX(pX), .pY(pY), .eaten(dots_left[18]));
	dot d19(.Clk(Clk), .Reset(Reset), .x(dX[19]), .y(dY[19]), .pX(pX), .pY(pY), .eaten(dots_left[19]));
	dot d20(.Clk(Clk), .Reset(Reset), .x(dX[20]), .y(dY[20]), .pX(pX), .pY(pY), .eaten(dots_left[20]));
	dot d21(.Clk(Clk), .Reset(Reset), .x(dX[21]), .y(dY[21]), .pX(pX), .pY(pY), .eaten(dots_left[21]));
	dot d22(.Clk(Clk), .Reset(Reset), .x(dX[22]), .y(dY[22]), .pX(pX), .pY(pY), .eaten(dots_left[22]));
	dot d23(.Clk(Clk), .Reset(Reset), .x(dX[23]), .y(dY[23]), .pX(pX), .pY(pY), .eaten(dots_left[23]));
	dot d24(.Clk(Clk), .Reset(Reset), .x(dX[24]), .y(dY[24]), .pX(pX), .pY(pY), .eaten(dots_left[24]));
	dot d25(.Clk(Clk), .Reset(Reset), .x(dX[25]), .y(dY[25]), .pX(pX), .pY(pY), .eaten(dots_left[25]));
	dot d26(.Clk(Clk), .Reset(Reset), .x(dX[26]), .y(dY[26]), .pX(pX), .pY(pY), .eaten(dots_left[26]));
	dot d27(.Clk(Clk), .Reset(Reset), .x(dX[27]), .y(dY[27]), .pX(pX), .pY(pY), .eaten(dots_left[27]));
	dot d28(.Clk(Clk), .Reset(Reset), .x(dX[28]), .y(dY[28]), .pX(pX), .pY(pY), .eaten(dots_left[28]));
	dot d29(.Clk(Clk), .Reset(Reset), .x(dX[29]), .y(dY[29]), .pX(pX), .pY(pY), .eaten(dots_left[29]));
	dot d30(.Clk(Clk), .Reset(Reset), .x(dX[30]), .y(dY[30]), .pX(pX), .pY(pY), .eaten(dots_left[30]));
	dot d31(.Clk(Clk), .Reset(Reset), .x(dX[31]), .y(dY[31]), .pX(pX), .pY(pY), .eaten(dots_left[31]));

endmodule



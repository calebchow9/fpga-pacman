module random_dir(input Clk, Reset,
	output [7:0] dir
);
	logic Load_DR;
	logic Load_C;
	
	logic [31:0] data_to_counter;
	logic [31:0] data_from_counter;
	logic [7:0] data_to_dr;

	parameter [0:99][1:0] dirs = {
		2'd2,
		2'd3,
		2'd1,
		2'd3,
		2'd1,
		2'd3,
		2'd1,
		2'd0,
		2'd3,
		2'd0,
		2'd2,
		2'd3,
		2'd0,
		2'd3,
		2'd0,
		2'd2,
		2'd0,
		2'd0,
		2'd2,
		2'd0,
		2'd0,
		2'd1,
		2'd3,
		2'd2,
		2'd0,
		2'd3,
		2'd2,
		2'd3,
		2'd2,
		2'd1,
		2'd2,
		2'd3,
		2'd2,
		2'd0,
		2'd1,
		2'd2,
		2'd2,
		2'd1,
		2'd0,
		2'd0,
		2'd3,
		2'd1,
		2'd3,
		2'd2,
		2'd3,
		2'd2,
		2'd3,
		2'd1,
		2'd2,
		2'd1,
		2'd2,
		2'd3,
		2'd3,
		2'd2,
		2'd1,
		2'd0,
		2'd2,
		2'd2,
		2'd3,
		2'd0,
		2'd0,
		2'd1,
		2'd2,
		2'd0,
		2'd0,
		2'd2,
		2'd1,
		2'd1,
		2'd3,
		2'd3,
		2'd0,
		2'd2,
		2'd3,
		2'd2,
		2'd2,
		2'd3,
		2'd3,
		2'd1,
		2'd0,
		2'd3,
		2'd0,
		2'd2,
		2'd1,
		2'd3,
		2'd0,
		2'd3,
		2'd2,
		2'd2,
		2'd0,
		2'd3,
		2'd3,
		2'd2,
		2'd1,
		2'd2,
		2'd0,
		2'd3,
		2'd0,
		2'd2,
		2'd1,
		2'd2
	};

	dots_left_reg counter(.Clk(Clk), .Reset(Reset), .Load(Load_C), .Data_in(data_to_counter), .Data_out(data_from_counter));
	dir_reg dir_r(.Clk(Clk), .Reset(Reset), .Load(Load_DR), .Data_in(data_to_dr), .Data_out(dir));

	always_comb
	begin
		Load_DR = 1'b0;
		data_to_dr = 8'b0;
		
		if(data_from_counter % 1 == 0)
			begin
				// get random direction
				case (dirs[data_from_counter])
					2'b00: data_to_dr = 8'h04; // left
					2'b01: data_to_dr = 8'h07; // right
					2'b10: data_to_dr = 8'h16; // down
					2'b11: data_to_dr = 8'h1A; // up
				endcase
				// load into direction register
				Load_DR = 1'b1;
			end
		
		// update counter
		data_to_counter = data_from_counter + 1;
		Load_C = 1'b1;
	end


endmodule
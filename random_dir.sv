module random_dir(input Clk, Reset, sec,
	output logic [7:0] dir
);
	logic Load_DR;
	
	logic [7:0] data_to_dr;
	logic [7:0] lfsr_out;
	logic [7:0] data_from_dr;
	
	// randomized counter LFSR
	lfsr_reg lfsr(.Clk(Clk), .LFSR(lfsr_out));
	
	dir_reg dir_r(.Clk(Clk), .Reset(Reset), .Load(Load_DR), .Data_in(data_to_dr), .Data_out(data_from_dr));
	
	assign dir = data_from_dr;

	always_ff @(posedge Clk)
	begin		
		Load_DR <= 1'b0;
		data_to_dr <= 8'd0;
		if(sec == 1'b1)
			begin
				// get random direction
				case (lfsr_out[1:0])
					2'b00: data_to_dr <= 8'h04; // left
					2'b01: data_to_dr <= 8'h07; // right
					2'b10: data_to_dr <= 8'h16; // down
					2'b11: data_to_dr <= 8'h1A; // up
					default: data_to_dr <= 8'h04;
				endcase
				// load into direction register
				Load_DR <= 1'b1;
			end
	end


endmodule
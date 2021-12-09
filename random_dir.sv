module random_dir(input Clk, Reset, sec,
	output [7:0] dir1,
	output [7:0] dir2,
	output [7:0] dir3
);
	logic Load_DR;
	
	logic [7:0] data_to_dr1;
	logic [7:0] data_to_dr2;
	logic [7:0] data_to_dr3;
	logic [7:0] lfsr_out;
	logic [7:0] data_from_dr1;
	logic [7:0] data_from_dr2;
	logic [7:0] data_from_dr3;
	
	// randomized counter LFSR
	lfsr_reg lfsr(.Clk(sec), .LFSR(lfsr_out));
	
	dir_reg dir_r1(.Clk(Clk), .Reset(Reset), .Load(Load_DR), .Data_in(data_to_dr1), .Data_out(data_from_dr1));
	dir_reg dir_r2(.Clk(Clk), .Reset(Reset), .Load(Load_DR), .Data_in(data_to_dr2), .Data_out(data_from_dr2));
	dir_reg dir_r3(.Clk(Clk), .Reset(Reset), .Load(Load_DR), .Data_in(data_to_dr3), .Data_out(data_from_dr3));
	
	assign dir1 = data_from_dr1;
	assign dir2 = data_from_dr2;
	assign dir3 = data_from_dr3;

	always_ff @(posedge Clk)
	begin		
		Load_DR <= 1'b0;
		data_to_dr1 <= 8'd0;
		data_to_dr2 <= 8'd0;
		data_to_dr3 <= 8'd0;
		if(sec == 1'b1)
			begin
				// get random direction
				case (lfsr_out[1:0])
					2'b00: data_to_dr1 <= 8'h04; // left
					2'b01: data_to_dr1 <= 8'h07; // right
					2'b10: data_to_dr1 <= 8'h16; // down
					2'b11: data_to_dr1 <= 8'h1A; // up
				endcase
				
				case (lfsr_out[3:2])
					2'b00: data_to_dr2 <= 8'h04; // left
					2'b01: data_to_dr2 <= 8'h07; // right
					2'b10: data_to_dr2 <= 8'h16; // down
					2'b11: data_to_dr2 <= 8'h1A; // up
				endcase
				
				case (lfsr_out[5:4])
					2'b00: data_to_dr3 <= 8'h04; // left
					2'b01: data_to_dr3 <= 8'h07; // right
					2'b10: data_to_dr3 <= 8'h16; // down
					2'b11: data_to_dr3 <= 8'h1A; // up
				endcase
				// load into direction register
				Load_DR <= 1'b1;
			end
	end


endmodule
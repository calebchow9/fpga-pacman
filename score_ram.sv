module score_ram(
		input [9:0] score,
		input [7:0] data_In,
		input [7:0] write_address, read_address,
		input we, Clk,

		output logic [7:0] data_Out
);

	// mem has width of 3 bits and a total of 400 addresses
	logic [7:0] mem [159:0];
	
	logic [9:0] temp_score;
	logic [7:0] hundreds;
	logic [7:0] tens;
	logic [7:0] ones;

	initial
	begin
		mem[0] = 8'h53; // S
		mem[1] = 8'h63; // c
		mem[2] = 8'h6f; // o
		mem[3] = 8'h72; // r
		mem[4] = 8'h65; // e
		mem[5] = 8'h3a; // :
		mem[6] = 8'h00;
		// score number variables (default 000)
		mem[7] = 8'h30;
		mem[8] = 8'h30;
		mem[9] = 8'h30;
		mem[10] = 8'h00;
		for(int i = 11; i < 25; i+= 1)
			begin
				mem[i] = 8'h00;
			end
		mem[25] = 8'h4c; // L
		mem[26] = 8'h69; // i
		mem[27] = 8'h76; // v
		mem[28] = 8'h65; // e
		mem[29] = 8'h73; // s
		mem[30] = 8'h3a; // :
		mem[31] = 8'h00;
		// lives number variable (default 2)
		mem[32] = 8'h32;
		
		for(int j = 33; j < 160; j+= 1)
			begin
				mem[j] = 8'h00;
			end
	end
	
	// set new score
	always_comb
		begin
			temp_score = score;
			ones <= temp_score % 10;
			temp_score /= 10;
			tens <= temp_score % 10;
			temp_score /= 10;
			hundreds <= temp_score % 10;
		end

	always_ff @ (posedge Clk) begin
		if (we)
			mem[write_address] <= data_In;
		data_Out<= mem[read_address];
		
		// display score
		mem[7] <= 8'h30 + hundreds;
		mem[8] <= 8'h30 + tens;
		mem[9] <= 8'h30 + ones;
	end

endmodule
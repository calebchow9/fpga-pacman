module score_ram(
		input [9:0] score,
		input [31:0] counter,
		input [7:0] lives,
		input [7:0] data_In,
		input [7:0] write_address, read_address,
		input win, lose,
		input we, Clk,

		output logic [7:0] data_Out
);

	// mem has width of 3 bits and a total of 400 addresses
	logic [7:0] mem [159:0];
	
	logic [9:0] temp_score;
	logic [7:0] hundreds;
	logic [7:0] tens;
	logic [7:0] ones;
	
	logic [63:0] temp_counter;
	logic [7:0] chundreds;
	logic [7:0] ctens;
	logic [7:0] cones;
	
	// set new score/counter
	always_comb
		begin
			temp_score = score;
			ones <= temp_score % 10;
			temp_score /= 10;
			tens <= temp_score % 10;
			temp_score /= 10;
			hundreds <= temp_score % 10;
			
			temp_counter = counter;
			cones <= temp_counter % 10;
			temp_counter /= 10;
			ctens <= temp_counter % 10;
			temp_counter /= 10;
			chundreds <= temp_counter % 10;
		end

	always_ff @ (posedge Clk) begin
		if (we)
			mem[write_address] <= data_In;
		data_Out<= mem[read_address];
		
		mem[0] <= 8'h53; // S
		mem[1] <= 8'h63; // c
		mem[2] <= 8'h6f; // o
		mem[3] <= 8'h72; // r
		mem[4] <= 8'h65; // e
		mem[5] <= 8'h3a; // :
		mem[6] <= 8'h00;
		
		// display score
		mem[7] <= 8'h30 + hundreds;
		mem[8] <= 8'h30 + tens;
		mem[9] <= 8'h30 + ones;
		
		mem[10] <= 8'h00;
		for(int i = 11; i < 25; i+= 1)
			begin
				mem[i] <= 8'h00;
			end
		
		mem[25] <= 8'h4c; // L
		mem[26] <= 8'h69; // i
		mem[27] <= 8'h76; // v
		mem[28] <= 8'h65; // e
		mem[29] <= 8'h73; // s
		mem[30] <= 8'h3a; // :
		mem[31] <= 8'h00;
		
		// display lives
		mem[32] <= 8'h33 - lives;
		
		for(int j = 33; j < 80; j+= 1)
			begin
				mem[j] <= 8'h00;
			end
		
		mem[80] <= 8'h54; // T
		mem[81] <= 8'h69; // i
		mem[82] <= 8'h6d; // m
		mem[83] <= 8'h65; // e
		mem[84] <= 8'h72; // r
		mem[85] <= 8'h3a; // :
		mem[86] <= 8'h00;
		
		// display timer
		mem[87] <= 8'h30 + chundreds;
		mem[88] <= 8'h30 + ctens;
		mem[89] <= 8'h30 + cones;
		
		for (int k = 90; k < 105; k++)
			begin
				mem[k] <= 8'h00;
			end
			
		mem[105] <= 8'h53; // S
		mem[106] <= 8'h74; // t
		mem[107] <= 8'h61; // a
		mem[108] <= 8'h74; // t
		mem[109] <= 8'h75; // u
		mem[110] <= 8'h73; // s
		mem[111] <= 8'h3a; // :
		mem[112] <= 8'h00;
		
		if(win || lose)
			begin
				mem[113] <= 8'h47; // G
				mem[114] <= 8'h61; // a
				mem[115] <= 8'h6d; // m
				mem[116] <= 8'h65; // e
				mem[117] <= 8'h00; 
			end
		else
			begin
				mem[113] <= 8'h50; // P
				mem[114] <= 8'h6c; // l
				mem[115] <= 8'h61; // a
				mem[116] <= 8'h79; // y
				mem[117] <= 8'h21; // !
			end
		
		if(win)
			begin
				mem[118] <= 8'h57; // W
				mem[119] <= 8'h6f; // o
				mem[120] <= 8'h6e; // n
				mem[121] <= 8'h00;  
			end
		else if (lose)
			begin
				mem[118] <= 8'h4f; // O
				mem[119] <= 8'h76; // v
				mem[120] <= 8'h65; // e
				mem[121] <= 8'h72; // r
			end
		else
			begin
				mem[118] <= 8'h00;
				mem[119] <= 8'h00;
				mem[120] <= 8'h00;
				mem[121] <= 8'h00;
			end
		
		for(int l = 122; l < 160; l++)
			begin
				mem[l] = 8'h00;
			end
		
	end

endmodule
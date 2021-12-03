module score_reg (input Clk, Reset, Load,
					input [9:0] Data_in,
					output logic [9:0] Data_out
);

			always_ff @(posedge Clk)
			begin
				if(Reset)
					Data_out <= 10'b0000000000;
				else if(Load)
					Data_out <= Data_in;

			end
					
endmodule
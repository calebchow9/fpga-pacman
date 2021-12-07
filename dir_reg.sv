module dir_reg (input Clk, Reset, Load,
					input [7:0] Data_in,
					output logic [7:0] Data_out
);

			always_ff @(posedge Clk)
			begin
				if(Reset)
					Data_out <= 8'b0;
				else if(Load)
					Data_out <= Data_in;

			end
					
endmodule
module dot_reg (input Clk, Reset, Load,
					input Data_in,
					output logic Data_out
);

			always_ff @(posedge Clk)
			begin
				if(Reset)
					Data_out <= 1'b0;
				else if(Load)
					Data_out <= Data_in;

			end
					
endmodule
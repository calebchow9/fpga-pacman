module fruits_reg (input Clk, Reset, Load,
					input [3:0] Data_in,
					output logic [3:0] Data_out
);

			always_ff @(posedge Clk)
			begin
				if(Reset)
					Data_out <= 4'b0000;
				else if(Load)
					Data_out <= Data_in;

			end
					
endmodule
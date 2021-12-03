module dot_reg (input Clk, Reset, Load,
					input [31:0] Data_in,
					output logic [31:0] Data_out
);

			always_ff @(posedge Clk)
			begin
				if(Reset)
					Data_out <= 32'b0;
				else if(Load)
					Data_out <= Data_in;
			end
					
endmodule
module second_counter (input Clk, Reset, 
							  output logic sec, 
							  output logic [31:0] counter_out
);
	
	logic Load_C;
	logic [31:0] counter_to_reg, counter_from_reg;
	logic dot_to_reg, dot_from_reg;
	reg [25:0] accum = 0;
	wire pps = (accum == 0);
	
	initial
		begin
			  dot_to_reg = 1'b1;
		end

	counter_reg cr(.Clk(Clk), .Reset(Reset), .Load(Load_C), .Data_in(counter_to_reg), .Data_out(counter_from_reg));
	
	assign counter_out = counter_from_reg;

	always @(posedge Clk) begin
		Load_C <= 1'b0;
		sec <= 1'b0;
		accum <= (pps ? 50_000_000 : accum) - 1;

		 // on each second:
		 if (pps) begin
			  sec <= 1'b1;
			  
			  if(counter_from_reg == 32'd0)
					counter_to_reg <= 32'd0;
			  else
					counter_to_reg <= counter_from_reg - 32'd1;
			  Load_C <= 1'b1;
		 end
	end

endmodule
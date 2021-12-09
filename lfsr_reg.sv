module lfsr_reg(
  input Clk,
  output [7:0] LFSR
);

logic [7:0] temp = 8'd55;
wire feedback = LFSR[7];

always @(posedge Clk)
begin
  temp[0] <= feedback;
  temp[1] <= temp[0];
  temp[2] <= temp[1] ^ feedback;
  temp[3] <= temp[2] ^ feedback;
  temp[4] <= temp[3] ^ feedback;
  temp[5] <= temp[4];
  temp[6] <= temp[5];
  temp[7] <= temp[6];
end

assign LFSR = temp;

endmodule
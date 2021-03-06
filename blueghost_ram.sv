/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  blueghost_ram
(
		input [23:0] data_In,
		input [9:0] write_address, read_address,
		input we, Clk,

		output logic [23:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [23:0] mem [0:675];

initial
begin
	$readmemh("C:/Users/caleb/Desktop/fpga-pacman/blueghost.txt", mem);
end

always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule
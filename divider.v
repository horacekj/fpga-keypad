/* Simple clock divider
 * This code is taken from https://github.com/hxing9974/Verilog-Design-of-a-Keypad-Reader/blob/master/simulation.v
 */
 
module clock_divider (reset, clock_in, clock_out);
	parameter input_hz = 50000;
	parameter output_hz = 1;
	parameter in_out_ratio = input_hz / output_hz; // can process upmost 2^20 = 1048576 ratio

	input clock_in, reset;
	output clock_out;
	reg clock_out;
	reg [19:0] internal_count;

	always @(posedge clock_in or posedge reset) begin
		if (reset) begin
			internal_count <= 'b0;
			clock_out <= 1'b0;
		end
		else if (internal_count == (in_out_ratio - 1)) begin
			internal_count <= 20'b0;
			clock_out <= 1'b1; // time to shoot a rising edge
		end
		else if (internal_count == (in_out_ratio/2 - 1)) begin
			clock_out <= 1'b0; 	// holding time passed
			internal_count <= internal_count + 1;
		end
		else begin
			internal_count <= internal_count + 1;
		end
	end
endmodule
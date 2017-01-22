/* Simple keypad reader with segment display output.
 * This code demonstrates reading data from keypad. It
 * shows numbers 0-9 and characters A-D on a segment display.
 * "*" or "#" clears the output.
 * Creatd by Jan Horacek 2016 as project for PB170 course at FI MUNI.
 * This code assumes keypad connected to GPIO with pull-up resistors.
 */
 
module keyboard(
	LEDR,
	GPIO_1,
	CLOCK_50,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7
);

// Keypad Reading

input CLOCK_50;
output [15:0] LEDR;
inout [7:0] GPIO_1;
reg reset = 1;
wire myclock;

// Custom clock @ 1 kHz
clock_divider cd (reset, CLOCK_50, myclock);

reg [3:0] GOUT = 4'bzzzz;	// GPIO outputs
reg [15:0] OUT;				// LED outputs
reg [7:0] index;				// index of read row
reg [1:0] status;				// 0 = preparing to read a row, 1 = reading row, 2 = end of read
reg new_key;					// turned on when new key is read; automatically turned off
reg [3:0] new_key_char;		// index of new key

assign GPIO_1 = { GOUT, 4'bzzzz };  // GPIO_1 used bidirectional
assign LEDR[15:0] = OUT;				// only some LEDs are used to show pushed buttons

// Reset
always@(posedge CLOCK_50) begin
	if (reset)
		reset = 1'b0;
end

/* Custom clocks at 1 kHz.
 * This "loop" scans keypad horizontally, each line in every
 * cycle. Each line scan is divided into 3 patrs:
 *  1) Set current line output to 0 (groud).
 *  2) Read inputs.
 *  3) Set current line output to 1 (VCC).
 */
always@(posedge myclock) begin
	if (status == 0) begin
		// set current line output to 0 (ground)
		GOUT[index] <= 0;
		status <= 1;		
	end else if (status == 1) begin
	
		// detect key press		
		if ((!GPIO_1[0]) && (OUT[4*index] != !GPIO_1[0])) begin
			new_key_char <= 4*index;
			new_key <= 1;
		end
		if ((!GPIO_1[1]) && (OUT[4*index+1] != !GPIO_1[1])) begin
			new_key_char <= 4*index+1;
			new_key <= 1;
		end
		if ((!GPIO_1[2]) && (OUT[4*index+2] != !GPIO_1[2])) begin
			new_key_char <= 4*index+2;
			new_key <= 1;
		end
		if ((!GPIO_1[3]) && (OUT[4*index+3] != !GPIO_1[3])) begin
			new_key_char <= 4*index+3;
			new_key <= 1;
		end
		
		// change state of LEDs
		OUT[4*index] <= !GPIO_1[0];
		OUT[4*index+1] <= !GPIO_1[1];
		OUT[4*index+2] <= !GPIO_1[2];
		OUT[4*index+3] <= !GPIO_1[3];
		status <= 2;
	end else begin
		// set all line outputs to high impedance (do not set to VCC here!)
		GOUT <= 4'bzzzz;
		
		if (index < 3)
			// keypad not yet scanned -> scan new line
			index <= index + 1;
		else
			// whole keypad scanned -> new scan
			index <= 0;
			
		status <= 0;
		new_key <= 0;	// reset key press flag
	end;
end

// ----------------------------------------------------------------------------
// Segment Display

output [6:0] HEX0;
output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;
output [6:0] HEX4;
output [6:0] HEX5;
output [6:0] HEX6;
output [6:0] HEX7;

reg [6:0] hex0 = 127;
reg [6:0] hex1 = 127;
reg [6:0] hex2 = 127;
reg [6:0] hex3 = 127;
reg [6:0] hex4 = 127;
reg [6:0] hex5 = 127;
reg [6:0] hex6 = 127;
reg [6:0] hex7 = 127;

assign HEX0 = hex0;
assign HEX1 = hex1;
assign HEX2 = hex2;
assign HEX3 = hex3;
assign HEX4 = hex4;
assign HEX5 = hex5;
assign HEX6 = hex6;
assign HEX7 = hex7;

/* Insert new char at the end of display
 * and push all the other characters left.
 * This block is run when "new_key" flag is set (<=> new key was just pressed).
 */
always@(posedge new_key) begin
	// Push characters left.
	hex7 <= hex6;
	hex6 <= hex5;
	hex5 <= hex4;
	hex4 <= hex3;
	hex3 <= hex2;
	hex2 <= hex1;
	hex1 <= hex0;

	// Show a new character.
	case (new_key_char) 
		 0 : hex0 <= ~7'b0000110; // 1
		 1 : hex0 <= ~7'b1011011; // 2
		 2 : hex0 <= ~7'b1001111; // 3
		 3 : hex0 <= ~7'b1110111; // A
		 4 : hex0 <= ~7'b1100110; // 4
		 5 : hex0 <= ~7'b1101101; // 5
		 6 : hex0 <= ~7'b1111101; // 6
		 7 : hex0 <= ~7'b1111100; // b
		 8 : hex0 <= ~7'b0000111; // 7
		 9 : hex0 <= ~7'b1111111; // 8
		10 : hex0 <= ~7'b1101111; // 9
		11 : hex0 <= ~7'b0111001; // C
		13 : hex0 <= ~7'b0111111; // 0
		15 : hex0 <= ~7'b1011110; // d
		default : begin
			hex0 <= 127;
			hex1 <= 127;
			hex2 <= 127;
			hex3 <= 127;
			hex4 <= 127;
			hex5 <= 127;
			hex6 <= 127;
			hex7 <= 127;
		end
	endcase
end

endmodule
`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:49:18 11/18/2010
// Design Name:   dev
// Module Name:   C:/work/bsv/mag/hard/net_sig_proc/dev_tb.v
// Project Name:  net_sig_proc
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dev
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dev_tb;

	// Inputs
	reg CLK;
	reg BTN_SOUTH;
	reg BTN_EAST;
	reg AD_DOUT;

	// Outputs
	wire [7:0] LED;
	wire AMP_CS;
	wire SPI_SCK;
	wire SPI_MOSI;
	wire AD_CONV;

	// Instantiate the Unit Under Test (UUT)
	dev uut (
		.CLK(CLK), 
		.BTN_SOUTH(BTN_SOUTH), 
		.BTN_EAST(BTN_EAST), 
		.LED(LED), 
		.AMP_CS(AMP_CS), 
		.SPI_SCK(SPI_SCK), 
		.SPI_MOSI(SPI_MOSI), 
		.AD_DOUT(AD_DOUT), 
		.AD_CONV(AD_CONV)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;
		BTN_SOUTH = 0;
		BTN_EAST = 1;
		AD_DOUT = 1;

		// Wait 100 ns for global reset to finish
		#100;
        BTN_EAST = 0;
        #20
        BTN_SOUTH = 1;
        #50
        BTN_SOUTH = 0;
	end
    
    always #10 CLK = ~CLK;
      
endmodule


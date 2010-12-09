`timescale 1ns / 1ps

module adc_tb;

	// Inputs
	reg clk;
	reg conv;
	reg reset;
	reg adc_out;

	// Outputs
	wire end_conv;
	wire [13:0] ch0_out;
	wire [13:0] ch1_out;
	wire ad_conv;
	wire spi_sck;

	// Instantiate the Unit Under Test (UUT)
	adc uut (
		.clk(clk), 
		.conv(conv), 
		.reset(reset), 
		.end_conv(end_conv), 
		.ch0_out(ch0_out), 
		.ch1_out(ch1_out), 
		.adc_out(adc_out), 
		.ad_conv(ad_conv), 
		.spi_sck(spi_sck)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		conv = 0;
		reset = 1;
		adc_out = 1;
        
		// Wait 100 ns for global reset to finish
		#20;
        reset = 0;
        #100
        conv = 1;
        #720
        adc_out = 0;    

	end
    
    always #10 clk = ~clk;
      
endmodule


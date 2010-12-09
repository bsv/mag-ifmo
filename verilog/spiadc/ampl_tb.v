`timescale 1ns / 1ps

module ampl_tb;

	// Inputs
	reg clk;
	reg reset;
	reg load;
	reg [7:0] data;

	// Outputs
	wire load_ok;
	wire amp_cs;
	wire spi_sck;
	wire spi_mosi;

	// Instantiate the Unit Under Test (UUT)
	ampl uut (
		.clk(clk), 
		.reset(reset), 
		.load(load), 
		.data(data), 
		.load_ok(load_ok), 
		.amp_cs(amp_cs), 
		.spi_sck(spi_sck), 
		.spi_mosi(spi_mosi)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		load = 0;
		data = 0;

		// Wait 100 ns for global reset to finish
		#20;
        reset = 0;
        #20
        data = 8'hA4;
        load = 1;
        #100
        load =  1;
        #20
        load = 0;
		// Add stimulus here

	end
    
    always #50 clk = ~clk;
      
endmodule


`timescale 1ns / 1ps

module glitch_free 
#(parameter SIZE_REG_DELAY = 22
)
(
    input wire clk, 
    input wire in, 
    
    output wire out
);

    reg [SIZE_REG_DELAY-1:0] sw_cnt;
    wire sw_on = &sw_cnt;
    
    assign out = sw_on;
    
    always @(posedge clk)
        if (~in) 
            sw_cnt <= 0;
        else 
            sw_cnt <= (sw_on) ? sw_cnt : sw_cnt + 1'b1;
    
endmodule

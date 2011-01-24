`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:51:30 12/17/2010 
// Design Name: 
// Module Name:    rotor 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module rotor(
    input wire clk,  // 50 MHz
    input wire reset,
    input ROT_A,
    input ROT_B,
    
    output reg [7:0] out
);

    localparam SIZE_REG_DELAY = 12;
    
    wire rot_a_free;
    wire rot_b_free;
    
    glitch_free #(.SIZE_REG_DELAY(SIZE_REG_DELAY)) rotAFree (
        .clk(clk),
        .in(ROT_A),
        .out(rot_a_free)
    );
    
    glitch_free #(.SIZE_REG_DELAY(SIZE_REG_DELAY)) rotBFree (
        .clk(clk),
        .in(ROT_B),
        .out(rot_b_free)
    );
        
    reg [3:0] sig;
    reg [7:0] out_next;
   
    always@(posedge clk, posedge reset)
        if(reset)
            begin
                sig <= 0;
                out <= 0;
            end
        else    
            begin
                sig <= {sig[2], rot_a_free, sig[0], rot_b_free};
                out <= out_next;
            end

    wire left = sig[1] & sig[0] & ~sig[3] & sig[2];
    wire right = sig[3] & sig[2] & ~sig[1] & sig[0];
    
    always@*
        begin
            out_next = out;
            if(right)
                out_next = out + 1;
            
            if(left)
                out_next = out - 1;
        end
endmodule

`timescale 1ns / 1ps

module m_counter
#(
    parameter N = 4, // number of bits in counter
              M = 10 // mod-M
)
(
    input wire clk, reset,
    output wire max_tick,
    output wire [N-1:0] q
);
    reg [N-1:0] r_reg;
    wire [N-1:0] r_next;
    
    assign r_next = (r_reg == (M-1))? 0 : r_reg + 1;
    assign max_tick = (r_reg == (M-1))? 1 : 0;
    assign q = r_reg;
    
    always@(posedge clk, posedge reset)
        if(reset)
            r_reg <= 0;
        else
            r_reg <= r_next;

endmodule
`timescale 1ns / 1ps

module mod_m_counter
#(
    parameter N = 4, // number of bits in counter
              M = 10 // mod-M
)
(
    input wire clk, reset,
    output reg max_tick
);
    reg [N-1:0] r_reg;
    wire [N-1:0] r_next;
    
    assign r_next = (r_reg == (M-1))? 0 : r_reg + 1;
    
    always@(posedge clk, posedge reset)
        if(reset)
            begin 
                r_reg <= 0;
                max_tick <= 0;
            end
        else
            begin
                r_reg <= r_next;
                if(r_next == 0)
                    max_tick <= ~max_tick;
            end

endmodule
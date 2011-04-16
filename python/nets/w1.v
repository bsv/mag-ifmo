module w1 (
    input wire [1:0] addr,
    output wire [13:0] out_weight
);
    wire [13:0] w [3:0];
    
    assign out_weight = w[addr];
    assign w[0] = 7708;
    assign w[1] = 14811;
    assign w[2] = 441;
    assign w[3] = 597;
endmodule 

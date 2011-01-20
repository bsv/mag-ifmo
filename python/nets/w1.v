module w1 (
    input wire [0:0] addr,
    output wire [12:0] out_weight
);
    wire [12:0] w [1:0];
    
    assign out_weight = w[addr];
    assign w[0] = 6033;
    assign w[1] = 5831;
endmodule 

module w0 (
    input wire [0:0] addr,
    output wire [12:0] out_weight
);
    wire [12:0] w [1:0];
    
    assign out_weight = w[addr];
    assign w[0] = 4690;
    assign w[1] = 4712;
endmodule 

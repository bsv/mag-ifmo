module w0 (
    input wire [1:0] addr,
    output wire [13:0] out_weight
);
    wire [13:0] w [3:0];
    
    assign out_weight = w[addr];
    assign w[0] = 4963;
    assign w[1] = 12994;
    assign w[2] = 225;
    assign w[3] = 348;
endmodule 

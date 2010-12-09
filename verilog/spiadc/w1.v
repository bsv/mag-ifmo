module w1 (
    input wire [3:0] addr,
    output wire [7:0] out_weight
);
    wire [7:0] w [15:0];
    
    assign out_weight = w[addr];
    assign w[0] = 177;
    assign w[1] = 215;
    assign w[2] = 233;
    assign w[3] = 138;
    assign w[4] = 183;
    assign w[5] = 221;
    assign w[6] = 238;
    assign w[7] = 137;
    assign w[8] = 184;
    assign w[9] = 221;
    assign w[10] = 238;
    assign w[11] = 138;
    assign w[12] = 184;
    assign w[13] = 221;
    assign w[14] = 210;
    assign w[15] = 99;
endmodule 

module w0 (
    input wire [3:0] addr,
    output wire [7:0] out_weight
);
    wire [7:0] w [15:0];
    
    assign out_weight = w[addr];
    assign w[0] = 3;
    assign w[1] = 4;
    assign w[2] = 5;
    assign w[3] = 3;
    assign w[4] = 3;
    assign w[5] = 4;
    assign w[6] = 4;
    assign w[7] = 3;
    assign w[8] = 3;
    assign w[9] = 4;
    assign w[10] = 5;
    assign w[11] = 3;
    assign w[12] = 3;
    assign w[13] = 4;
    assign w[14] = 7;
    assign w[15] = 10;
endmodule 

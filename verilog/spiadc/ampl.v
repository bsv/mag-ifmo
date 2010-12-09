`timescale 1ns / 1ps
module ampl(
    input wire clk,
    input wire reset,
    input wire load,
    input wire [7:0] data,
    
    output reg load_ok,
    
    //fpga
    output reg amp_cs,
    output wire spi_sck,
    output reg spi_mosi
);
    assign spi_sck = clk;
    reg [7:0] data_reg;
    reg [2:0] data_ctr;
    
    reg amp_cs_next, load_ok_next;
    
    wire [2:0] data_ctr_next = (!amp_cs)? data_ctr - 1: data_ctr;
        
    always@(negedge spi_sck, posedge reset)
        if(reset)
            begin
                amp_cs   = 1;
                data_ctr = 7;
                spi_mosi = 0;
                load_ok  = 0;
            end
        else
            begin
                amp_cs   = amp_cs_next;
                data_ctr = data_ctr_next;
                spi_mosi = data_reg[data_ctr];
                load_ok  = load_ok_next;
            end

     always@*
     begin
        //amp_cs_next = amp_cs;
        load_ok_next = load_ok;
        
        if(load)
            begin
                amp_cs_next = 0;
                data_reg = data;
                load_ok_next = 0;
            end
        if(data_ctr == 0)
            begin
                load_ok_next = 1;
                amp_cs_next = 1;
            end
     end
            
endmodule

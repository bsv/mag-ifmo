`timescale 1ns / 1ps

module adc
(
    input wire clk,
    input wire conv,
    input wire reset,
    
    output reg end_conv,
    output reg [13:0] ch0_out,
    output reg [13:0] ch1_out,
    
    // fpga
    input wire adc_out, 
    
    output reg ad_conv,
    output wire spi_sck
);

    localparam 
        IDLE      = 0,
        DATA      = 1,
        END_CONV  = 2;

    reg [2:0] state, state_next;
    reg [5:0] cycle_ctr;
    reg ad_conv_next, end_conv_next;
    
    reg [13:0] ch0_out_next, ch1_out_next;
    
    assign spi_sck = ((state == DATA) && !ad_conv)? clk: 0;
    
    always@(negedge clk, posedge reset)
        if(reset) 
            begin
                state <= IDLE;
                ad_conv <= 0;
                cycle_ctr <= 0;
                ch0_out <= 0;
                ch1_out <= 0;
                end_conv <= 0;
            end
        else 
            begin
                state    <= state_next;
                end_conv <= end_conv_next;
                ad_conv  <= ad_conv_next;
                ch0_out  <= ch0_out_next;
                ch1_out  <= ch1_out_next;
            end
            
    always@(posedge spi_sck, posedge ad_conv)
        if(ad_conv)
            cycle_ctr <= 0;
        else
            if(cycle_ctr == 33)
                cycle_ctr <= 0;
            else
                cycle_ctr <= cycle_ctr + 1;
            
                
    always@*
    begin
        state_next = state;
        end_conv_next = end_conv;
        ad_conv_next = ad_conv;
		ch0_out_next = ch0_out;
		ch1_out_next = ch1_out;
        case(state)
            IDLE: 
                begin
                    end_conv_next = 0;
                    if(conv)
                        begin
                            ad_conv_next = 1;
                            state_next = DATA;
                        end
                end
            DATA:
                begin 
                    ad_conv_next = 0;
                    if(cycle_ctr > 2 && cycle_ctr < 17)
                        ch0_out_next = (ch0_out << 1) | adc_out;
                    else if(cycle_ctr > 18 && cycle_ctr < 33)
                        ch1_out_next = (ch1_out << 1) | adc_out;
                    else if(cycle_ctr == 33)
                        begin
                            end_conv_next = 1;    
                            state_next = IDLE;  
                        end
                end
            default: state_next = IDLE;
        endcase
    end

endmodule

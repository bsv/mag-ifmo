`timescale 1ns / 1ps

module dev(
    // fpga
    input wire CLK,    

    // fpga i/o
    input  wire BTN_SOUTH,
    input  wire BTN_EAST,
    
    output wire [7:0] LED,

    // fpga amp
    input wire AMP_DOUT,
    
    output wire AMP_CS,
    output wire SPI_SCK,
    output wire AMP_SHDN,
    output wire SPI_MOSI,
    
    // fpga adc
    input  wire AD_DOUT,
    
    output wire AD_CONV,
    
    //fpga UART
    input wire RS232_DTE_RXD,
    output wire RS232_DTE_TXD,
	 
	 //fpga J18 connector 1 pin
	 output wire RFID_CLK
);

    reg r_data, w_data, r_data_next, w_data_next;
    reg [7:0] data_out;
    wire [7:0] data_in;
    wire data_empty, data_full;
    
    wire tx;
    assign AMP_SHDN = 0;
    wire rx = RS232_DTE_RXD;
    assign RS232_DTE_TXD = tx;

    wire reset = BTN_EAST;
    wire start = BTN_SOUTH;
    
    reg amp_load, amp_load_next;
    reg [7:0] amp_data, amp_data_next;
    wire amp_load_ok;
    
    reg adc_conv, adc_conv_next;
    wire adc_end_conv;
    wire [13:0] adc_ch0_out, adc_ch1_out;
    wire adc_spi_clk, amp_spi_clk;
    wire net_ready, net_out_data;
    wire net_step;
    reg [7:0] net_data_in;
    
    net 
    #(
        .NUM_IN(16),
        .ADDR_SIZE(4),
        .DATA_SIZE(8)
    ) net_unit (
        .clk(CLK),
        .reset(reset),
        .adc_int(adc_end_conv), // !!!!
        .in_data(net_data_in),
        
        .ready(net_ready),
        .step(net_step),
        .out_data(net_out_data)
    );
	 
	 // 125 ���
	 mod_m_counter #(
        .M(200), 
        .N(8)  
    ) rfid_clk_unit
    (
        .clk(CLK),
        .reset(reset),
        .max_tick(RFID_CLK)
    );

    mod_m_counter #(
        .M(3), // ����� �� 6 �������� ������
        .N(2)  // ���-�� ��� ��� �������� 
    ) amp_clk_unit
    (
        .clk(CLK),
        .reset(reset),
        .max_tick(amp_clk)
    );
    
    mod_m_counter #(
        .M(367), // 50���/2/2000���/34 = 367 --- 2kHz
        .N(9)  
    ) adc_clk_unit
    (
        .clk(CLK),
        .reset(reset),
        .max_tick(adc_clk)
    );
    
    ampl amp_unit(
        .clk(amp_clk),
        .reset(reset),
        .load(amp_load),
        .data(amp_data),
    
        .load_ok(amp_load_ok),
    
        //fpga
        .amp_cs(AMP_CS),
        .spi_sck(amp_spi_clk),
        .spi_mosi(SPI_MOSI)
    );
    
    adc adc_unit
    (
        .clk(adc_clk),
        .conv(adc_conv),
        .reset(reset),
        
        .end_conv(adc_end_conv),
        .ch0_out(adc_ch0_out),
        .ch1_out(adc_ch1_out),
    
        // fpga
        .adc_out(AD_DOUT), 
    
        .ad_conv(AD_CONV),
        .spi_sck(adc_spi_clk)
    );
    
    uart #(
        // 57600 baud, 8 data bits, 1 stop bit, 2^2 FIFO
        .DBIT(8),       // # data bits
        .SB_TICK(16),   // # ticks for stop bits,
                        // 16/24/32 for 1/1.5/2 bits
        .DVSR(54),      // baud rate divisor 
                        // 163 aey 19200
                        // 24.4 aey 128000
                        // 54.2 aey 57600!!!
                        // DVSR = 50M/(16*baud rate)
        .DVSR_BIT(8),   // # bits of DVSR
        .FIFO_W(2))     // #addr bits of FIFO
                        // # words in FIFO = 2^FIFO_W
    uart_unit(
        .clk(CLK),
        .reset(reset),
        .rd_uart(r_data), 
        .wr_uart(w_data), 
        .rx(rx), 
        .w_data(data_out), 
        .tx_full(data_full), 
        .rx_empty(data_empty), 
        .tx(tx), 
        .r_data(data_in)
    );
   
    
    localparam 
        IDLE   = 0,
        AMP    = 1,
        ADC    = 2,
        ADC_WAIT = 3,
        SAVE    = 4,
		WAIT    = 5;
        
    reg [2:0] state, state_next;
    
    assign SPI_SCK = (state == IDLE)? 0:
                     (state == ADC_WAIT)? adc_spi_clk : amp_spi_clk; 
                     
    assign LED[2:0] = state;
    assign LED[3] = data_full;
    assign LED[4] = data_empty;
    assign LED[7:5] = 0;
    
    always@(posedge CLK, posedge reset)
        if(reset)
            begin
                state    <= IDLE;
                amp_load <= 0;
                amp_data <= 0;
                adc_conv <= 0;
                
                w_data <= 0;
                r_data <= 0;
            end
        else
            begin
                amp_data <= amp_data_next;
                amp_load <= amp_load_next;
                adc_conv <= adc_conv_next;
                state    <= state_next;
                
                r_data <= r_data_next;
                w_data <= w_data_next;
            end
    
    /*always@(negedge SPI_SCK, posedge reset)
        if(reset)
            data_out = 0;
        else if(state == ADC)
        begin
            data_out = (data_out << 1) | AMP_DOUT;
        end*/
		  
	 reg save = 0;
    reg [13:0] ch0_data;
    
    always@*
    begin
        state_next = state;
        amp_load_next = amp_load;
        amp_data_next = amp_data;
        adc_conv_next = adc_conv;
        
        r_data_next = r_data;
        w_data_next = w_data;
        
        case(state)
            IDLE:
            begin
                w_data_next = 0;
                if(start)
                    begin
                        amp_data_next = 8'h01; // -1 - range from 0.4 to 2.9 (Vin A)
                        amp_load_next = 1;
                        state_next = AMP;
                    end
                   
            end
            AMP: 
                begin
                    amp_load_next = 0;
                    if (!AMP_CS)
                        begin
                            state_next = ADC;
                        end
                end
            ADC:
                if(amp_load_ok)
                    begin
                        adc_conv_next = 1;
                        state_next = ADC_WAIT;
                    end
            ADC_WAIT:
                begin
                    w_data_next = 0;
                    if(adc_end_conv)
                        begin
                            save = 0; 
                            ch0_data = adc_ch0_out;
                            state_next = SAVE;
                        end
                end
            SAVE:
                begin
                    if(!data_full)
                        begin
                            state_next = WAIT;
                            w_data_next = 1;
                            if(!save)
                                begin
                                    data_out = {2'h0, ch0_data[13:8]};
                                end
                            else
                                begin
                                    data_out = ch0_data[7:0];
                                end
                        end
                end
			   WAIT:
					begin
                        w_data_next = 0;
						if(!save)
							begin
								save = 1;
								state_next = SAVE;
						   end
						 else if(!adc_end_conv)
							begin
								state_next = ADC_WAIT;
							end
                    end
            default: state_next = IDLE;
        endcase
    end
    

endmodule

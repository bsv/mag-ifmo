module uart_rx 
#(
    parameter DBIT = 8,     // биты данных
              SB_TICK = 16  // количество тиков в одном периоде передачи бита
                            // чтение происходит в середине периода
)
(
    input wire clk, reset,
    input wire rx, s_tick,
    output reg rx_done_tick,
    output wire [7:0] dout
);
    // перечень состояний автомата
    localparam [1:0] 
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;
        
    reg [1:0] state_reg, state_next;// регистр состояния автомата
    reg [3:0] s_reg, s_next;        // счетчик тиков синхронизации
    reg [2:0] n_reg, n_next;        // счетчик принятых битов данных
    reg [7:0] b_reg, b_next;        // сдвиговый регистр для приема данных  
    
    assign dout = b_reg;
    
    always@(posedge clk, posedge reset)
        if(reset)
            begin
                state_reg <= IDLE;
                s_reg <= 0;
                n_reg <= 0;
                b_reg <= 0;
            end
        else
            begin
                state_reg <= state_next;
                s_reg <= s_next;
                n_reg <= n_next;
                b_reg <= b_next;
            end
    
    always@*
    begin
        state_next = state_reg;
        rx_done_tick = 0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        case(state_reg)
            IDLE :
                if(~rx)
                    begin
                        state_next = 1;
                        s_next = 0;
                    end
            START:
                if(s_tick)
                    if(s_reg == (SB_TICK/2 - 1))   // начинаем считывание с середины периода передачи одного бита             
                        begin
                            state_next = DATA;
                            s_next = 0;
                            n_next = 0;
                        end
                    else
                        s_next = s_reg + 1;
            DATA :
                if(s_tick)
                    if(s_reg == (SB_TICK - 1))  
                        begin
                            s_next = 0;
                            b_next = {rx, b_reg[7:1]};
                            if(n_reg == (DBIT - 1))
                                state_next = STOP;
                            else
                                n_next = n_reg + 1;
                        end
                    else
                        s_next = s_reg + 1;
            STOP :
                if(s_tick)
                    if(s_reg == (SB_TICK - 1))
                        begin
                            state_next = IDLE;
                            rx_done_tick = 1;
                        end
                    else
                        s_next = s_reg + 1;
        endcase
    end
    
endmodule

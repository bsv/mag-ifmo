module net 
#(parameter
    NUM_IN = 16,
    ADDR_SIZE = 4,
    DATA_SIZE = 8
)
(
    input clk,
    input reset,
    input adc_int,
    input [DATA_SIZE-1:0] in_data,
    
    output reg ready,
    output reg step,
    output reg out_data
);

    localparam 
        IDLE  = 0,
        DIST  = 1,
        CMP   = 2;
        
    reg [2:0] state, state_next;
    reg [ADDR_SIZE-1:0] addr, addr_next;
    reg out_data_next;
    reg ready_next, step_next;
    
    reg [DATA_SIZE-1:0] x_data;
    
    reg [2*DATA_SIZE-1:0] manh1, manh2;
    reg [2*DATA_SIZE-1:0] manh1_next, manh2_next;
    wire [DATA_SIZE:0] dist1, dist2;
    wire [DATA_SIZE-1:0] w1, w2;
    
    assign dist1 = x_data - w1;
    assign dist2 = x_data - w2; 
    

    w0 w0_mem(
        .addr(addr),
        .out_weight(w1)
    );
    
    w1 w1_mem(
        .addr(addr),
        .out_weight(w2)
    );
    
    reg run, run_next;

    always@(posedge clk, posedge reset, posedge adc_int)
        if(reset)
            begin
                ready    <= 0;
                state    <= IDLE;
                out_data <= 0;
                step     <= 0;
                addr     <= 0;
                run      <= 0;
                manh1    <= 0;
                manh2    <= 0;
            end
        else if(adc_int)
            run <= 1;
        else if(clk)
            begin
                state    <= state_next;
                ready    <= ready_next;
                out_data <= out_data_next;
                step     <= step_next;
                addr     <= addr_next;
                run      <= run_next;
                manh1 <= manh1_next;
                manh2 <= manh2_next;
            end

    // Логика
    always@*
    begin
        state_next = state;
        out_data_next = out_data;
        ready_next = ready;
        step_next = step;
        addr_next = addr;
        run_next = run;
        manh1_next = manh1;
        manh2_next = manh2;
        case(state)
            IDLE: 
                if(run)
                    begin
                        ready_next = 0;
                        step_next = 0;
                        x_data = in_data;
                        state_next = DIST;
                    end
            DIST: 
                begin
                    manh1_next = (dist1[DATA_SIZE] == 1'b1)? ~dist1 + 1 + manh1: dist1 + manh1;
                    manh2_next = (dist2[DATA_SIZE] == 1'b1)? ~dist2 + 1 + manh1: dist2 + manh2;  
                    run_next = 0;
                    step_next = 1; // Может не нужно?
                    
                    if(addr == NUM_IN-1)
                        begin
                            state_next = CMP;
                            addr_next = 0;
                        end
                    else
                        begin
                            state_next = IDLE;
                            addr_next = addr + 1;
                        end
                end
            CMP:
                begin
                    out_data_next = ({1'b0, manh2} - {1'b0, manh1}) >> (2*DATA_SIZE-1);
                    ready_next = 1;
                    manh1_next = 0;
                    manh2_next = 0;
                    state_next = IDLE;
                end
        endcase
    end

endmodule

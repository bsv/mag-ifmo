`timescale 1ns / 1ps

`define READ_COM        0
`define WRITE_COM       2
`define ERASE_BLOCK_COM 6

`define NOCOM 0
`define READ  1
`define WRITE 2
`define ERASE 3

module mem(
	input wire clk, // 40 ns - 25 Mhz
	input wire reset,

    input wire run,
	input wire [1:0] com, // 0 - nocom, 1 - read, 2 - write, 3 - erase 
	
	input wire [21:0] addr,	
	inout [15:0] data,
	
	output reg gl_endop,
    output wire [15:0] data_test,
	
	//fpga
	
	input wire NF_STS, //status
	
	inout [14:1] NF_D,
	inout SPI_MISO,
	
	output reg [21:1] NF_A,
	inout NF_A0,

	output reg NF_CE,
	output reg NF_OE,
	output reg NF_WE,
	
	output wire NF_BYTE,
	output wire NF_RP,
	output wire NF_WP
    
);

    // Регистры атомата циклов чтения и записи
	reg [2:0] state, state_next;
	reg [15:0] data_reg, data_next;
	reg cs_next, out_en_next, write_en_next;
	reg status, status_next;
    reg out_data, out_data_next;
    
    assign data_test = data_reg;
    
    localparam 
        IDLE = 0,
		ENABLE_READ = 1,
		BYTE_READ   = 2,
		DATA_READ   = 3,
		END_READ    = 4,
		DATA_WRITE  = 5,
		END_WRITE   = 6,
        START_WRITE = 7;
    //===========================
    
    // Регистры автомата управления чтением и записью
    reg [2:0] gl_state, gl_state_next;
    reg [15:0] gl_data, gl_data_next;
    reg [21:0] gl_addr, gl_addr_next;
    reg gl_read, gl_write, gl_read_next, gl_write_next;
    reg gl_endop_next;
    reg [2:0] com_ctr, com_ctr_next;
    reg [7:0] addr_com_mem, addr_com_mem_next;
    wire [21:0] com_addr;
    wire [15:0] com_data;
	 
    localparam
        START = 1,
        WORK  = 2;
    //===========================

	assign NF_RP   = 1; // Flash active
	assign NF_WP   = 1; // Hardware protection disabled
	assign NF_BYTE = 0; // 8 bit data
	
	assign data = (gl_endop)? data_reg: 16'hz;
	
	assign NF_A0 = gl_addr[0];

	assign NF_D = (out_data)? data_reg[15:1]: 15'hz;
	assign SPI_MISO = (out_data)? data_reg[0]: 1'bz;
	
	always@(negedge clk, posedge reset)
		if(reset)
			begin
				NF_CE <= 1;
				NF_OE <= 1;
				NF_WE <= 1;
				NF_A  <= 0;
				data_reg <= 0;
				state <= IDLE;
				status <= 0;
                out_data <= 0;
			end
		else if(!clk)
			begin
                out_data <= out_data_next;
				data_reg <= data_next;
				NF_A <= gl_addr[21:1];
				NF_CE <= cs_next;
				NF_OE <= out_en_next;
				NF_WE <= write_en_next;
				state <= state_next;
				status <= status_next;
			end
			
	always@*
		begin
			data_next = data_reg;
			cs_next = NF_CE;
			out_en_next = NF_OE;
			write_en_next = NF_WE;
			status_next = status;
            out_data_next = out_data;
			
			case(state)
				IDLE:
					begin
                        status_next = 0;
                        
						if(gl_read)
							begin
								//BYTE = 1;
								state_next = ENABLE_READ;
							end
						else if(gl_write)
							begin
								data_next = gl_data;
                                out_data_next = 1;
								
								state_next = START_WRITE;
							end
					end
                START_WRITE:
                    begin
                        cs_next = 0;
                        write_en_next = 0;
                        state_next = DATA_WRITE;
                    end
				DATA_WRITE:
					begin
                        cs_next = 1;
						write_en_next = 1;
                        out_data_next = 0;
                        status_next = 1;
						state_next = IDLE;
					end
				ENABLE_READ:
					begin
						cs_next = 0;
                        out_en_next = 0;
                        //BYTE = 0;
						state_next = DATA_READ;
					end
				DATA_READ:
					begin
						data_next = {NF_A0, NF_D, SPI_MISO};
                        cs_next = 1;
						status_next = 1;
						out_en_next = 1;
						state_next = IDLE;
					end
				default: state_next = IDLE;
			endcase
		end
    
    always@(posedge clk, posedge reset)
        if(reset)
            begin
                gl_state <= IDLE;
                gl_data  <= 0;
                gl_addr  <= 0;
                gl_write <= 0;
                gl_read  <= 0;
                gl_endop <= 0;
                com_ctr  <= 0;
                addr_com_mem <= 0;
            end
        else
            begin
                gl_state <= gl_state_next;
                gl_data  <= gl_data_next;
                gl_addr  <= gl_addr_next;
                gl_write <= gl_write_next;
                gl_read  <= gl_read_next;
                gl_endop <= gl_endop_next;
                com_ctr  <= com_ctr_next;
                addr_com_mem <= addr_com_mem_next;
            end

    always@*
        begin
            gl_state_next = gl_state;
            gl_data_next  = gl_data;
            gl_addr_next  = gl_addr;
            gl_write_next = gl_write;
            gl_read_next  = gl_read;
            gl_endop_next = gl_endop;
            com_ctr_next  = com_ctr;
            addr_com_mem_next = addr_com_mem;
            
            case(gl_state)
                IDLE:
                    begin
                        gl_endop_next = 0;
                        com_ctr_next = 0;

                        if(run)
                            begin
                                gl_state_next = START;
                                case(com)
                                    `READ:
                                        begin 
                                            com_ctr_next = 2;
                                            addr_com_mem_next = `READ_COM; // READ_RESET 1
                                        end
                                    `WRITE:
                                        begin
                                            com_ctr_next = 4;
                                            addr_com_mem_next = `WRITE_COM; // PROGRAM 1
                                        end
                                    `ERASE:
                                        begin
                                            com_ctr_next = 6;
                                            addr_com_mem_next = `ERASE_BLOCK_COM;
                                        end
                                    default: gl_state_next = IDLE;
                                endcase
                            end
                    end
                START:
                    begin
                        gl_addr_next = com_addr;
                        gl_data_next = com_data; 
                        gl_write_next = 1;
                        addr_com_mem_next = addr_com_mem + 1;
                        com_ctr_next = com_ctr - 1;
                        gl_state_next = WORK;
                    end
                WORK:
                    begin
                        gl_write_next = 0;
                        gl_read_next  = 0;
                        if(status)
                            if(com_ctr == 0)
                                begin
                                    gl_endop_next = 1;
                                    gl_state_next = IDLE;
                                end
                            else
                                begin
                                    case(com_addr)
                                        22'hBA: gl_addr_next = addr;
                                        default: gl_addr_next = com_addr;
                                    endcase

                                    case(com_data)
                                        0: gl_read_next = 1;
                                        16'hBD: 
                                            begin
                                                gl_data_next = data;
                                                gl_write_next = 1;
                                            end
                                        default:
                                            begin
                                                gl_data_next = com_data;
                                                gl_write_next = 1;
                                            end                              
                                    endcase
                                    com_ctr_next = com_ctr - 1;
                                    addr_com_mem_next = addr_com_mem + 1;
                                end
                    end
            endcase
        end
        
        mem_command mcom(addr_com_mem, com_addr, com_data);

endmodule

module mem_command(
    input wire  [7:0] addr,
    output reg [21:0] addr_out,
    output reg [15:0] data_out
);

    always@(addr)
        begin
            case(addr)
                0: //READ_RESET 1 = READ_COM
                    begin
                        addr_out = 0;
                        data_out = 16'hF0;
                    end
                1: // READ_RESET 2 
                    begin
                        addr_out = 22'hBA;
                        data_out = 0;
                    end
                2: // PROGRAM 1 = WRITE_COM
                    begin
                        addr_out = 22'hAAA;
                        data_out = 16'hAA;
                    end
                3: // PROGRAM 2
                    begin
                        addr_out = 22'h555;
                        data_out = 16'h55;
                    end
                4: // PROGRAM 3
                    begin
                        addr_out = 22'hAAA;
                        data_out = 16'hA0;
                    end
                5: // PROGRAM 4
                    begin
                        addr_out = 22'hBA;
                        data_out = 16'hBD;
                    end
                6: // BLOCK ERASE 1
                    begin
                        addr_out = 22'hAAA;
                        data_out = 16'hAA;
                    end
                7: // BLOCK ERASE 2
                    begin
                        addr_out = 22'h555;
                        data_out = 16'h55;
                    end
                8: // BLOCK ERASE 3
                    begin
                        addr_out = 22'hAAA;
                        data_out = 16'h80;
                    end
                9: // BLOCK ERASE 4
                    begin
                        addr_out = 22'hAAA;
                        data_out = 16'hAA;
                    end
                10: // BLOCK ERASE 5
                    begin
                        addr_out = 22'h555;
                        data_out = 16'h55;
                    end
                11: // BLOCK ERASE 6
                    begin
                        addr_out = 22'hBA;
                        data_out = 16'h30;
                    end
                default: 
                    begin
                        addr_out = 0;
                        data_out = 16'hFFFF;
                    end
            endcase
        end
    
endmodule



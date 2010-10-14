.include "m8def.inc"

    .def tmp = r15
    .def acc = r16 ; �����������
    .def timer_ctr = R17
    .def S = R0
    .def push_SPL = R4
    .def push_SPH = R5
    .def Flag_R = R25 ;0 ���, ������� Rfid �������
    .def bitcnt = R20
    .def	system	  	=R18
    .def	command 	=R19
    .def paket_byte1 = r1
    .def paket_byte2 = r2
    .def paket_byte3 = r3
    .def paket_byte4 = r6
    .def	parity		=R21
    

; �������=============================================
    ; �������� ����� � ����
    .macro outi
        ldi acc, @1
        out @0, acc
    .endmacro

.CSEG
; Interrupt service vectors
.org 0
;
	rjmp	RESET		;
	rjmp	EXT_INT0 	;
	rjmp	EXT_INT1 	;
	rjmp	TIMER2_COMP	;
	rjmp	TIMER2_OVF	;
	rjmp	TIMER1_CAPT	;
	rjmp	TIMER1_COMPA	;
	rjmp	TIMER1_COMPB	;
	rjmp	TIMER1_OVF	;
	rjmp	TIMER0_OVF	;
	rjmp	SPI_STC 		; 
	rjmp	USART_RXC 	;
	rjmp	USART_DRE 	; 
	rjmp	USART_TXC 	; 
	rjmp	ADC_INT 		;
	rjmp	EE_RDY		;
	rjmp	ANA_COMP 	;
	rjmp	TWI		;
	rjmp	SPM_RDY	;
;
;====================================================================
;
EXT_INT0:
	RETI
EXT_INT1:
	RETI
;TIMER2_COMP:
;	RETI
TIMER2_OVF:
	RETI
TIMER1_CAPT:
	RETI
TIMER1_COMPA:
	RETI
TIMER1_COMPB:
	RETI
TIMER1_OVF:
	RETI
TIMER0_OVF:
	RETI
SPI_STC:
	RETI
USART_RXC:
	RETI
USART_DRE:
	RETI
USART_TXC:
	RETI
;ADC_INT:
;	RETI
EE_RDY:
	RETI
ANA_COMP:
	RETI
TWI:
	RETI
SPM_RDY:
	RETI
;===================================================
RESET:
;�������������� ����
    outi SPL,low(RAMEND)
    outi SPH, high(RAMEND)

;����������� �����
    
    ;PORTB ����� � 0
    outi ddrb,  0xFF
    outi portb, 0x00
    
    ;PORTC ����� � 0
    outi ddrc,  0xFD
    outi portc, 0xFF
    
    ;PORTD PD7(� ����������� q4) �� ���� � ��������� � 1, ��������� �� ����� � 0
    outi ddrd, 0xFF - 0x80
    outi portd, 0x80

; ��������� USART
    outi ucsra, 0x00 ; ��� �������� ��������

    ;������� ��� ����� 1 - ���������� � ucsrc, ����� � ubrrh
    outi ucsrc, (1<<ursel)|(3<<ucsz0); ����������� �����, 1 ����-���, ��� �������� ��������
    outi ubrrl, 0x33 ; 51(0x33) - �������� 19200, 1 - 500000
    outi ubrrh, 0x00 ; 
    outi ucsrb, (1<<RXEN)|(1<<TXEN) ; ��������� ����� � �������� USART

;�������� ���.
    outi admux,0b01100001 ; pin pc0(adc0)
	outi adcsra,(1<<ADEN)|(1<<ADIE)|(1<<ADSC)|(1<<ADFR)|(3<<ADPS0)
	
	;cbi	ADCSRA,ADEN ; ��� �������� !!!!!!!!!!!!!!!!!
	
;��������� ������� 2
    outi TCCR2, 0b10011001 ; ����������� ��������� �������� ��������
    ; ����������� � ������ ������ ��� ���������, ��� ��������� �����������
    ; ���� PB3 (OC2)
	outi OCR2, 63 ; ��������� ��������� ��� �������������� ������� �� 8 MHz = 32	
    outi TIMSK, 1<<OCIE2; ������������ ���������� ��� ���������

;�������� ����� ���������.
	cbi	ACSR,ACD		;���������� �������
	sbi	ACSR,ACBG ; ����������� � �������� �����(PD6-AIN0) ���������� ��� (1.23�)

	sei; ��������� ����������
	
	clr tmp
main:
    rjmp main
    
; ������������ ==================================
usart_transmit:
    ; ���� ���� �� ����� ���� ����� ��������
    sbis ucsra, udre
    rjmp usart_transmit
    ; ���������� ������ �� ������������
    out udr, acc
    ret

usart_recieve:
    ; ���� ���� ������ ����� ��������
    sbis ucsra, rxc
    rjmp usart_recieve
    ; ��������� ������
    in acc, udr
    ret
 
;================================================
; ����������� ����������
ADC_INT:
    in acc, adch
    ;cpi acc, 0x34
    ;brlo END_ADC
    rcall usart_transmit
END_ADC:
	RETI
TIMER2_COMP:
	;in	S,sreg ;���������� ������� �������
	inc	timer_ctr
    ;mov acc, timer_ctr
    ;rcall iusart_transmit
	;out	sreg, S
	reti

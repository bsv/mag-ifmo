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
ADC_INT:
	RETI
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
    outi ddrc,  0xFF
    outi portc, 0xFF
    
    ;PORTD PD7(� ����������� q4) �� ���� � ��������� � 1, ��������� �� ����� � 0
    outi ddrd, 0xFF - 0x80
    outi portd, 0x80

; ��������� USART
    outi ucsra, 0x00 ; ��� �������� ��������

    ;������� ��� ����� 1 - ���������� � ucsrc, ����� � ubrrh
    outi ucsrc, (1<<ursel)|(3<<ucsz0); ����������� �����, 1 ����-���, ��� �������� ��������
    outi ubrrl, 0x33 ; 51 - �������� 19200
    outi ubrrh, 0x00 ; 
    outi ucsrb, (1<<RXEN)|(1<<TXEN) ; ��������� ����� � �������� USART
    
;��������� ������� 2
    outi TCCR2, 0b10011001 ; ����������� ��������� �������� ��������
    ; ����������� � ������ ������ ��� ���������, ��� ��������� �����������
    ; ���� PB3 (OC2)
	outi OCR2, 63 ; (��� 16��� = 63, ��������� �������������)
                  ; ��������� ��������� ��� �������������� ������� �� 8 MHz = 32	
    outi TIMSK, 1<<OCIE2; ������������ ���������� ��� ���������

;�������� ����� ���������.
	cbi	ADCSRA,ADEN ; ��� ��������
	cbi	ACSR,ACD		;���������� �������
	sbi	ACSR,ACBG ; ����������� � �������� �����(PD6-AIN0) ���������� ��� (1.23�)

	sei; ��������� ����������
	clr tmp
main: 
rcall	detect			;����� ������������ ���������� ��������
	sbrs	Flag_R,0			;��������� ����(0-���) ������� �� ����� �����
	rjmp	error_rfid

    inc tmp
    mov acc, tmp
    rcall usart_transmit

    ; �������� ��� ��������
    mov acc, paket_byte1
    rcall usart_transmit
    mov acc, paket_byte2
    rcall usart_transmit
    mov acc, paket_byte3
    rcall usart_transmit
    mov acc, paket_byte4
    rcall usart_transmit

    rjmp main

error_rfid:
    ; � ������ ������ �������� 0
    ;clr acc
    ;rcall usart_transmit
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
    
DETECT:
	in	push_SPL,SPL
	in	push_SPH,SPH
hig_lin:
	sbiS	ACSR,ACO
	rjmp	hig_lin
low_lin:
	sbiC	ACSR,ACO
	rjmp	low_lin
    
	cbr	Flag_R,0b00000001
	ldi	command,64	;���-�� ����������� ���
scan_preambula:
	clr	timer_ctr
	ldi	bitcnt,9		;Preambula 
;
	clr	system
;
	rcall	sample
	brcc	no_prbl
	cpi	system,0xff
	breq	preambula_yes
no_prbl:
	dec	command
	brne	scan_preambula
;
	rjmp	fault
;
preambula_yes:
;
	clr	parity
;
;��������� �������������
;
	rcall	read_byte
;�� ����������
;--
;1
	rcall	read_byte
;
    mov paket_byte1, command
	;sts	(ee_paket_byte1),command
    
;--
;2
	rcall	read_byte
;
    mov paket_byte2, command
	;sts	(ee_paket_byte2),command
;--
;3
	rcall	read_byte
;
    mov paket_byte3, command
	;sts	(ee_paket_byte3),command
;--
;4
	rcall	read_byte
;
    mov paket_byte4, command
	;sts	(ee_paket_byte4),command
;--
;�������� �������� �� �������� 4 ���� + 0 ���� ���.
;
	rcall	read_nibl
	brcs	fault
	cp	parity,system
	brne	fault
;
	rjmp	ready_yes
;
;----------------------------------------------------------------
;����� �� �������
;
fault:
;
	ldi	system,15
	out SPL,push_SPL
;
	ret	
;
;----------------------------------------------------------------
;
read_byte:
;
	rcall	read_nibl
	eor	parity,system		
	mov	command,system
	rcall	read_nibl
	eor	parity,system
	swap	command
	or	command,system
;
	ret
;
;---------------------------------------------------------------
; ������ 5 ���
read_nibl:
;
	clr	timer_ctr
	ldi	bitcnt,5		;Preambula ;Receive 55 bits
	clr	system
;
	rcall	sample
	clc
	ror	system
	ret
;
;----------------------------------------------------------------
;
;
sample:
		cpi	timer_ctr,96	;����� ���������� (int osc 8Mhz)
		brlo	sample
;
		sbiS	ACSR,ACO
		rjmp	bit_is_a_1
;
bit_is_a_0:	sec			
		rol	system
;
bit_is_a_0a:	cpi	timer_ctr,144	;����� ���������� (int osc 8Mhz)
		brsh	fault
		sbiC	ACSR,ACO
		rjmp	bit_is_a_0a	
		clr	timer_ctr
		rjmp	nextbit
;
;---------------------------------------
;
bit_is_a_1:
		clc			
		rol	system
bit_is_a_1a:	cpi	timer_ctr,144	;����� ���������� (int osc 8,0Mhz)	
		brsh	fault		
		sbiS	ACSR,ACO
		rjmp	bit_is_a_1a	
		clr	timer_ctr
nextbit:
		dec	bitcnt		
		brne	sample		
	ret
;
;----------------------------------------
;
ready_yes:
;
;All bits sucessfully received!
;
;��� ������ ���������.
;
	sbr	Flag_R,0b00000001
;
	out SPL,push_SPL
	out SPH,push_SPH
;
		ret
;
;================================================
; ����������� ����������
TIMER2_COMP:
	in	S,sreg ;���������� ������� �������
	inc	timer_ctr
	out	sreg, S
	reti

.include "m8def.inc"
 
    .def tmp = r15
    .def acc = r16 ; Аккумулятор
    .def timer_ctr = R17
    .def S = R0
    .def push_SPL = R4
    .def push_SPH = R5
    .def Flag_R = R25 ;0 бит, посылка Rfid считана
    .def bitcnt = R20
    .def	system	  	=R18
    .def	command 	=R19
    .def paket_byte1 = r1
    .def paket_byte2 = r2
    .def paket_byte3 = r3
    .def paket_byte4 = r6
    .def	parity		=R21
    

; Макросы=============================================
    ; Загрузка числа в порт
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
;Инициализируем стек
    outi SPL,low(RAMEND)
    outi SPH, high(RAMEND)

;Настраиваем порты
    
    ;PORTB выход в 0
    outi ddrb,  0xFF
    outi portb, 0x00
    
    ;PORTC выход в 0
    outi ddrc,  0xFF
    outi portc, 0xFF
    
    ;PORTD PD7(с транзистора q4) на вход с подтяжкой в 1, остальные на выход в 0
    outi ddrd, 0xFF - 0x80
    outi portd, 0x80

; Настройка USART
    outi ucsra, 0x00 ; без удвоения скорости

    ;старший бит равен 1 - записываем в ucsrc, иначе в ubrrh
    outi ucsrc, (1<<ursel)|(3<<ucsz0); асинхронный режим, 1 стоп-бит, без крнтроля четности
    outi ubrrl, 0x33 ; 51 - скорость 19200
    outi ubrrh, 0x00 ; 
    outi ucsrb, (1<<RXEN)|(1<<TXEN) ; разрешить прием и передачу USART
    
;Настройка таймера 2
    outi TCCR2, 0b10011001 ; тактируется системным тактовым сигналом
    ; запускается в режиме сброса при сравнении, при сравнении инвертирует
    ; порт PB3 (OC2)
	outi OCR2, 63 ; (для 16МГц = 63, проверено осциллографом)
                  ; константа сравнения при тактированании таймера от 8 MHz = 32	
    outi TIMSK, 1<<OCIE2; генерировать прерывание при сравнении

;Настрйка блока сравнения.
	cbi	ADCSRA,ADEN ; ацп выключен
	cbi	ACSR,ACD		;компаратор включен
	sbi	ACSR,ACBG ; подключение к неинверт входу(PD6-AIN0) внутренний ион (1.23В)

	sei; разрешаем прерывания
	clr tmp
main: 
rcall	detect			;Вызов подпрограммы считывания карточки
	sbrs	Flag_R,0			;Проверяем флаг(0-бит) считана ли любая карта
	rjmp	error_rfid

    inc tmp
    mov acc, tmp
    rcall usart_transmit

    ; передаем код карточки
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
    ; в случае ошибки передаем 0
    ;clr acc
    ;rcall usart_transmit
    rjmp main
    
; подпрограммы ==================================
usart_transmit:
    ; ждем пока не будет пуст буфер передачи
    sbis ucsra, udre
    rjmp usart_transmit
    ; отправляем данные из аккумулятора
    out udr, acc
    ret

usart_recieve:
    ; ждем пока данные будут получены
    sbis ucsra, rxc
    rjmp usart_recieve
    ; считываем данные
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
	ldi	command,64	;кол-во чтитываемых бит
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
;Групповой идентификатор
;
	rcall	read_byte
;не используем
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
;контроль столбцов на чётность 4 бита + 0 стоп бит.
;
	rcall	read_nibl
	brcs	fault
	cp	parity,system
	brne	fault
;
	rjmp	ready_yes
;
;----------------------------------------------------------------
;Выход по ошибкам
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
; чтение 5 бит
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
		cpi	timer_ctr,96	;число прерываний (int osc 8Mhz)
		brlo	sample
;
		sbiS	ACSR,ACO
		rjmp	bit_is_a_1
;
bit_is_a_0:	sec			
		rol	system
;
bit_is_a_0a:	cpi	timer_ctr,144	;число прерываний (int osc 8Mhz)
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
bit_is_a_1a:	cpi	timer_ctr,144	;число прерываний (int osc 8,0Mhz)	
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
;Код считан правильно.
;
	sbr	Flag_R,0b00000001
;
	out SPL,push_SPL
	out SPH,push_SPH
;
		ret
;
;================================================
; Обработчики прерываний
TIMER2_COMP:
	in	S,sreg ;запоминаем регистр статуса
	inc	timer_ctr
	out	sreg, S
	reti

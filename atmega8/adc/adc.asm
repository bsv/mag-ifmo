.include "m8def.inc"

    .def tmp = r18
    .def acc = r16 ; Аккумулятор
    .def div_ctr = R17
    .def push_SPL = R4
    .def push_SPH = R5
    

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
;Инициализируем стек
    outi SPL,low(RAMEND)
    outi SPH, high(RAMEND)

;Настраиваем порты
    
    ;PORTB выход в 0
    outi ddrb,  0xFF
    outi portb, 0x00
    
    ;PORTC выход в 0
    outi ddrc,  0xFD
    outi portc, 0xFF
    
    ;PORTD PD7(с транзистора q4) на вход с подтяжкой в 1, остальные на выход в 0
    outi ddrd, 0xFF - 0x80
    outi portd, 0x80

; Настройка USART
    outi ucsra, 0x00 ; без удвоения скорости

    ;старший бит равен 1 - записываем в ucsrc, иначе в ubrrh
    outi ucsrc, (1<<ursel)|(3<<ucsz0); асинхронный режим, 1 стоп-бит, без крнтроля четности
    outi ubrrl, 0x10 ; 51(0x33) - скорость 19200, 1 - 500000, 16 - 57600
    outi ubrrh, 0x00 ; 
    outi ucsrb, (1<<RXEN)|(1<<TXEN) ; разрешить прием и передачу USART

;Настрйка АЦП.
    outi admux,0b01100001 ; pin pc0(adc0)
	outi adcsra,(1<<ADEN)|(1<<ADIE)|(1<<ADSC)|(1<<ADFR)|(7<<ADPS0)
	
	;cbi	ADCSRA,ADEN ; ацп выключен !!!!!!!!!!!!!!!!!
	
;Настройка таймера 2
    outi TCCR2, 0b10011001 ; тактируется системным тактовым сигналом
    ; запускается в режиме сброса при сравнении, при сравнении инвертирует
    ; порт PB3 (OC2)
	outi OCR2, 63 ; константа сравнения при тактированании таймера от 8 MHz = 32	
    outi TIMSK, 1 << OCIE2; генерировать прерывание при сравнении

;Настрйка блока сравнения.
	cbi	ACSR,ACD		;компаратор включен
	sbi	ACSR,ACBG ; подключение к неинверт входу(PD6-AIN0) внутренний ион (1.23В)

	sei; разрешаем прерывания
	
	clr tmp
main:
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
 
;================================================
; Обработчики прерываний
ADC_INT:
    in acc, adch
    cpi div_ctr, 4
    breq END_ADC
    inc div_ctr
    reti
;
END_ADC:
    rcall usart_transmit
    clr div_ctr
	reti
;
TIMER2_COMP:
	;in	S,sreg ;запоминаем регистр статуса
	;inc	timer_ctr
    ;mov acc, timer_ctr
    ;rcall iusart_transmit
	;out	sreg, S
	reti

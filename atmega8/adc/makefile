ASM    = avra
LOADER = avrdude 
PROG   = avr109 
NAME   = adc
PORT   = /dev/ttyUSB0

all : $(NAME).asm
	$(ASM) $(NAME).asm

load: $(NAME).hex
	$(LOADER) -p m8 -P $(PORT) -c $(PROG) -U flash:w:$(NAME).hex

clean :
	rm -f *.hex *.obj *.cof *.lst

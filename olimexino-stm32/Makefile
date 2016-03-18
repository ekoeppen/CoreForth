CPU := cortex-m3
#ASMFLAGS := -defsym TRACE_DEBUG=1
ASMFLAGS :=

include ../generic/Makefile

OBJS = olimexino_stm32_board.o olimexino_stm32_words.o

olimexino_stm32__board.s: ../generic/CoreForth.s

coreforth.elf: $(OBJS)
	arm-none-eabi-ld $(OBJS) -o $@ -Tolimexino_stm32.ld
	
coreforth.bin: coreforth.elf
	arm-none-eabi-objcopy -Obinary $< $@
	thumbulator -d $@ -m 00010000 -d ../generic/systick.ft -d ../generic/quit.ft -d olimexino_stm32.ft -o $@
	LC_CTYPE=C && LANG=C && sed -e "s/revision NNNNNNNN/revision $(REVISION)/" < $@ > $@.bak && mv $@.bak $@

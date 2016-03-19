CPU := cortex-m3
ASMFLAGS :=

include ../generic/Makefile

OBJS = stm32f103_board.o stm32f103_words.o

stm32f103__board.s: ../generic/CoreForth.s

coreforth.elf: $(OBJS)
	arm-none-eabi-ld $(OBJS) -o $@ -Tstm32f103x8.ld
	
coreforth.bin: coreforth.elf
	arm-none-eabi-objcopy -Obinary $< $@
	thumbulator -d $@ -m 00010000 -d ../generic/systick.ft -d ../generic/quit.ft -d stm32f103.ft -o $@
	LC_CTYPE=C && LANG=C && sed -e "s/revision NNNNNNNN/revision $(REVISION)/" < $@ > $@.bak && mv $@.bak $@

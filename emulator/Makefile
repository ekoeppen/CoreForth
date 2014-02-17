CPU := cortex-m0
ASMFLAGS := -defsym THUMB1=1

include ../generic/Makefile

OBJS = emulator_board.o emulator_words.o

emulator_board.s: ../generic/CoreForth.s

coreforth.elf: $(OBJS)
	arm-none-eabi-ld $(OBJS) -o $@ -Temulator.ld
	
coreforth.bin: coreforth.elf
	arm-none-eabi-objcopy -Obinary $< $@
	thumbulator -d $@ -m 00010000 -d ../generic/ansi.ft -d ../generic/systick.ft -d ../generic/multitasking.ft -d ../generic/quit.ft -d emulator.ft -o $@
	LC_CTYPE=C && LANG=C && sed -e "s/revision NNNNNNNN/revision $(REVISION)/" < $@ > $@.bak && mv $@.bak $@


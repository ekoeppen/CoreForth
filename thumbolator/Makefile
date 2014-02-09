CPU := cortex-m0
ASMFLAGS := -defsym THUMB1=1

include ../generic/Makefile

GEN += thumbolator_ram.gen.s
OBJS = thumbolator_board.o thumbolator_words.o

thumbolator_board.s: ../generic/CoreForth.s $(GEN)

coreforth.elf: $(OBJS)
	arm-none-eabi-ld $(OBJS) -o $@ -Tthumbolator.ld

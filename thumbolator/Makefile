CPU := cortex-m0
ASMFLAGS := -defsym THUMB1=1

include ../generic/Makefile

GEN += thumbolator_ram.gen.s

thumbolator_board.s: ../generic/CoreForth.s $(GEN)

coreforth.elf: thumbolator_board.o
	arm-none-eabi-ld $< -o $@ -Tthumbolator.ld

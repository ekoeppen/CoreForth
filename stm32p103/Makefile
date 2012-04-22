include ../generic/Makefile

GEN += stm32p103.gen.s stm32p103_ram.gen.s

precompiler.s: ../precompiler/board.s stm32p103_words.s $(GEN)
stm32p103_board.s: ../generic/CoreForth.s stm32p103_words.s precompiled_words.s $(GEN)

coreforth.elf: stm32p103_board.o
	arm-none-eabi-ld $< -o $@ -Tstm32p103.ld

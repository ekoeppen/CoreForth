include ../generic/Makefile

GEN += olimexino_stm32.gen.s olimexino_stm32_ram.gen.s

precompiler.o: ../precompiler/board.s olimexino_stm32_words.s $(GEN)
olimexino_stm32_board.o: ../generic/CoreForth.s olimexino_stm32_words.s precompiled_words.s $(GEN)

coreforth.elf: olimexino_stm32_board.o
	arm-none-eabi-ld $< -o $@ -Tolimexino_stm32.ld

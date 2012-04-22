include ../generic/Makefile

GEN += lm3s811.gen.s lm3s811_ram.gen.s

precompiler.s: ../precompiler/board.s lm3s811_words.s $(GEN)
lm3s811_board.s: ../generic/CoreForth.s lm3s811_words.s precompiled_words.s $(GEN)

coreforth.elf: lm3s811_board.o
	arm-none-eabi-ld $< -o $@ -Tlm3s811.ld

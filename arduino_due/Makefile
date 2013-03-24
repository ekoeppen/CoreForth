include ../generic/Makefile

GEN += arduino_due.gen.s arduino_due_ram.gen.s

precompiler.s: ../precompiler/board.s arduino_due_words.s $(GEN)
arduino_due_board.s: ../generic/CoreForth.s arduino_due_words.s precompiled_words.s $(GEN)

coreforth.elf: arduino_due_board.o
	arm-none-eabi-ld $< -o $@ -Tarduino_due.ld

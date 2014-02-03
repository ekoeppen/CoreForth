include ../generic/Makefile

.s.o:
	arm-none-eabi-as -defsym THUMB1=1 -gdwarf2 -mcpu=cortex-m0 -mthumb -I../generic/ -o $@ $<

GEN += stm32f030.gen.s stm32f030_ram.gen.s

precompiler.s: ../precompiler/board.s stm32f030_words.s $(GEN)
stm32f030g_board.s: ../generic/CoreForth.s stm32f030_words.s precompiled_words.s $(GEN)

coreforth.elf: stm32f030_board.o
	arm-none-eabi-ld $< -o $@ -Tstm32f030.ld

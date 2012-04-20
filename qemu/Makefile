include ../generic/Makefile

GEN += ../lm3s811/lm3s811.gen.s ../lm3s811/lm3s811ram.gen.s

lm3s811.o: ../lm3s811/lm3s811.s ../generic/CoreForth.s precomp.s $(GEN)
	arm-none-eabi-as -mcpu=cortex-m3 -I../generic/ -I../lm3s811/ -o $@ $<

precomp.o: ../lm3s811/lm3s811.s ../generic/CoreForth.s $(GEN)
	arm-none-eabi-as -mcpu=cortex-m3 -defsym PRECOMP_LM3S811=1 -I../generic/ -I../lm3s811/ -o $@ $<

coreforth.elf: lm3s811.o
	arm-none-eabi-ld $< -o $@ -T../lm3s811/lm3s811.ld

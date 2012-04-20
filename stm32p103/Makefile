include ../generic/Makefile

GEN += stm32p103.gen.s stm32p103ram.gen.s

stm32p103.o: stm32p103.s ../generic/CoreForth.s precomp.s $(GEN)
	arm-none-eabi-as -mcpu=cortex-m3 -I../generic/ -o $@ $<

precomp.o: ../lm3s811/lm3s811.s ../generic/CoreForth.s $(GEN)
	arm-none-eabi-as -mcpu=cortex-m3 -defsym PRECOMP_STM32P103=1 -I../generic/ -I../lm3s811/ -o $@ $<

coreforth.elf: stm32p103.o
	arm-none-eabi-ld $< -o $@ -Tstm32p103.ld

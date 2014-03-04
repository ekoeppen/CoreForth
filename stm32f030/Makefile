CPU := cortex-m0
ASMFLAGS := -defsym THUMB1=1

ifdef EXTRA
EXTRA_FT := -d $(EXTRA)
endif

include ../generic/Makefile

OBJS = stm32f030_board.o stm32f030_words.o

stm32f030_board.s: ../generic/CoreForth.s

coreforth.elf: $(OBJS)
	arm-none-eabi-ld $(OBJS) -o $@ -Tstm32f030.ld
	
coreforth.bin: coreforth.elf
	arm-none-eabi-objcopy -Obinary $< $@
	thumbulator -d $@ -m 00010000 \
		-d ../generic/cortex.ft \
		-d ../generic/systick.ft \
		-d stm32f030.ft $(EXTRA_FT) -o $@
	LC_CTYPE=C && LANG=C && sed -e "s/revision NNNNNNNN/revision $(REVISION)/" < $@ > $@.bak && mv $@.bak $@

CPU ?= cortex-m3

GEN := ../generic/ansi.gen.s ../generic/systick.gen.s \
      ../generic/editor.gen.s ../generic/protothreads.gen.s \
      ../generic/find.gen.s ../generic/strings.gen.s ../generic/multitasking.gen.s \
      ../generic/blocks.gen.s ../generic/quit.gen.s

REVISION := $(shell git log -1 --abbrev=8 --pretty=format:%h)

%.bin: %.elf
	LC_CTYPE=C && LANG=C && sed -e "s/revision NNNNNNNN/revision $(REVISION)/" < $< > $<.bak && mv $<.bak $<
	arm-none-eabi-objcopy -Obinary $< $@

%.lst: %.elf
	arm-none-eabi-objdump -D $< >$@

%.gen.s: %.ft
	awk '{ gsub(/\\/, "\\\\\\"); gsub(/"/, "\\\""); print ".ascii \"" $$0 "\\n\""}' < $< > $@
# %.gen.s: %.ft
#	awk '{ print ".byte ", length($$0); gsub(/\\/, "\\\\\\"); gsub(/"/, "\\\""); print ".ascii \"" $$0 "\""} END{print ".align 2, 0"}' < $< > $@

.s.o:
	arm-none-eabi-as -gdwarf2 $(ASMFLAGS) -mcpu=$(CPU) -I../generic/ -o $@ $<

all: coreforth.bin coreforth.lst

listing: coreforth.lst

coreforth.elf: $(GEN) Makefile ../generic/Makefile

coreforth.bin: coreforth.elf

clean:
	rm -f *.elf *.bin *.o *.gen.s *.log *.lst

run: coreforth.elf
	qemu-system-arm -M lm3s811evb -serial stdio -kernel coreforth.elf -semihosting; stty sane

run_text: coreforth.elf
	qemu-system-arm -M lm3s811evb -nographic -kernel coreforth.elf -semihosting; stty sane

precompile: precompiler.elf
	qemu-system-arm -M lm3s6965evb -nographic -kernel precompiler.elf -semihosting > precompiled_words.s; stty sane

precompiler.elf: precompiler.o
	arm-none-eabi-ld $< -o $@ -T../precompiler/precompiler.ld

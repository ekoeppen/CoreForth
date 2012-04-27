GEN = ../generic/ansi.gen.s ../generic/accept.gen.s \
      ../generic/editor.gen.s ../generic/protothreads.gen.s \
      ../generic/find.gen.s ../generic/strings.gen.s \
      ../generic/quit.gen.s

%.bin: %.elf
	arm-none-eabi-objcopy -Obinary $< $@

%.gen.s: %.ft
	awk '{ print ".byte ", length($$0); gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); print ".ascii \"" $$0 "\""} END{print ".align 2, 0"}' < $< > $@

.s.o:
	arm-none-eabi-as -mcpu=cortex-m3 -I../generic/ -o $@ $< 

all: coreforth.bin

clean:
	rm -f *.elf *.bin *.o *.gen.s

run: coreforth.elf
	qemu-system-arm -M lm3s811evb -serial stdio -kernel coreforth.elf -semihosting; stty sane

run_text: coreforth.elf
	qemu-system-arm -M lm3s811evb -nographic -kernel coreforth.elf -semihosting; stty sane

precompile: precompiler.elf
	qemu-system-arm -M lm3s6965evb -nographic -kernel precompiler.elf -semihosting > precompiled_words.s; stty sane

precompiler.elf: precompiler.o
	arm-none-eabi-ld $< -o $@ -T../precompiler/precompiler.ld

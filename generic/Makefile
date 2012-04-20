GEN =  ../generic/ansi.gen.s ../generic/accept.gen.s ../generic/editor.gen.s ../generic/protothreads.gen.s ../generic/quit.gen.s

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

precomp: precomp.elf
	qemu-system-arm -M lm3s6965evb -nographic -kernel precomp.elf -semihosting > precomp.s; stty sane

precomp.elf: precomp.o
	arm-none-eabi-ld $< -o $@ -T../generic/lm3s6965.ld

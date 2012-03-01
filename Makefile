all: lm3s811.bin qemu.bin

%.bin: %.elf
	arm-none-eabi-objcopy -Obinary $< $@

%.gen.s: %.ft
	awk '{ print ".byte ", length($$0); gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); print ".ascii \"" $$0 "\""} END{print ".byte 255,\n.align 2, 0"}' < $< > $@

.s.o:
	arm-none-eabi-as -mcpu=cortex-m3 -o $@ $< 

lm3s811.o: CoreForth.s CoreForth.gen.s lm3s811.gen.s

qemu.o: CoreForth.s CoreForth.gen.s lm3s811.gen.s

qemu.o: lm3s811.s
	arm-none-eabi-as -mcpu=cortex-m3 -defsym UART_USE_INTERRUPTS=1 -o $@ $< 

precomp.o: lm3s811.s CoreForth.gen.s lm3s811.gen.s
	arm-none-eabi-as -mcpu=cortex-m3 -defsym UART_USE_INTERRUPTS=1 -defsym PRECOMPILE=1 -o $@ $< 

lm3s811.elf: lm3s811.o
	arm-none-eabi-ld $< -o $@ -Tlm3s811.ld

qemu.elf: qemu.o
	arm-none-eabi-ld $< -o $@ -Tlm3s811.ld

precomp.elf: precomp.o
	arm-none-eabi-ld $< -o $@ -Tlm3s811.ld

clean:
	rm -f *.elf *.bin *.o *.gen.s

run: qemu.elf
	qemu-system-arm -M lm3s811evb -serial stdio -kernel qemu.elf; stty sane

precomp: precomp.bin
	qemu-system-arm -M lm3s811evb -serial stdio -kernel precomp.elf > CoreForth.precomp.s; stty sane

OUTPUT_FORMAT("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(reset_handler)

MEMORY
{
    FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 0x00800000
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00002000
}

SECTIONS
{
    .flash : {
        *(.text)
        *(.rodata)
        . = 0x00040000 ;
        *(.host)
        KEEP(*(interrupt_vector))
    } > FLASH

    .data : {
        ram_start = . ;
        *(.data)
        *(.bss)
    } >SRAM AT> FLASH

    ram_top = 0x20000000 + 0x00001c00 ;
    irq_stack_top = ram_top - 0x40;
    trace_buffer = ram_top;
    trace_ptr = trace_buffer + 0x100;
    breakpoint = trace_ptr + 0x4;
    breakpoint_ip = trace_ptr + 0x8;
    breakpoint_rp = trace_ptr + 0xc;
}

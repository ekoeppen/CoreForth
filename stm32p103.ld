OUTPUT_FORMAT("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(reset_handler)

MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 0x00010000
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00002000
}

SECTIONS
{
    .flash : {
        *(.text)
        *(.rodata)
        KEEP(*(interrupt_vector))
    } > FLASH

    .data : {
        ram_start = . ;
        *(.data)
        *(.bss)
    } >SRAM AT> FLASH

    ram_top = 0x20000000 + 0x00002000 ;
    irq_stack_top = ram_top ;
}

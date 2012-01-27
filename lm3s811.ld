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
        *(.data)
        *(.bss)
    } >SRAM AT> FLASH

    stack_top = 0x20000000 + 1024;
    return_stack_top = stack_top + 256 ;
    serial_buffer = return_stack_top  + 4 ;
    serial_buffer_tail = serial_buffer + 256 ;
    serial_buffer_head = serial_buffer_tail + 4 ;
    addr_IVT = serial_buffer_head + 4 ;
    addr_TIB = addr_IVT + 48 * 4 ;
    addr_DP = addr_TIB + 132 ;
    addr_STATE = addr_DP + 4 ;
    addr_LATEST = addr_STATE + 4 ;
    addr_S0 = addr_LATEST + 4 ;
    addr_BASE = addr_S0 + 4 ;
    addr_ININDEX = addr_BASE + 4 ;
    data_start = addr_ININDEX + 4 ;
        

/*
    .ram_initialized 0x20000000: AT (LOADADDR(.flash) + SIZEOF(.flash)) {
         *(.data)
    }

    .ram : {
        *(.bss)
    }

    stack_top = 0x20000000 + 1024;
    return_stack_top = stack_top + 256;
    data_start = return_stack_top;
*/
}

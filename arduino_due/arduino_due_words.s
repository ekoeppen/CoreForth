    .ltorg

    defcode "RETI", RETI
    pop {r4 - r12, pc}

    defword ";I", SEMICOLONI, F_IMMED
    .word LIT, RETI, COMMAXT, REVEAL, LBRACKET, EXIT

    defcode "KEY?", KEYQ
    ldr r0, =addr_SBUF_HEAD
    ldr r1, [r0]
    ldr r0, =addr_SBUF_TAIL
    ldr r0, [r0]
    subs r0, r1
    beq 1f
    movs r0, #0
    mvns r0, r0
1:  push {r0}
    NEXT

    defcode "FLASH-PAGE", FLASH_PAGE
    ldr r0, =EEFC0
    pop {r2}
1:  ldr r1, [r0, #EEFC_FSR]
    ands r1, #1
    beq 1b
    ldr r1, =0x5A000003
    lsl r2, #8
    orrs r1, r2
    mov r0, #0
    ldr r2, =0x00100008
    ldr r2, [r2]
    adds r2, #1
    ldr lr, =(cont + 1)
    mov pc, r2
cont:
    NEXT

    defvar "SBUF", SBUF, 16
    defvar "SBUF-HEAD", SBUF_HEAD
    defvar "SBUF-TAIL", SBUF_TAIL
    defvar "IVT", IVT, 48 * 4
    defvar "UART0-TASK", UARTZ_TASK

    .ltorg

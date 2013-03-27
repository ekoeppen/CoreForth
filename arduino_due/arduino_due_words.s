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

    .ltorg

    defvar "SBUF", SBUF, 16
    defvar "SBUF-HEAD", SBUF_HEAD
    defvar "SBUF-TAIL", SBUF_TAIL
    defvar "IVT", IVT, 48 * 4
    defvar "UART-TASK", UART_TASK

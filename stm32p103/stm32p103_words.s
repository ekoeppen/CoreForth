    .ltorg

    defcode "RETI", RETI
    pop {r4 - r12, pc}

    defword ";I", SEMICOLONI, F_IMMED
    .word LIT, RETI, COMMAXT, REVEAL, LBRACKET, EXIT

    defvar "IVT", IVT, 75 * 4

    defcode "KEY?", KEYQ
    mov r2, #0
    ldr r0, =UART2
    ldr r1, [r0, #UART_SR]
    ands r3, #32
    beq 1f
    mvn r2, #1
1:  push {r2}
    NEXT

    defvar "SBUF", SBUF, 16
    defvar "SBUF-HEAD", SBUF_HEAD
    defvar "SBUF-TAIL", SBUF_TAIL
    defvar "IVT", IVT, 48 * 4
    defvar "UART0-TASK", UARTZ_TASK

    .ltorg

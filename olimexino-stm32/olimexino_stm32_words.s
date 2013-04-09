    .ltorg

sysclock:
    push {r4, r5}
    ldr r0, =8000000
    ldr r4, =RCC
    ldr r4, [r4, #RCC_CFGR]
    mov r5, r4
    ands r5, #0x0c
    beq 1f
    cmp r5, #0x04
    beq 1f
    lsrs r4, #16
    ands r4, #0x3f
    mov r5, r4
    ands r5, #0x01
    beq 2f
    ands r5, #0x02
    beq 3f
2:  lsrs r0, #1
3:  lsrs r4, #2
    adds r4, #2
    mul r0, r0, r4
1:  pop {r4, r5}
    bx lr

    defcode "SYSCLOCK", SYSCLOCK
    bl sysclock
    push {r0}
    NEXT

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

    defcode "ERASE-PAGE", ERASE_PAGE
    pop {r1}
    ldr r0, =FPEC
    mov r2, #0x2
    str r2, [r0, #FLASH_CR]
    str r1, [r0, #FLASH_AR]
    ldr r2, [r0, #FLASH_CR]
    orrs r2, #0x40
    str r2, [r0, #FLASH_CR]
1:  ldr r2, [r0, #FLASH_SR]
    ands r2, #0x1
    bne 1b
    NEXT

    defcode "FLASH-PAGE", FLASH_PAGE
    pop {r2}
    pop {r3}
    mov r4, #0x400
    ldr r0, =FPEC
1:  mov r1, #0x1
    str r1, [r0, #FLASH_CR]
    ldrh r1, [r3]
    strh r1, [r2]
2:  ldr r1, [r0, #FLASH_SR]
    ands r1, #0x1
    bne 2b
    adds r2, #2
    adds r3, #2
    subs r4, #2
    bne 1b
    NEXT

    defvar "SBUF", SBUF, 16
    defvar "SBUF-HEAD", SBUF_HEAD
    defvar "SBUF-TAIL", SBUF_TAIL
    defvar "IVT", IVT, 48 * 4
    defvar "UART0-TASK", UARTZ_TASK

    .ltorg

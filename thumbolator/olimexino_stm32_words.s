    .ltorg

sysclock:
    push {r4, r5, r6}
    ldr r0, =8000000
    ldr r4, =RCC
    ldr r4, [r4, #RCC_CFGR]
    mov r5, r4
    movs r6, #0x0c
    ands r5, r6
    beq 1f
    cmp r5, #0x04
    beq 1f
    lsrs r4, #16
    movs r6, #0x3f
    ands r4, r6
    mov r5, r4
    movs r6, #0x01
    ands r5, r6
    beq 2f
    movs r6, #0x02
    ands r5, r6
    beq 3f
2:  lsrs r0, #1
3:  lsrs r4, #2
    adds r4, #2
    muls r0, r0, r4
1:  pop {r4, r5}
    bx lr

    defcode "SYSCLOCK", SYSCLOCK
    bl sysclock
    push {r0}
    NEXT

    defcode "RETI", RETI
    pop {r4}
    mov r12, r4
    pop {r4}
    mov r11, r4
    pop {r4}
    mov r10, r4
    pop {r4}
    mov r9, r4
    pop {r4}
    mov r8, r4
    pop {r4 - r7, pc}

    defword ";I", SEMICOLONI, F_IMMED
    .word LIT, RETI, COMMAXT, REVEAL, LBRACKET, EXIT

    defvar "IVT", IVT, (end_of_irq - _start)

    defcode "KEY?", KEYQ
    movs r2, #0
    ldr r0, =UART2
    ldr r1, [r0, #UART_SR]
    movs r0, #32
    ands r3, r0
    beq 1f
    subs r2, #1
1:  push {r2}
    NEXT

    defcode "ERASE-PAGE", ERASE_PAGE
    pop {r1}
    ldr r0, =FPEC
    movs r2, #0x2
    str r2, [r0, #FLASH_CR]
    str r1, [r0, #FLASH_AR]
    ldr r2, [r0, #FLASH_CR]
    movs r1, #0x40
    orrs r2, r1
    str r2, [r0, #FLASH_CR]
1:  ldr r2, [r0, #FLASH_SR]
    movs r1, #0x01
    ands r2, r1
    bne 1b
    NEXT

    defcode "FLASH-PAGE", FLASH_PAGE
    pop {r2}
    pop {r3}
    movs r4, #1
    lsrs r4, #10
    ldr r0, =FPEC
1:  movs r1, #0x1
    str r1, [r0, #FLASH_CR]
    ldrh r1, [r3]
    strh r1, [r2]
2:  ldr r1, [r0, #FLASH_SR]
    movs r0, #0x01
    ands r1, r0
    bne 2b
    adds r2, #2
    adds r3, #2
    subs r4, #2
    bne 1b
    NEXT

    defcode "CON-RX!", CON_RXSTORE
    ldr r0, =addr_CON_RX
    ldr r1, =addr_CON_RX_HEAD
con_store:
    pop {r3}
    ldr r2, [r1]
    strb r3, [r0, r2]
    adds r2, #1
    movs r3, #0x3f
    ands r2, r3
    str r2, [r1]
    NEXT

    defcode "CON-TX!", CON_TXSTORE
    ldr r0, =addr_CON_TX
    ldr r1, =addr_CON_TX_HEAD
    b con_store

    defvar "CON-RX-TAIL", CON_RX_TAIL
    defvar "CON-RX-HEAD", CON_RX_HEAD
    defvar "CON-RX", CON_RX, 64
    defvar "CON-TX-TAIL", CON_TX_TAIL
    defvar "CON-TX-HEAD", CON_TX_HEAD
    defvar "CON-TX", CON_TX, 64
    defvar "UART0-TASK", UARTZ_TASK

    .ltorg

@ ---------------------------------------------------------------------
@ -- CoreForth starts here --------------------------------------------

    .syntax unified
    .text

    .set ram_start, 0x20000000
    .set eval_words, 0x00010000

    .include "../stm32p103/stm32p103_definitions.s"
    .include "CoreForth.s"

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

    target_conditional ENABLE_COMPILER

    defword ";I", SEMICOLONI, F_IMMED
    .short LIT_XT, RETI, COMMAXT, REVEAL, LBRACKET, EXIT

    end_target_conditional

    defvar "IVT", IVT, 4 * 83

    defcode "KEY?", KEYQ
    movs r1, #32
    movs r2, #0
    ldr r0, =UART2
    ldr r0, [r0, #UART_SR]
    ands r0, r1
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
    movs r3, #0x40
    orrs r2, r3
    str r2, [r0, #FLASH_CR]
    movs r3, #1
1:  ldr r2, [r0, #FLASH_SR]
    ands r2, r3
    bne 1b
    NEXT

    defcode "FLASH-PAGE", FLASH_PAGE
    pop {r2}
    pop {r3}
    movs r4, #1
    lsls r4, #10
    ldr r0, =FPEC
1:  movs r1, #0x1
    str r1, [r0, #FLASH_CR]
    ldrh r1, [r3]
    strh r1, [r2]
    movs r5, #1
2:  ldr r1, [r0, #FLASH_SR]
    ands r1, r5
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

    defword "COLD", COLD
    .short EMULATIONQ, QBRANCH, 1f - .
    .short ROM, LIT
    .word eval_words
    .short EVALUATE
    .short HERE, LIT
    .word init_here
    .short STORE
    .short RAM_DP, FETCH, LIT
    .word init_data_start
    .short STORE
    .short LATEST, FETCH, LIT
    .word init_last_word
    .short STORE
    .short ROM_DUMP, BYE
1:  .short LATEST, FETCH, FROMLINK, EXECUTE

    .ltorg

    .set last_word, link
    .set last_host, link_host
    .set data_start, ram_here
    .set here, .


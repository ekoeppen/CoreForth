@ ---------------------------------------------------------------------
@ -- CoreForth starts here --------------------------------------------

    .syntax unified
    .text

    .set ram_start, 0x20000000
    .set eval_words, 0x00010000

    .include "stm32f030_definitions.s"
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

    defcode "KEY?", KEYQ
    movs r2, #0
    ldr r0, =(UART1 + UART_ISR)
    ldr r0, [r0]
    movs r1, #32
    tst r1, r0
    beq 1f
    subs r2, #1
1:  push {r2}
    NEXT

    defvar "SBUF", SBUF, 16
    defvar "SBUF-HEAD", SBUF_HEAD
    defvar "SBUF-TAIL", SBUF_TAIL
    defvar "IVT", IVT, 48 * 4
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

    .set last_word, link
    .set last_host, link_host
    .set data_start, ram_here
    .set here, .

    .ltorg

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

    defword ";I", SEMICOLONI, F_IMMED
    .word LIT, RETI, COMMAXT, REVEAL, LBRACKET, EXIT

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
    .word EMULATIONQ, QBRANCH, 1f - .
    .word ROM, LIT, eval_words, EVALUATE
    .word HERE, LIT, init_here, STORE
    .word RAM_DP, FETCH, LIT, init_data_start, STORE
    .word LATEST, FETCH, LIT, init_last_word, STORE
    .word ROM_DUMP, BYE
1:  .word LATEST, FETCH, FROMLINK, EXECUTE

    .set last_word, link
    .set last_host, link_host
    .set data_start, ram_here
    .set here, .

    .ltorg

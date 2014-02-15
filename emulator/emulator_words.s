@ ---------------------------------------------------------------------
@ -- CoreForth starts here --------------------------------------------

    .syntax unified
    .text

    .org 0x400
    .set ram_start, 0x20000000
    .set eval_words, 0x00010000

    .include "emulator_definitions.s"
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
    ldr r0, =UART_DR
    ldr r0, [r0]
    push {r0}
    NEXT

    defvar "IVT", IVT, 0x140
    defvar "UART0-TASK", UARTZ_TASK

    defword "COLD", COLD
    .word EMULATIONQ, QBRANCH, 1f - .
    .word ROM, LIT, eval_words, DUP, LIT, 40, TYPE, CR, EVALUATE
    .word HERE, LIT, init_here, STORE
    .word RAM_DP, FETCH, LIT, init_data_start, STORE
    .word LATEST, FETCH, LIT, init_last_word, STORE
    .word ROM_DUMP, BYE
1:  .word LATEST, FETCH, FROMLINK, EXECUTE

    .set last_word, link
    .set data_start, ram_here
    .set here, .

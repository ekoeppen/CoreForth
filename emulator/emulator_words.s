@ ---------------------------------------------------------------------
@ -- CoreForth starts here --------------------------------------------

    .syntax unified
    .text

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
    .short LIT
    .word RETI
    .short COMMAXT, REVEAL, LBRACKET, EXIT

    defcode "KEY?", KEYQ
    ldr r0, =UART_DR
    ldr r0, [r0]
    push {r0}
    NEXT

    defvar "IVT", IVT, 0x140
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

@ ---------------------------------------------------------------------
@ -- CoreForth starts here --------------------------------------------

    .syntax unified
    .text

    .org 0x400
    .set ram_start, 0x20000000

    .include "CoreForth.s"

    defword "COLD", COLD
    .word EMULATIONQ, QBRANCH, 1f - .
    .word ROM, LIT, eval_words, EVALUATE
    .word HERE, LIT, init_here, STORE
    .word RAM_DP, FETCH, LIT, init_data_start, STORE
    .word LATEST, FETCH, LIT, init_last_word, STORE
    .word ROM_DUMP, BYE
1:  .word RAM, LIT, startup_words, EVALUATE
startup_words:
    .include "thumbolator_ram.gen.s"
    .word 0xffffffff

    .set last_word, link
    .set data_start, ram_here
    .set here, .

    .org . + 0x10000
eval_words:
    @ .include "thumbolator.gen.s"
    .include "ansi.gen.s"
    .include "quit.gen.s"
    .byte 0
    .align 2,0


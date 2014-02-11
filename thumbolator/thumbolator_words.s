@ ---------------------------------------------------------------------
@ -- CoreForth starts here --------------------------------------------

    .syntax unified
    .text

    .org 0x400
    .set ram_start, 0x20000000

    .include "CoreForth.s"

    defword "COLD", COLD
    .word LIT, eval_words, EVALUATE
eval_words:
    .include "thumbolator_ram.gen.s"
    .word 0xffffffff

    .set last_word, link
    .set data_start, ram_here
    .set here, .

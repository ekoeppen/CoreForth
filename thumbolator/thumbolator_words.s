@ ---------------------------------------------------------------------
@ -- CoreForth starts here --------------------------------------------

    .syntax unified
    .text

    .org 0x400
    .set ram_start, 0x20000000

    .include "CoreForth.s"
    .include "../stm32p103/stm32p103_definitions.s"
    .include "olimexino_stm32_words.s"

    defword "COLD", COLD
    .word LIT, eval_words, EVALUATE
eval_words:
    .include "../olimexino-stm32/olimexino_stm32.gen.s"
    .include "systick.gen.s"
    .include "ansi.gen.s"
    .include "editor.gen.s"
    .include "blocks.gen.s"
    .include "protothreads.gen.s"
    .include "multitasking.gen.s"
    .include "thumbolator_ram.gen.s"
    .word 0xffffffff

    .set last_word, link
    .set data_start, ram_here

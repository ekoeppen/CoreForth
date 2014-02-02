    .include "../precompiler/board.s"
    .include "stm32f030_definitions.s"
    .include "stm32f030_words.s"

precompile_words:
    .include "stm32f030.gen.s"
    .include "quit.gen.s"
    .word 0xffffffff

    .set last_word, link
    .set data_start, ram_here

    .include "../precompiler/board.s"
    .include "arduino_due_words.s"

precompile_words:
    .include "arduino_due.gen.s"
    .include "ansi.gen.s"
    @.include "accept.gen.s"
    @.include "editor.gen.s"
    @.include "protothreads.gen.s"
    @.include "multitasking.gen.s"
    .include "quit.gen.s"
    .word 0xffffffff

    .set last_word, link
    .set data_start, ram_here

@ -- vim:syntax=asm:foldmethod=marker:foldmarker=@\ --\ ,@\ ---:

    .org 0x400

@ ---------------------------------------------------------------------
@ -- Variable definitions ---------------------------------------------

    .set F_IMMED,           0x80
    .set F_HIDDEN,          0x20
    .set F_LENMASK,         0x1f

    .set link,                 0
    .set compiled_here, ram_start

@ ---------------------------------------------------------------------
@ -- Macros -----------------------------------------------------------

    .macro CHR, c
    push {r0, r1}
    movs r0, \c
    bl putchar
    pop {r0, r1}
    .endm

    .macro REG, r
    push {r0, r1}
    movs r0, \r
    bl puthexnumber
    pop {r0, r1}
    .endm

    .macro NEXT
    ldr r0, [r7]
    adds r7, r7, #4
    ldr r1, [r0]
    adds r1, r1, #1
    bx r1
    .endm

    .macro defword name, label, flags=0, xt=DOCOL
    .align 2, 0
    .global name_\label
name_\label :
    .int link
    .set link, name_\label
    .byte \flags | (99f - 98f)
98:
    .ascii "\name"
99:
    .align  2, 0
    .global \label
\label :
    .int \xt
    @ parameter field follows
    .endm

    .macro defcode name, label, flags=0
    .align 2, 0
    .global name_\label
name_\label :
    .int link
    .set link, name_\label
    .byte \flags | (99f - 98f)
98:
    .ascii "\name"
99:
    .align 2, 0
    .global \label
\label :
    .int code_\label
    .global code_\label
code_\label :
    @ parameter field follows
    .endm

    .macro defconst name, label, value
    .align 2, 0
    .global name_\label
name_\label :
    .int link
    .set link, name_\label
    .byte (99f - 98f)
98:
    .ascii "\name"
99:
    .align 2, 0
    .global \label
\label :
    .int DOCON
constaddr_\label :
    .word \value
    .endm

    .macro defvar name, label, size=4
    defconst \name,\label,compiled_here
    .set addr_\label, compiled_here
    .set compiled_here, compiled_here + \size
    .endm

    .macro defdata name, label
    defword \name,\label,,DODATA
    .endm

@ ---------------------------------------------------------------------
@ -- Entry point ------------------------------------------------------

reset_handler:
    bl init_board
    ldr r6, =addr_RTOS
    ldr r7, =cold_start
    NEXT
cold_start:
    .word LIT, 10, BASE, STORE
    .word LIT, data_start, DP, STORE
    .word LIT, last_word, LATEST, STORE
    .word LIT, 0, FIXUPS, STORE
    .word COLD

    .ltorg

@ ---------------------------------------------------------------------
@ -- Interpreter code -------------------------------------------------

DOCOL:
    subs r6, r6, #4
    str r7, [r6]
    adds r7, r0, #4
    NEXT

DOVAR:
    adds r1, r0, #4
    push {r1}
    NEXT

DODATA:
    adds r1, r0, #4
    push {r1}
    NEXT

DOCON:
    ldr r1, [r0, #4]
    push {r1}
    NEXT

DODOES:
    subs r6, r6, #4
    str r7, [r6]
    mov r7, lr
    adds r7, r7, #5
    adds r0, r0, #4
    push {r0}
    NEXT

DOOFFSET:
    ldr r1, [r0, #4]
    pop {r2}
    adds r1, r2, r1
    push {r1}
    NEXT

    defcode "EXIT", EXIT
    ldr r7, [r6]
    adds r6, r6, #4
    NEXT

@ ---------------------------------------------------------------------
@ -- Helper code ------------------------------------------------------

putstring:
    cmp r1, #0
    bgt 1f
    mov pc, lr
1:  push {r5, r6, lr}
    mov r5, r0
    mov r6, r1
putstring_loop:
    ldrb r0, [r5]
    adds r5, r5, #1
    bl putchar
    subs r6, r6, #1
    bgt putstring_loop
    pop {r5, r6, pc}

putnumber:
    push {lr}
    cmp r0, #0
    bne 1f
    movs r0, #48
    bl putchar
    pop {pc}
1:  push {r4}
    movs r4, #0
    movs r3, #10
    movs r1, #48
2:  sdiv r2, r0, r3
    mls r0, r3, r2, r0
    adds r0, r1
    push {r0}
    adds r4, #1
    mov r0, r2
    cmp r0, #0
    bgt 2b
3:  pop {r0}
    bl putchar
    subs r4, #1
    bne 3b
    pop {r4, pc}

puthexnumber:
    push {r4, r5, lr}
    mov r4, r0
    movs r0, #'0'
    bl putchar
    movs r0, #'x'
    bl putchar
    mov r0, r4
    movs r3, #0
    movs r5, #8
puthexnumber_loop:
    rors r0, r0, #28
    mov r4, r0
    ands r0, r0, #15
    cmp r3, #0
    bgt 3f
    cmp r0, #0
    beq 2f
    movs r3, #1
3:  adds r0, r0, #'0'
    cmp r0, #'9'
    ble 1f
    adds r0, r0, #'a' - '0' - 10
1:  bl putchar
2:  mov r0, r4
    subs r5, r5, #1
    bne puthexnumber_loop
    cmp r3, #0
    bne 4f
    movs r0, #'0'
    bl putchar
4:  pop {r4, r5, pc}

putsignedhexnumber:
    push {lr}
    cmp r0, #0
    bge 1f
    push {r0}
    movs r0, #'-'
    bl putchar
    pop {r1}
    negs r0, r1
1:  bl puthexnumber
    pop {pc}

readline:
    push {r4, r5, r6, lr}
    mov r4, r0
    mov r5, r0
    movs r6, r1
    beq readline_end
readline_loop:
    bl read_key
    cmp r0, #13
    beq readline_end
    cmp r0, #127
    beq readline_backspace
    cmp r0, #8
    bne readline_addchar
readline_backspace:
    cmp r4, r5
    beq readline_loop
    movs r0, #32
    strb r0, [r5]
    subs r5, r5, #1
    adds r6, r6, #1
    movs r0, #8
    bl putchar
    movs r0, #32
    bl putchar
    movs r0, #8
    bl putchar
    b readline_loop
readline_addchar:
    bl putchar
    strb r0, [r5]
    adds r5, r5, #1
    subs r6, r6, #1
    bgt readline_loop
readline_end:
    subs r0, r5, r4
    pop {r4, r5, r6, pc}

/* read keys including escape sequences. Reading escape itself is
 * not supported yet. Escape sequences return negative numbers
 */
read_widekey:
    push {r4, r5, lr}
    bl read_key
    cmp r0, #27
    bne 1f
    bl read_key
    cmp r0, '['
    bne 1f
    bl read_key
    cmp r0, 'A'
    blt 3f
    cmp r0, 'Z'
    bgt 3f
    subs r4, r0, '@'
    b 4f
3:  movs r4, #10
    movs r5, #10
2:  cmp r0, '~'
    beq 4f
    cmp r0, '0'
    blt 1f
    cmp r0, '9'
    bgt 1f
    subs r0, '0'
    muls r4, r4, r5
    adds r4, r0
    bl read_key
    b 2b
4:  movs r0, #0
    subs r0, r4
1:  pop {r4, r5, pc}

printstack:
    ldr r0, =addr_TOS
    cmp sp, r0
    push {r4, lr}
    blt 1f
    beq 2f
    ldr r0, =stack_underflow_message
    movs r1, #(stack_underflow_message_end - stack_underflow_message)
    bl putstring
2:  pop {r4, pc}
1:  ldr r4, =addr_TOS
    subs r4, r4, #4
printstack_loop:
    ldr r0, [r4]
    bl puthexnumber
    movs r0, #32
    bl putchar
    subs r4, r4, #8
    cmp r4, sp
    beq printstack_end
    adds r4, r4, #4
    b printstack_loop
printstack_end:
    movs r0, #13
    bl putchar
    movs r0, #10
    bl putchar
    pop {r4, pc}
stack_underflow_message:
    .ascii "*** STACK UNDERFLOW ***\n"
stack_underflow_message_end:
    .ltorg

printrstack:
    push {r4, lr}
    ldr r4, =addr_RTOS
    subs r4, r4, #4
1:  ldr r0, [r4]
    bl puthexnumber
    movs r0, #32
    bl putchar
    cmp r4, r6
    beq 2f
    subs r4, r4, #4
    b 1b
2:  movs r0, #13
    bl putchar
    movs r0, #10
    bl putchar
    pop {r4, pc}
    .ltorg

    @ Busy delay with three ticks per count
delay:
    subs r0, #1
    bne delay
    bx lr

@ ---------------------------------------------------------------------
@ -- Stack manipulation -----------------------------------------------

    defcode "DROP", DROP
    add sp, sp, #4
    NEXT

    defcode "SWAP", SWAP
    pop {r1}
    pop {r0}
    push {r1}
    push {r0}
    NEXT

    defcode "OVER", OVER
    ldr r0, [sp, #4]
    push {r0}
    NEXT

    defcode "ROT", ROT
    pop {r0, r1, r2}
    push {r1}
    push {r0}
    push {r2}
    NEXT

    defcode "?DUP", QDUP
    ldr r0, [sp]
    cmp r0, #0
    beq 1f
    push {r0}
1:  NEXT

    defcode "DUP", DUP
    ldr r0, [sp]
    push {r0}
    NEXT

    defcode "NIP", NIP
    pop {r0}
    pop {r1}
    push {r0}
    NEXT

    defcode "TUCK", TUCK
    pop {r0}
    pop {r1}
    push {r0}
    push {r1}
    push {r0}
    NEXT

    defcode "2DUP", TWODUP
    ldr r1, [sp, #4]
    ldr r0, [sp]
    push {r0, r1}
    NEXT

    defcode "2SWAP", TWOSWAP
    pop {r0, r1, r2, r3}
    push {r1}
    push {r0}
    push {r3}
    push {r2}
    NEXT

    defcode "2DROP", TWODROP
    add sp, sp, #8
    NEXT

    defcode "2OVER", TWOOVER
    ldr r0, [sp, #8]
    ldr r1, [sp, #12]
    push {r1}
    push {r0}
    NEXT

    defcode ">R", TOR
    pop {r0}
    subs r6, r6, #4
    str r0, [r6]
    NEXT

    defcode "R>", RFROM
    ldr r0, [r6]
    adds r6, r6, #4
    push {r0}
    NEXT

    defcode "R@", RFETCH
    ldr r0, [r6]
    push {r0}
    NEXT

    defcode "RDROP", RDROP
    adds r6, r6, #4
    NEXT

    defcode "SP@", SPFETCH
    mov r0, sp
    push {r0}
    NEXT

    defcode "RP@", RPFETCH
    push {r6}
    NEXT

    defcode "SP!", SPSTORE
    pop {r0}
    mov sp, r0
    NEXT

    defcode "RP!", RPSTORE
    pop {r6}
    NEXT

    defword "-ROT", ROTROT
    .word ROT, ROT, EXIT

@ ---------------------------------------------------------------------
@ -- Memory operations -----------------------------------------------

    defconst "CHAR", CHAR, 1
    defconst "CELL", CELL, 4

    defword "CELLS", CELLS
    .word LIT, 4, MUL, EXIT

    defcode "ALIGNED", ALIGNED
    pop {r0}
    adds r0, r0, #3
    mvns r1, #3
    ands r0, r0, r1
    push {r0}
    NEXT

    defcode "C@", FETCHBYTE
    pop {r0}
    ldrb r1, [r0]
    push {r1}
    NEXT

    defcode "C!", STOREBYTE
    pop {r1}
    pop {r0}
    strb r0, [r1]
    NEXT

    defcode "@", FETCH
    pop {r0}
    ldr r1, [r0]
    push {r1}
    NEXT

    defcode "!", STORE
    pop {r1}
    pop {r0}
    str r0, [r1]
    NEXT

    defcode "+!", ADDSTORE
    pop {r1}
    pop {r0}
    ldr r2, [r1]
    adds r2, r2, r0
    str r2, [r1]
    NEXT

    defcode "-!", SUBSTORE
    pop {r1}
    pop {r0}
    ldr r2, [r1]
    subs r2, r2, r0
    str r2, [r1]
    NEXT

    defcode "FILL", FILL
    pop {r2}
fill_code:
    pop {r1}
    pop {r0}
    cmp r1, #0
    beq fill_done
fill_loop:
    strb r2, [r0]
    adds r0, r0, #1
    subs r1, r1, #1
    bne fill_loop
fill_done:
    NEXT

    defword "BLANK", BLANK
    .word BL, FILL, EXIT

    defcode "CMOVE>", CMOVEUP
    pop {r0}
    pop {r1}
    pop {r2}
2:  subs r0, r0, #1
    cmp r0, #0
    blt 1f
    ldrb r3, [r2, r0]
    strb r3, [r1, r0]
    b 2b
1:  NEXT

    defcode "CMOVE", CMOVE
    pop {r0}
    pop {r1}
    pop {r2}
2:  subs r0, r0, #1
    cmp r0, #0
    blt 1f
    ldrb r3, [r2]
    strb r3, [r1]
    adds r1, #1
    adds r2, #1
    b 2b
1:  NEXT

    defcode "S=", SEQU
    pop {r2}
    pop {r1}
    pop {r0}
    push {r4, r5}
1:  cmp r2, #0
    beq 2f
    ldrb r4, [r0]
    adds r0, r0, #1
    ldrb r5, [r1]
    adds r1, r1, #1
    subs r5, r5, r4
    bne 3f
    subs r2, r2, #1
    b 1b
3:  mov r2, r5
2:  pop {r4, r5}
    push {r2}
    NEXT

    .ltorg

    defword "/STRING", TRIMSTRING
    .word ROT, OVER, ADD, ROT, ROT, SUB, EXIT

    defword "COUNT", COUNT
    .word DUP, INCR, SWAP, FETCHBYTE, EXIT

    defword "(S\")", XSQUOTE
    .word RFROM, COUNT, TWODUP, ADD, ALIGNED, TOR, EXIT

    defword ">>SOURCE", GTGTSOURCE
    .word LIT, 1, SOURCEINDEX, ADDSTORE, EXIT

    defword "S\"", SQUOT, F_IMMED
    .word LIT, XSQUOTE, COMMAXT, LIT, '"', WORD
    .word FETCHBYTE, INCR, ALIGNED, ALLOT
    .word GTGTSOURCE, EXIT

    defword "SZ\"", SZQUOT, F_IMMED
    .word LIT, XSQUOTE, COMMAXT, LIT, '"', WORD
    .word LIT, 1, OVER, ADDSTORE, LIT, 0, OVER, DUP, FETCHBYTE, ADD, STOREBYTE
    .word FETCHBYTE, INCR, ALIGNED, ALLOT
    .word GTGTSOURCE, EXIT

    defword "PAD", PAD
    .word HERE, LIT, 128, ADD, EXIT

@ ---------------------------------------------------------------------
@ -- Arithmetic ------------------------------------------------------

    defcode "1+", INCR
    ldr r0, [sp]
    adds r0, r0, #1
    str r0, [sp]
    NEXT

    defcode "1-", DECR
    ldr r0, [sp]
    subs r0, r0, #1
    str r0, [sp]
    NEXT

    defcode "4+", INCR4
    ldr r0, [sp]
    adds r0, r0, #4
    str r0, [sp]
    NEXT

    defcode "4-", DECR4
    ldr r0, [sp]
    subs r0, r0, #4
    str r0, [sp]
    NEXT

    defcode "+", ADD
    pop {r1}
    pop {r0}
    adds r0, r1, r0
    push {r0}
    NEXT

    defcode "-", SUB
    pop {r1}
    pop {r0}
    subs r0, r0, r1
    push {r0}
    NEXT

    defcode "*", MUL
    pop {r0}
    pop {r1}
    muls r0, r1, r0
    push {r0}
    NEXT

    defcode "/MOD", DIVMOD
    pop {r1}
    pop {r0}
    sdiv r2, r0, r1
    mls r0, r1, r2, r0
    push {r0}
    push {r2}
    NEXT

    defcode "/", DIV
    pop {r1}
    pop {r0}
    sdiv r0, r0, r1
    push {r0}
    NEXT

    defcode "MOD", MOD
    pop {r1}
    pop {r0}
    sdiv r2, r0, r1
    mls r0, r1, r2, r0
    push {r0}
    NEXT

    defcode "2*", TWOMUL
    ldr r0, [sp]
    lsls r0, r0, #1
    str r0, [sp]
    NEXT

    defcode "2/", TWODIV
    ldr r0, [sp]
    asrs r0, r0, #1
    str r0, [sp]
    NEXT

    defcode "ABS", ABS
    ldr r0, [sp]
    cmp r0, #0
    bge 1f
    mvns r0, r0
    adds r0, #1
    str r0, [sp]
1:  NEXT

    defcode "MAX", MAX
    pop {r0}
    pop {r1}
    cmp r0, r1
    bge 1f
    mov r0, r1
1:  push {r0}
    NEXT

    defcode "MIN", MIN
    pop {r0}
    pop {r1}
    cmp r0, r1
    ble 1f
    mov r0, r1
1:  push {r0}
    NEXT

    defcode "ROR", ROR
    pop {r0}
    pop {r1}
1:  rors r1, r0
    push {r1}
    NEXT

    defword "ROTATE", ROTATE
    .word DUP, ZGT, ZBRANCH, 1f - ., LIT, 32, SWAP, SUB, ROR, EXIT
1:  .word NEGATE, ROR, EXIT

    defword "NEGATE", NEGATE
    .word LIT, -1, MUL, EXIT

    defword "WITHIN", WITHIN
    .word OVER, SUB, TOR, SUB, RFROM, ULT, EXIT

    defword "BITE", BITE
    .word DUP, LIT, 0xff, AND, SWAP, LIT, 8, ROR, EXIT

    defword "CHEW", CHEW
    .word BITE, BITE, BITE, BITE, DROP, EXIT

@ ---------------------------------------------------------------------
@ -- Boolean operators -----------------------------------------------

    defcode "AND", AND
    pop {r1}
    pop {r0}
    ands r0, r1, r0
    push {r0}
    NEXT

    defcode "OR", OR
    pop {r1}
    pop {r0}
    orrs r0, r1, r0
    push {r0}
    NEXT

    defcode "XOR", XOR
    pop {r1}
    pop {r0}
    eors r0, r1, r0
    push {r0}
    NEXT

    defcode "INVERT", INVERT
    ldr r0, [sp]
    mvns r0, r0
    str r0, [sp]
    NEXT

@ ---------------------------------------------------------------------
@ -- Comparisons -----------------------------------------------------

    defcode "=", EQU
    pop {r1}
    pop {r0}
    movs r2, #0
    cmp r0, r1
    bne 1f
    mvns r2, r2
1:  push {r2}
    NEXT

    defcode "<", LT
    pop {r1}
    pop {r0}
    movs r2, #0
    cmp r0, r1
    bge 1f
    mvns r2, r2
1:  push {r2}
    NEXT

    defcode "U<", ULT
    pop {r1}
    pop {r0}
    movs r2, #0
    cmp r0, r1
    bcs 1f
    mvns r2, r2
1:  push {r2}
    NEXT

    defword ">", GT
    .word SWAP, LT, EXIT

    defword "U>", UGT
    .word SWAP, ULT, EXIT

    defword "<>", NEQU
    .word EQU, INVERT, EXIT

    defword "<=", LE
    .word GT, INVERT, EXIT

    defword ">=", GE
    .word LT, INVERT, EXIT

    defword "0=", ZEQU
    .word LIT, 0, EQU, EXIT

    defword "0<>", ZNEQU
    .word LIT, 0, NEQU, EXIT

    defword "0<", ZLT
    .word LIT, 0, LT, EXIT

    defword "0>", ZGT
    .word LIT, 0, GT, EXIT

    defword "0<=", ZLE
    .word LIT, 0, LE, EXIT

    defword "0>=", ZGE
    .word LIT, 0, GE, EXIT

@ ---------------------------------------------------------------------
@ -- Input/output ----------------------------------------------------

    defconst "#TIB", TIBSIZE, 128

    defword "SOURCE", SOURCE
    .word XSOURCE, FETCH, SOURCECOUNT, FETCH, EXIT

    .ltorg

    defcode ".S", PRINTSTACK
    bl printstack
    NEXT

    defcode ".R", PRINTRSTACK
    bl printrstack
    NEXT

    defcode "EMIT", EMIT
    pop {r0}
    bl putchar
    NEXT

    defword "LF", LF
    .word LIT, 10, EMIT, EXIT

    defword "CR", CR
    .word LIT, 13, EMIT, LF, EXIT

    defconst "BL", BL, 32

    defword "SPACE", SPACE
    .word BL, EMIT, EXIT

    defcode "TYPE", TYPE
    pop {r1}
    pop {r0}
    bl putstring
    NEXT

    defcode ".H", DOTH
    pop {r0}
    bl putsignedhexnumber
    NEXT

    defcode ".UH", DOTUH
    pop {r0}
    bl puthexnumber
    NEXT

    defcode ".D", DOTD
    pop {r0}
    bl putnumber
    NEXT

    defword ".", DOT
    .word DOTH, SPACE, EXIT

    defcode "(KEY)", XKEY
    bl read_key
    push {r0}
    NEXT

    defcode "KEY", KEY
    bl read_widekey
    push {r0}
    NEXT

    defcode "ACCEPT", SIMPLE_ACCEPT
    pop {r1}
    pop {r0}
    bl readline
    push {r0}
    NEXT

    defword "DUMP", DUMP
    .word QDUP, ZBRANCH, dump_end - .
    .word SWAP
dump_start_line:
    .word CR, DUP, DOT, LIT, 58, EMIT, BL, EMIT
dump_line:
    .word DUP, FETCHBYTE, DOT, INCR
    .word SWAP, DECR, QDUP, ZBRANCH, dump_end - .
    .word SWAP, DUP, LIT, 7, AND, ZBRANCH, dump_start_line - .
    .word BRANCH, dump_line - .
dump_end:
    .word DROP, EXIT

    defword "SKIP", SKIP
    .word TOR
1:
    .word OVER, FETCHBYTE, RFETCH, EQU, OVER, ZGT, AND, ZBRANCH, 2f - .
    .word LIT, 1, TRIMSTRING, BRANCH, 1b - .
2:
    .word RDROP, EXIT

    defword "SCAN", SCAN
    .word TOR
1:  .word OVER, FETCHBYTE, RFETCH, NEQU, OVER, ZGT, AND, ZBRANCH, 2f - .
    .word LIT, 1, TRIMSTRING, BRANCH, 1b - .
2:  .word RDROP, EXIT

    defword "?SIGN", ISSIGN
    .word OVER, FETCHBYTE, LIT, 0x2c, SUB, DUP, ABS
    .word LIT, 1, EQU, AND, DUP, ZBRANCH, 1f - .
    .word INCR, TOR, LIT, 1, TRIMSTRING, RFROM
1:  .word EXIT

    defword "DIGIT?", ISDIGIT
    .word DUP, LIT, '9', GT, LIT, 0x100, AND, ADD
    .word DUP, LIT, 0x140, GT, LIT, 0x107, AND, SUB, LIT, 0x30, SUB
    .word DUP, BASE, FETCH, ULT, EXIT

    defword ">NUMBER", TONUMBER
/*
    DUP WHILE
        OVER C@ DIGIT?
        0= IF DROP EXIT THEN
        >R ROT BASE @ *
        R> + ROT ROT
        1 /STRING
    REPEAT ;
*/
tonumber_loop:
    .word DUP, ZBRANCH, tonumber_done - .
    .word OVER, FETCHBYTE, ISDIGIT
    .word ZEQU, ZBRANCH, tonumber_cont - .
    .word DROP, EXIT
tonumber_cont:
    .word TOR, ROT, BASE, FETCH, MUL
    .word RFROM, ADD, ROT, ROT
    .word LIT, 1, TRIMSTRING
    .word BRANCH, tonumber_loop - .
tonumber_done:
    .word EXIT

    defword "?NUMBER", ISNUMBER /* ( c-addr -- n true | c-addr false ) */
    .word DUP, LIT, 0, DUP, ROT, COUNT
    .word ISSIGN, TOR, TONUMBER, ZBRANCH, is_number - .
    .word RDROP, TWODROP, DROP, LIT, 0, EXIT
is_number:
    .word TWOSWAP, TWODROP, DROP, RFROM, ZNEQU, ZBRANCH, is_positive - ., NEGATE
is_positive:
    .word LIT, -1, EXIT

    .ltorg

    defword "DECIMAL", DECIMAL
    .word LIT, 10, BASE, STORE, EXIT

    defword "HEX", HEX
    .word LIT, 16, BASE, STORE, EXIT

    defword "OCTAL", OCTAL
    .word LIT, 8, BASE, STORE, EXIT

@ ---------------------------------------------------------------------
@ -- Control flow -----------------------------------------------------

    defcode "BRANCH", BRANCH
    ldr r0, [r7]
    adds r7, r0
    NEXT

    defcode "0BRANCH", ZBRANCH
    pop {r0}
    cmp r0, #0
    beq code_BRANCH
    adds r7, r7, #4
    NEXT

    defword "BEGIN", BEGIN, F_IMMED
    .word HERE, EXIT

    defword "AGAIN", AGAIN, F_IMMED
    .word LIT, BRANCH, COMMAXT, HERE, SUB, COMMA, EXIT

    defword "UNTIL", UNTIL, F_IMMED
    .word LIT, ZBRANCH, COMMAXT, HERE, SUB, COMMA, EXIT

    defword "IF", IF, F_IMMED
    .word LIT, ZBRANCH, COMMAXT, HERE, DUP, COMMA, EXIT

    defword "ELSE", ELSE, F_IMMED
    .word LIT, BRANCH, COMMAXT, HERE, DUP, COMMA
    .word SWAP, THEN, EXIT

    defword "THEN", THEN, F_IMMED
    .word HERE, OVER, SUB, SWAP, STORE, EXIT

    defword "WHILE", WHILE, F_IMMED
    .word IF, EXIT

    defword "REPEAT", REPEAT, F_IMMED
    .word SWAP, LIT, BRANCH, COMMAXT, HERE, SUB, COMMA
    .word THEN, EXIT

    defword "CASE", CASE, F_IMMED
    .word LIT, 0, EXIT

    defword "OF", OF, F_IMMED
    .word LIT, OVER, COMMA, LIT, EQU, COMMA, IF, LIT, DROP, COMMA, EXIT

    defword "ENDCASE", ENDCASE, F_IMMED
    .word LIT, DROP, COMMA
1:  .word DUP, ZBRANCH, 2f - .
    .word THEN, BRANCH, 1b - .
2:  .word DROP, EXIT

    defcode "(DO)", XDO
    pop {r0, r1}
    ldr r2, [r6]
    str r1, [r6]
    subs r6, r6, #4
    str r0, [r6]
    subs r6, r6, #4
    str r2, [r6]
    NEXT

    defcode "I", INDEX
    ldr r0, [r6, #4]
    push {r0}
    NEXT

    defcode "(LOOP)", XLOOP
    ldr r0, [r6, #4]
    adds r0, r0, #1
    ldr r1, [r6, #8]
    cmp r0, r1
    bge 1f
    str r0, [r6, #4]
    movs r0, #0
    push {r0}
    NEXT
1:  ldr r0, [r6]
    adds r6, r6, #8
    str r0, [r6]
    mvns r0, #0
    push {r0}
    NEXT

    defword "DO", DO, F_IMMED
    .word LIT, XDO, COMMAXT, HERE, EXIT

    defword "LOOP", LOOP, F_IMMED
    .word LIT, XLOOP, COMMAXT, LIT, ZBRANCH, COMMAXT, HERE, SUB, COMMA, EXIT

    defcode "DELAY", DELAY
    pop {r0}
    bl delay
    NEXT

@ ---------------------------------------------------------------------
@ -- Compiler ands interpreter ----------------------------------------

    defcode "BYE", BYE
    movs r0, #0x18
    bkpt 0xab

    defcode "WFI", WFI
    wfi
    NEXT

    defcode "RESET", RESET
    ldr r0, =0xe000ed0c
    ldr r1, =0x05fa0004
    str r1, [r0]

    defcode "HALT", HALT
    b .

    defword "HERE", HERE
    .word DP, FETCH, EXIT

    defword "ALLOT", ALLOT
    .word DP, ADDSTORE, EXIT

    defword ",", COMMA
    .word HERE, STORE, CELL, ALLOT, EXIT

    defword "+FIXUP", ADDFIXUP
    .word ROMTOP, GT, ZBRANCH, 1f - .
    .word FIXUPS, FETCH, QDUP, ZBRANCH, 1f - .
    .word DUP, FETCH, INCR, CELLS, OVER, ADD, HERE, SWAP, STORE
    .word LIT, 1, SWAP, ADDSTORE
1:
    .word EXIT

    defword ",FIXED", COMMAFIXED
    .word DUP, ADDFIXUP, HERE, STORE, CELL, ALLOT, EXIT

    defword ",DEST", COMMADEST
    .word COMMAFIXED, EXIT

    defword ",XT", COMMAXT
    .word COMMAFIXED, EXIT

    defword ",LINK", COMMALINK
    .word COMMAFIXED, EXIT

    defword "C,", CCOMMA
    .word HERE, STOREBYTE, LIT, 1, ALLOT, EXIT

    defword "\'", TICK
    .word BL, WORD, FIND, DROP, EXIT  @ TODO abort if not found

    defword "[\']", BRACKETTICK, F_IMMED
    .word TICK, LIT, LIT, COMMAXT, COMMAXT, EXIT

    defword "(DOES>)", XDOES
    .word RFROM, LATEST, FETCH, FROMLINK, STORE, EXIT

    defword "DOES>", DOES, F_IMMED
    .word LIT, XDOES, COMMAXT
    .word LIT
    ldr.w r1, [pc, #4]
    .word COMMA
    .word LIT
    blx r1
    .short 0
    .word COMMA
    .word LIT, DODOES + 1, COMMA, EXIT

    defword "(CREATE)", XCREATE
    .word HERE, ALIGNED, DP, STORE
    .word LATEST, FETCH
    .word HERE, LATEST, STORE
    .word COMMALINK
    .word BL, WORD, FETCHBYTE, INCR, ALIGNED, ALLOT
    .word EXIT

    defword "CREATE", CREATE
    .word XCREATE, LIT, DOVAR, COMMAXT
    .word EXIT

    defword "DATA", DATA
    .word XCREATE, LIT, DODATA, COMMAXT, EXIT

    defword "VARIABLE", VARIABLE
    .word CREATE, COMMA, CELL, ALLOT, EXIT

    defword "CONSTANT", CONSTANT
    .word CREATE, COMMA, XDOES
    .set DOCONSTANT, .
    adds r0, r0, #4
    ldr r0, [r0]
    push {r0}
    NEXT

    defcode "LIT", LIT
    ldr r0, [r7]
    adds r7, r7, #4
    push {r0}
    NEXT

    defword "DEFER", DEFER
    .word CREATE, LIT, EXIT, COMMA, XDOES
    .set DEFER_XT, .
    ldr.w r1, [pc, #4]
    blx r1
    .byte 0, 0
    .word DODOES + 1, FETCH, EXECUTE, EXIT

    defword "IS", IS
    .word TICK, GTBODY, STORE, EXIT

    defcode "FIND", FIND
    pop {r0}
    mov r10, r0
    ldrb r1, [r0]
    adds r0, r0, #1
    mov r2, r1          @ length
    mov r1, r0          @ address
    ldr r0, =addr_LATEST
    ldr r0, [r0]        @ current dictionary pointer
1:  cmp r0, #0          @ NULL?
    bne 12f
    movs r1, #0
    mov r0, r10
    b 4f              @ end of list!
12: ldrb r3, [r0, #4]       @ flags+length field
    ands r3, r3, #(F_HIDDEN|F_LENMASK)
    cmp r3, r2          @ length the same?
    bne 2f              @ nope, skip this entry
    mov r4, r1          @ current char in string A
    mov r5, r0
    adds r5, r5, #5      @ current char in string B
10: push {r0, r1, r2}
    movs r2, #32
    ldrb r0, [r4]
    adds r4, r4, #1
    ldrb r1, [r5]
    adds r5, r5, #1
    cmp r0, #64
    ble 11f
    cmp r0, #90
    bgt 11f
    orrs r0, r2
11: cmp r1, #64
    ble 12f
    cmp r1, #90
    bgt 12f
    orrs r1, r2
12: mov r8, r0
    mov r9, r1
    pop {r0, r1, r2}
    cmp r8, r9          @ A = B?
    bne 2f              @ nope
    subs r3, r3, #1      @ decrement
    cmp r3, #0
    bne 10b             @ > 0, keep going
    adds r0, r0, #4      @ skip link pointer
    ldrb r1, [r0]       @ load flags+len
    movs r2, #F_IMMED
    ands r2, r1, r2    @ save to check flags
    cmp r2, #0
    beq 13f
    movs r2, #1        @ 1 for immediate words
    b 14f
13: movs r2, #0        @ -1 for normal words
    subs r2, r2, #1
14: adds r0, r0, #1      @ skip flags+len bytes
    ands r1, r1, #F_LENMASK  @ mask out flags
    adds r0, r0, r1      @ skip name
    adds r0, r0, #3      @ align to 4-byte boundary
    mvns r3, #3
    ands r0, r0, r3
    mov r1, r2
    b 4f                @ strings are equal, r0 is the correct entry pointer
2:  ldr r0, [r0]        @ previous dictionary pointer
    b 1b                @ try again
4:  push {r0}
    push {r1}
    NEXT

    .ltorg

    defword "\\", BACKSLASH, F_IMMED
    .word SOURCECOUNT, FETCH, SOURCEINDEX, STORE, EXIT

    defword "(", LPAREN, F_IMMED
    .word LIT, ')', WORD, DROP, EXIT

    defword "WORD", WORD
    .word DUP, SOURCE, SOURCEINDEX, FETCH, TRIMSTRING
    .word DUP, TOR, ROT, SKIP
    .word OVER, TOR, ROT, SCAN
    .word DUP, ZNEQU, ZBRANCH, noskip_delim - ., DECR
noskip_delim:
    .word RFROM, RFROM, ROT, SUB, SOURCEINDEX, ADDSTORE
    .word TUCK, SUB
    .word DUP, HERE, STOREBYTE
    .word HERE, INCR, SWAP, CMOVE
    .word HERE, EXIT

    defword "LINK>", FROMLINK
    .word CELL, ADD, DUP, FETCHBYTE, LIT, F_LENMASK, AND, CHAR, ADD, ADD, ALIGNED, EXIT

    defcode ">NAME", TONAME
    pop {r0}
    mvns r2, #F_IMMED
1:  subs r0, r0, #1
    ldrb r1, [r0]
    ands r1, r2
    cmp r1, #32
    bgt 1b
    cmp r1, #0
    beq 1b
    push {r0}
    NEXT

    .ltorg

    defword ">LINK", TOLINK
    .word TONAME, CELL, SUB, EXIT

    defword ">BODY", GTBODY
    .word CELL, ADD, EXIT

    defcode "EXECUTE", EXECUTE
    pop {r0}
    ldr r1, [r0]
    adds r1, r1, #1
    mov pc, r1

    defword "(INTERPRET)", XINTERPRET @ TODO restructure this
interpret_loop:
    .word BL, WORD, DUP, FETCHBYTE, ZBRANCH, interpret_eol - .
    .word FIND, QDUP, ZBRANCH, interpret_check_number - .
    .word STATE, FETCH, ZBRANCH, interpret_execute - .
    .word INCR, ZBRANCH, interpret_compile_word - .
    .word EXECUTE, BRANCH, interpret_loop - .
interpret_compile_word:
    .word COMMAXT, BRANCH, interpret_loop - .
interpret_execute:
    .word DROP, EXECUTE, BRANCH, interpret_loop - .
interpret_check_number:
    .word ISNUMBER, ZBRANCH, interpret_not_found - .
    .word STATE, FETCH, ZBRANCH, interpret_loop - .
    .word LIT, LIT, COMMAXT, COMMA, BRANCH, interpret_loop - .
interpret_not_found:
    .word LIT, 0, EXIT
interpret_eol:
    .word LIT, -1, EXIT

    defword "EVALUATE", EVALUATE
    .word XSOURCE, STORE
    .word LIT, 0, STATE, STORE
1:
    .word XSOURCE, FETCH, DUP, FETCHBYTE, DUP, LIT, 255, NEQU, ZBRANCH, 2f - .
    .word SOURCECOUNT, STORE, INCR, XSOURCE, STORE, LIT, 0, SOURCEINDEX, STORE, XINTERPRET, ZBRANCH, 3f - ., DROP
    .word SOURCECOUNT, FETCH, XSOURCE, ADDSTORE, BRANCH, 1b - .
2:
    .word TWODROP, EXIT
3:
    .word DROP, DUP, DOT, SPACE, COUNT, TYPE, LIT, '?', EMIT, CR, EXIT

    defword "FORGET", FORGET
    .word BL, WORD, FIND, DROP, TOLINK, FETCH, LATEST, STORE, EXIT

    defword "HIDE", HIDE
    .word LATEST, FETCH, CELL, ADD, DUP, FETCHBYTE, LIT, F_HIDDEN, OR, SWAP, STOREBYTE, EXIT

    defword "REVEAL", REVEAL
    .word LATEST, FETCH, CELL, ADD, DUP, FETCHBYTE, LIT, F_HIDDEN, INVERT, AND, SWAP, STOREBYTE, EXIT

    defword "IMMEDIATE", IMMEDIATE
    .word LATEST, FETCH, CELL, ADD, DUP, FETCHBYTE, LIT, F_IMMED, OR, SWAP, STOREBYTE, EXIT

    defword "[", LBRACKET, F_IMMED
    .word LIT, 0, STATE, STORE, EXIT

    defword "]", RBRACKET
    .word LIT, -1, STATE, STORE, EXIT

    defword ":", COLON
    .word CREATE, HIDE, RBRACKET, LIT, DOCOL, HERE, CELL, SUB, STORE, EXIT

    defword ";", SEMICOLON, F_IMMED
    .word LIT, EXIT, COMMAXT, REVEAL, LBRACKET, EXIT

    defword "WORDS", WORDS
    .word LATEST, FETCH
words_loop:
    .word DUP, CELL, ADD, COUNT, LIT, 31, AND, TYPE, SPACE
    .word FETCH, QDUP, ZEQU, ZBRANCH, words_loop - .
    .word EXIT

@ ---------------------------------------------------------------------
@ -- Disassembler -----------------------------------------------------

    defword "TYPE-ESCAPED", TYPE_ESCAPED
    .word QDUP, ZBRANCH, 0x4c
    .word SWAP, DUP, CFETCH, DUP, LIT, '"', EQU, ZBRANCH, 0x10
    .word LIT, '\\', EMIT
    .word EMIT, ONEPLUS, SWAP, ONEMINUS, BRANCH, 0xffffffb0, DROP, EXIT

    defword "QUOTE-CHAR", QUOTE_CHAR
    .word LIT, QUOTE_CHARS
2:  .word TWODUP, FETCHBYTE, DUP, ZNEQU, ZBRANCH, 3f - ., NEQU, ZBRANCH, 1f - .
    .word CHAR, ADD, DUP, FETCHBYTE, ADD, CHAR, ADD, BRANCH, 2b - .
1:  .word CHAR, ADD, NIP, LIT, -1, EXIT
3:  .word TWODROP, DROP, LIT, 0, EXIT

QUOTE_MINUS:
    .ascii "-\005MINUS"
QUOTE_CHARS:
    .ascii "-\001_"
    .ascii "0\001Z"
    .ascii "1\003ONE"
    .ascii "2\003TWO"
    .ascii "`\010BACKTICK"
    .ascii "~\005TILDE"
    .ascii "!\005STORE"
    .ascii "@\005FETCH"
    .ascii "\"\004QUOT"
    .ascii "#\003NUM"
    .ascii "$\003VAL"
    .ascii "%\007PERCENT"
    .ascii "^\005CARET"
    .ascii "&\003AND"
    .ascii "*\003MUL"
    .ascii "(\006LPAREN"
    .ascii ")\006RPAREN"
    .ascii "+\004PLUS"
    .ascii "=\003EQU"
    .ascii "[\005LBRAC"
    .ascii "]\005RBRAC"
    .ascii "\\\011BACKSLASH"
    .ascii "{\006LBRACE"
    .ascii "}\006RBRACE"
    .ascii "|\003BAR"
    .ascii ";\004SEMI"
    .ascii ":\005COLON"
    .ascii "'\004TICK"
    .ascii ",\005COMMA"
    .ascii ".\003DOT"
    .ascii "/\005SLASH"
    .ascii "<\002LT"
    .ascii ">\002GT"
    .ascii "?\001Q"
    .byte 0

    defword ".QUOTED", DOTQUOTED
    .word OVER, FETCHBYTE, LIT, '-', EQU, ZBRANCH, 1f - .
    .word SWAP, LIT, QUOTE_MINUS + 1, BRANCH, 5f - .
1:  .word DUP, ZGT, ZBRANCH, 4f - .
    .word DUP, LIT, 1, EQU, ZBRANCH, 6f - .
    .word OVER, FETCHBYTE, LIT, '-', EQU, ZBRANCH, 6f - .
    .word SWAP, LIT, QUOTE_MINUS + 1, BRANCH, 5f - .
6:  .word SWAP, DUP, FETCHBYTE, QUOTE_CHAR, ZBRANCH, 2f - . 
5:  .word COUNT, TYPE, BRANCH, 3f - .
2:  .word EMIT 
3:  .word INCR, SWAP, DECR, BRANCH, 1b - .
4:  .word TWODROP, EXIT

    defword "VALID-ADDR?", ISVALIDADDR
    .word DUP, LIT, 0x400, LIT, last_word, WITHIN, QDUP, ZBRANCH, 1f - .
    .word NIP, EXIT
1:  .word LIT, ram_start, LIT, ram_top, WITHIN, EXIT
    

    defword "XT?", XTQ
    .word DUP, ISVALIDADDR, ZBRANCH, 2f - .
    .word LATEST
1:  .word FETCH, TWODUP, FROMLINK, EQU, OVER, ZEQU, OR, ZBRANCH, 1b - ., NIP, ZNEQU, EXIT
2:  .word DROP, LIT, 0, EXIT

    defword "ANY>LINK", ANYTOLINK
    .word LATEST
1:  .word FETCH, TWODUP, GT, ZBRANCH, 1b - .
    .word NIP, EXIT

    defword "NEXT-WORD", NEXT_WORD
    .word LATEST, FETCH
    .word TWODUP, EQU, ZBRANCH, 1f - .
    .word TWODROP, HERE, EXIT
1:  .word TWODUP, FETCH, NEQU, ZBRANCH, 2f - .
    .word FETCH, BRANCH, 1b - .
2:  .word SWAP, DROP, EXIT

    defword "(.CSPACE)", XCSPACE
    .word LIT, ',', EMIT, SPACE, EXIT

    defword "(.WORD-FLAGS)", XWORD_FLAGS
    .word TONAME, FETCH, LIT, 0xc0, AND, XCSPACE, DOTH, EXIT

    defword "(.WORD-NAME)", XWORD_NAME
    .word LIT, '"', EMIT, TONAME, COUNT, LIT, 31, AND, TWODUP, TYPE_ESCAPED
    .word LIT, 1f, COUNT, TYPE, DOTQUOTED, EXIT
1:  .ascii "\003\", "

    defword ".SQUOTE", DOTSQUOTE
    .word TONAME, COUNT, DOTQUOTED, XCSPACE, DROP, CELL, ADD, DUP, FETCHBYTE, CHAR, ADD, ALIGNED, DUP, ROTROT
1:  .word SWAP, DUP, FETCH, DOTH, OVER, CELL, NEQU, ZBRANCH, 2f - ., XCSPACE
2:  .word CELL, ADD, SWAP, CELL, SUB, DUP, ZEQU, ZBRANCH, 1b - .
    .word TWODROP, CELL, ADD, EXIT

    defword ".DOCOL-HEADER", DOTDOCOL_HEADER
    .word LIT, 1f, COUNT, TYPE, DUP, XWORD_NAME, XWORD_FLAGS, EXIT
1:  .ascii "\015\n    defword "

    defword ".DOCOL", DOTDOCOL
    .word DOTDOCOL_HEADER, LIT, 1f, COUNT, TYPE, EXIT
1:  .ascii "\013\n    .word "

    defword ".DOVAR", DOTDOVAR
    .word LIT, 1f, COUNT, TYPE, XWORD_NAME, XCSPACE, TWODUP, SUB, LIT, 2, CELLS, SUB, DOTH, LF, EXIT
1:  .ascii "\014\n    defvar "

    defword ".DOCON", DOTDOCON
    .word LIT, 1f, COUNT, TYPE, XWORD_NAME, XCSPACE, DUP, CELL, ADD, FETCH, DOTH, LF, EXIT
1:  .ascii "\016\n    defconst "

    defword ".DODATA", DOTDODATA
    .word LIT, 1f, COUNT, TYPE, XWORD_NAME, LIT, 2f, COUNT, TYPE, EXIT
1:  .ascii "\015\n    defdata "
2:  .ascii "\013\n    .word "

    defword ".DOTDODOES", DOTDODOES
    .word SWAP, DOTDOCOL_HEADER, XCSPACE, ANYTOLINK, CELL, ADD, COUNT, DOTQUOTED
    .word LIT, 1f, COUNT, TYPE, EXIT
1:  .ascii "\016_XT\n    .word "

    defword ".WORD", DOTWORD
    .word DUP, DUP, FETCH, CELL, SUB, OVER, NEQU, ZBRANCH, print_code - .
    .word DUP, FETCH
    .word DUP, ISVALIDADDR, ZBRANCH, 1f - .
    .word DUP, LIT, DOCOL, NEQU, ZBRANCH, print_docol - .
    .word DUP, LIT, DOVAR, NEQU, ZBRANCH, print_dovar - .
    .word DUP, LIT, DOCON, NEQU, ZBRANCH, print_docon - .
    .word DUP, LIT, DODATA, NEQU, ZBRANCH, print_dodata - .
    .word DUP, LIT, DOCONSTANT, NEQU, ZBRANCH, print_docon - .
    .word DUP, LIT, XDOES, NEQU, ZBRANCH, print_xdoes - .
    .word DUP, LIT, XSQUOTE, NEQU, ZBRANCH, print_xsquote - .
    .word DUP, FETCH, LIT, 0x1004f8df, NEQU, ZBRANCH, print_dodoes - .
    .word DUP, XTQ, ZBRANCH, 1f - .
    .word TONAME, COUNT, LIT, 31, AND, DOTQUOTED, TWODROP, CELL, EXIT
1:  .word DOTUH, TWODROP, CELL, EXIT
print_code:
    .word DROP, LIT, print_label_code, COUNT, TYPE, DROP, CELL, EXIT
print_docol:
    .word DROP, DOTDOCOL, DROP, CELL, EXIT
print_dovar:
    .word DROP, DOTDOVAR, TWODROP, LIT, 0, EXIT
print_docon:
    .word DROP, DOTDOCON, TWODROP, LIT, 0, EXIT
print_dodata:
    .word DROP, DOTDODATA, DROP, CELL, EXIT
print_xdoes:
    .word TONAME, COUNT, DOTQUOTED
    .word LIT, print_xdoes_xt, COUNT, TYPE, DUP, ANYTOLINK, CELL, ADD, COUNT, DOTQUOTED
    .word LIT, print_xt_suffix, COUNT, TYPE
    .word CELL, ADD, DUP, FETCH, DOTH, XCSPACE, CELL, ADD, FETCH, DOTH, XCSPACE, LIT, print_label_dodoes, COUNT, TYPE
    .word DROP, LIT, 4, CELLS, EXIT
print_xsquote:
    .word DOTSQUOTE, EXIT
print_dodoes:
    .word DOTDODOES, DROP, CELL, EXIT
print_label_code:
    .ascii "\004CODE"
print_label_lit:
    .ascii "\003LIT"
print_label_branch:
    .ascii "\006BRANCH"
print_label_zbranch:
    .ascii "\007ZBRANCH"
print_label_dodoes:
    .ascii "\012DODOES + 1"
print_xdoes_xt:
    .ascii "\012\n    .set "
print_xt_suffix:
    .ascii "\021_XT, .\n    .word "
    .align 2

    defword "(SEE)", XSEE
    .word DUP, TOLINK, NEXT_WORD
    .word OVER, DOTWORD, DUP, ZBRANCH, 2f - .
    .word ROT, ADD, SWAP
    .word TWODUP, NEQU, ZBRANCH, 2f - .
1:  .word OVER, DOTWORD, DUP, ZBRANCH, 2f - .
    .word ROT, ADD, SWAP
    .word TWODUP, NEQU, ZBRANCH, 2f - .
    .word XCSPACE, BRANCH, 1b - .
2:  .word TWODROP
    .word LF, EXIT

    defword "SEE", SEE
    .word BL, WORD, FIND, ZBRANCH, 3f - .
    .word XSEE
3:  .word EXIT

    defword "SEE-RANGE", SEE_RANGE
1:  .word DUP, XSEE, TOLINK, FETCH, FROMLINK, TWODUP, EQU, ZBRANCH, 1b - ., TWODROP, EXIT

    defword "PRECOMP-BEGIN", PRECOMP_BEGIN
    .word LATEST, FETCH, FROMLINK, EXIT

    defword "PRECOMP-END", PRECOMP_END
    .word LATEST, FETCH, FROMLINK, SEE_RANGE, BYE

@ ---------------------------------------------------------------------
@ -- User variables ---------------------------------------------------

    defconst "ROMTOP", ROMTOP, end_of_rom
    defconst "CORETOP", CORETOP, end_of_core
    defconst "LATESTROM", LATESTROM, last_rom_word
    defconst "LATESTCORE", LATESTCORE, last_core_word
    defconst "C/BLK", CSLASHBLK, 1024
    defvar "STACK", STACK, 512
    defvar "S0", TOS, 0
    defvar "RSTACK", RSTACK, 256
    defvar "R0", RTOS, 0
    defvar "STATE", STATE
    defvar "DP", DP
    defvar "LATEST", LATEST
    defvar "BASE", BASE
    defvar "TIB", TIB, 132
    defvar ">TIB", TIBINDEX
    defvar "TIB#", TIBCOUNT
    defvar "(SOURCE)", XSOURCE
    defvar "SOURCE#", SOURCECOUNT
    defvar ">SOURCE", SOURCEINDEX
    defvar "FIXUPS", FIXUPS

    .ltorg

@ ---------------------------------------------------------------------
@ -- Symbol aliases ---------------------------------------------------

    .set PLUS, ADD
    .set MINUS, SUB
    .set SZ, TOS
    .set RZ, RTOS
    .set LPARENSOURCERPAREN, XSOURCE
    .set SOURCENUM, SOURCECOUNT
    .set GTSOURCE, SOURCEINDEX
    .set GTR, TOR
    .set RGT, FRROM
    .set LPARENSQUOTRPAREN, XSQUOTE
    .set GTTIB, TIBINDEX
    .set CMOVEGT, CMOVEUP
    .set CSTORE, STOREBYTE
    .set CFETCH, FETCHBYTE
    .set PLUSSTORE, ADDSTORE
    .set MINUSSTORE, SUBSTORE
    .set ONEPLUS, INCR
    .set ONEMINUS, DECR
    .set MINUSROT, ROTROT
    .set NUMTIB, TIBSIZE
    .set TIBNUM, TIBCOUNT
    .set LPARENINTERPRETRPAREN, XINTERPRET
    .set LPARENDORPAREN, XDO
    .set LPARENLOOPRPAREN, XLOOP
    .set LPARENDOESGTRPAREN, XDOES
    .set I, INDEX
    .set TWOSLASH, TWODIV
    .set LTGT, NEQU
    .set SLASHMOD, DIVMOD
    .set DOTS, PRINTSTACK
    .set LBRAC, LBRACKET
    .set RBRAC, RBRACKET
    .set LINKGT, FROMLINK
    .set SEMI, SEMICOLON

@ ---------------------------------------------------------------------

    .set last_core_word, link
    .set end_of_core, .


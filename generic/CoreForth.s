@ -- vim:syntax=asm:foldmethod=marker:foldmarker=@\ --\ ,@\ ---:

@ ---------------------------------------------------------------------
@ -- Variable definitions ---------------------------------------------

    .set F_IMMED,           0x01
    .set F_HIDDEN,          0x20
    .set F_NODISASM,        0x40
    .set F_LENMASK,         0x1f
    .set F_MARKER,          0x80
    .set F_FLAGSMASK,       0x7f

    .set link,                 0
    .set ram_here, ram_start

@ ---------------------------------------------------------------------
@ -- Macros -----------------------------------------------------------

    .macro NEXT
    ldr r0, [r7]
    adds r7, r7, #4
    ldr r1, [r0]
    adds r1, r1, #1
    bx r1
    .endm

    .macro checkdef name
    .ifdef \name
    .print "Redefining \name"
    .endif
    .endm

    .macro defword name, label, flags=0, xt=DOCOL
    .align 2, 0
    checkdef \label
    .global name_\label
    .set name_\label , .
    .int link
    .set link, name_\label
    .byte \flags | F_MARKER
    .byte (99f - 98f)
98:
    .ascii "\name"
99:
    .align  2, 0
    .global \label
    .set \label , .
    .int \xt
    @ parameter field follows
    .endm

    .macro defcode name, label, flags=0
    .align 2, 0
    .global name_\label
    checkdef \label
    .set name_\label , .
    .int link
    .set link, name_\label
    .byte \flags | F_MARKER
    .byte (99f - 98f)
98:
    .ascii "\name"
99:
    .align 2, 0
    .global \label
    checkdef \label
    .set \label , .
    .int code_\label
    .global code_\label
    .set code_\label , .
    @ parameter field follows
    .endm

    .macro defconst name, label, value
    .align 2, 0
    .global name_\label
    checkdef \label
    .set name_\label , .
    .int link
    .set link, name_\label
    .byte F_MARKER
    .byte (99f - 98f)
98:
    .ascii "\name"
99:
    .align 2, 0
    .global \label
    .set \label , .
    .int DOCON
    .set constaddr_\label , .
    .word \value
    .endm

    .macro defvar name, label, size=4
    defconst \name,\label,ram_here
    .set addr_\label, ram_here
    .set ram_here, ram_here + \size
    .endm

    .macro defdata name, label
    defword \name,\label,,DODATA
    .endm

@ ---------------------------------------------------------------------
@ -- Entry point ------------------------------------------------------

reset_handler:
    bl init_board
    movs r0, 64
    ldr r6, =addr_TASKZRTOS
    ldr r7, =cold_start
    NEXT
cold_start:
    .word TASKZ, UPSTORE
    .word TASKZRTOS, RZ, STORE
    .word TASKZTOS, SZ, STORE
    .word LIT, 10, BASE, STORE
    .word LIT, data_start, DP, STORE
    .word LIT, last_word, LATEST, STORE
    .word SERIAL_CON
    .word COLD
    .ltorg

@ ---------------------------------------------------------------------
@ -- Interpreter code -------------------------------------------------

DOCOL:
    adds r6, r6, #4
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
    adds r6, r6, #4
    str r7, [r6]
    mov r7, lr
    adds r7, r7, #3
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
    subs r6, r6, #4
    NEXT

@ ---------------------------------------------------------------------
@ -- Helper code ------------------------------------------------------

putstring:
    cmp r1, #0
    bgt 1f
    mov pc, lr
1:  push {r4, r5, lr}
    mov r5, r0
    mov r4, r1
putstring_loop:
    ldrb r0, [r5]
    adds r5, r5, #1
    bl putchar
    subs r4, r4, #1
    bgt putstring_loop
    pop {r4, r5, pc}

readline:
    push {r3, r4, r5, lr}
    mov r4, r0
    mov r5, r0
    movs r3, r1
    beq readline_end
readline_loop:
    bl readkey
    cmp r0, #10
    beq readline_end
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
    adds r3, r3, #1
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
    subs r3, r3, #1
    bgt readline_loop
readline_end:
    subs r0, r5, r4
    pop {r3, r4, r5, pc}

puthexnumber:
    push {r4, r5, r6, r7, lr}
    movs r3, #0
    movs r5, #8
    movs r6, #15
    movs r7, #28
puthexnumber_loop:
    rors r0, r7
    mov r4, r0
    ands r0, r6
    cmp r3, #0
    bgt 3f
    cmp r0, #0
    beq 2f
    movs r3, #1
3:  adds r0, r0, #'0'
    cmp r0, #'9'
    ble 1f
    adds r0, r0, #'A' - '0' - 10
1:  bl putchar
2:  mov r0, r4
    subs r5, r5, #1
    bne puthexnumber_loop
    cmp r3, #0
    bne 4f
    movs r0, #'0'
    bl putchar
4:  pop {r4, r5, r6, r7, pc}

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

printrstack:
    push {r4, lr}
    ldr r4, =addr_TASKZRTOS
    adds r4, r4, #4
1:  ldr r0, [r4]
    bl puthexnumber
    movs r0, #32
    bl putchar
    cmp r4, r6
    beq 2f
    adds r4, r4, #4
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
    adds r6, r6, #4
    str r0, [r6]
    NEXT

    defcode "R>", RFROM
    ldr r0, [r6]
    subs r6, r6, #4
    push {r0}
    NEXT

    defcode "R@", RFETCH
    ldr r0, [r6]
    push {r0}
    NEXT

    defcode "RDROP", RDROP
    subs r6, r6, #4
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
    movs r1, #3
    mvns r1, r1
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

    defcode "H@", HFETCH
    pop {r0}
    ldrh r1, [r0]
    push {r1}
    NEXT

    defcode "H!", HSTORE
    pop {r1}
    pop {r0}
    strh r0, [r1]
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

    defword "2!", TWOSTORE
    .word SWAP, OVER, STORE, CELL, ADD, STORE, EXIT

    defword "2@", TWOFETCH
    .word DUP, CELL, ADD, FETCH, SWAP, FETCH, EXIT

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

    defcode "ALIGNED-MOVE>", ALIGNED_MOVEGT
    pop {r0}
    pop {r1}
    pop {r2}
2:  subs r0, r0, #4
    cmp r0, #0
    blt 1f
    ldr r3, [r2, r0]
    str r3, [r1, r0]
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
    .word LIT_XT, XSQUOTE, COMMAXT, LIT, '"', WORD
    .word FETCHBYTE, INCR, ALIGNED, ALLOT
    .word GTGTSOURCE, EXIT

    defword ".\"", DOTQUOT, F_IMMED
    .word SQUOT, LIT_XT, TYPE, COMMAXT, EXIT

    defword "SZ\"", SZQUOT, F_IMMED
    .word LIT_XT, XSQUOTE, COMMAXT, LIT, '"', WORD
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

    .ifndef THUMB1
    defcode "U/MOD", UDIVMOD
    pop {r1}
    pop {r0}
    udiv r2, r0, r1
    mls r0, r1, r2, r0
    push {r0}
    push {r2}
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

    defcode "UMOD", UMOD
    pop {r1}
    pop {r0}
    udiv r2, r0, r1
    mls r0, r1, r2, r0
    push {r0}
    NEXT

    .else

unsigned_div_mod:               @ r0 / r1 = r3, remainder = r0
    mov     r2, r1              @ put divisor in r2
    mov     r3, r0
    lsrs    r3, #1
1:  cmp     r2, r3
    bgt     3f
    lsls    r2, #1              @ until r2 > r3 / 2
    b       1b
3:  movs    r3, #0              @ initialize quotient
2:  adds    r3, r3              @ double quotien
    cmp     r0, r2              @ can we subtract r2?
    blo     4f
    adds    r3, #1              @ if we can, increment quotiend
    subs    r0, r0, r2          @ and substract
4:  lsrs    r2, #1              @ halve r2,
    cmp     r2, r1              @ and loop until
    bhs     2b                  @ less than divisor
    bx      lr

    defcode "U/MOD", UDIVMOD
    pop {r1}
    pop {r0}
    bl unsigned_div_mod
    push {r0}
    push {r3}
    NEXT

    defcode "/MOD", DIVMOD
    pop {r1}
    pop {r0}
    bl unsigned_div_mod
    push {r0}
    push {r3}
    NEXT

    defcode "/", DIV
    pop {r1}
    pop {r0}
    movs r3, #0
    movs r4, #1
    movs r5, #1
    cmp r0, r3
    bge 1f
    subs r4, #2
    muls r0, r4
1:  cmp r1, r3
    bge 2f
    subs r5, #2
    muls r1, r5
2:  bl unsigned_div_mod
    muls r3, r4
    muls r3, r5
    push {r3}
    NEXT

    defcode "MOD", MOD
    pop {r1}
    pop {r0}
    movs r3, #0
    movs r4, #1
    movs r5, #0
    subs r5, #1
    cmp r0, r3
    bge 1f
    subs r4, #2
    muls r0, r4
1:  cmp r1, r3
    bge 2f
    muls r1, r5
2:  bl unsigned_div_mod
    muls r0, r4
    push {r0}
    NEXT

    defcode "UMOD", UMOD
    pop {r1}
    pop {r0}
    bl unsigned_div_mod
    push {r0}
    NEXT
    .endif

    defcode "2*", TWOMUL
    ldr r0, [sp]
    .ifndef THUMB1
    lsls r0, r0, #1
    .endif
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
    .word DUP, ZGT, QBRANCH, 1f - ., LIT, 32, SWAP, SUB, ROR, EXIT
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
    defconst "C/BLK", CSLASHBLK, 1024

    defword "SOURCE", SOURCE
    .word XSOURCE, FETCH, SOURCECOUNT, FETCH, EXIT

    .ltorg

    defword ".S", PRINTSTACK
    .word SPFETCH, SZ, FETCH
1:  .word TWODUP, LTGT, QBRANCH, 2f - ., CELL, MINUS, DUP, FETCH, DOT, BRANCH, 1b - .
2:  .word TWODROP, CR, EXIT

    defcode ".R", PRINTRSTACK
    bl printrstack
    NEXT

    defcode "PUTCHAR", PUTCHAR
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

    defword "HOLD", HOLD
    .word LIT, 1, HP, SUBSTORE, HP, FETCH, CSTORE, EXIT

    defword "<#", LTNUM
    .word PAD, HP, STORE, EXIT

    defword ">DIGIT", TODIGIT
    .word DUP, LIT, 9, GT, LIT, 7, AND, PLUS, LIT, 48, PLUS, EXIT

    defword "#", NUM
    .word BASE, FETCH, UDIVMOD, SWAP, TODIGIT, HOLD, EXIT

    defword "#S", NUMS
1:  .word NUM, DUP, ZEQU, QBRANCH, 1b - ., EXIT

    defword "#>", NUMGT
    .word DROP, HP, FETCH, PAD, OVER, SUB, EXIT

    defword "SIGN", SIGN
    .word ZLT, QBRANCH, 1f - .
    .word LIT, '-', HOLD
1:  .word EXIT

    defword "U.", UDOT
    .word LTNUM, NUMS, NUMGT, TYPE, SPACE, EXIT

    defword ".", DOT
    .word LTNUM, DUP, ABS, NUMS, SWAP, SIGN, NUMGT, TYPE, SPACE, EXIT

    defcode ".UX", DOTUX
    movs r0, '0'
    bl putchar
    movs r0, 'x'
    bl putchar
    pop {r0}
    bl puthexnumber
    NEXT

    defcode "READ-KEY", READ_KEY
    bl readkey
    push {r0}
    NEXT

    defcode "READ-LINE", READ_LINE
    ldr r0, =constaddr_TIB
    ldr r0, [r0]
    ldr r1, =constaddr_TIBSIZE
    ldr r1, [r1]
    bl readline
    push {r0}
    NEXT

    .ltorg

    defword "WAIT-KEY", WAIT_KEY
    .word TICKWAIT_KEY, FETCH, EXECUTE, EXIT

    defword "FINISH-OUTPUT", FINISH_OUTPUT
    .word TICKFINISH_OUTPUT, FETCH, EXECUTE, EXIT

    defword "(KEY)", XKEY
    .word WAIT_KEY, READ_KEY, EXIT

    defword "KEY", KEY
    .word TICKKEY, FETCH, EXECUTE, EXIT

    defword "(EMIT)", XEMIT
    .word FINISH_OUTPUT, PUTCHAR, EXIT

    defcode "(TYPE)", XTYPE
    pop {r1}
    pop {r0}
    bl putstring
    NEXT

    defword "ACCEPT", ACCEPT
    .word TICKACCEPT, FETCH, EXECUTE, EXIT

    defword "EMIT", EMIT
    .word TICKEMIT, FETCH, EXECUTE, EXIT

    defword "TYPE", TYPE
    .word TICKTYPE, FETCH, EXECUTE, EXIT

    defword "4NUM", FOURNUM
    .word NUM, NUM, NUM, NUM, EXIT

    defword "SERIAL-CON", SERIAL_CON
    .word LIT_XT, NOOP, DUP, TICKWAIT_KEY, STORE, TICKFINISH_OUTPUT, STORE
    .word LIT_XT, XKEY, TICKKEY, STORE
    .word LIT_XT, XEMIT, TICKEMIT, STORE
    .word LIT_XT, XTYPE, TICKTYPE, STORE
    .word LIT_XT, READ_LINE, TICKACCEPT, STORE
    .word EXIT


    defword "(DUMP-ADDR)", XDUMP_ADDR
    .word CR, DUP, LTNUM, FOURNUM, FOURNUM, NUMGT, TYPE, LIT, 58, EMIT, SPACE, EXIT

    defword "DUMP", DUMP
    .word BASE, FETCH, TOR, HEX, QDUP, QBRANCH, dump_end - .
    .word SWAP
dump_start_line:
    .word XDUMP_ADDR
dump_line:
    .word DUP, FETCHBYTE, LTNUM, NUM, NUM, NUMGT, TYPE, SPACE, INCR
    .word SWAP, DECR, QDUP, QBRANCH, dump_end - .
    .word SWAP, DUP, LIT, 7, AND, QBRANCH, dump_start_line - .
    .word BRANCH, dump_line - .
dump_end:
    .word DROP, RFROM, BASE, STORE, EXIT

    defword "DUMPW", DUMPW
    .word BASE, FETCH, TOR, HEX, QDUP, QBRANCH, dumpw_end_final - .
    .word SWAP
dumpw_start_line:
    .word XDUMP_ADDR
dumpw_line:
    .word DUP, FETCH, LTNUM, FOURNUM, FOURNUM, NUMGT, TYPE, SPACE, INCR4
    .word SWAP, DECR4, DUP, ZGT, QBRANCH, dumpw_end - .
    .word SWAP, DUP, LIT, 0x1f, AND, QBRANCH, dumpw_start_line - .
    .word BRANCH, dumpw_line - .
dumpw_end:
    .word DROP
dumpw_end_final:
    .word DROP, RFROM, BASE, STORE, EXIT

    defword "SKIP", SKIP
    .word TOR
1:
    .word OVER, FETCHBYTE, RFETCH, EQU, OVER, ZGT, AND, QBRANCH, 2f - .
    .word LIT, 1, TRIMSTRING, BRANCH, 1b - .
2:
    .word RDROP, EXIT

    defword "SCAN", SCAN
    .word TOR
1:  .word OVER, FETCHBYTE, RFETCH, NEQU, OVER, ZGT, AND, QBRANCH, 2f - .
    .word LIT, 1, TRIMSTRING, BRANCH, 1b - .
2:  .word RDROP, EXIT

    defword "?SIGN", ISSIGN
    .word OVER, FETCHBYTE, LIT, 0x2c, SUB, DUP, ABS
    .word LIT, 1, EQU, AND, DUP, QBRANCH, 1f - .
    .word INCR, TOR, LIT, 1, TRIMSTRING, RFROM
1:  .word EXIT

    defword "DIGIT?", ISDIGIT
    .word DUP, LIT, '9', GT, LIT, 0x100, AND, ADD
    .word DUP, LIT, 0x140, GT, LIT, 0x107, AND, SUB, LIT, 0x30, SUB
    .word DUP, BASE, FETCH, ULT, EXIT

    defword "SETBASE", SETBASE
    .word OVER, FETCHBYTE
    .word DUP, LIT, '$', EQU, QBRANCH, 1f - ., HEX, BRANCH, 4f - .
1:  .word DUP, LIT, '#', EQU, QBRANCH, 2f - ., DECIMAL, BRANCH, 4f - .
2:  .word DUP, LIT, '%', EQU, QBRANCH, 3f - ., BINARY, BRANCH, 4f - .
3:  .word DROP, EXIT
4:  .word DROP, LIT, 1, TRIMSTRING, EXIT

    defword ">NUMBER", TONUMBER
    .word BASE, FETCH, TOR, SETBASE
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
    .word DUP, QBRANCH, tonumber_done - .
    .word OVER, FETCHBYTE, ISDIGIT
    .word ZEQU, QBRANCH, tonumber_cont - .
    .word DROP, BRANCH, tonumber_done - .
tonumber_cont:
    .word TOR, ROT, BASE, FETCH, MUL
    .word RFROM, ADD, ROT, ROT
    .word LIT, 1, TRIMSTRING
    .word BRANCH, tonumber_loop - .
tonumber_done:
    .word RFROM, BASE, STORE, EXIT

    defword "?NUMBER", ISNUMBER /* ( c-addr -- n true | c-addr false ) */
    .word DUP, LIT, 0, DUP, ROT, COUNT
    .word ISSIGN, TOR, TONUMBER, QBRANCH, is_number - .
    .word RDROP, TWODROP, DROP, LIT, 0, EXIT
is_number:
    .word TWOSWAP, TWODROP, DROP, RFROM, ZNEQU, QBRANCH, is_positive - ., NEGATE
is_positive:
    .word LIT, -1, EXIT

    .ltorg

    defword "DECIMAL", DECIMAL
    .word LIT, 10, BASE, STORE, EXIT

    defword "HEX", HEX
    .word LIT, 16, BASE, STORE, EXIT

    defword "OCTAL", OCTAL
    .word LIT, 8, BASE, STORE, EXIT

    defword "BINARY", BINARY
    .word LIT, 2, BASE, STORE, EXIT

@ ---------------------------------------------------------------------
@ -- Control flow -----------------------------------------------------

    defcode "NOOP", NOOP
    NEXT

    defcode "BRANCH", BRANCH
    ldr r0, [r7]
    adds r7, r0
    NEXT

    defcode "?BRANCH", QBRANCH
    pop {r0}
    cmp r0, #0
    beq code_BRANCH
    adds r7, r7, #4
    NEXT

    defword "POSTPONE", POSTPONE, F_IMMED
    .word BL, WORD, FIND
    .WORD ZLT, QBRANCH,  1f - .
    .word LIT_XT, LIT_XT, COMMAXT, COMMA
    .WORD LIT_XT, COMMAXT, COMMAXT, BRANCH,  2f - .
1:  .word COMMAXT
2:  .word EXIT

    defword "LITERAL", LITERAL, F_IMMED
    .word LIT_XT, LIT, COMMAXT, COMMA, EXIT

    defword "BEGIN", BEGIN, F_IMMED
    .word HERE, EXIT

    defword "AGAIN", AGAIN, F_IMMED
    .word LIT_XT, BRANCH, COMMAXT, HERE, SUB, COMMA, EXIT

    defword "UNTIL", UNTIL, F_IMMED
    .word LIT_XT, QBRANCH, COMMAXT, HERE, SUB, COMMA, EXIT

    defword "IF", IF, F_IMMED
    .word LIT_XT, QBRANCH, COMMAXT, HERE, DUP, COMMA, EXIT

    defword "ELSE", ELSE, F_IMMED
    .word LIT_XT, BRANCH, COMMAXT, HERE, DUP, COMMA
    .word SWAP, THEN, EXIT

    defword "THEN", THEN, F_IMMED
    .word HERE, OVER, SUB, SWAP, STORE, EXIT

    defword "WHILE", WHILE, F_IMMED
    .word IF, EXIT

    defword "REPEAT", REPEAT, F_IMMED
    .word SWAP, LIT_XT, BRANCH, COMMAXT, HERE, SUB, COMMA
    .word THEN, EXIT

    defword "CASE", CASE, F_IMMED
    .word LIT, 0, EXIT

    defword "OF", OF, F_IMMED
    .word LIT_XT, OVER, COMMA, LIT_XT, EQU, COMMA, IF, LIT_XT, DROP, COMMA, EXIT

    defword "ENDCASE", ENDCASE, F_IMMED
    .word LIT_XT, DROP, COMMA
1:  .word DUP, QBRANCH, 2f - .
    .word THEN, BRANCH, 1b - .
2:  .word DROP, EXIT

    defcode "(DO)", XDO
    pop {r0, r1}
    ldr r2, [r6]
    str r1, [r6]
    adds r6, r6, #4
    str r0, [r6]
    adds r6, r6, #4
    str r2, [r6]
    NEXT

    defcode "I", INDEX
    .ifndef THUMB1
    ldr r0, [r6, #-4]
    .else
    mov r0, r6
    subs r0, #4
    ldr r0, [r0]
    .endif
    push {r0}
    NEXT

    defcode "(LOOP)", XLOOP
    .ifndef THUMB1
    ldr r0, [r6, #-4]
    .else
    mov r0, r6
    subs r0, #4
    ldr r0, [r0]
    .endif
    adds r0, r0, #1
    .ifndef THUMB1
    ldr r1, [r6, #-8]
    .else
    mov r1, r6
    subs r1, #8
    ldr r1, [r1]
    .endif
    cmp r0, r1
    bge 1f
    .ifndef THUMB1
    str r0, [r6, #-4]
    .else
    mov r0, r6
    subs r0, #4
    str r0, [r0]
    .endif
    movs r0, #0
    push {r0}
    NEXT
1:  ldr r0, [r6]
    subs r6, r6, #8
    str r0, [r6]
    movs r0, #0
    mvns r0, r0
    push {r0}
    NEXT

    defword "DO", DO, F_IMMED
    .word LIT_XT, XDO, COMMAXT, HERE, EXIT

    defword "LOOP", LOOP, F_IMMED
    .word LIT_XT, XLOOP, COMMAXT, LIT_XT, QBRANCH, COMMAXT, HERE, SUB, COMMA, EXIT

    defcode "DELAY", DELAY
    pop {r0}
    bl delay
    NEXT

    defword "RECURSE", RECURSE, F_IMMED
    .word LATEST, FETCH, FROMLINK, COMMAXT, EXIT

@ ---------------------------------------------------------------------
@ -- Compiler and interpreter ----------------------------------------

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

    .ltorg

    defword "HERE", HERE
    .word DP, FETCH, EXIT

    defword "ALLOT", ALLOT
    .word DP, ADDSTORE, EXIT

    defword ",", COMMA
    .word HERE, STORE, CELL, ALLOT, EXIT

    defword ",DEST", COMMADEST
    .word COMMA, EXIT

    defword ",XT", COMMAXT
    .word COMMA, EXIT

    defword ",LINK", COMMALINK
    .word COMMA, EXIT

    defword "C,", CCOMMA
    .word HERE, STOREBYTE, LIT, 1, ALLOT, EXIT

    defword "\'", TICK
    .word BL, WORD, FIND, DROP, EXIT  @ TODO abort if not found

    defword "[\']", BRACKETTICK, F_IMMED
    .word TICK, LIT_XT, LIT_XT, COMMAXT, COMMAXT, EXIT

    defword "(DOES>)", XDOES
    .word RFROM, LATEST, FETCH, FROMLINK, STORE, EXIT

    defword "DOES>", DOES, F_IMMED
    .word LIT_XT, XDOES, COMMAXT
    .word LIT
    ldr r1, [pc]
    blx r1
    .word COMMA
    .word LIT_XT, DODOES + 1, COMMA, EXIT

    defword "(CREATE)", XCREATE
    .word HERE, ALIGNED, DP, STORE
    .word LATEST, FETCH
    .word HERE, LATEST, STORE
    .word COMMALINK
    .word LIT_XT, F_MARKER, CCOMMA
    .word BL, WORD, FETCHBYTE, INCR, INCR, ALIGNED, DECR, ALLOT
    .word EXIT

    defword "CREATE", CREATE
    .word XCREATE, LIT_XT, DOVAR, COMMAXT
    .word EXIT

    defword "DATA", DATA
    .word XCREATE, LIT_XT, DODATA, COMMAXT, EXIT

    defword "VARIABLE", VARIABLE
    .word CREATE, CELL, ALLOT, EXIT

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

    defcode "LIT-XT", LIT_XT
    ldr r0, [r7]
    adds r7, r7, #4
    push {r0}
    NEXT

    defword "DEFER", DEFER
    .word CREATE, LIT_XT, EXIT, COMMA, XDOES
    .set DEFER_XT, .
    ldr r1, [pc]
    blx r1
    .word DODOES + 1, FETCH, EXECUTE, EXIT

    defword "IS", IS
    .word TICK, GTBODY, STORE, EXIT

    defword "DECLARE", DECLARE
    .word CREATE, LATEST, FETCH, LINKTOFLAGS, DUP, FETCH, LIT, F_NODISASM, OR, SWAP, STORE, EXIT

    defword ">UPPER", GTUPPER, 0x0
    .word OVER, PLUS, SWAP, LPARENDORPAREN, I, CFETCH, UPPERCASE, I, CSTORE, LPARENLOOPRPAREN, QBRANCH, 0xffffffe4, EXIT

    defword "UPPERCASE", UPPERCASE, 0x0
    .word DUP, LIT, 0x61, LIT, 0x7b, WITHIN, LIT, 0x20, AND, XOR, EXIT

    defword "SI=", SIEQU, 0x0
    .word GTR, RFETCH, DUP, QBRANCH, 0x24, DROP, TWODUP, CFETCH, UPPERCASE, SWAP, CFETCH, UPPERCASE, EQU, QBRANCH, 0x24, ONEPLUS, SWAP, ONEPLUS, RGT, ONEMINUS, GTR, BRANCH, 0xffffffac, TWODROP, RGT, ZEQU, EXIT

    defword "FIND", FIND, 0x0
    .word LATEST, FETCH, TWODUP, LINKGTNAME, OVER, CFETCH, ONEPLUS, SIEQU, ZEQU, DUP, QBRANCH, 0x10, DROP, FETCH, DUP, ZEQU, QBRANCH, 0xffffffc4, DUP, QBRANCH, 0x38, NIP, DUP, LINKGT, SWAP, LINKGTFLAGS, CFETCH, LIT, 0x1, AND, ZEQU, LIT, 0x1, OR, EXIT

    defword "\\", BACKSLASH, F_IMMED
    .word SOURCECOUNT, FETCH, SOURCEINDEX, STORE, EXIT

    defword "(", LPAREN, F_IMMED
    .word LIT, ')', WORD, DROP, EXIT

    defword "WORD", WORD
    .word DUP, SOURCE, SOURCEINDEX, FETCH, TRIMSTRING
    .word DUP, TOR, ROT, SKIP
    .word OVER, TOR, ROT, SCAN
    .word DUP, ZNEQU, QBRANCH, noskip_delim - ., DECR
noskip_delim:
    .word RFROM, RFROM, ROT, SUB, SOURCEINDEX, ADDSTORE
    .word TUCK, SUB
    .word DUP, HERE, STOREBYTE
    .word HERE, INCR, SWAP, CMOVE
    .word HERE, EXIT

    defword "LINK>", FROMLINK
    .word LINKTONAME, DUP, FETCHBYTE, LIT, F_LENMASK, AND, CHAR, ADD, ADD, ALIGNED, EXIT

    defcode ">FLAGS", TOFLAGS
    pop {r0}
1:  subs r0, #1
    ldrb r1, [r0]
    cmp r1, #F_MARKER
    blt 1b
    push {r0}
    NEXT

    defword ">NAME", TONAME
    .word TOFLAGS, CHAR, ADD, EXIT

    .ltorg

    defword ">LINK", TOLINK
    .word TONAME, LIT, 5, SUB, EXIT

    defword ">BODY", GTBODY
    .word CELL, ADD, EXIT

    defword "LINK>NAME", LINKTONAME
    .word LIT, 5, ADD, EXIT

    defword "LINK>FLAGS", LINKTOFLAGS
    .word CELL, ADD, EXIT

    defword "ANY>LINK", ANYTOLINK
    .word LATEST
1:  .word FETCH, TWODUP, GT, QBRANCH, 1b - .
    .word NIP, EXIT

    defword "MARKER", MARKER, 0X0
    .word CREATE, LATEST, FETCH, FETCH, COMMA, LPARENDOESGTRPAREN
    .set marker_XT, .
    .word 0x47884900, DODOES + 1, FETCH, LATEST, STORE, EXIT

    defcode "EXECUTE", EXECUTE
    pop {r0}
    ldr r1, [r0]
    adds r1, r1, #1
    mov pc, r1

    defword "(INTERPRET)", XINTERPRET @ TODO restructure this
interpret_loop:
    .word BL, WORD, DUP, FETCHBYTE, QBRANCH, interpret_eol - .
    .word FIND, QDUP, QBRANCH, interpret_check_number - .
    .word STATE, FETCH, QBRANCH, interpret_execute - .
    .word INCR, QBRANCH, interpret_compile_word - .
    .word EXECUTE, BRANCH, interpret_loop - .
interpret_compile_word:
    .word COMMAXT, BRANCH, interpret_loop - .
interpret_execute:
    .word DROP, EXECUTE, BRANCH, interpret_loop - .
interpret_check_number:
    .word ISNUMBER, QBRANCH, interpret_not_found - .
    .word STATE, FETCH, QBRANCH, interpret_loop - .
    .word LIT_XT, LIT, COMMAXT, COMMA, BRANCH, interpret_loop - .
interpret_not_found:
    .word LIT, 0, EXIT
interpret_eol:
    .word LIT, -1, EXIT

    defword "EVALUATE", EVALUATE
    .word XSOURCE, STORE
    .word LIT, 0, STATE, STORE
1:  .word XSOURCE, FETCH, DUP, FETCHBYTE, DUP, LIT, 255, NEQU, QBRANCH, 2f - .
    .word SOURCECOUNT, STORE, INCR, XSOURCE, STORE, LIT, 0, SOURCEINDEX, STORE, XINTERPRET, QBRANCH, 3f - ., DROP
    .word SOURCECOUNT, FETCH, XSOURCE, ADDSTORE, BRANCH, 1b - .
2:  .word TWODROP, EXIT
3:  .word DROP, DUP, DOT, SPACE, COUNT, TYPE, LIT, '?', EMIT, CR, EXIT

    defword "FORGET", FORGET
    .word BL, WORD, FIND, DROP, TOLINK, FETCH, LATEST, STORE, EXIT

    defword "HIDE", HIDE
    .word LATEST, FETCH, LINKTONAME, DUP, FETCHBYTE, LIT, F_HIDDEN, OR, SWAP, STOREBYTE, EXIT

    defword "REVEAL", REVEAL
    .word LATEST, FETCH, LINKTONAME, DUP, FETCHBYTE, LIT, F_HIDDEN, INVERT, AND, SWAP, STOREBYTE, EXIT

    defword "IMMEDIATE", IMMEDIATE
    .word LATEST, FETCH, LINKTOFLAGS, DUP, FETCHBYTE, LIT, F_IMMED, OR, SWAP, STOREBYTE, EXIT

    defword "[", LBRACKET, F_IMMED
    .word LIT, 0, STATE, STORE, EXIT

    defword "]", RBRACKET
    .word LIT, -1, STATE, STORE, EXIT

    defword ":", COLON
    .word CREATE, HIDE, RBRACKET, LIT_XT, DOCOL, HERE, CELL, SUB, STORE, EXIT

    defword ";", SEMICOLON, F_IMMED
    .word LIT_XT, EXIT, COMMAXT, REVEAL, LBRACKET, EXIT

    defword "WORDS", WORDS
    .word LATEST, FETCH
words_loop:
    .word DUP, CELL, ADD, CHAR, ADD, COUNT, TYPE, SPACE
    .word FETCH, QDUP, ZEQU, QBRANCH, words_loop - .
    .word EXIT

    defword "DEFINED?", DEFINEDQ
    .word BL, WORD, FIND, NIP, EXIT

@ ---------------------------------------------------------------------
@ -- User variables  --------------------------------------------------

    defword "USER", USER
    .word CREATE, COMMA, XDOES
    .set USER_XT, .
    ldr r1, [pc]
    blx r1
    .word DODOES + 1, FETCH, UPFETCH, ADD, EXIT

    defword "UP@", UPFETCH
    .word UP, FETCH, EXIT

    defword "UP!", UPSTORE
    .word UP, STORE, EXIT

    defword "R0", RZ, , USER_XT
    .word 0x04

    defword "S0", SZ, , USER_XT
    .word 0x08

@ ---------------------------------------------------------------------
@ -- System variables -------------------------------------------------

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
    defvar "UP", UP
    defvar "HP", HP
    defvar "\047KEY", TICKKEY
    defvar "\047ACCEPT", TICKACCEPT
    defvar "\047EMIT", TICKEMIT
    defvar "\047TYPE", TICKTYPE
    defvar "\047WAIT-KEY", TICKWAIT_KEY
    defvar "\047FINISH-OUTPUT", TICKFINISH_OUTPUT

@ ---------------------------------------------------------------------
@ -- Main task user variables -----------------------------------------

    defvar "TASK0WAKE-AT", TASKZWAKE_AT
    defvar "TASK0UTOS", TASKZUTOS
    defvar "TASK0STATUS", TASKZSTATUS
    defvar "TASK0", TASKZ, 0
    defvar "TASK0FOLLOWER", TASKZFOLLOWER
    defvar "TASK0RZ", TASKZRZ
    defvar "TASK0SZ", TASKZSZ
    defvar "TASK0RTOS", TASKZRTOS, 0
    defvar "TASK0RTACK", TASKZRSTACK, 128
    defvar "TASK0STACK", TASKZSTACK, 128
    defvar "TASK0TOS", TASKZTOS, 0

    .ltorg

@ ---------------------------------------------------------------------
@ -- Symbol aliases ---------------------------------------------------

    .set PLUS, ADD
    .set MINUS, SUB
    .set LPARENSOURCERPAREN, XSOURCE
    .set SOURCENUM, SOURCECOUNT
    .set GTSOURCE, SOURCEINDEX
    .set GTR, TOR
    .set RGT, RFROM
    .set LPARENSQUOTRPAREN, XSQUOTE
    .set GTTIB, TIBINDEX
    .set CMOVEGT, CMOVEUP
    .set CSTORE, STOREBYTE
    .set CFETCH, FETCHBYTE
    .set PLUSSTORE, ADDSTORE
    .set MINUSSTORE, SUBSTORE
    .set ONEPLUS, INCR
    .set ONEMINUS, DECR
    .set FOURPLUS, INCR4
    .set FOURMINUS, DECR4
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
    .set ANYGTLINK, ANYTOLINK
    .set LINKGTNAME, LINKTONAME
    .set LINKGTFLAGS, LINKTOFLAGS
    .set SEMI, SEMICOLON
    .set SLASH, DIV
    .set LTEQU, LE
    .set ZLTGT, ZNEQU
    .set QNUMBER, ISNUMBER

@ ---------------------------------------------------------------------

    .set last_core_word, link
    .set end_of_core, .


@ -- vim:syntax=asm:foldmethod=marker:foldmarker=@\ --\ ,@\ ---:

    .global reset_handler

@ ---------------------------------------------------------------------
@ -- Variable definitions ---------------------------------------------

    .set F_IMMED,           0x01
    .set F_HIDDEN,          0x20
    .set F_NODISASM,        0x40
    .set F_LENMASK,         0x1f
    .set F_MARKER,          0x80
    .set F_FLAGSMASK,       0x7f

    .set link,                 0
    .set link_host,            0
    .set ram_here, ram_start

    .set ENABLE_COMPILER,      1
    @ .set TRACE, 1

@ ---------------------------------------------------------------------
@ -- Macros -----------------------------------------------------------

next:
    ldrh r0, [r7]
    .ifdef TRACE
    push {r0, r1, r2, r3}
    bl puthexnumber
    movs r0, #32
    bl putchar
    movs r0, r7
    bl puthexnumber
    movs r0, #13
    bl putchar
    movs r0, #10
    bl putchar
    pop {r0, r1, r2, r3}
    .endif
    adds r7, r7, #2
    movs r1, #1
    tst r0, r1
    bne 1f
2:  ldrh r1, [r0]
    adds r1, r1, #1
    bx r1
1:  movs r2, #3
    rors r1, r2
    orrs r0, r1
    b 2b

    .macro NEXT
    bl next
    .endm

    .macro checkdef name
    .ifdef \name
    .print "Redefining \name"
    .endif
    .endm

    .macro target_conditional, feature
    .ifndef \feature
    .section .host
    .set link_save, link
    .set link, link_host
    .set conditional_feature, 1
    .endif
    .endm

    .macro end_target_conditional
    .if conditional_feature==1
    .set link_host, link
    .set link, link_save
    .section .text
    .set conditional_feature, 0
    .endif
    .endm

    .macro defword name, label, flags=0, xt=DOCOL
    .align 2, 0
    checkdef \label
    .global name_\label
    .set name_\label , .
    .word link
    .set link, name_\label
    .byte \flags | F_MARKER
    .byte (99f - 98f)
98:
    .ascii "\name"
99:
    .align  2, 0
    .global \label
    .set \label , .
    .short \xt
    @ parameter field follows
    .endm

    .macro defcode name, label, flags=0
    .align 2, 0
    .global name_\label
    checkdef \label
    .set name_\label , .
    .word link
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
    .word code_\label
    .global code_\label
    .set code_\label , .
    @ parameter field follows
    .endm

    .macro defconst name, label, value
    .align 2, 0
    .global name_\label
    checkdef \label
    .set name_\label , .
    .word link
    .set link, name_\label
    .byte F_MARKER
    .byte (99f - 98f)
98:
    .ascii "\name"
99:
    .align 2, 0
    .global \label
    .set \label , .
    .short DOCON
    .set constaddr_\label , .
    .word \value
    .endm

    .macro defvar name, label, size=4
    defconst \name,\label,ram_here
    .set addr_\label, ram_here
    .global addr_\label
    .set ram_here, ram_here + \size
    .endm

    .macro defdata name, label
    defword \name,\label,,DODATA
    .endm

@ ---------------------------------------------------------------------
@ -- Entry point ------------------------------------------------------

reset_handler:
    bl init_board
    ldr r6, =addr_TASKZRTOS
    ldr r7, =cold_start
    NEXT

    .align 2, 0
cold_start:
    .short TASKZ, UPSTORE
    .short TASKZRTOS, RZ, STORE
    .short TASKZTOS, SZ, STORE
    .short HLIT, 10, BASE, STORE
    .short RAM
    .short LIT
    .word init_here
    .short FETCH, ROM_DP, STORE
    .short LIT
    .word init_data_start
    .short FETCH, RAM_DP, STORE
    .short LIT
    .word init_last_word
    .short FETCH, LATEST, STORE
    .short SERIAL_CON
    .short COLD
    .ltorg

init_here:
    .word here
init_data_start:
    .word data_start
init_last_word:
    .word last_word

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

    defcode ".UX", DOTUX
    movs r0, '0'
    bl putchar
    movs r0, 'x'
    bl putchar
    pop {r0}
    bl puthexnumber
    NEXT

@ ---------------------------------------------------------------------
@ -- Interpreter code -------------------------------------------------

DOCOL:
    adds r6, r6, #4
    str r7, [r6]
    adds r7, r0, #2
    NEXT

DOVAR:
    adds r1, r0, #2
    push {r1}
    NEXT

DODATA:
    adds r1, r0, #2
    push {r1}
    NEXT

DOCON:
    movs r1, r0
    ldrh r2, [r1, #2]
    ldrh r1, [r1, #4]
    lsls r1, #16
    orrs r1, r2
    push {r1}
    NEXT

DOCON16:
    movs r1, r0
    adds r1, #2
    ldrh r1, [r1]
    push {r1}
    NEXT

DODOES:
    adds r6, r6, #4
    str r7, [r6]
    mov r7, lr
    adds r7, r7, #3
    adds r0, r0, #2
    push {r0}
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
    .short ROT, ROT, EXIT

@ ---------------------------------------------------------------------
@ -- Memory operations -----------------------------------------------

    defconst "CHAR", CHAR, 1
    defconst "CELL", CELL, 4
    defconst "/XT", PERXT, 2
    defconst "/DEST", PERDEST, 2

    defword "CELLS", CELLS
    .short HLIT, 4, MUL, EXIT

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
    ldrh r1, [r0]
    ldrh r0, [r0, #2]
    lsls r0, #16
    orrs r1, r0
    push {r1}
    NEXT

    defcode "!", STORE
    pop {r1}
    pop {r0}
    strh r0, [r1]
    lsrs r0, #16
    strh r0, [r1, #2]
    NEXT

    defword "2!", TWOSTORE
    .short SWAP, OVER, STORE, CELL, ADD, STORE, EXIT

    defword "2@", TWOFETCH
    .short DUP, CELL, ADD, FETCH, SWAP, FETCH, EXIT

    defword "+!", ADDSTORE
    .short SWAP, OVER, FETCH, ADD, SWAP, STORE, EXIT

    defcode "-!", SUBSTORE
    .short SWAP, OVER, FETCH, SWAP, SUB, SWAP, STORE, EXIT

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
    .short BL, FILL, EXIT

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
    .short ROT, OVER, ADD, ROT, ROT, SUB, EXIT

    defword "COUNT", COUNT
    .short DUP, INCR, SWAP, FETCHBYTE, EXIT

    defword "(S\")", XSQUOTE
    .short RFROM, COUNT, TWODUP, ADD, ALIGNED, TOR, EXIT

    defword ">>SOURCE", GTGTSOURCE
    .short HLIT, 1, SOURCEINDEX, ADDSTORE, EXIT

    defword "S\"", SQUOT, F_IMMED
    .short LIT_XT, XSQUOTE, COMMAXT, LIT, '"', 0, WORD
    .short FETCHBYTE, ALLOT, ALIGN
    .short GTGTSOURCE, EXIT

    defword ".\"", DOTQUOT, F_IMMED
    .short SQUOT
    .short LIT_XT, TYPE, COMMAXT, EXIT

    defword "SZ\"", SZQUOT, F_IMMED
    .short LIT_XT, XSQUOTE, COMMAXT, LIT, '"', 0, WORD
    .short HLIT, 1, OVER, ADDSTORE, HLIT, 0, OVER, DUP, FETCHBYTE, ADD, STOREBYTE
    .short FETCHBYTE, ALLOT, ALIGN
    .short GTGTSOURCE, EXIT

    defword "PAD", PAD
    .short HERE, HLIT, 128, ADD, EXIT

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
    .short DUP, ZGT, QBRANCH, 1f - ., HLIT, 32, SWAP, SUB, ROR, EXIT
1:  .short NEGATE, ROR, EXIT

    defword "NEGATE", NEGATE
    .short LIT, -1, -1, MUL, EXIT

    defword "WITHIN", WITHIN
    .short OVER, SUB, TOR, SUB, RFROM, ULT, EXIT

    defword "BITE", BITE
    .short DUP, HLIT, 0xff, AND, SWAP, HLIT, 8, ROR, EXIT

    defword "CHEW", CHEW
    .short BITE, BITE, BITE, BITE, DROP, EXIT

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
    .short SWAP, LT, EXIT

    defword "U>", UGT
    .short SWAP, ULT, EXIT

    defword "<>", NEQU
    .short EQU, INVERT, EXIT

    defword "<=", LE
    .short GT, INVERT, EXIT

    defword ">=", GE
    .short LT, INVERT, EXIT

    defword "0=", ZEQU
    .short HLIT, 0, EQU, EXIT

    defword "0<>", ZNEQU
    .short HLIT, 0, NEQU, EXIT

    defword "0<", ZLT
    .short HLIT, 0, LT, EXIT

    defword "0>", ZGT
    .short HLIT, 0, GT, EXIT

    defword "0<=", ZLE
    .short HLIT, 0, LE, EXIT

    defword "0>=", ZGE
    .short HLIT, 0, GE, EXIT

@ ---------------------------------------------------------------------
@ -- Input/output ----------------------------------------------------

    defconst "#TIB", TIBSIZE, 128
    defconst "C/BLK", CSLASHBLK, 1024

    defword "SOURCE", SOURCE
    .short XSOURCE, FETCH, SOURCECOUNT, FETCH, EXIT

    .ltorg

    defword "(.S)", XPRINTSTACK
1:  .short TWODUP, LTGT, QBRANCH, 2f - ., CELL, MINUS, DUP, FETCH, DOTUX, SPACE, BRANCH, 1b - .
2:  .short TWODROP, CR, EXIT

    defword ".S", PRINTSTACK
    .short SPFETCH, SZ, FETCH, XPRINTSTACK, EXIT

    defword ".R", PRINTRSTACK
    .short RZ, FETCH, CELL, ADD, RPFETCH, CELL, ADD, XPRINTSTACK, EXIT

    defcode "PUTCHAR", PUTCHAR
    pop {r0}
    bl putchar
    NEXT

    defword "LF", LF
    .short HLIT, 10, EMIT, EXIT

    defword "CR", CR
    .short HLIT, 13, EMIT, LF, EXIT

    defconst "BL", BL, 32

    defword "SPACE", SPACE
    .short BL, EMIT, EXIT

    defword "HOLD", HOLD
    .short HLIT, 1, HP, SUBSTORE, HP, FETCH, CSTORE, EXIT

    defword "<#", LTNUM
    .short PAD, HP, STORE, EXIT

    defword ">DIGIT", TODIGIT
    .short DUP, HLIT, 9, GT, HLIT, 7, AND, PLUS, HLIT, 48, PLUS, EXIT

    defword "#", NUM
    .short BASE, FETCH, UDIVMOD, SWAP, TODIGIT, HOLD, EXIT

    defword "#S", NUMS
1:  .short NUM, DUP, ZEQU, QBRANCH, 1b - ., EXIT

    defword "#>", NUMGT
    .short DROP, HP, FETCH, PAD, OVER, SUB, EXIT

    defword "SIGN", SIGN
    .short ZLT, QBRANCH, 1f - .
    .short LIT, '-', 0, HOLD
1:  .short EXIT

    defword "U.", UDOT
    .short LTNUM, NUMS, NUMGT, TYPE, SPACE, EXIT

    defword ".", DOT
    .short LTNUM, DUP, ABS, NUMS, SWAP, SIGN, NUMGT, TYPE, SPACE, EXIT

    defcode "READ-KEY", READ_KEY
    bl readkey
    push {r0}
    NEXT

    defcode "READ-LINE", READ_LINE
    ldr r1, =constaddr_TIB
    ldrh r0, [r1]
    ldrh r1, [r1, #2]
    lsls r1, #16
    orrs r0, r1
    ldr r2, =constaddr_TIBSIZE
    ldrh r1, [r2]
    ldrh r2, [r2, #2]
    lsls r2, #16
    orrs r1, r2
    bl readline
    push {r0}
    NEXT

    .ltorg

    defword "WAIT-KEY", WAIT_KEY
    .short TICKWAIT_KEY, FETCH, EXECUTE, EXIT

    defword "FINISH-OUTPUT", FINISH_OUTPUT
    .short TICKFINISH_OUTPUT, FETCH, EXECUTE, EXIT

    defword "(KEY)", XKEY
    .short WAIT_KEY, READ_KEY, EXIT

    defword "KEY", KEY
    .short TICKKEY, FETCH, EXECUTE, EXIT

    defword "(EMIT)", XEMIT
    .short FINISH_OUTPUT, PUTCHAR, EXIT

    defcode "(TYPE)", XTYPE
    pop {r1}
    pop {r0}
    bl putstring
    NEXT

    defword "ACCEPT", ACCEPT
    .short TICKACCEPT, FETCH, EXECUTE, EXIT

    defword "EMIT", EMIT
    .short TICKEMIT, FETCH, EXECUTE, EXIT

    defword "TYPE", TYPE
    .short TICKTYPE, FETCH, EXECUTE, EXIT

    defword "4NUM", FOURNUM
    .short NUM, NUM, NUM, NUM, EXIT

    defword "SERIAL-CON", SERIAL_CON
    .short LIT_XT, NOOP, DUP, TICKWAIT_KEY, STORE, TICKFINISH_OUTPUT, STORE
    .short LIT_XT, XKEY, TICKKEY, STORE
    .short LIT_XT, XEMIT, TICKEMIT, STORE
    .short LIT_XT, XTYPE, TICKTYPE, STORE
    .short LIT_XT, READ_LINE, TICKACCEPT, STORE
    .short EXIT

    defword "(DUMP-ADDR)", XDUMP_ADDR
    .short CR, DUP, LTNUM, FOURNUM, FOURNUM, NUMGT, TYPE, HLIT, 58, EMIT, SPACE, EXIT

    defword "DUMP", DUMP
    .short BASE, FETCH, TOR, HEX, QDUP, QBRANCH, dump_end - .
    .short SWAP
dump_start_line:
    .short XDUMP_ADDR
dump_line:
    .short DUP, FETCHBYTE, LTNUM, NUM, NUM, NUMGT, TYPE, SPACE, INCR
    .short SWAP, DECR, QDUP, QBRANCH, dump_end - .
    .short SWAP, DUP, HLIT, 7, AND, QBRANCH, dump_start_line - .
    .short BRANCH, dump_line - .
dump_end:
    .short DROP, RFROM, BASE, STORE, EXIT

    defword "DUMPW", DUMPW
    .short BASE, FETCH, TOR, HEX, QDUP, QBRANCH, dumpw_end_final - .
    .short SWAP
dumpw_start_line:
    .short XDUMP_ADDR
dumpw_line:
    .short DUP, FETCH, LTNUM, FOURNUM, FOURNUM, NUMGT, TYPE, SPACE, INCR4
    .short SWAP, DECR4, DUP, ZGT, QBRANCH, dumpw_end - .
    .short SWAP, DUP, HLIT, 0x1f, AND, QBRANCH, dumpw_start_line - .
    .short BRANCH, dumpw_line - .
dumpw_end:
    .short DROP
dumpw_end_final:
    .short DROP, RFROM, BASE, STORE, EXIT

    defword "SKIP", SKIP
    .short TOR
1:  .short OVER, FETCHBYTE, RFETCH, EQU, OVER, ZGT, AND, QBRANCH, 2f - .
    .short HLIT, 1, TRIMSTRING, BRANCH, 1b - .
2:  .short RDROP, EXIT

    defword "SCAN", SCAN
    .short TOR
1:  .short OVER, FETCHBYTE, RFETCH, NEQU, OVER, ZGT, AND, QBRANCH, 2f - .
    .short HLIT, 1, TRIMSTRING, BRANCH, 1b - .
2:  .short RDROP, EXIT

    defword "?SIGN", ISSIGN
    .short OVER, FETCHBYTE, HLIT, 0x2c, SUB, DUP, ABS
    .short HLIT, 1, EQU, AND, DUP, QBRANCH, 1f - .
    .short INCR, TOR, HLIT, 1, TRIMSTRING, RFROM
1:  .short EXIT

    defword "DIGIT?", ISDIGIT
    .short DUP, LIT, '9', 0, GT, HLIT, 0x100, AND, ADD, DUP
    .short HLIT, 0x140, GT, HLIT, 0x107, AND, SUB, HLIT, 0x30, SUB
    .short DUP, BASE, FETCH, ULT, EXIT

    defword "SETBASE", SETBASE
    .short OVER, FETCHBYTE
    .short DUP, LIT, '$', 0, EQU, QBRANCH, 1f - ., HEX, BRANCH, 4f - .
1:  .short DUP, LIT, '#', 0, EQU, QBRANCH, 2f - ., DECIMAL, BRANCH, 4f - .
2:  .short DUP, LIT, '%', 0, EQU, QBRANCH, 3f - ., BINARY, BRANCH, 4f - .
3:  .short DROP, EXIT
4:  .short DROP
    .short HLIT, 1, TRIMSTRING, EXIT

    defword ">NUMBER", TONUMBER
    .short BASE, FETCH, TOR, SETBASE
tonumber_loop:
    .short DUP, QBRANCH, tonumber_done - .
    .short OVER, FETCHBYTE, ISDIGIT
    .short ZEQU, QBRANCH, tonumber_cont - .
    .short DROP, BRANCH, tonumber_done - .
tonumber_cont:
    .short TOR, ROT, BASE, FETCH, MUL
    .short RFROM, ADD, ROT, ROT
    .short HLIT, 1, TRIMSTRING
    .short BRANCH, tonumber_loop - .
tonumber_done:
    .short RFROM, BASE, STORE, EXIT

    defword "?NUMBER", ISNUMBER /* ( c-addr -- n true | c-addr false ) */
    .short DUP
    .short HLIT, 0, DUP, ROT, COUNT
    .short ISSIGN, TOR, TONUMBER, QBRANCH, is_number - .
    .short RDROP, TWODROP, DROP
    .short HLIT, 0, EXIT
is_number:
    .short TWOSWAP, TWODROP, DROP, RFROM, ZNEQU, QBRANCH, is_positive - ., NEGATE
is_positive:
    .short LIT, -1, -1, EXIT

    .ltorg

    defword "DECIMAL", DECIMAL
    .short HLIT, 10, BASE, STORE, EXIT

    defword "HEX", HEX
    .short HLIT, 16, BASE, STORE, EXIT

    defword "OCTAL", OCTAL
    .short HLIT, 8, BASE, STORE, EXIT

    defword "BINARY", BINARY
    .short HLIT, 2, BASE, STORE, EXIT

@ ---------------------------------------------------------------------
@ -- Control flow -----------------------------------------------------

    defcode "NOOP", NOOP
    NEXT

    defcode "BRANCH", BRANCH
    ldrh r0, [r7]
    sxth r0, r0
    adds r7, r0
    NEXT

    defcode "?BRANCH", QBRANCH
    pop {r0}
    cmp r0, #0
    beq code_BRANCH
    adds r7, r7, #2
    NEXT

    target_conditional ENABLE_COMPILER

    defword "POSTPONE", POSTPONE, F_IMMED
    .short BL, WORD, FIND
    .short ZLT, QBRANCH,  1f - .
    .short LIT_XT
    .short LIT_XT, COMMAXT, COMMA
    .short LIT_XT, COMMAXT, COMMAXT, BRANCH,  2f - .
1:  .short COMMAXT
2:  .short EXIT

    defword "LITERAL", LITERAL, F_IMMED
    .short LIT_XT, LIT, COMMAXT, COMMA, EXIT

    defword "DEST!", DESTSTORE
    .short HSTORE, EXIT

    defword "XT!", XTSTORE
    .short HSTORE, EXIT

    defword "BEGIN", BEGIN, F_IMMED
    .short HERE, EXIT

    defword "AGAIN", AGAIN, F_IMMED
    .short LIT_XT, BRANCH, COMMAXT, HERE, SUB, COMMADEST, EXIT

    defword "UNTIL", UNTIL, F_IMMED
    .short LIT_XT, QBRANCH, COMMAXT, HERE, SUB, COMMADEST, EXIT

    defword "IF", IF, F_IMMED
    .short LIT_XT, QBRANCH, COMMAXT, HERE, DUP, COMMADEST, EXIT

    defword "ELSE", ELSE, F_IMMED
    .short LIT_XT, BRANCH, COMMAXT, HERE, DUP, COMMADEST
    .short SWAP, THEN, EXIT

    defword "THEN", THEN, F_IMMED
    .short HERE, OVER, SUB, SWAP, DESTSTORE, EXIT

    defword "WHILE", WHILE, F_IMMED
    .short IF, EXIT

    defword "REPEAT", REPEAT, F_IMMED
    .short SWAP
    .short LIT_XT, BRANCH, COMMAXT, HERE, SUB, COMMADEST
    .short THEN, EXIT

    defword "CASE", CASE, F_IMMED
    .short HLIT, 0, EXIT

    defword "OF", OF, F_IMMED
    .short LIT_XT, OVER, COMMAXT
    .short LIT_XT, EQU, COMMAXT, IF, LIT_XT, DROP, COMMAXT, EXIT

    defword "ENDCASE", ENDCASE, F_IMMED
    .short LIT_XT, DROP, COMMAXT
1:  .short DUP, QBRANCH, 2f - .
    .short THEN, BRANCH, 1b - .
2:  .short DROP, EXIT

    end_target_conditional

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

    target_conditional ENABLE_COMPILER

    defword "DO", DO, F_IMMED
    .short LIT_XT, XDO, COMMAXT, HERE, EXIT

    defword "LOOP", LOOP, F_IMMED
    .short LIT_XT, XLOOP, COMMAXT
    .short LIT_XT, QBRANCH, COMMAXT, HERE, SUB, COMMADEST, EXIT

    defcode "DELAY", DELAY
    pop {r0}
    bl delay
    NEXT

    defword "RECURSE", RECURSE, F_IMMED
    .short LATEST, FETCH, FROMLINK, COMMAXT, EXIT

    end_target_conditional

@ ---------------------------------------------------------------------
@ -- Compiler and interpreter ----------------------------------------

    defcode "EMULATION?", EMULATIONQ
    ldr r0, =0xe000ed00
    ldr r0, [r0]
    movs r1, #0
    cmp r0, r1
    bne 1f
    subs r1, #1
1:  push {r1}
    NEXT

    defcode "EMULATOR-BKPT", EMULATOR_BKPT
    bkpt 0xab
    NEXT

    target_conditional ENABLE_COMPILER

    defword "ROM-DUMP", ROM_DUMP
    .short LIT
    .word _start
    .short ROM_DP, FETCH
    .short HLIT, 0x80, EMULATOR_BKPT, EXIT

    end_target_conditional

    defword "BYE", BYE
    .short HLIT, 0x18, EMULATOR_BKPT, EXIT

    defcode "WFI", WFI
    wfi
    NEXT

    defcode "WFE", WFE
    wfe
    NEXT

    defcode "RESET", RESET
    ldr r0, =0xe000ed0c
    ldr r1, =0x05fa0004
    str r1, [r0]

    defcode "HALT", HALT
    b .

    .ltorg

    defcode "LIT", LIT
    ldrh r0, [r7]
    ldrh r1, [r7, #2]
    lsls r1, #16
    orrs r0, r1
    adds r7, r7, #4
    push {r0}
    NEXT

    defcode "HLIT", HLIT
    ldrh r0, [r7]
    adds r7, r7, #2
    push {r0}
    NEXT

    defcode "LIT-XT", LIT_XT
    ldrh r0, [r7]
    adds r7, r7, #2
    push {r0}
    NEXT

    defword "ROM", ROM
    .short LIT
    .word 1
    .short ROM_ACTIVE, STORE, EXIT

    defword "RAM", RAM
    .short LIT
    .word 0
    .short ROM_ACTIVE, STORE, EXIT

    defword "ROM?", ROMQ
    .short ROM_ACTIVE, FETCH, EXIT

    defword "DP", DP
    .short ROMQ, QBRANCH, 1f - .
    .short ROM_DP, EXIT
1:  .short RAM_DP, EXIT

    defword "HERE", HERE
    .short DP, FETCH, EXIT

    defword "ORG", ORG
    .short DP, STORE, EXIT

    defword "ALLOT", ALLOT
    .short DP, ADDSTORE, EXIT

    defword "ALIGN", ALIGN
    .short HERE, ALIGNED, ORG, EXIT

    defword ",", COMMA
    .short HERE, STORE, CELL, ALLOT, EXIT

    defword ",XT", COMMAXT
    .short DUP, LIT, 0, 0x0001, GE, QBRANCH, 1f - .
    .short HLIT, 1, OR
1:  .short HERE, XTSTORE, PERXT, ALLOT, EXIT

    defword ",DEST", COMMADEST
    .short HERE, DESTSTORE, PERDEST, ALLOT, EXIT

    defword ",LINK", COMMALINK
    .short COMMA, EXIT

    defword "C,", CCOMMA
    .short HERE, STOREBYTE, HLIT, 1, ALLOT, EXIT

    defword ">UPPER", GTUPPER
    .short OVER, PLUS, SWAP
1:  .short LPARENDORPAREN, I, CFETCH, UPPERCASE, I, CSTORE, LPARENLOOPRPAREN, QBRANCH, 1b - ., EXIT

    defword "UPPERCASE", UPPERCASE
    .short DUP, HLIT, 0x61, HLIT, 0x7b, WITHIN, HLIT, 0x20, AND, XOR, EXIT

    defword "SI=", SIEQU
    .short GTR
1:  .short RFETCH, DUP, QBRANCH, 2f - ., DROP, TWODUP, CFETCH, UPPERCASE
    .short SWAP, CFETCH, UPPERCASE, EQU
2:  .short QBRANCH, 3f - .
    .short ONEPLUS, SWAP, ONEPLUS, RGT, ONEMINUS, GTR, BRANCH, 1b - .
3:  .short TWODROP, RGT, ZEQU, EXIT

    defword "LINK>", FROMLINK
    .short LINKTONAME, DUP, FETCHBYTE
    .short LIT
    .word F_LENMASK
    .short AND, CHAR, ADD, ADD, ALIGNED, EXIT

    defcode ">FLAGS", TOFLAGS
    pop {r0}
1:  subs r0, #1
    ldrb r1, [r0]
    cmp r1, #F_MARKER
    blt 1b
    push {r0}
    NEXT

    defword ">NAME", TONAME
    .short TOFLAGS, CHAR, ADD, EXIT

    .ltorg

    defword ">LINK", TOLINK
    .short TONAME
    .short LIT
    .word 5
    .short SUB, EXIT

    defword ">BODY", GTBODY
    .short CELL, ADD, EXIT

    defword "LINK>NAME", LINKTONAME
    .short LIT
    .word 5
    .short ADD, EXIT

    defword "LINK>FLAGS", LINKTOFLAGS
    .short CELL, ADD, EXIT

    defword "ANY>LINK", ANYTOLINK
    .short LATEST
1:  .short FETCH, TWODUP, GT, QBRANCH, 1b - .
    .short NIP, EXIT

    defcode "EXECUTE", EXECUTE
    pop {r0}
    ldrh r1, [r0]
    adds r1, r1, #1
    mov pc, r1

    target_conditional ENABLE_COMPILER

    defword "MARKER", MARKER, 0X0
    .short CREATE, LATEST, FETCH, FETCH, COMMA, LPARENDOESGTRPAREN
    .set marker_XT, .
    .short 0x4788, 0x4900, DODOES + 1, 0, FETCH, LATEST, STORE, EXIT

    defword "\'", TICK
    .short BL, WORD, FIND, DROP, EXIT  @ TODO abort if not found

    defword "[\']", BRACKETTICK, F_IMMED
    .short TICK
    .short LIT_XT, LIT_XT, COMMAXT, COMMAXT, EXIT

    defword "(DOES>)", XDOES
    .short RFROM, LATEST, FETCH, FROMLINK
    .short DUP, LIT, 0, 0x0001, GE, QBRANCH, 1f - .
    .short HLIT, 1, OR
1:  .short XTSTORE, EXIT

    defword "DOES>", DOES, F_IMMED
    .short LIT_XT, XDOES, COMMAXT
    .short LIT
    ldr r1, [pc]
    blx r1
    .short COMMA
    .short LIT_XT, DODOES + 1, COMMA, EXIT

    defword "(CREATE)", XCREATE
    .short ALIGN
    .short LATEST, FETCH
    .short HERE, LATEST, STORE
    .short COMMALINK
    .short LIT
    .word F_MARKER
    .short CCOMMA
    .short BL, WORD, FETCHBYTE, INCR, INCR, ALIGNED, DECR, ALLOT
    .short EXIT

    defword "CREATE", CREATE
    .short XCREATE
    .short LIT_XT, DOVAR, COMMAXT, EXIT

    defword "DATA", DATA
    .short XCREATE
    .short LIT_XT, DODATA, COMMAXT, EXIT

    defword "BUFFER", BUFFER
    .short XCREATE
    .short LIT_XT, DOCON, COMMAXT
    .short ROM_ACTIVE, FETCH
    .short HERE, CELL, ALLOT
    .short RAM, HERE, SWAP, STORE
    .short SWAP, ALLOT
    .short ROM_ACTIVE, STORE, EXIT

    defword "VARIABLE", VARIABLE
    .short CELL, BUFFER, EXIT

    defword "CONSTANT", CONSTANT
    .short XCREATE
    .short LIT_XT, DOCON, COMMAXT, COMMA, EXIT

    defword "DEFER", DEFER
    .short CREATE
    .short LIT_XT, EXIT, COMMA, XDOES
    .set DEFER_XT, .
    ldr r1, [pc]
    blx r1
    .short DODOES + 1, 0, FETCH, EXECUTE, EXIT

    defword "IS", IS
    .short TICK, GTBODY, STORE, EXIT

    defword "DECLARE", DECLARE
    .short CREATE, LATEST, FETCH, LINKTOFLAGS, DUP, FETCH
    .short LIT
    .word F_NODISASM
    .short OR, SWAP, STORE, EXIT

    defword ".TOS", DOTTOS
    .short DUP, DOTUX, CR, EXIT

    defword "(FIND)", XFIND
2:  .short TWODUP, LINKGTNAME, OVER, CFETCH, ONEPLUS, SIEQU, ZEQU, DUP, QBRANCH, 1f - .
    .short DROP, FETCH, DUP
1:  .short ZEQU, QBRANCH, 2b - .
    .short DUP, QBRANCH, 3f - .
    .short NIP, DUP, LINKGT, SWAP, LINKGTFLAGS, CFETCH
    .short HLIT, 1, AND, ZEQU
    .short HLIT, 1, OR
3:  .short EXIT

    defword "FIND", FIND
    .short LATEST, FETCH, XFIND, QDUP, QBRANCH, 1f - ., EXIT
1:  .short LIT
    .word last_host
    .short QDUP, QBRANCH, 2f - ., XFIND, EXIT
2:  .short HLIT, 0, EXIT

    defword "\\", BACKSLASH, F_IMMED
    .short SOURCECOUNT, FETCH, SOURCEINDEX, STORE, EXIT

    defword "(", LPAREN, F_IMMED
    .short LIT
    .word ')'
    .short WORD, DROP, EXIT

    defword "WORD", WORD
    .short DUP, SOURCE, SOURCEINDEX, FETCH, TRIMSTRING
    .short DUP, TOR, ROT, SKIP
    .short OVER, TOR, ROT, SCAN
    .short DUP, ZNEQU, QBRANCH, noskip_delim - ., DECR
noskip_delim:
    .short RFROM, RFROM, ROT, SUB, SOURCEINDEX, ADDSTORE
    .short TUCK, SUB
    .short DUP, HERE, STOREBYTE
    .short HERE, INCR, SWAP, CMOVE
    .short HERE, EXIT

    defword "(INTERPRET)", XINTERPRET @ TODO restructure this
interpret_loop:
    .short BL, WORD, DUP, FETCHBYTE, QBRANCH, interpret_eol - .
    .short FIND, QDUP, QBRANCH, interpret_check_number - .
    .short STATE, FETCH, QBRANCH, interpret_execute - .
    .short INCR, QBRANCH, interpret_compile_word - .
    .short EXECUTE, BRANCH, interpret_loop - .
interpret_compile_word:
    .short COMMAXT, BRANCH, interpret_loop - .
interpret_execute:
    .short DROP, EXECUTE, BRANCH, interpret_loop - .
interpret_check_number:
    .short ISNUMBER, QBRANCH, interpret_not_found - .
    .short STATE, FETCH, QBRANCH, interpret_loop - .
    .short LIT_XT, LIT, COMMAXT, COMMA, BRANCH, interpret_loop - .
interpret_not_found:
    .short HLIT, 0, EXIT
interpret_eol:
    .short LIT, -1, -1, EXIT

    defword "EVALUATE", EVALUATE
    .short XSOURCE, STORE
    .short HLIT, 0, STATE, STORE
1:  .short XSOURCE, FETCH
5:  .short DUP, FETCHBYTE, DUP, ZNEQU, QBRANCH, 2f - .
    .short HLIT, 10, EQU, QBRANCH, 7f - .
    .short INCR, BRANCH, 5b - .
7:  .short DUP
6:  .short DUP, FETCHBYTE, HLIT, 10, NEQU, QBRANCH, 4f - .
    .short INCR, BRANCH, 6b - .
4:  .short OVER, SUB
    .short TWODUP, TYPE, CR
    .short SOURCECOUNT, STORE, XSOURCE, STORE
    .short HLIT, 0, SOURCEINDEX, STORE
    .short XINTERPRET, QBRANCH, 3f - ., DROP
    .short SOURCECOUNT, FETCH, XSOURCE, ADDSTORE, BRANCH, 1b - .
2:  .short DROP, EXIT
3:  .short DROP, DUP, DOT, SPACE, COUNT, TYPE
    .short LIT, '?', 0, EMIT, CR, EXIT

    defword "FORGET", FORGET
    .short BL, WORD, FIND, DROP, TOLINK, FETCH, LATEST, STORE, EXIT

    defword "HIDE", HIDE
    .short LATEST, FETCH, LINKTONAME, DUP, FETCHBYTE
    .short LIT
    .word F_HIDDEN
    .short OR, SWAP, STOREBYTE, EXIT

    defword "REVEAL", REVEAL
    .short LATEST, FETCH, LINKTONAME, DUP, FETCHBYTE
    .short LIT
    .word F_HIDDEN
    .short INVERT, AND, SWAP, STOREBYTE, EXIT

    defword "IMMEDIATE", IMMEDIATE
    .short LATEST, FETCH, LINKTOFLAGS, DUP, FETCHBYTE
    .short LIT
    .word F_IMMED
    .short OR, SWAP, STOREBYTE, EXIT

    defword "[", LBRACKET, F_IMMED
    .short LIT
    .word 0
    .short STATE, STORE, EXIT

    defword "]", RBRACKET
    .short LIT
    .word -1
    .short STATE, STORE, EXIT

    defword ":", COLON
    .short CREATE, HIDE, RBRACKET
    .short LIT_XT, DOCOL, HERE, PERXT, SUB, STORE, EXIT

    defword ";", SEMICOLON, F_IMMED
    .short LIT_XT, EXIT, COMMAXT, REVEAL, LBRACKET, EXIT

    end_target_conditional

    defword "WORDS", WORDS
    .short LATEST, FETCH
words_loop:
    .short DUP, CELL, ADD, CHAR, ADD, COUNT, TYPE, SPACE
    .short FETCH, QDUP, ZEQU, QBRANCH, words_loop - .
    .short EXIT

    defword "DEFINED?", DEFINEDQ
    .short BL, WORD, FIND, NIP, EXIT

@ ---------------------------------------------------------------------
@ -- User variables  --------------------------------------------------

    defword "USER", USER
    .short CREATE, COMMA, XDOES
    .set USER_XT, .
    ldr r1, [pc]
    blx r1
    .short DODOES + 1, 0, FETCH, UPFETCH, ADD, EXIT

    defword "UP@", UPFETCH
    .short UP, FETCH, EXIT

    defword "UP!", UPSTORE
    .short UP, STORE, EXIT

    defword "R0", RZ, , USER_XT
    .word 0x04

    defword "S0", SZ, , USER_XT
    .word 0x08

@ ---------------------------------------------------------------------
@ -- System variables -------------------------------------------------

    defvar "STATE", STATE
    defvar "RAM-DP", RAM_DP
    defvar "ROM-DP", ROM_DP
    defvar "ROM-ACTIVE", ROM_ACTIVE
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


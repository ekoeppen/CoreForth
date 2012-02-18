@ -- vim:syntax=asm:foldmethod=marker:foldmarker=@\ --\ ,@\ ---:

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
    mov r0, \c
    bl putchar
    pop {r0, r1}
    .endm

    .macro REG, r
    push {r0, r1}
    mov r0, \r
    bl puthexnumber
    pop {r0, r1}
    .endm

    .macro NEXT
    ldr r0, [r7]
    add r7, r7, #4
    ldr r1, [r0]
    add r1, r1, #1
    bx r1
    .endm

    .macro defword name, namelen, flags=0, label, xt=DOCOL
    .align 2, 0
    .global name_\label
name_\label :
    .int link
    .set link,name_\label
    .byte \flags+\namelen
    .ascii "\name"
    .align  2, 0
    .global \label
\label :
    .int \xt
    @ parameter field follows
    .endm

    .macro defcode name, namelen, flags=0, label
    .align 2, 0
    .global name_\label
name_\label :
    .int link
    .set link,name_\label
    .byte \flags+\namelen
    .ascii "\name"
    .align 2, 0
    .global \label
\label :
    .int code_\label
    .global code_\label
code_\label :
    @ parameter field follows
    .endm

    .macro defvar name, namelen, flags=0, label, size=4
    defcode \name,\namelen,\flags,\label
    .set addr_\label, compiled_here
    ldr r0, =addr_\label
    push {r0}
    NEXT
    .set compiled_here, compiled_here + \size
    .endm

    .macro defconst name, namelen, flags=0, label, value
    .align 2, 0
    .global name_\label
name_\label :
    .int link
    .set link,name_\label
    .byte \flags+\namelen
    .ascii "\name"
    .align 2, 0
    .global \label
\label :
    .int DOCON
    .word \value
    .endm

@ ---------------------------------------------------------------------
@ -- Entry point ------------------------------------------------------

reset_handler:
    bl init_board
    ldr r0, =start_prompt
    mov r1, #(start_prompt_end - start_prompt)
    bl putstring
    ldr r6, =addr_RTOS
    ldr r7, =cold_start
    NEXT
start_prompt:
    .ascii "CoreForth ready.\r\n"
start_prompt_end:
    .align 2, 0
cold_start:
    .word LIT, 10, BASE, STORE
    .word LIT, data_start, DP, STORE
    .word LIT, last_word, LATEST, STORE
    .word COLD

    .ltorg

@ ---------------------------------------------------------------------
@ -- Interpreter code -------------------------------------------------

DOCOL:
    sub r6, r6, #4
    str r7, [r6]
    add r7, r0, #4
    NEXT

DOVAR:
    add r1, r0, #4
    push {r1}
    NEXT

DOCON:
    ldr r1, [r0, #4]
    push {r1}
    NEXT   

DODOES:
    sub r6, r6, #4
    str r7, [r6]
    mov r7, lr
    add r7, r7, #5
    add r0, r0, #4
    push {r0}
    NEXT

DOOFFSET:
    ldr r1, [r0, #4]
    pop {r2}
    add r1, r2, r1
    push {r1}
    NEXT   

    defcode "EXIT", 4, , EXIT
    ldr r7, [r6]
    add r6, r6, #4
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
    add r5, r5, #1
    bl putchar
    subs r6, r6, #1
    bgt putstring_loop
    pop {r5, r6, pc}

puthexnumber:
    push {r4, r5, lr}
    mov r4, r0
    mov r0, #'0'
    bl putchar
    mov r0, #'x'
    bl putchar
    mov r0, r4
    mov r3, #0
    mov r5, #8
puthexnumber_loop:
    ror r0, r0, #28
    mov r4, r0
    and r0, r0, #15
    cmp r3, #0
    bgt 3f
    cmp r0, #0
    beq 2f
    mov r3, #1
3:  add r0, r0, #'0'
    cmp r0, #'9'
    ble 1f
    add r0, r0, #'a' - '0' - 10
1:  bl putchar
2:  mov r0, r4
    subs r5, r5, #1
    bne puthexnumber_loop
    cmp r3, #0
    bne 4f
    mov r0, #'0'
    bl putchar
4:  pop {r4, r5, pc}

putsignedhexnumber:
    push {lr}
    cmp r0, #0
    bge 1f
    push {r0}
    mov r0, #'-'
    bl putchar
    pop {r1}
    neg r0, r1
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
    mov r0, #32
    strb r0, [r5]
    sub r5, r5, #1
    add r6, r6, #1
    mov r0, #8
    bl putchar
    mov r0, #32
    bl putchar
    mov r0, #8
    bl putchar
    b readline_loop
readline_addchar:
    bl putchar
    strb r0, [r5]
    add r5, r5, #1
    subs r6, r6, #1
    bgt readline_loop
readline_end:
    sub r0, r5, r4
    pop {r4, r5, r6, pc}

printstack:
    ldr r0, =addr_TOS
    cmp sp, r0
    push {r4, lr}
    blt 1f
    beq 2f
    ldr r0, =stack_underflow_message
    mov r1, #(stack_underflow_message_end - stack_underflow_message)
    bl putstring
2:  pop {r4, pc}
1:  ldr r4, =addr_TOS
    sub r4, r4, #4
printstack_loop:
    ldr r0, [r4]
    bl puthexnumber
    mov r0, #32
    bl putchar
    sub r4, r4, #8
    cmp r4, sp
    beq printstack_end
    add r4, r4, #4
    b printstack_loop
printstack_end:
    mov r0, #13
    bl putchar
    mov r0, #10
    bl putchar
    pop {r4, pc}
stack_underflow_message:
    .ascii "*** STACK UNDERFLOW ***\n"
stack_underflow_message_end:
    .ltorg

calc_wide_branch:
    mov ip, #0x9000
    ands r1, r0, #0x800000
    ubfx r2, r0, #1, #11
    movt ip, #0xffff
    it ne
    movne r1, #0x2000
    orr r3, r2, ip
    ands r2, r0, #0x400000
    orr ip, r3, r1
    it ne
    movne r2, #0x800
    ubfx r0, r0, #12, #10
    orr r1, ip, r2
    orr r0, r0, #0xf400
    sxth r3, r1
    lsls r3, r3, #16
    adds r0, r3, r0
    subs r0, r0, #1
    bx lr

@ ---------------------------------------------------------------------
@ -- Stack manipulation -----------------------------------------------

    defcode "DROP", 4, , DROP
    add sp, sp, #4
    NEXT

    defcode "SWAP", 4, , SWAP
    pop {r1}
    pop {r0}
    push {r1}
    push {r0}
    NEXT

    defcode "OVER", 4, , OVER
    ldr r0, [sp, #4]
    push {r0}
    NEXT

    defcode "ROT", 3, , ROT
    pop {r0, r1, r2}
    push {r1}
    push {r0}
    push {r2}
    NEXT

    defcode "?DUP", 4, , QDUP
    ldr r0, [sp]
    cmp r0, #0
    beq 1f
    push {r0}
1:  NEXT

    defcode "DUP", 3, , DUP
    ldr r0, [sp]
    push {r0}
    NEXT

    defcode "NIP", 3, , NIP
    pop {r0}
    pop {r1}
    push {r0}
    NEXT

    defcode "TUCK", 4, , TUCK
    pop {r0}
    pop {r1}
    push {r0}
    push {r1}
    push {r0}
    NEXT

    defcode "2DUP", 4, , TWODUP
    ldr r1, [sp, #4]
    ldr r0, [sp]
    push {r0, r1}
    NEXT

    defcode "2SWAP", 5, , TWOSWAP
    pop {r0, r1, r2, r3}
    push {r1}
    push {r0}
    push {r3}
    push {r2}
    NEXT

    defcode "2DROP", 5, , TWODROP
    add sp, sp, #8
    NEXT

    defcode "2OVER", 5, , TWOOVER
    ldr r0, [sp, #8]
    ldr r1, [sp, #12]
    push {r1}
    push {r0}
    NEXT

    defcode ">R", 2, , TOR
    pop {r0}
    sub r6, r6, #4
    str r0, [r6]
    NEXT

    defcode "R>", 2, , RFROM
    ldr r0, [r6]
    add r6, r6, #4
    push {r0}
    NEXT

    defcode "R@", 2, , RFETCH
    ldr r0, [r6]
    push {r0}
    NEXT

    defcode "SP@", 3, , SPAT
    mov r0, sp
    push {r0}
    NEXT

    defcode "RP@", 3, , RPAT
    push {r6}
    NEXT

@ ---------------------------------------------------------------------
@ -- Memory operations -----------------------------------------------

    defcode "CHAR", 4, , CHAR
    mov r0, #1
    push {r0}
    NEXT

    defcode "CELL", 4, , CELL
    mov r0, #4
    push {r0}
    NEXT

    defcode "CELLS", 5, , CELLS
    pop {r0}
    mov r1, #4
    mul r0, r0, r1
    push {r0}
    NEXT

    defcode "ALIGNED", 7, , ALIGNED
    pop {r0}
    add r0, r0, #3
    mvn r1, #3
    and r0, r0, r1
    push {r0}
    NEXT

    defcode "C@", 2, , FETCHBYTE
    pop {r0}
    ldrb r1, [r0]
    push {r1}
    NEXT

    defcode "C!", 2, , STOREBYTE
    pop {r1}
    pop {r0}
    strb r0, [r1]
    NEXT

    defcode "@", 1, , FETCH
    pop {r0}
    ldr r1, [r0]
    push {r1}
    NEXT

    defcode "!", 1, , STORE
    pop {r1}
    pop {r0}
    str r0, [r1]
    NEXT

    defcode "+!", 2, , ADDSTORE
    pop {r1}
    pop {r0}
    ldr r2, [r1]
    add r2, r2, r0
    str r2, [r1]
    NEXT

    defcode "-!", 2, , SUBSTORE
    pop {r1}
    pop {r0}
    ldr r2, [r1]
    sub r2, r2, r0
    str r2, [r1]
    NEXT

    defcode "FILL", 4, , FILL
    pop {r2}
fill_code:
    pop {r1}
    pop {r0}
    cmp r1, #0
    beq fill_done
fill_loop:
    strb r2, [r0]
    add r0, r0, #1
    subs r1, r1, #1
    bne fill_loop
fill_done:
    NEXT

    defcode "BLANK", 5, , BLANK
    mov r2, #32
    b fill_code   

	defcode "CMOVE",5 , , CMOVE
	pop {r0}
	pop {r1}
	pop {r2}
cmove_loop:
	sub r0, r0, #1
    cmp	r0, #0
    blt 1f
	ldrb r3, [r2, r0]
	strb r3, [r1, r0]
	b cmove_loop
1:  NEXT

    defcode "S=", 2, , SEQU
    pop {r2}
    pop {r1}
    pop {r0}
    push {r4, r5}
1:  cmp r2, #0
    beq 2f
    ldrb r4, [r0]
    add r0, r0, #1
    ldrb r5, [r1]
    add r1, r1, #1
    subs r5, r5, r4
    bne 3f
    sub r2, r2, #1
    b 1b
3:  mov r2, r5
2:  pop {r4, r5}
    push {r2}
    NEXT

    .ltorg

    defword "/STRING", 7, , TRIMSTRING
    .word ROT, OVER, ADD, ROT, ROT, SUB, EXIT

    defword "COUNT", 5, , COUNT
    .word DUP, INCR, SWAP, FETCHBYTE, EXIT

    defword "(S\")", 4, , XSQUOTE
    .word RFROM, COUNT, TWODUP, ADD, ALIGNED, TOR, EXIT

    defword "S\"", 2, F_IMMED, SQUOTE
    .word LIT, XSQUOTE, COMMA, LIT, '"', WORD, FETCHBYTE, INCR, ALIGNED, ALLOT
    .word LIT, 1, ININDEX, ADDSTORE
    .word EXIT 

    defword "PAD", 3, , PAD
    .word HERE, LIT, 256, ADD, EXIT

@ ---------------------------------------------------------------------
@ -- Arithmetic ------------------------------------------------------

    defcode "1+", 2, , INCR
    ldr r0, [sp]
    add r0, r0, #1
    str r0, [sp]
    NEXT

    defcode "1-", 2, , DECR
    ldr r0, [sp]
    sub r0, r0, #1
    str r0, [sp]
    NEXT

    defcode "4+", 2, , INCR4
    ldr r0, [sp]
    add r0, r0, #4
    str r0, [sp]
    NEXT

    defcode "4-", 2, , DECR4
    ldr r0, [sp]
    sub r0, r0, #4
    str r0, [sp]
    NEXT

    defcode "+", 1, , ADD
    pop {r1}
    pop {r0}
    add r0, r1, r0
    push {r0}
    NEXT

    defcode "-", 1, , SUB
    pop {r1}
    pop {r0}
    sub r0, r0, r1
    push {r0}
    NEXT

    defcode "*", 1, , MUL
    pop {r0}
    pop {r1}
    mul r0, r1, r0
    push {r0}
    NEXT

    defcode "/MOD", 4, , DIVMOD
    pop {r1}
    pop {r0}
    sdiv r2, r0, r1
    mls r0, r1, r2, r0
    push {r0}
    push {r2}
    NEXT

    defcode "/", 1, , DIV
    pop {r1}
    pop {r0}
    sdiv r0, r0, r1
    push {r0}
    NEXT

    defcode "MOD", 3, , MOD
    pop {r1}
    pop {r0}
    sdiv r2, r0, r1
    mls r0, r1, r2, r0
    push {r0}
    NEXT

    defcode "2*", 2, , TWOSTAR
    ldr r0, [sp]
    lsl r0, r0, #1
    str r0, [sp]
    NEXT

    defcode "2/", 2, , TWOSLASH
    ldr r0, [sp]
    asr r0, r0, #1
    str r0, [sp]
    NEXT

@ ---------------------------------------------------------------------
@ -- Boolean operators -----------------------------------------------

    defcode "AND", 3, , AND
    pop {r1}
    pop {r0}
    and r0, r1, r0
    push {r0}
    NEXT

    defcode "OR", 2, , OR
    pop {r1}
    pop {r0}
    orr r0, r1, r0
    push {r0}
    NEXT

    defcode "XOR", 3, , XOR
    pop {r1}
    pop {r0}
    eor r0, r1, r0
    push {r0}
    NEXT

    defcode "INVERT", 6, , INVERT
    ldr r0, [sp]
    mvn r0, r0
    str r0, [sp]
    NEXT

@ ---------------------------------------------------------------------
@ -- Comparisons -----------------------------------------------------

    defcode "=", 1, , EQU
    pop {r1}
    pop {r0}
    mov r2, #0
    cmp r0, r1
    bne 1f
    mvn r2, r2
1:  push {r2}
    NEXT

    defcode "<", 1, , LT
    pop {r1}
    pop {r0}
    mov r2, #0
    cmp r0, r1
    bge 1f
    mvn r2, r2
1:  push {r2}
    NEXT

    defcode "U<", 2, , ULT
    pop {r1}
    pop {r0}
    mov r2, #0
    cmp r0, r1
    bcs 1f
    mvn r2, r2
1:  push {r2}
    NEXT

    defword ">", 1, , GT
    .word SWAP, LT, EXIT

    defword "U>", 2, , UGT
    .word SWAP, ULT, EXIT

    defword "<>", 2, , NEQU
    .word EQU, INVERT, EXIT

    defword "<=", 2, , LE
    .word GT, INVERT, EXIT

    defword ">=", 2, , GE
    .word LT, INVERT, EXIT

    defword "0=", 2, , ZEQU
    .word LIT, 0, EQU, EXIT

    defword "0<>", 3, , ZNEQU
    .word LIT, 0, NEQU, EXIT

    defword "0<", 2, , ZLT
    .word LIT, 0, LT, EXIT

    defword "0>", 2, , ZGT
    .word LIT, 0, GT, EXIT

    defword "0<=", 3, , ZLE
    .word LIT, 0, LE, EXIT

    defword "0>=", 3, , ZGE
    .word LIT, 0, GE, EXIT

@ ---------------------------------------------------------------------
@ -- Input/output ----------------------------------------------------

    defconst "#TIB", 4, , TIBSIZE, 128

    defword "SOURCE", 6, , SOURCE
    .word XSOURCE, FETCH, EXIT

    .ltorg

    defcode ".S", 2, , PRINTSTACK
    bl printstack
    NEXT

    defcode "EMIT", 4, , EMIT
    pop {r0}
    bl putchar
    NEXT

    defcode "CR", 2, , CR
    mov r0, #13
    bl putchar
    mov r0, #10
    bl putchar
    NEXT

    defcode "BL", 2, , BL
    mov r0, #32
    push {r0}
    NEXT

    defword "SPACE", 5, , SPACE
    .word LIT, 32, EMIT, EXIT

    defcode "TYPE", 4, , TYPE
    pop {r1}
    pop {r0}
    bl putstring
    NEXT

    defcode ".", 1, , DOT
    pop {r0}
    bl putsignedhexnumber
    mov r0, #32
    bl putchar
    NEXT

    defcode "KEY", 3, , KEY
    bl read_key
    push {r0}
    NEXT

    defcode "ACCEPT", 6, , ACCEPT
    pop {r1}
    pop {r0}
    bl readline
    push {r0}
    NEXT

    defword "DUMP", 4, , DUMP
    .word QDUP, ZBRANCH, dump_end
    .word SWAP
dump_start_line:
    .word CR, DUP, DOT, LIT, 58, EMIT, BL, EMIT
dump_line:
    .word DUP, FETCHBYTE, DOT, INCR
    .word SWAP, DECR, QDUP, ZBRANCH, dump_end
    .word SWAP, DUP, LIT, 7, AND, ZBRANCH, dump_start_line
    .word BRANCH, dump_line
dump_end:
    .word DROP, EXIT

    defword "SCAN", 4, , SCAN
    @ :SCAN ( c-addr -- c-addr' )
    @ BEGIN DUP C@ 32 <> WHILE 1+ UNTIL ;
scan_loop:
    .word DUP, FETCHBYTE, LIT, 32, NEQU, ZBRANCH, scan_cont
    .word EXIT
scan_cont:
    .word INCR, BRANCH, scan_loop

    defword "-SCAN", 5, , NOTSCAN
    @ :-SCAN ( c-addr -- c-addr' )
    @ BEGIN DUP C@ 32 = WHILE 1+ UNTIL ;
not_scan_loop:
    .word DUP, FETCHBYTE, LIT, 32, EQU, ZBRANCH, not_scan_cont
    .word EXIT
not_scan_cont:
    .word INCR, BRANCH, not_scan_loop

    defword "DIGIT?", 6, , ISDIGIT
    .word DUP, LIT, '9', GT, LIT, 0x100, AND, ADD
    .word DUP, LIT, 0x140, GT, LIT, 0x107, AND, SUB, LIT, 0x30, SUB
    .word DUP, BASE, FETCH, ULT, EXIT

    defword ">NUMBER", 7, , TONUMBER
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
    .word DUP, ZBRANCH, tonumber_done
    .word OVER, FETCHBYTE, ISDIGIT
    .word ZEQU, ZBRANCH, tonumber_cont
    .word DROP, EXIT
tonumber_cont:
    .word TOR, ROT, BASE, FETCH, MUL
    .word RFROM, ADD, ROT, ROT
    .word LIT, 1, TRIMSTRING
    .word BRANCH, tonumber_loop
tonumber_done:
    .word EXIT

    defword "?NUMBER", 7, , ISNUMBER /* ( c-addr -- n true | c-addr false ) */
    .word DUP, LIT, 0, DUP, ROT, COUNT
    .word TONUMBER, ZBRANCH, is_number
    .word TWODROP, DROP, LIT, 0, EXIT
is_number:
    .word TWOSWAP, TWODROP, DROP, LIT, -1, EXIT

    .ltorg

    defword "DECIMAL", 7, , DECIMAL
    .word LIT, 10, BASE, STORE, EXIT

    defword "HEX", 3, , HEX
    .word LIT, 16, BASE, STORE, EXIT

    defword "OCTAL", 5, , OCTAL
    .word LIT, 8, BASE, STORE, EXIT

@ ---------------------------------------------------------------------
@ -- Control flow ----------------------------------------------------

    defcode "BRANCH", 7, , BRANCH
    ldr r7, [r7]
    NEXT

    defcode "0BRANCH", 7, , ZBRANCH
    pop {r0}
    cmp r0, #0
    beq code_BRANCH
    add r7, r7, #4
    NEXT

    defword "BEGIN", 5, F_IMMED, BEGIN 
    .word HERE, EXIT

    defword "AGAIN", 5, F_IMMED, AGAIN
    .word LIT, BRANCH, COMMA, COMMA, EXIT

    defword "UNTIL", 5, F_IMMED, UNTIL
    .word LIT, ZBRANCH, COMMA, COMMA, EXIT

    defword "IF", 2, F_IMMED, IF
    .word LIT, ZBRANCH, COMMA, HERE, DUP, COMMA, EXIT

    defword "ELSE", 4, F_IMMED, ELSE
    .word LIT, BRANCH, COMMA, HERE, DUP, COMMA
    .word SWAP, ENDIF, EXIT 

    defword "ENDIF", 5, F_IMMED, ENDIF
    .word HERE, SWAP, STORE, EXIT 

    defword "WHILE", 5, F_IMMED, WHILE
    .word IF, EXIT

    defword "REPEAT", 6, F_IMMED, REPEAT
    .word SWAP, LIT, BRANCH, COMMA, COMMA
    .word ENDIF, EXIT

    defcode "(DO)", 4, , XDO
    pop {r0, r1}
    ldr r2, [r6]
    str r1, [r6]
    sub r6, r6, #4
    str r0, [r6]
    sub r6, r6, #4
    str r2, [r6]
    NEXT

    defcode "I", 1, , INDEX
    ldr r0, [r6, #4]
    push {r0}
    NEXT

    defcode "(LOOP)", 6, , XLOOP
    ldr r0, [r6, #4]
    add r0, r0, #1
    ldr r1, [r6, #8]
    cmp r0, r1
    bge 1f
    str r0, [r6, #4]
    mov r0, #0
    push {r0}
    NEXT
1:  ldr r0, [r6]
    add r6, r6, #8
    str r0, [r6]
    mvn r0, #0
    push {r0}
    NEXT

    defword "DO", 2, F_IMMED, DO
    .word LIT, XDO, COMMA, HERE, EXIT

    defword "LOOP", 4, F_IMMED, LOOP
    .word LIT, XLOOP, COMMA, LIT, ZBRANCH, COMMA, COMMA, EXIT

@ ---------------------------------------------------------------------
@ -- Compiler and interpreter ----------------------------------------

    defcode "(ABRANCH)", 9, , ASMBRANCH
    pop {r0}
    bl calc_wide_branch
    push {r0}
    NEXT

    defword "HERE", 4, , HERE
    .word DP, FETCH, EXIT

    defword "ALLOT", 5, , ALLOT
    .word DP, ADDSTORE, EXIT

    defword ",", 1, , COMMA
    .word HERE, STORE, CELL, ALLOT, EXIT

    defword "C,", 2, , CCOMMA
    .word HERE, STOREBYTE, LIT, 1, ALLOT, EXIT

    defword "\'", 1, , TICK
    .word BL, WORD, FIND, DROP, EXIT  @ TODO abort if not found

    defword "[\']", 3, F_IMMED, BRACKETTICK
    .word TICK, LIT, LIT, COMMA, COMMA, EXIT  

    defword "(DOES>)", 7, , XDOES
    .word RFROM, LATEST, FETCH, FROMLINK, STORE, EXIT 

    defword "DOES>", 5, F_IMMED, DOES
    .word LIT, XDOES, COMMA
    .word LIT
    ldr.w r1, [pc, #4]
    .word COMMA
    .word LIT
    blx r1
    .short 0
    .word COMMA
    .word LIT, DODOES + 1, COMMA, EXIT

    defword "CREATE", 6, , CREATE
    .word HERE, ALIGNED, DP, STORE
    .word LATEST, FETCH
    .word HERE, LATEST, STORE       @ update latest
    .word COMMA                     @ set link
    .word BL, WORD, FETCHBYTE, INCR, ALIGNED, ALLOT  @ set name field
    .word LIT, DOVAR, COMMA         @ set code field
    .word EXIT

    defword "VARIABLE", 8, , VARIABLE
    .word CREATE, CELL, ALLOT, EXIT

    defword "CONSTANT", 8, , CONSTANT
    .word CREATE, COMMA, XDOES
    add r0, r0, #4
    ldr r0, [r0]
    push {r0}
    NEXT

    defcode "LIT", 3, , LIT
    ldr r0, [r7]
    add r7, r7, #4
    push {r0}
    NEXT

    defcode "FIND", 4, , FIND
    pop {r0}
    mov r10, r0
    ldrb r1, [r0]
    add r0, r0, #1
    mov r2, r1          @ length
    mov r1, r0          @ address
    ldr r0, =addr_LATEST
    ldr r0, [r0]        @ current dictionary pointer
1:  cmp r0, #0          @ NULL?
    bne 12f
    mov r1, #0
    mov r0, r10
    b 4f              @ end of list!
12: ldrb r3, [r0, #4]       @ flags+length field
    and r3, r3, #(F_HIDDEN|F_LENMASK)
    cmp r3, r2          @ length the same?
    bne 2f              @ nope, skip this entry
    mov r4, r1          @ current char in string A
    mov r5, r0
    add r5, r5, #5      @ current char in string B
10: push {r0, r1, r2}
    mov r2, #32
    ldrb r0, [r4]
    add r4, r4, #1
    ldrb r1, [r5]
    add r5, r5, #1
    cmp r0, #64
    ble 11f
    cmp r0, #90
    bgt 11f
    orr r0, r2
11: cmp r1, #64
    ble 12f
    cmp r1, #90
    bgt 12f
    orr r1, r2
12: mov r8, r0
    mov r9, r1
    pop {r0, r1, r2}
    cmp r8, r9          @ A = B?
    bne 2f              @ nope
    sub r3, r3, #1      @ decrement
    cmp r3, #0
    bne 10b             @ > 0, keep going
    add r0, r0, #4      @ skip link pointer
    ldrb r1, [r0]       @ load flags+len
    mov r2, #F_IMMED
    and r2, r1, r2    @ save to check flags
    cmp r2, #0
    beq 13f
    mov r2, #1        @ 1 for immediate words
    b 14f
13: mov r2, #0        @ -1 for normal words
    sub r2, r2, #1
14: add r0, r0, #1      @ skip flags+len bytes
    and r1, r1, #F_LENMASK  @ mask out flags
    add r0, r0, r1      @ skip name
    add r0, r0, #3      @ align to 4-byte boundary
    mvn r3, #3
    and r0, r0, r3
    mov r1, r2
    b 4f                @ strings are equal, r0 is the correct entry pointer
2:  ldr r0, [r0]        @ previous dictionary pointer
    b 1b                @ try again
4:  push {r0}
    push {r1}
    NEXT


    .ltorg

    defword "SKIP", 4, , SKIP
/*  SKIP ( c-addr n c -- c-addr' n' ) \ TODO: check result if not found
    : skip >r begin over c@ r@ = over 0>= and while 1 /string repeat r> drop ;
*/
    NEXT    

    defword "+SKIP", 5, , PSKIP
/*
    +SKIP ( c -- )
    ( fetch source address, get byte, compare fetched byte to delimiter, increment address and loop if not equal )
    BEGIN
      DUP SOURCE >IN @ +      ( delimiter delimiter address )
      C@                      ( delimiter delimiter content )
      (compare)               ( delimiter check)
    WHILE
      CHAR >IN +! 
    REPEAT
    DROP
*/

skip_loop:
    .word DUP, SOURCE, ININDEX, FETCH, ADD
    .word FETCHBYTE
    .word EQU
    .word ZBRANCH, skip_loop_done
    .word CHAR, ININDEX, ADDSTORE
    .word BRANCH, skip_loop
skip_loop_done:
    .word DROP, EXIT

    defword "WORD", 4, , WORD
    .word SOURCE, ININDEX, FETCH, ADD
word_find_start:
    .word DUP, FETCHBYTE, ROT, SWAP, OVER, EQU, ROT, DUP, FETCHBYTE, DUP, BL, LE, AND, ROT, OR, SWAP, ROT, ROT, ZBRANCH, word_start_found
    .word SWAP, INCR
    .word LIT, 1, ININDEX, ADDSTORE
    .word BRANCH, word_find_start
word_start_found:
    .word OVER
word_find_end:
    .word DUP, FETCHBYTE, ROT, SWAP, OVER, NEQU, ROT, DUP, FETCHBYTE, DUP, BL, GE, AND, ROT, AND, SWAP, ROT, ROT, ZBRANCH, word_end_found
    .word SWAP, INCR
    .word LIT, 1, ININDEX, ADDSTORE
    .word BRANCH, word_find_end
word_end_found:
    .word DROP, OVER, SUB
    .word DUP, HERE, STORE
    .word HERE, INCR, SWAP, CMOVE
    .word HERE, EXIT

    defcode "LINK>", 5, , FROMLINK
    pop {r0}
    add r0, r0, #4      @ skip link pointer
    ldrb r1, [r0]       @ load flags+len
    add r0, r0, #1      @ skip flags+len bytes
    and r1, r1, #F_LENMASK  @ mask out flags
    add r0, r0, r1      @ skip name
    add r0, r0, #3      @ align to 4-byte boundary
    mvn r2, #3
    and r0, r2
    push {r0}
    NEXT

    defcode ">NAME", 5, , TONAME
    pop {r0}
    mvn r2, #F_IMMED
1:  sub r0, r0, #1
    ldrb r1, [r0]
    and r1, r2
    cmp r1, #32
    bgt 1b
    cmp r1, #0
    beq 1b
    push {r0}
    NEXT

    .ltorg

    defword ">LINK", 5, , TOLINK
    .word TONAME, CELL, SUB, EXIT

    defcode "EXECUTE",7, ,EXECUTE
    pop {r0}
    ldr r1, [r0]
    add r1, r1, #1
    mov pc, r1

    defword "(INTERPRET)", 11, , XINTERPRET @ TODO restructure this
    .word LIT, 0, STATE, STORE
interpret_loop:
    .word BL, WORD, DUP, FETCHBYTE, ZBRANCH, interpret_eol
    .word FIND, QDUP, ZBRANCH, interpret_check_number
    .word STATE, FETCH, ZBRANCH, interpret_execute
    .word INCR, ZBRANCH, interpret_compile_word
    .word EXECUTE, BRANCH, interpret_loop
interpret_compile_word:
    .word COMMA, BRANCH, interpret_loop
interpret_execute:
    .word DROP, EXECUTE, BRANCH, interpret_loop
interpret_check_number:
    .word ISNUMBER, ZBRANCH, interpret_not_found
    .word STATE, FETCH, ZBRANCH, interpret_loop
    .word LIT, LIT, COMMA, COMMA, BRANCH, interpret_loop
interpret_not_found:
    .word LIT, 0, EXIT
interpret_eol:
    .word LIT, -1, EXIT

    defword "INTERPRET", 9, , INTERPRET
    .word TIB, XSOURCE, STORE
    .word LIT, 0, ININDEX, STORE
    .word SOURCE, DUP, TIBSIZE, ACCEPT, ADD, LIT, 0, SWAP, STOREBYTE, SPACE
    .word XINTERPRET, ZBRANCH, interpret_error
    .word DROP, LIT, prompt, LIT, 4, TYPE, CR, EXIT
interpret_error:
    .word COUNT, TYPE, LIT, '?', EMIT, CR, EXIT
prompt:
    .ascii " ok "

    defword "EVALUATE", 8, , EVALUATE
    .word XSOURCE, STORE, LIT, 0, ININDEX, STORE, XINTERPRET, TWODROP, EXIT

    .align 2, 0

    defword "FORGET", 6, , FORGET
    /* BL WORD DROP FIND DROP >LINK @ LATEST ! */
    .word BL, WORD, FIND, DROP, TOLINK, FETCH, LATEST, STORE, EXIT

    defword "HIDE", 4, , HIDE
    .word LATEST, FETCH, CELL, ADD, DUP, FETCHBYTE, LIT, F_HIDDEN, OR, SWAP, STOREBYTE, EXIT  

    defword "REVEAL", 6, , REVEAL
    .word LATEST, FETCH, CELL, ADD, DUP, FETCHBYTE, LIT, F_HIDDEN, INVERT, AND, SWAP, STOREBYTE, EXIT  

    defword "IMMEDIATE", 9, , IMMEDIATE
    .word LATEST, FETCH, CELL, ADD, DUP, FETCHBYTE, LIT, F_IMMED, OR, SWAP, STOREBYTE, EXIT  

    defword "[", 1, F_IMMED, LBRACKET
    .word LIT, 0, STATE, STORE, EXIT

    defword "]", 1, , RBRACKET
    .word LIT, -1, STATE, STORE, EXIT

    defword ":", 1, , COLON
    /* CREATE HIDE ] ' DOCOL HERE CELL - ! */
    .word CREATE, HIDE, RBRACKET, LIT, DOCOL, HERE, CELL, SUB, STORE, EXIT

    defword ";", 1, F_IMMED, SEMICOLON
    .word LIT, EXIT, COMMA, REVEAL, LBRACKET, EXIT

    defword "QUIT", 4, , QUIT
quit_loop:
    .word INTERPRET
    .word BRANCH, quit_loop

    defword "TEST", 4, , TEST
    .word QUIT

    defword "WORDS", 5, , WORDS
    .word LATEST, FETCH
words_loop:
    .word DUP, CELL, ADD, COUNT, LIT, 31, AND, TYPE, SPACE
    .word FETCH, QDUP, ZEQU, ZBRANCH, words_loop
    .word EXIT

    defword "get-next", 8, , get_next
    .word LATEST, FETCH
get_next_loop:
    .word TWODUP, FETCH, NEQU, ZBRANCH, get_next_done
    .word FETCH, BRANCH, get_next_loop
get_next_done:
    .word SWAP, DROP, EXIT

    defword "print-word", 10, , print_word
    .word DUP, DUP, FETCH, CELL, SUB, OVER, NEQU, ZBRANCH, print_code
    .word DUP, FETCH
    .word DUP, LIT, DOCOL, NEQU, ZBRANCH, print_docol
    .word DUP, LIT, BRANCH, NEQU, ZBRANCH, print_branch
    .word DUP, LIT, ZBRANCH, NEQU, ZBRANCH, print_zbranch
    .word DUP, LIT, LIT, NEQU, ZBRANCH, print_literal
    .word TONAME, COUNT, LIT, 31, AND, TYPE, SPACE, TWODROP, CELL, EXIT
print_code:
    .word DROP, LIT, print_label_code, LIT, 4, TYPE, SPACE, DROP, LIT, 0, EXIT
print_docol:
    .word DROP, LIT, ':', EMIT, SPACE, TWODROP, CELL, EXIT
print_branch:
    .word DROP, LIT, print_label_branch, LIT, 6, TYPE, SPACE, CELL, ADD, FETCH, SWAP, SUB, CELL, DIV, DOT, LIT, 2, CELLS, EXIT
print_zbranch:
    .word DROP, LIT, print_label_zbranch, LIT, 7, TYPE, SPACE, CELL, ADD, FETCH, SWAP, SUB, CELL, DIV, DOT, LIT, 2, CELLS, EXIT
print_literal:
    .word DROP, LIT, print_label_lit, LIT, 3, TYPE, SPACE, CELL, ADD, FETCH, DOT, DROP, LIT, 2, CELLS, EXIT
print_label_code:
    .ascii "CODE"
print_label_lit:
    .ascii "LIT"
print_label_branch:
    .ascii "BRANCH"
print_label_zbranch:
    .ascii "ZBRANCH"
    .align 2

    defword "SEE", 3, , SEE
    .word BL, WORD, FIND, ZBRANCH, see_not_found
    .word DUP, TOLINK, get_next
see_loop:
    .word OVER, TWODUP, NEQU, ZBRANCH, see_done
    .word print_word, DUP, ZBRANCH, see_done
    .word ROT, ADD, SWAP
    .word BRANCH, see_loop
see_not_found:
see_done:
    .word EXIT

@ ---------------------------------------------------------------------
@ -- User variables ---------------------------------------------------

    defvar "STACK", 5, , STACK, 1024
    defvar "TOS", 3, , TOS, 0
    defvar "RSTACK", 6, , RSTACK, 256
    defvar "RTOS", 3, , RTOS, 0
    defvar "STATE", 5, , STATE
    defvar "DP", 2, , DP
    defvar "LATEST", 6, , LATEST
    defvar "S0", 2, , SZ
    defvar "BASE", 4, , BASE
    defvar ">IN", 3, , ININDEX
    defvar "TIB", 3, , TIB, 132
    defvar "(SOURCE)", 7, , XSOURCE

    .ltorg

@ ---------------------------------------------------------------------


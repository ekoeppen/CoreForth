@ ---------------------------------------------------------------------
@ -- Disassembler -----------------------------------------------------

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

    defcode ".UX", DOTUX
    movs r0, '0'
    bl putchar
    movs r0, 'x'
    bl putchar
    pop {r0}
    bl puthexnumber
    NEXT

    defword "TYPE-ESCAPED", TYPE_ESCAPED
    .word QDUP, QBRANCH, 0x4c
    .word SWAP, DUP, CFETCH, DUP, LIT, '"', EQU, QBRANCH, 0x10
    .word LIT, '\\', EMIT
    .word EMIT, ONEPLUS, SWAP, ONEMINUS, BRANCH, 0xffffffb0, DROP, EXIT

    defword "QUOTE-CHAR", QUOTE_CHAR
    .word LIT, QUOTE_CHARS
2:  .word TWODUP, FETCHBYTE, DUP, ZNEQU, QBRANCH, 3f - ., NEQU, QBRANCH, 1f - .
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
    .ascii "4\004FOUR"
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
    .word OVER, FETCHBYTE, LIT, '-', EQU, QBRANCH, 1f - .
    .word SWAP, LIT, QUOTE_MINUS + 1, BRANCH, 5f - .
1:  .word DUP, ZGT, QBRANCH, 4f - .
    .word DUP, LIT, 1, EQU, QBRANCH, 6f - .
    .word OVER, FETCHBYTE, LIT, '-', EQU, QBRANCH, 6f - .
    .word SWAP, LIT, QUOTE_MINUS + 1, BRANCH, 5f - .
6:  .word SWAP, DUP, FETCHBYTE, QUOTE_CHAR, QBRANCH, 2f - .
5:  .word COUNT, TYPE, BRANCH, 3f - .
2:  .word EMIT
3:  .word INCR, SWAP, DECR, BRANCH, 1b - .
4:  .word TWODROP, EXIT

    defword "VALID-ADDR?", ISVALIDADDR
    .word DUP, LIT, cold_start, LIT, last_word, FROMLINK, CELL, ADD, WITHIN, QDUP, QBRANCH, 1f - .
    .word NIP, EXIT
1:  .word LIT, ram_start, LIT, ram_top, WITHIN, EXIT


    defword "XT?", XTQ
    .word DUP, ISVALIDADDR, QBRANCH, 2f - .
    .word LATEST
1:  .word FETCH, TWODUP, FROMLINK, EQU, OVER, ZEQU, OR, QBRANCH, 1b - ., NIP, ZNEQU, EXIT
2:  .word DROP, LIT, 0, EXIT

    defword "NEXT-WORD", NEXT_WORD
    .word LATEST, FETCH
    .word TWODUP, EQU, QBRANCH, 1f - .
    .word TWODROP, HERE, EXIT
1:  .word TWODUP, FETCH, NEQU, QBRANCH, 2f - .
    .word FETCH, BRANCH, 1b - .
2:  .word SWAP, DROP, EXIT

    defword "(.CSPACE)", XCSPACE
    .word LIT, ',', EMIT, SPACE, EXIT

    defword "(.WORD-FLAGS)", XWORD_FLAGS
    .word TOFLAGS, FETCHBYTE, LIT, F_FLAGSMASK, AND, XCSPACE, DOTUX, EXIT

    defword "(.WORD-NAME)", XWORD_NAME
    .word LIT, '"', EMIT, TONAME, COUNT, LIT, 31, AND, TWODUP, TYPE_ESCAPED
    .word LIT, 1f, COUNT, TYPE, DOTQUOTED, EXIT
1:  .ascii "\003\", "

    defword ".SQUOTE", DOTSQUOTE
    .word TONAME, COUNT, DOTQUOTED, XCSPACE, DROP, CELL, ADD, DUP, FETCHBYTE, CHAR, ADD, ALIGNED, DUP, ROTROT
1:  .word SWAP, DUP, FETCH, DOTUX, OVER, CELL, NEQU, QBRANCH, 2f - ., XCSPACE
2:  .word CELL, ADD, SWAP, CELL, SUB, DUP, ZEQU, QBRANCH, 1b - .
    .word TWODROP, CELL, ADD, EXIT

    defword ".DOCOL-HEADER", DOTDOCOL_HEADER
    .word LIT, 1f, COUNT, TYPE, DUP, XWORD_NAME, XWORD_FLAGS, EXIT
1:  .ascii "\015\n    defword "

    defword ".DOCOL", DOTDOCOL
    .word DOTDOCOL_HEADER, LIT, 1f, COUNT, TYPE, EXIT
1:  .ascii "\013\n    .word "

    defword ".DOVAR", DOTDOVAR
    .word LIT, 1f, COUNT, TYPE, XWORD_NAME, XCSPACE, TWODUP, SUB, CELL, SUB, DOTUX, LF, EXIT
1:  .ascii "\014\n    defvar "

    defword ".DOCON", DOTDOCON
    .word LIT, 1f, COUNT, TYPE, XWORD_NAME, XCSPACE, DUP, CELL, ADD, FETCH
    .word DOTLITORXT, LF, EXIT
1:  .ascii "\016\n    defconst "

    defword ".LIT-OR-XT", DOTLITORXT
    .word DUP, XTQ, QBRANCH, 1f - .
    .word TONAME, COUNT, LIT, 31, AND, DOTQUOTED, EXIT
1:  .word DOTUX, EXIT

    defword ".DODATA", DOTDODATA
    .word LIT, 1f, COUNT, TYPE, XWORD_NAME, LIT, 2f, COUNT, TYPE, EXIT
1:  .ascii "\015\n    defdata "
2:  .ascii "\013\n    .word "

    defword ".DOTDODOES", DOTDODOES
    .word SWAP, DOTDOCOL_HEADER, XCSPACE, ANYTOLINK, LINKTONAME, COUNT, DOTQUOTED
    .word LIT, 1f, COUNT, TYPE, EXIT
1:  .ascii "\016_XT\n    .word "

    defword ".WORD", DOTWORD
    .word DUP, DUP, FETCH, CELL, SUB, OVER, NEQU, QBRANCH, print_code - .
    .word DUP, FETCH
    .word DUP, ISVALIDADDR, QBRANCH, 1f - .
    .word DUP, LIT, LIT, NEQU, QBRANCH, print_lit - .
    .word DUP, LIT, DOCOL, NEQU, QBRANCH, print_docol - .
    .word DUP, LIT, DOVAR, NEQU, QBRANCH, print_dovar - .
    .word DUP, LIT, DOCON, NEQU, QBRANCH, print_docon - .
    .word DUP, LIT, DODATA, NEQU, QBRANCH, print_dodata - .
    .word DUP, LIT, XDOES, NEQU, QBRANCH, print_xdoes - .
    .word DUP, LIT, XSQUOTE, NEQU, QBRANCH, print_xsquote - .
    .word DUP, FETCH, LIT, 0x47884900, NEQU, QBRANCH, print_dodoes - .
    .word DOTLITORXT, TWODROP, CELL, EXIT
1:  .word DOTUX, TWODROP, CELL, EXIT
print_lit:
    .word DROP, LIT, print_label_lit, COUNT, TYPE, XCSPACE, CELL, ADD, FETCH, DOTUX, DROP, LIT, 2, CELLS, EXIT
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
    .word LIT, print_xdoes_xt, COUNT, TYPE, DUP, ANYTOLINK, LINKTONAME, COUNT, DOTQUOTED
    .word LIT, print_xt_suffix, COUNT, TYPE
    .word CELL, ADD, FETCH, DOTUX, XCSPACE, LIT, print_label_dodoes, COUNT, TYPE
    .word DROP, LIT, 3, CELLS, EXIT
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
    .ascii "\007QBRANCH"
print_label_dodoes:
    .ascii "\012DODOES + 1"
print_xdoes_xt:
    .ascii "\012\n    .set "
print_xt_suffix:
    .ascii "\021_XT, .\n    .word "
    .align 2

    defword "(SEE)", XSEE
    .word DUP, TOLINK, NEXT_WORD
    .word OVER, DOTWORD, DUP, QBRANCH, 2f - .
    .word ROT, ADD, SWAP
    .word TWODUP, NEQU, QBRANCH, 2f - .
1:  .word OVER, DOTWORD, DUP, QBRANCH, 2f - .
    .word ROT, ADD, SWAP
    .word TWODUP, NEQU, QBRANCH, 2f - .
    .word XCSPACE, BRANCH, 1b - .
2:  .word TWODROP
    .word LF, EXIT

    defword "SEE", SEE
    .word BL, WORD, FIND, QBRANCH, 3f - .
    .word XSEE
3:  .word EXIT

    defword ">>PAD!", STORETOPAD
    .word CELL, PAD, PLUSSTORE, PAD, FETCH, STORE, EXIT

    defword "SEE-RANGE", SEE_RANGE
    .word PAD, DUP, STORE
1:  .word DUP, LINKTOFLAGS, FETCH, LIT, F_NODISASM, AND, ZEQU, QBRANCH, 5f - .
    .word DUP, FROMLINK, STORETOPAD
5:  .word TWODUP, NEQU, QBRANCH, 2f - .
    .word FETCH, BRANCH, 1b - .
2:  .word TWODROP
    .word PAD, DUP, FETCH
3:  .word TWODUP, NEQU, QBRANCH, 4f - .
    .word DUP, FETCH, XSEE, CELL, SUB, BRANCH, 3b - .
4:  .word TWODROP, EXIT

    defword "PRECOMP-BEGIN", PRECOMP_BEGIN
    .word HERE, EXIT

    defword "PRECOMP-END", PRECOMP_END
    .word LATEST, FETCH, SEE_RANGE, BYE

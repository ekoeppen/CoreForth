
    defword "?ABORT", QABORT, 0x0
    .word ROT, QBRANCH, 0xc, TYPE, ABORT, TWODROP, EXIT

    defword "ABORT", ABORT, 0x0
    .word SZ, SPSTORE, LPARENSQUOTRPAREN, 0x726f4310, 0x726f4665, 0x72206874, 0x79646165, 0x2e, TYPE, CR, QUIT, EXIT

    defword "QUIT", QUIT, 0x0
    .word RZ, RPSTORE, INTERPRET, BRANCH, 0xfffffff8, EXIT

    defword "INTERPRET", INTERPRET, 0x0
    .word LIT, 0x0, STATE, STORE, TIB, LPARENSOURCERPAREN, STORE, LIT, 0x0, GTSOURCE, STORE, ACCEPT, SOURCENUM, STORE, SPACE, LPARENINTERPRETRPAREN, QBRANCH, 0x20, DROP, LPARENSQUOTRPAREN, 0x6b6f2004, 0x20, TYPE, BRANCH, 0x18, COUNT, TYPE, LIT, 0x63, EMIT, CR, EXIT

    defword "?YIELD", QYIELD, 0x80
    .word LIT, IF, EXECUTE, LIT, LIT, COMMAXT, SWAP, COMMA, LIT, LIT, COMMAXT, LATEST, FETCH, LINKGT, GTBODY, COMMA, LIT, STORE, COMMAXT, LIT, EXIT, COMMAXT, LIT, THEN, EXECUTE, EXIT

    defword ";PT", SEMIPT, 0x80
    .word LIT, LIT, COMMAXT, LATEST, FETCH, LINKGT, GTBODY, DUP, CELL, PLUS, COMMA, LIT, LIT, COMMAXT, COMMA, LIT, STORE, COMMAXT, LIT, SEMI, EXECUTE, EXIT

    defword "PT:", PTCOLON, 0x0
    .word CREATE, HERE, CELL, PLUS, COMMA, RBRAC, LPARENDOESGTRPAREN
    .set PTCOLON_XT, .
    .word 0x47884900, DODOES + 1, FETCH, GTR, EXIT

    defword "EDIT", EDIT, 0x0
    .word CLS, LIT, 0x0, DUP, AT_XY, LIST, LIT, 0x0, STOREXY, KEY, SWAP, QCH, SWAP, LIT, 0x18, EQU, QBRANCH, 0xffffffdc, UPDATE, DROP, L, EXIT

    defword "?CH", QCH, 0x0
    .word OVER, BL, MINUS, LIT, 0x5f, ULT, QBRANCH, 0x10, STORECH, ONEPLUS, EXIT, OVER, KEY_LEFT, EQU, QBRANCH, 0x8, ONEMINUS, OVER, KEY_RIGHT, EQU, QBRANCH, 0x8, ONEPLUS, OVER, KEY_UP, EQU, QBRANCH, 0xc, CSLASHL, MINUS, OVER, KEY_DOWN, EQU, QBRANCH, 0xc, CSLASHL, PLUS, OVER, KEY_HOME, EQU, QBRANCH, 0x14, CSLASHL, ONEMINUS, INVERT, AND, OVER, KEY_DELETE, EQU, QBRANCH, 0x14, DUP, TAILLT, DUP, DOTTAIL, OVER, KEY_BACKSPACE, EQU, QBRANCH, 0x1c, ONEMINUS, DUP, TAILLT, STOREXY, DUP, DOTTAIL, OVER, KEY_PGUP, EQU, QBRANCH, 0x1c, UPDATE, B, L, DROP, LIT, 0x0, OVER, KEY_PGDOWN, EQU, QBRANCH, 0x1c, UPDATE, N, L, DROP, LIT, 0x0, OVER, LIT, 0xd, EQU, QBRANCH, 0x18, CSLASHL, TWODUP, MOD, MINUS, PLUS, EXIT

    defword "!CH", STORECH, 0x0
    .word DUP, TAILGT, TWODUP, GTBLK, CSTORE, DUP, DOTTAIL, EXIT

    defword "!XY", STOREXY, 0x0
    .word CSLASHBLK, ONEMINUS, AND, DUP, CSLASHL, SLASHMOD, ONEPLUS, AT_XY, EXIT

    defword "N", N, 0x0
    .word LIT, 0x1, SCR, PLUSSTORE, EXIT

    defword "B", B, 0x0
    .word LIT, 0xffffffff, SCR, PLUSSTORE, EXIT

    defword "L", L, 0x0
    .word LIT, 0x0, DUP, AT_XY, RE, LIST, EXIT

    defword "RE", RE, 0x0
    .word SCR, FETCH, EXIT

    defword "LIST", LIST, 0x0
    .word DUP, SCR, STORE, DOTD, LPARENSQUOTRPAREN, 0x63732004, 0x72, TYPE, CR, LIT, 0x0, DUP, LL, CR, ONEPLUS, DUP, LIT, 0x10, EQU, QBRANCH, 0xffffffdc, DROP, EXIT

    defword "LL", LL, 0x0
    .word CSLASHL, MUL, SCR, FETCH, BLOCK, PLUS, CSLASHL, TYPE, EXIT

    defword "TAIL<", TAILLT, 0x0
    .word DUP, DUP, GTBLK, DUP, ONEPLUS, SWAP, ROT, GTTAIL_LENGTH, CMOVE, CLR_LAST, EXIT

    defword "TAIL>", TAILGT, 0x0
    .word DUP, GTBLK, DUP, ONEPLUS, ROT, GTTAIL_LENGTH, ONEMINUS, CMOVEGT, EXIT

    defword ".TAIL", DOTTAIL, 0x0
    .word STORECURSOR, DUP, GTBLK, SWAP, GTTAIL_LENGTH, TYPE, FETCHCURSOR, EXIT

    defword ">TAIL-LENGTH", GTTAIL_LENGTH, 0x0
    .word CSLASHL, TUCK, ONEMINUS, AND, MINUS, EXIT

    defword "CLR-LAST", CLR_LAST, 0x0
    .word CSLASHL, ONEMINUS, OR, GTBLK, BL, SWAP, CSTORE, EXIT

    defword ">BLK", GTBLK, 0x0
    .word LPARENLPARENBLOCKRPARENRPAREN, PLUS, EXIT

    defword "UPDATE", UPDATE, 0x0
    .word LPARENLPARENBLOCKRPARENRPAREN, BLOCKNUM, FETCH, LPARENUPDATERPAREN, EXIT

    defword "BLOCK", BLOCK, 0x0
    .word LPARENLPARENBLOCKRPARENRPAREN, SWAP, DUP, BLOCKNUM, FETCH, LTGT, QBRANCH, 0x1c, TWODUP, LPARENBLOCKRPAREN, BLOCKNUM, STORE, BRANCH, 0x8, DROP, EXIT

    defvar "BLOCK#", BLOCKNUM, 0x4


    defvar "SCR", SCR, 0x4


    defconst "C/L", CSLASHL, 0x40


    defword "ACCEPT", ACCEPT, 0x0
    .word LIT, 0x0, TIBNUM, STORE, LIT, 0x0, GTTIB, STORE, KEY, DUP, LIT, 0x20, LIT, 0x7f, WITHIN, MINUSFULLQ, AND, QBRANCH, 0x18, INSERT, DOTTIB_TAIL, CURSORGT, BRANCH, 0x12c, DUP, LIT, 0x7f, EQU, MINUSSTARTQ, AND, QBRANCH, 0x1c, DROP, CURSORLT, DELETE, DOTTIB_TAIL, BRANCH, 0xf4, DUP, LIT, 0x8, EQU, OVER, LIT, 0xffffff99, EQU, OR, MINUSENDQ, AND, QBRANCH, 0x18, DROP, DELETE, DOTTIB_TAIL, BRANCH, 0xac, DUP, LIT, 0xd, EQU, OVER, LIT, 0xa, EQU, OR, QBRANCH, 0x1c, DROP, TIBNUM, FETCH, EXIT, BRANCH, 0x68, DUP, LIT, 0xfffffffd, EQU, MINUSENDQ, AND, QBRANCH, 0x14, DROP, CURSORGT, BRANCH, 0x38, DUP, LIT, 0xfffffffc, EQU, MINUSSTARTQ, AND, QBRANCH, 0x14, DROP, CURSORLT, BRANCH, 0x8, DROP, BRANCH, 0xfffffe94, EXIT

    defword "-FULL?", MINUSFULLQ, 0x0
    .word TIBNUM, FETCH, NUMTIB, LT, EXIT

    defword "-END?", MINUSENDQ, 0x0
    .word GTTIB, FETCH, TIBNUM, FETCH, LT, EXIT

    defword "-START?", MINUSSTARTQ, 0x0
    .word GTTIB, FETCH, ZGT, EXIT

    defword "DELETE", DELETE, 0x0
    .word LIT, 0x1, TIBNUM, MINUSSTORE, TIB_TAIL, OVER, ONEPLUS, MINUSROT, CMOVE, EXIT

    defword "INSERT", INSERT, 0x0
    .word TIB_TAIL, OVER, ONEPLUS, SWAP, CMOVEGT, LIT, 0x1, TIBNUM, PLUSSTORE, TIB, GTTIB, FETCH, PLUS, CSTORE, EXIT

    defword "CURSOR<", CURSORLT, 0x0
    .word LIT, 0x1, GTTIB, MINUSSTORE, CURSOR_LEFT, EXIT

    defword "CURSOR>", CURSORGT, 0x0
    .word LIT, 0x1, GTTIB, PLUSSTORE, CURSOR_RIGHT, EXIT

    defword ".TIB-TAIL", DOTTIB_TAIL, 0x0
    .word CLR_EOL, STORECURSOR, TIB_TAIL, TYPE, FETCHCURSOR, EXIT

    defword "TIB-TAIL", TIB_TAIL, 0x0
    .word GTTIB, FETCH, TIBNUM, FETCH, OVER, MINUS, SWAP, TIB, PLUS, SWAP, EXIT

    defconst "KEY-BACKSPACE", KEY_BACKSPACE, -0x6b


    defconst "KEY-PGDOWN", KEY_PGDOWN, -0x6a


    defconst "KEY-PGUP", KEY_PGUP, -0x69


    defconst "KEY-DELETE", KEY_DELETE, -0x67


    defconst "KEY-INSERT", KEY_INSERT, -0x66


    defconst "KEY-END", KEY_END, -0x68


    defconst "KEY-HOME", KEY_HOME, -0x65


    defconst "KEY-RIGHT", KEY_RIGHT, -0x3


    defconst "KEY-LEFT", KEY_LEFT, -0x4


    defconst "KEY-DOWN", KEY_DOWN, -0x2


    defconst "KEY-UP", KEY_UP, -0x1


    defword "CLR-LINE", CLR_LINE, 0x0
    .word ANSI_ESC_START, LIT, 0x32, EMIT, LIT, 0x4b, EMIT, EXIT

    defword "CLR-SOL", CLR_SOL, 0x0
    .word ANSI_ESC_START, LIT, 0x31, EMIT, LIT, 0x4b, EMIT, EXIT

    defword "CLR-EOL", CLR_EOL, 0x0
    .word ANSI_ESC_START, LIT, 0x30, EMIT, LIT, 0x4b, EMIT, EXIT

    defword "CURSOR-LEFT", CURSOR_LEFT, 0x0
    .word ANSI_ESC_START, LIT, 0x44, EMIT, EXIT

    defword "CURSOR-RIGHT", CURSOR_RIGHT, 0x0
    .word ANSI_ESC_START, LIT, 0x43, EMIT, EXIT

    defword "CURSOR-DOWN", CURSOR_DOWN, 0x0
    .word ANSI_ESC_START, LIT, 0x42, EMIT, EXIT

    defword "CURSOR-UP", CURSOR_UP, 0x0
    .word ANSI_ESC_START, LIT, 0x41, EMIT, EXIT

    defword "CLS", CLS, 0x0
    .word ANSI_ESC_START, LIT, 0x32, EMIT, LIT, 0x4a, EMIT, LIT, 0x0, LIT, 0x0, AT_XY, EXIT

    defword "@CURSOR", FETCHCURSOR, 0x0
    .word LIT, 0x1b, EMIT, LIT, 0x38, EMIT, EXIT

    defword "!CURSOR", STORECURSOR, 0x0
    .word LIT, 0x1b, EMIT, LIT, 0x37, EMIT, EXIT

    defword "AT-XY", AT_XY, 0x0
    .word ANSI_ESC_START, ONEPLUS, DOTD, LIT, 0x3b, EMIT, ONEPLUS, DOTD, LIT, 0x48, EMIT, EXIT

    defword "ANSI-ESC-START", ANSI_ESC_START, 0x0
    .word LIT, 0x1b, EMIT, LIT, 0x5b, EMIT, EXIT

    defword "LED0!", LEDZSTORE, 0x0
    .word LIT, 0x1, EQU, LIT, 0x20, AND, LIT, 0x20, GPIOC, GPIO_DATASTORE, EXIT

    defword "LED0-ENABLE", LEDZ_ENABLE, 0x0
    .word LIT, 0x20, GPIOC, GPIO_DIR, SET_BITS, EXIT

    defword "UART0-BRR@", UARTZ_BRRFETCH, 0x0
    .word UARTZ, UART_IBRD, FETCH, UARTZ, UART_FBRD, FETCH, EXIT

    defword "UART0-BRR!", UARTZ_BRRSTORE, 0x0
    .word UARTZ, UART_FBRD, STORE, UARTZ, UART_IBRD, STORE, EXIT

    defword "UART0-ENABLE", UARTZ_ENABLE, 0x0
    .word LIT, 0x301, UARTZ, UART_CR, STORE, EXIT

    defword "UART0-DISABLE", UARTZ_DISABLE, 0x0
    .word LIT, 0x0, UARTZ, UART_CR, STORE, EXIT

    defword "USE-PLL", USE_PLL, 0x0
    .word SYSCTL_RCC, DUP, FETCH, LIT, 0xffff7ff, AND, SWAP, STORE, EXIT

    defword "PLL-50HZ", PLL_5ZHZ, 0x0
    .word SYSCTL_RCC, DUP, DUP, FETCH, LIT, 0xf83fffff, AND, LIT, 0x800, OR, SWAP, STORE, DUP, DUP, FETCH, LIT, 0xffffcfcf, AND, SWAP, STORE, DUP, FETCH, LIT, 0xf87ffc3f, AND, LIT, 0x1c002c0, OR, SWAP, STORE, SYSCTL_RIS, DUP, FETCH, LIT, 0x40, AND, QBRANCH, 0xffffffe8, DROP, EXIT

    defword "(UPDATE)", LPARENUPDATERPAREN, 0x0
    .word DISK_WRITE_BLK, EXIT

    defword "(BLOCK)", LPARENBLOCKRPAREN, 0x0
    .word DISK_READ_BLK, EXIT

    defword "((BLOCK))", LPARENLPARENBLOCKRPARENRPAREN, 0x0
    .word PAD, EXIT

    defword "DISK-WRITE-BLK", DISK_WRITE_BLK, 0x0
    .word DISK_OPEN, DUP, ROT, CSLASHBLK, MUL, FSEEK, DROP, TUCK, SWAP, CSLASHBLK, FWRITE, DROP, FCLOSE, DROP, EXIT

    defword "DISK-READ-BLK", DISK_READ_BLK, 0x0
    .word DISK_OPEN, DUP, ROT, CSLASHBLK, MUL, FSEEK, DROP, TUCK, SWAP, CSLASHBLK, FREAD, DROP, FCLOSE, DROP, EXIT

    defword "DISK-OPEN", DISK_OPEN, 0x0
    .word DISK_NAME, DROP, LIT, 0x2, FOPEN, EXIT

    defword "DISK-NAME", DISK_NAME, 0x0
    .word LPARENSQUOTRPAREN, 0x73696409, 0x6d692e6b, 0x67, EXIT

    defword "SSIM-ENABLE", SSIM_ENABLE, 0x0
    .word GPIOA, GPIO_AFSEL, DUP, FETCH, LIT, 0x3c, OR, SWAP, STORE, LIT, 0x0, SSI_CRONE, STORE, LIT, 0x2, SSI_CPSR, STORE, LIT, 0xf907, SSI_CRZ, STORE, LIT, 0x2, SSI_CRONE, STORE, EXIT

    defword "DISP-TYPE", DISP_TYPE, 0x0
    .word LIT, 0x0, LPARENDORPAREN, DUP, I, PLUS, CFETCH, DISP_EMIT, LPARENLOOPRPAREN, QBRANCH, 0xffffffe4, DROP, EXIT

    defword "DISP-EMIT", DISP_EMIT, 0x0
    .word LIT, 0x40, ITWOCMSTORE, ITWOCM_SEND_START, ITWOC_DELAY, LIT, 0x20, MINUS, LIT, 0x5, MUL, DISP_FONT, PLUS, LIT, 0x5, LIT, 0x0, LPARENDORPAREN, DUP, I, PLUS, CFETCH, ITWOCMSTORE, ITWOCM_SEND_RUN, ITWOC_DELAY, LPARENLOOPRPAREN, QBRANCH, 0xffffffdc, DROP, LIT, 0x0, ITWOCMSTORE, ITWOCM_SEND_STOP, ITWOC_DELAY, EXIT

    defword "DISP-MOVE", DISP_MOVE, 0x0
    .word LIT, 0x80, ITWOCMSTORE, ITWOCM_SEND_START, ITWOC_DELAY, LIT, 0xb0, PLUS, ITWOCMSTORE, ITWOCM_SEND_RUN, ITWOC_DELAY, LIT, 0x80, ITWOCMSTORE, ITWOCM_SEND_RUN, ITWOC_DELAY, LIT, 0x4, PLUS, DUP, LIT, 0xf, AND, ITWOCMSTORE, ITWOCM_SEND_RUN, ITWOC_DELAY, LIT, 0x80, ITWOCMSTORE, ITWOCM_SEND_RUN, ITWOC_DELAY, TWOSLASH, TWOSLASH, TWOSLASH, TWOSLASH, LIT, 0xf, AND, LIT, 0x10, OR, ITWOCMSTORE, ITWOCM_SEND_STOP, ITWOC_DELAY, EXIT

    defword "DISP-CLEAR", DISP_CLEAR, 0x0
    .word LIT, 0x0, DISP_FILL, EXIT

    defword "DISP-SET", DISP_SET, 0x0
    .word LIT, 0xff, DISP_FILL, EXIT

    defword "DISP-FILL", DISP_FILL, 0x0
    .word DUP, DISP_SELECT_ROWZ, DISP_FILL_ROW, DISP_SELECT_ROWONE, DISP_FILL_ROW, EXIT

    defword "DISP-FILL-ROW", DISP_FILL_ROW, 0x0
    .word ITWOCM_SINGLE_SEQ_STARTSTORE, DROP, LIT, 0x96, LIT, 0x0, LPARENDORPAREN, DUP, ITWOCMSTORE, ITWOCM_SEND_RUN, ITWOC_DELAY, LPARENLOOPRPAREN, QBRANCH, 0xffffffe8, ITWOCMSTORE, ITWOCM_SEND_STOP, ITWOC_DELAY, EXIT

    defword "DISP-ENABLE", DISP_ENABLE, 0x0
    .word ITWOCM_ENABLE, LIT, 0x3d, TWOMUL, ITWOCMSA, CSTORE, LIT, 0x16, LPARENITWOC_DELAYRPAREN, STORE, DISP_INIT_SEQ, ITWOCM_SEQSTORE, LIT, 0x8, LPARENITWOC_DELAYRPAREN, STORE, EXIT

    defdata "DISP-SELECT-ROW1", DISP_SELECT_ROWONE
    .word 0x80b18007, 0x40128004

    defdata "DISP-SELECT-ROW0", DISP_SELECT_ROWZ
    .word 0x80b08007, 0x40128004

    defdata "DISP-INIT-SEQ", DISP_INIT_SEQ
    .word 0xae800213, 0x2048002, 0x80041280, 0x22b8081, 0x8002a180, 0xd3800440, 0x80040080, 0x20f80a8, 0x8002a480, 0xb08002a6, 0x4c88002, 0x7280d580, 0x80d88004, 0xd9800400, 0x80042280, 0x41280da, 0xf80db80, 0x80ad8004, 0xaf80028b

    defword "POT@", POTFETCH, 0x0
    .word LIT, 0x8, ADCPSSI, CSTORE, ADCSSFIFO3, FETCH, EXIT

    defword "POT-ENABLE", POT_ENABLE, 0x0
    .word LIT, 0x8, ADCACTSS, CSTORE, EXIT

    defword "I2CM-SEQ!", ITWOCM_SEQSTORE, 0x0
    .word DUP, CFETCH, SWAP, ONEPLUS, SWAP, ONEPLUS, LIT, 0x1, LPARENDORPAREN, ITWOCM_SINGLE_SEQSTORE, LPARENLOOPRPAREN, QBRANCH, 0xfffffff4, DROP, EXIT

    defword "I2CM-SINGLE-SEQ!", ITWOCM_SINGLE_SEQSTORE, 0x0
    .word LIT, 0x5, SWAP, LPARENITWOCM_SINGLE_SEQSTORERPAREN, EXIT

    defword "I2CM-SINGLE-SEQ-START!", ITWOCM_SINGLE_SEQ_STARTSTORE, 0x0
    .word LIT, 0x1, SWAP, LPARENITWOCM_SINGLE_SEQSTORERPAREN, EXIT

    defword "(I2CM-SINGLE-SEQ!)", LPARENITWOCM_SINGLE_SEQSTORERPAREN, 0x0
    .word DUP, CFETCH, LIT, 0x1, LPARENDORPAREN, DUP, I, PLUS, CFETCH, ITWOCMSTORE, I, LIT, 0x1, EQU, LIT, 0x2, AND, LIT, 0x1, OR, ITWOCMCS, CSTORE, ITWOC_DELAY, LPARENLOOPRPAREN, QBRANCH, 0xffffffb0, DUP, CFETCH, PLUS, DUP, CFETCH, ITWOCMSTORE, SWAP, ITWOCMCS, CSTORE, ITWOC_DELAY, ONEPLUS, EXIT

    defword "I2C-DELAY", ITWOC_DELAY, 0x0
    .word LPARENITWOC_DELAYRPAREN, FETCH, ONEMINUS, DUP, ZEQU, QBRANCH, 0xfffffff0, DROP, EXIT

    defword "I2CS@", ITWOCSFETCH, 0x0
    .word ITWOCSDR, CFETCH, EXIT

    defword "I2CM!", ITWOCMSTORE, 0x0
    .word ITWOCMDR, CSTORE, EXIT

    defword "I2CM-SEND-STOP", ITWOCM_SEND_STOP, 0x0
    .word LIT, 0x5, ITWOCMCS, CSTORE, EXIT

    defword "I2CM-SEND-RUN", ITWOCM_SEND_RUN, 0x0
    .word LIT, 0x1, ITWOCMCS, CSTORE, EXIT

    defword "I2CM-SEND-START", ITWOCM_SEND_START, 0x0
    .word LIT, 0x3, ITWOCMCS, CSTORE, EXIT

    defword "I2CM-SINGLE-SEND", ITWOCM_SINGLE_SEND, 0x0
    .word LIT, 0x7, ITWOCMCS, CSTORE, EXIT

    defword "I2C-LOOPBACK", ITWOC_LOOPBACK, 0x0
    .word ITWOCM_ENABLE, ITWOCS_ENABLE, LIT, 0x1, ITWOCMCR, SET_BITS, LIT, 0x3c, TWOMUL, ITWOCMSA, CSTORE, EXIT

    defword "I2CS-ENABLE", ITWOCS_ENABLE, 0x0
    .word LIT, 0x20, ITWOCMCR, SET_BITS, LIT, 0x1, ITWOCSCSR, SET_BITS, LIT, 0x3c, ITWOCSOAR, CSTORE, EXIT

    defword "I2CM-ENABLE", ITWOCM_ENABLE, 0x0
    .word LIT, 0xc, GPIOB, GPIO_AFSEL, SET_BITS, LIT, 0xc, GPIOB, GPIO_ODR, SET_BITS, LIT, 0xc, GPIOB, GPIO_PUR, SET_BITS, LIT, 0xc, GPIOB, GPIO_PDR, CLEAR_BITS, LIT, 0xc, GPIOB, GPIO_DEN, SET_BITS, LIT, 0x10, ITWOCMCR, SET_BITS, LIT, 0x8, LPARENITWOC_DELAYRPAREN, STORE, LIT, 0x2, ITWOCMTPR, CSTORE, EXIT

    defvar "(I2C-DELAY)", LPARENITWOC_DELAYRPAREN, 0x4


    defword "BUTTON0-ENABLE", BUTTONZ_ENABLE, 0x0
    .word LIT, 0x4, NVIC_SETENAZ, SET_BITS, LIT, BUTTONZ_IRQ, IVT, LIT, 0x11, CELLS, PLUS, STORE, LIT, 0x10, GPIOC, GPIO_IM, SET_BITS, EXIT

    defword "BUTTON0-IRQ", BUTTONZ_IRQ, 0x0
    .word LIT, 0x10, GPIOC, GPIO_ICR, CSTORE, LIT, 0xff, PAD, STORE, RETI

    defconst "SSI-ICR", SSI_ICR, 0x40008020


    defconst "SSI-MIS", SSI_MIS, 0x4000801c


    defconst "SSI-RIS", SSI_RIS, 0x40008018


    defconst "SSI-IM", SSI_IM, 0x40008014


    defconst "SSI-CPSR", SSI_CPSR, 0x40008010


    defconst "SSI-SR", SSI_SR, 0x4000800c


    defconst "SSI-DR", SSI_DR, 0x40008008


    defconst "SSI-CR1", SSI_CRONE, 0x40008004


    defconst "SSI-CR0", SSI_CRZ, 0x40008000


    defconst "SSI", SSI, 0x40008000


    defconst "ADCTMLB", ADCTMLB, 0x40038100


    defconst "ADCSSFSTAT3", ADCSSFSTAT3, 0x400380ac


    defconst "ADCSSFIFO3", ADCSSFIFO3, 0x400380a8


    defconst "ADCSSCTL3", ADCSSCTL3, 0x400380a4


    defconst "ADCSSMUX3", ADCSSMUX3, 0x400380a0


    defconst "ADCSSFSTAT2", ADCSSFSTATTWO, 0x4003808c


    defconst "ADCSSFIFO2", ADCSSFIFOTWO, 0x40038088


    defconst "ADCSSCTL2", ADCSSCTLTWO, 0x40038084


    defconst "ADCSSMUX2", ADCSSMUXTWO, 0x40038080


    defconst "ADCSSFSTAT1", ADCSSFSTATONE, 0x4003806c


    defconst "ADCSSFIFO1", ADCSSFIFOONE, 0x40038068


    defconst "ADCSSCTL1", ADCSSCTLONE, 0x40038064


    defconst "ADCSSMUX1", ADCSSMUXONE, 0x40038060


    defconst "ADCSSFSTAT0", ADCSSFSTATZ, 0x4003804c


    defconst "ADCSSFIFO0", ADCSSFIFOZ, 0x40038048


    defconst "ADCSSCTL0", ADCSSCTLZ, 0x40038044


    defconst "ADCSSMUX0", ADCSSMUXZ, 0x40038040


    defconst "ADCSAC", ADCSAC, 0x40038030


    defconst "ADCPSSI", ADCPSSI, 0x40038028


    defconst "ADCSSPRI", ADCSSPRI, 0x40038020


    defconst "ADCUSTAT", ADCUSTAT, 0x40038018


    defconst "ADCEMUX", ADCEMUX, 0x40038014


    defconst "ADCOSTAT", ADCOSTAT, 0x40038010


    defconst "ADCISC", ADCISC, 0x4003800c


    defconst "ADCIM", ADCIM, 0x40038008


    defconst "ADCRIS", ADCRIS, 0x40038004


    defconst "ADCACTSS", ADCACTSS, 0x40038000


    defconst "ADC", ADC, 0x40038000


    defword "GPTMTBR", GPTMTBR, 0x0, REGISTER_XT
    .word 0x4c

    defword "GPTMTAR", GPTMTAR, 0x0, REGISTER_XT
    .word 0x48

    defword "GPTMTBPMR", GPTMTBPMR, 0x0, REGISTER_XT
    .word 0x44

    defword "GPTMTAPMR", GPTMTAPMR, 0x0, REGISTER_XT
    .word 0x40

    defword "GPTMTBPR", GPTMTBPR, 0x0, REGISTER_XT
    .word 0x3c

    defword "GPTMTAPR", GPTMTAPR, 0x0, REGISTER_XT
    .word 0x38

    defword "GPTMTBMATCHR", GPTMTBMATCHR, 0x0, REGISTER_XT
    .word 0x34

    defword "GPTMTAMATCHR", GPTMTAMATCHR, 0x0, REGISTER_XT
    .word 0x30

    defword "GPTMTBILR", GPTMTBILR, 0x0, REGISTER_XT
    .word 0x2c

    defword "GPTMTAILR", GPTMTAILR, 0x0, REGISTER_XT
    .word 0x28

    defword "GPTMICR", GPTMICR, 0x0, REGISTER_XT
    .word 0x24

    defword "GPTMMIS", GPTMMIS, 0x0, REGISTER_XT
    .word 0x20

    defword "GPTMRIS", GPTMRIS, 0x0, REGISTER_XT
    .word 0x1c

    defword "GPTMMIR", GPTMMIR, 0x0, REGISTER_XT
    .word 0x18

    defword "GPTMCTL", GPTMCTL, 0x0, REGISTER_XT
    .word 0xc

    defword "GPTMTBMR", GPTMTBMR, 0x0, REGISTER_XT
    .word 0x8

    defword "GPTMTAMR", GPTMTAMR, 0x0, REGISTER_XT
    .word 0x4

    defword "GPTMCFG", GPTMCFG, 0x0, REGISTER_XT
    .word 0x0

    defconst "TIMER2", TIMERTWO, 0x40032000


    defconst "TIMER1", TIMERONE, 0x40031000


    defconst "TIMER0", TIMERZ, 0x40030000


    defconst "I2CSICR", ITWOCSICR, 0x40020818


    defconst "I2CSMIS", ITWOCSMIS, 0x40020814


    defconst "I2CSRIS", ITWOCSRIS, 0x40020810


    defconst "I2CSIMR", ITWOCSIMR, 0x4002080c


    defconst "I2CSDR", ITWOCSDR, 0x40020808


    defconst "I2CSCSR", ITWOCSCSR, 0x40020804


    defconst "I2CSOAR", ITWOCSOAR, 0x40020800


    defconst "I2CMCR", ITWOCMCR, 0x40020020


    defconst "I2CMICR", ITWOCMICR, 0x4002001c


    defconst "I2CMMIS", ITWOCMMIS, 0x40020018


    defconst "I2CMRIS", ITWOCMRIS, 0x40020014


    defconst "I2CMIMR", ITWOCMIMR, 0x40020010


    defconst "I2CMTPR", ITWOCMTPR, 0x4002000c


    defconst "I2CMDR", ITWOCMDR, 0x40020008


    defconst "I2CMCS", ITWOCMCS, 0x40020004


    defconst "I2CMSA", ITWOCMSA, 0x40020000


    defconst "I2C", ITWOC, 0x40020000


    defconst "UART-TXFF", UART_TXFF, 0x20


    defconst "UART-RXFE", UART_RXFE, 0x10


    defword "UART-DMACR", UART_DMACR, 0x0, REGISTER_XT
    .word 0x48

    defword "UART-ICR", UART_ICR, 0x0, REGISTER_XT
    .word 0x44

    defword "UART-MIS", UART_MIS, 0x0, REGISTER_XT
    .word 0x40

    defword "UART-RIS", UART_RIS, 0x0, REGISTER_XT
    .word 0x3c

    defword "UART-IMSC", UART_IMSC, 0x0, REGISTER_XT
    .word 0x38

    defword "UART-IFLS", UART_IFLS, 0x0, REGISTER_XT
    .word 0x34

    defword "UART-CR", UART_CR, 0x0, REGISTER_XT
    .word 0x30

    defword "UART-LCRH", UART_LCRH, 0x0, REGISTER_XT
    .word 0x2c

    defword "UART-FBRD", UART_FBRD, 0x0, REGISTER_XT
    .word 0x28

    defword "UART-IBRD", UART_IBRD, 0x0, REGISTER_XT
    .word 0x24

    defword "UART-LPR", UART_LPR, 0x0, REGISTER_XT
    .word 0x20

    defword "UART-FR", UART_FR, 0x0, REGISTER_XT
    .word 0x18

    defword "UART-RSR-ECR", UART_RSR_ECR, 0x0, REGISTER_XT
    .word 0x4

    defword "UART-DR", UART_DR, 0x0, REGISTER_XT
    .word 0x0

    defconst "UART0", UARTZ, 0x4000c000


    defword "GPIO-DEN", GPIO_DEN, 0x0, REGISTER_XT
    .word 0x51c

    defword "GPIO-PDR", GPIO_PDR, 0x0, REGISTER_XT
    .word 0x514

    defword "GPIO-PUR", GPIO_PUR, 0x0, REGISTER_XT
    .word 0x510

    defword "GPIO-ODR", GPIO_ODR, 0x0, REGISTER_XT
    .word 0x50c

    defword "GPIO-DR2R", GPIO_DRTWOR, 0x0, REGISTER_XT
    .word 0x500

    defword "GPIO-ICR", GPIO_ICR, 0x0, REGISTER_XT
    .word 0x41c

    defword "GPIO-MIS", GPIO_MIS, 0x0, REGISTER_XT
    .word 0x418

    defword "GPIO-RIS", GPIO_RIS, 0x0, REGISTER_XT
    .word 0x414

    defword "GPIO-IM", GPIO_IM, 0x0, REGISTER_XT
    .word 0x410

    defword "GPIO-IEV", GPIO_IEV, 0x0, REGISTER_XT
    .word 0x40c

    defword "GPIO-IBE", GPIO_IBE, 0x0, REGISTER_XT
    .word 0x408

    defword "GPIO-IS", GPIO_IS, 0x0, REGISTER_XT
    .word 0x404

    defword "GPIO-AFSEL", GPIO_AFSEL, 0x0, REGISTER_XT
    .word 0x420

    defword "GPIO-DIR", GPIO_DIR, 0x0, REGISTER_XT
    .word 0x400

    defconst "GPIOE", GPIOE, 0x40024000


    defconst "GPIOD", GPIOD, 0x40007000


    defconst "GPIOC", GPIOC, 0x40006000


    defconst "GPIOB", GPIOB, 0x40005000


    defconst "GPIOA", GPIOA, 0x40004000


    defconst "SYSCTL-RCGC2", SYSCTL_RCGCTWO, 0x400fe108


    defconst "SYSCTL-RCGC1", SYSCTL_RCGCONE, 0x400fe104


    defconst "SYSCTL-RCGC0", SYSCTL_RCGCZ, 0x400fe100


    defconst "SYSCTL-RCC", SYSCTL_RCC, 0x400fe060


    defconst "SYSCTL-RIS", SYSCTL_RIS, 0x400fe050


    defconst "SYSCTL-DID1", SYSCTL_DIDONE, 0x400fe004


    defconst "SYSCTL-DID0", SYSCTL_DIDZ, 0x400fe000


    defconst "SYSCTL", SYSCTL, 0x400fe000


    defconst "STCURRENT", STCURRENT, -0x1fff1fe8


    defconst "STRELOAD", STRELOAD, -0x1fff1fec


    defconst "STCTRL", STCTRL, -0x1fff1ff0


    defconst "NVIC-SETENA0", NVIC_SETENAZ, -0x1fff1f00


    defconst "NVIC", NVIC, -0x1fff2000


    defword "CLEAR-BITS", CLEAR_BITS, 0x0
    .word DUP, FETCH, ROT, INVERT, AND, SWAP, STORE, EXIT

    defword "SET-BITS", SET_BITS, 0x0
    .word DUP, FETCH, ROT, OR, SWAP, STORE, EXIT

    defword "REGISTER", REGISTER, 0x0
    .word CREATE, COMMA, LPARENDOESGTRPAREN
    .set REGISTER_XT, .
    .word 0x47884900, DODOES + 1, FETCH, PLUS, EXIT

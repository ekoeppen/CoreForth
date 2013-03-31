
    defword "REGISTER", REGISTER, 0x0
    .word CREATE, COMMA, LPARENDOESGTRPAREN
    .set REGISTER_XT, .
    .word 0x47884900, DODOES + 1, FETCH, PLUS, EXIT

    defword "SET-BITS", SET_BITS, 0x0
    .word DUP, FETCH, ROT, OR, SWAP, STORE, EXIT

    defword "CLEAR-BITS", CLEAR_BITS, 0x0
    .word DUP, FETCH, ROT, INVERT, AND, SWAP, STORE, EXIT

    defconst "HIGH", HIGH, 0x1


    defconst "LOW", LOW, 0x0


    defconst "ENABLE", ENABLE, 0x1


    defconst "DISABLE", DISABLE, 0x0


    defconst "ON", ON, 0x1


    defconst "OFF", OFF, 0x0


    defconst "NVIC", NVIC, 0xE000E000


    defconst "STCTRL", STCTRL, 0xE000E010


    defconst "STRELOAD", STRELOAD, 0xE000E014


    defconst "STCURRENT", STCURRENT, 0xE000E018


    defconst "PMC", PMC, 0x400E0600


    defword "PMC_SCER", PMC_SCER, 0x0, REGISTER_XT
    .word 0x0

    defword "PMC_SCDR", PMC_SCDR, 0x0, REGISTER_XT
    .word 0x4

    defword "PMC_SCSR", PMC_SCSR, 0x0, REGISTER_XT
    .word 0x8

    defword "PMC_PCER0", PMC_PCERZ, 0x0, REGISTER_XT
    .word 0x10

    defword "PMC_PCDR0", PMC_PCDRZ, 0x0, REGISTER_XT
    .word 0x14

    defword "PMC_PCSR0", PMC_PCSRZ, 0x0, REGISTER_XT
    .word 0x18

    defword "CKGR_UCKR", CKGR_UCKR, 0x0, REGISTER_XT
    .word 0x1C

    defword "CKGR_MOR", CKGR_MOR, 0x0, REGISTER_XT
    .word 0x20

    defword "CKGR_MCFR", CKGR_MCFR, 0x0, REGISTER_XT
    .word 0x24

    defword "CKGR_PLLAR", CKGR_PLLAR, 0x0, REGISTER_XT
    .word 0x28

    defword "PMC_MCKR", PMC_MCKR, 0x0, REGISTER_XT
    .word 0x30

    defword "PMC_USB", PMC_USB, 0x0, REGISTER_XT
    .word 0x38

    defword "PMC_PCK0", PMC_PCKZ, 0x0, REGISTER_XT
    .word 0x40

    defword "PMC_PCK1", PMC_PCKONE, 0x0, REGISTER_XT
    .word 0x44

    defword "PMC_PCK2", PMC_PCKTWO, 0x0, REGISTER_XT
    .word 0x48

    defword "PMC_IER", PMC_IER, 0x0, REGISTER_XT
    .word 0x60

    defword "PMC_IDR", PMC_IDR, 0x0, REGISTER_XT
    .word 0x64

    defword "PMC_SR", PMC_SR, 0x0, REGISTER_XT
    .word 0x68

    defword "PMC_IMR", PMC_IMR, 0x0, REGISTER_XT
    .word 0x6C

    defword "PMC_FSMR", PMC_FSMR, 0x0, REGISTER_XT
    .word 0x70

    defword "PMC_FSPR", PMC_FSPR, 0x0, REGISTER_XT
    .word 0x74

    defword "PMC_FOCR", PMC_FOCR, 0x0, REGISTER_XT
    .word 0x78

    defword "PMC_WPMR", PMC_WPMR, 0x0, REGISTER_XT
    .word 0xE4

    defword "PMC_WPSR", PMC_WPSR, 0x0, REGISTER_XT
    .word 0xE8

    defword "PMC_PCER1", PMC_PCERONE, 0x0, REGISTER_XT
    .word 0x100

    defword "PMC_PCDR1", PMC_PCDRONE, 0x0, REGISTER_XT
    .word 0x104

    defword "PMC_PCSR1", PMC_PCSRONE, 0x0, REGISTER_XT
    .word 0x108

    defword "PMC_PCR", PMC_PCR, 0x0, REGISTER_XT
    .word 0x10C

    defconst "UART", UART, 0x400E0800


    defword "UART_CR", UART_CR, 0x0, REGISTER_XT
    .word 0x0

    defword "UART_MR", UART_MR, 0x0, REGISTER_XT
    .word 0x4

    defword "UART_IER", UART_IER, 0x0, REGISTER_XT
    .word 0x8

    defword "UART_IDR", UART_IDR, 0x0, REGISTER_XT
    .word 0xC

    defword "UART_IMR", UART_IMR, 0x0, REGISTER_XT
    .word 0x10

    defword "UART_SR", UART_SR, 0x0, REGISTER_XT
    .word 0x14

    defword "UART_RHR", UART_RHR, 0x0, REGISTER_XT
    .word 0x18

    defword "UART_THR", UART_THR, 0x0, REGISTER_XT
    .word 0x1C

    defword "UART_BRGR", UART_BRGR, 0x0, REGISTER_XT
    .word 0x20

    defconst "PIOA", PIOA, 0x400E0E00


    defconst "PIOB", PIOB, 0x400E1000


    defconst "PIOC", PIOC, 0x400E1200


    defconst "PIOD", PIOD, 0x400E1400


    defconst "PIOE", PIOE, 0x400E1600


    defword "PIO_PER", PIO_PER, 0x0, REGISTER_XT
    .word 0x0

    defword "PIO_PDR", PIO_PDR, 0x0, REGISTER_XT
    .word 0x4

    defword "PIO_PSR", PIO_PSR, 0x0, REGISTER_XT
    .word 0x8

    defword "PIO_OER", PIO_OER, 0x0, REGISTER_XT
    .word 0x10

    defword "PIO_ODR", PIO_ODR, 0x0, REGISTER_XT
    .word 0x14

    defword "PIO_OSR", PIO_OSR, 0x0, REGISTER_XT
    .word 0x18

    defword "PIO_IFER", PIO_IFER, 0x0, REGISTER_XT
    .word 0x20

    defword "PIO_IFDR", PIO_IFDR, 0x0, REGISTER_XT
    .word 0x24

    defword "PIO_IFSR", PIO_IFSR, 0x0, REGISTER_XT
    .word 0x28

    defword "PIO_SODR", PIO_SODR, 0x0, REGISTER_XT
    .word 0x30

    defword "PIO_CODR", PIO_CODR, 0x0, REGISTER_XT
    .word 0x34

    defword "PIO_ODSR", PIO_ODSR, 0x0, REGISTER_XT
    .word 0x38

    defword "PIO_PDSR", PIO_PDSR, 0x0, REGISTER_XT
    .word 0x3C

    defword "PIO_IER", PIO_IER, 0x0, REGISTER_XT
    .word 0x40

    defword "PIO_IDR", PIO_IDR, 0x0, REGISTER_XT
    .word 0x44

    defword "PIO_IMR", PIO_IMR, 0x0, REGISTER_XT
    .word 0x48

    defword "PIO_ISR", PIO_ISR, 0x0, REGISTER_XT
    .word 0x4C

    defword "PIO_MDER", PIO_MDER, 0x0, REGISTER_XT
    .word 0x50

    defword "PIO_MDDR", PIO_MDDR, 0x0, REGISTER_XT
    .word 0x54

    defword "PIO_MDSR", PIO_MDSR, 0x0, REGISTER_XT
    .word 0x58

    defword "PIO_PUDR", PIO_PUDR, 0x0, REGISTER_XT
    .word 0x60

    defword "PIO_PUER", PIO_PUER, 0x0, REGISTER_XT
    .word 0x64

    defword "PIO_PUSR", PIO_PUSR, 0x0, REGISTER_XT
    .word 0x68

    defword "PIO_ABSR", PIO_ABSR, 0x0, REGISTER_XT
    .word 0x70

    defword "PIO_SCIFSR", PIO_SCIFSR, 0x0, REGISTER_XT
    .word 0x80

    defword "PIO_DIFSR", PIO_DIFSR, 0x0, REGISTER_XT
    .word 0x84

    defword "PIO_IFDGSR", PIO_IFDGSR, 0x0, REGISTER_XT
    .word 0x88

    defword "PIO_SCDR", PIO_SCDR, 0x0, REGISTER_XT
    .word 0x8C

    defword "PIO_OWER", PIO_OWER, 0x0, REGISTER_XT
    .word 0xA0

    defword "PIO_OWDR", PIO_OWDR, 0x0, REGISTER_XT
    .word 0xA4

    defword "PIO_OWSR", PIO_OWSR, 0x0, REGISTER_XT
    .word 0xA8

    defword "PIO_AIMER", PIO_AIMER, 0x0, REGISTER_XT
    .word 0xB0

    defword "PIO_AIMDR", PIO_AIMDR, 0x0, REGISTER_XT
    .word 0xB4

    defword "PIO_AIMMR", PIO_AIMMR, 0x0, REGISTER_XT
    .word 0xB8

    defword "PIO_ESR", PIO_ESR, 0x0, REGISTER_XT
    .word 0xC0

    defword "PIO_LSR", PIO_LSR, 0x0, REGISTER_XT
    .word 0xC4

    defword "PIO_ELSR", PIO_ELSR, 0x0, REGISTER_XT
    .word 0xC8

    defword "PIO_FELLSR", PIO_FELLSR, 0x0, REGISTER_XT
    .word 0xD0

    defword "PIO_REHLSR", PIO_REHLSR, 0x0, REGISTER_XT
    .word 0xD4

    defword "PIO_FRLHSR", PIO_FRLHSR, 0x0, REGISTER_XT
    .word 0xD8

    defword "PIO_LOCKSR", PIO_LOCKSR, 0x0, REGISTER_XT
    .word 0xE0

    defword "PIO_WPMR", PIO_WPMR, 0x0, REGISTER_XT
    .word 0xE4

    defword "PIO_WPSR", PIO_WPSR, 0x0, REGISTER_XT
    .word 0xE8

    defconst "EEFC0", EEFCZ, 0x400E0A00


    defconst "EEFC1", EEFCONE, 0x400E0C00


    defword "EEFC_FMR", EEFC_FMR, 0x0, REGISTER_XT
    .word 0x0

    defword "EEFC_FCR", EEFC_FCR, 0x0, REGISTER_XT
    .word 0x4

    defword "EEFC_FSR", EEFC_FSR, 0x0, REGISTER_XT
    .word 0x8

    defword "EEFC_FRR", EEFC_FRR, 0x0, REGISTER_XT
    .word 0xC

    defconst "WDT", WDT, 0x400E1A50


    defword "WDT_CR", WDT_CR, 0x0, REGISTER_XT
    .word 0x0

    defword "WDT_MR", WDT_MR, 0x0, REGISTER_XT
    .word 0x4

    defword "WDT_SR", WDT_SR, 0x0, REGISTER_XT
    .word 0x8

    defword "LED0-ENABLE", LEDZ_ENABLE, 0x0
    .word LIT, 0x8000000, PIOB, TWODUP, PIO_PER, SET_BITS, TWODUP, PIO_OER, SET_BITS, TWODUP, PIO_PUER, SET_BITS, TWODUP, PIO_MDDR, SET_BITS, TWODUP, PIO_OWER, SET_BITS, PIO_CODR, SET_BITS, EXIT

    defword "LED0!", LEDZSTORE, 0x0
    .word LIT, 0x5, ROR, PIOB, PIO_ODSR, STORE, EXIT

    defconst "C/PAGE", CSLASHPAGE, 0x100


    defconst "FIRST-PAGE", FIRST_PAGE, 0x80


    defconst "FLASH-START", FLASH_START, 0x80000


    defword "PAGE>FLASH", PAGEGTFLASH, 0x0
    .word CSLASHPAGE, MUL, FLASH_START, PLUS, EXIT

    defvar "((BLOCK))", LPARENLPARENBLOCKRPARENRPAREN, 0x400


    defword "(BLOCK)", LPARENBLOCKRPAREN, 0x0
    .word CSLASHBLK, MUL, FLASH_START, PLUS, CSLASHPAGE, FIRST_PAGE, MUL, PLUS, SWAP, CSLASHBLK, CMOVE, EXIT

    defword "(UPDATE-PAGE)", LPARENUPDATE_PAGERPAREN, 0x0
    .word TWODUP, PAGEGTFLASH, CSLASHPAGE, ALIGNED_MOVEGT, DUP, FLASH_PAGE, ONEPLUS, SWAP, CSLASHPAGE, PLUS, SWAP, EXIT

    defword "(UPDATE)", LPARENUPDATERPAREN, 0x0
    .word TWOMUL, TWOMUL, FIRST_PAGE, PLUS, LPARENUPDATE_PAGERPAREN, LPARENUPDATE_PAGERPAREN, LPARENUPDATE_PAGERPAREN, LPARENUPDATE_PAGERPAREN, TWODROP, EXIT

    defvar "SYSTICKS/TICK", SYSTICKSSLASHTICK, 0x4


    defvar "TICKS", TICKS, 0x4


    defword "SYSTICK-IRQ", SYSTICK_IRQ, 0x0
    .word LIT, 0x1, TICKS, PLUSSTORE, RETI

    defword "SYSTICK-ENABLE", SYSTICK_ENABLE, 0x0
    .word LIT, SYSTICK_IRQ, IVT, LIT, 0xE, CELLS, PLUS, STORE, LIT, 0x0, TICKS, STORE, SYSTICKSSLASHTICK, FETCH, STRELOAD, STORE, LIT, 0x7, STCTRL, STORE, EXIT

    defword "ANSI-ESC-START", ANSI_ESC_START, 0x0
    .word LIT, 0x1B, EMIT, LIT, 0x5B, EMIT, EXIT

    defword "AT-XY", AT_XY, 0x0
    .word ANSI_ESC_START, ONEPLUS, DOTD, LIT, 0x3B, EMIT, ONEPLUS, DOTD, LIT, 0x48, EMIT, EXIT

    defword "!CURSOR", STORECURSOR, 0x0
    .word LIT, 0x1B, EMIT, LIT, 0x37, EMIT, EXIT

    defword "@CURSOR", FETCHCURSOR, 0x0
    .word LIT, 0x1B, EMIT, LIT, 0x38, EMIT, EXIT

    defword "CLS", CLS, 0x0
    .word ANSI_ESC_START, LIT, 0x32, EMIT, LIT, 0x4A, EMIT, LIT, 0x0, LIT, 0x0, AT_XY, EXIT

    defword "CURSOR-UP", CURSOR_UP, 0x0
    .word ANSI_ESC_START, LIT, 0x41, EMIT, EXIT

    defword "CURSOR-DOWN", CURSOR_DOWN, 0x0
    .word ANSI_ESC_START, LIT, 0x42, EMIT, EXIT

    defword "CURSOR-RIGHT", CURSOR_RIGHT, 0x0
    .word ANSI_ESC_START, LIT, 0x43, EMIT, EXIT

    defword "CURSOR-LEFT", CURSOR_LEFT, 0x0
    .word ANSI_ESC_START, LIT, 0x44, EMIT, EXIT

    defword "CLR-EOL", CLR_EOL, 0x0
    .word ANSI_ESC_START, LIT, 0x30, EMIT, LIT, 0x4B, EMIT, EXIT

    defword "CLR-SOL", CLR_SOL, 0x0
    .word ANSI_ESC_START, LIT, 0x31, EMIT, LIT, 0x4B, EMIT, EXIT

    defword "CLR-LINE", CLR_LINE, 0x0
    .word ANSI_ESC_START, LIT, 0x32, EMIT, LIT, 0x4B, EMIT, EXIT

    defconst "KEY-UP", KEY_UP, 0x5B410000


    defconst "KEY-DOWN", KEY_DOWN, 0x5B420000


    defconst "KEY-LEFT", KEY_LEFT, 0x5B440000


    defconst "KEY-RIGHT", KEY_RIGHT, 0x5B430000


    defconst "KEY-HOME", KEY_HOME, 0x5B317E00


    defconst "KEY-END", KEY_END, 0x5B347E00


    defconst "KEY-INSERT", KEY_INSERT, 0x5B327E00


    defconst "KEY-DELETE", KEY_DELETE, 0x5B337E00


    defconst "KEY-PGUP", KEY_PGUP, 0x5B357E00


    defconst "KEY-PGDOWN", KEY_PGDOWN, 0x5B367E00


    defconst "KEY-BACKSPACE", KEY_BACKSPACE, 0x7F


    defword "ROTKEY", ROTKEY, 0x0
    .word OVER, ROTATE, ROT, OR, SWAP, LIT, 0x8, MINUS, EXIT

    defword "READWKEY", READWKEY, 0x0
    .word WAIT_KEY, READ_KEY, DUP, LIT, 0x1B, EQU, QBRANCH, 0xC0, DROP, LIT, 0x0, LIT, 0x18, WAIT_KEY, READ_KEY, DUP, LIT, 0x5B, EQU, QBRANCH, 0x60, ROTKEY, WAIT_KEY, READ_KEY, DUP, GTR, ROTKEY, RGT, DUP, LIT, 0x41, LIT, 0x5B, WITHIN, SWAP, LIT, 0x7E, EQU, OR, QBRANCH, 0xFFFFFFB8, DROP, BRANCH, 0x30, DUP, LIT, 0x4F, EQU, QBRANCH, 0x18, ROTKEY, WAIT_KEY, READ_KEY, ROTKEY, DROP, EXIT

    defword "TIB-TAIL", TIB_TAIL, 0x0
    .word GTTIB, FETCH, TIBNUM, FETCH, OVER, MINUS, SWAP, TIB, PLUS, SWAP, EXIT

    defword ".TIB-TAIL", DOTTIB_TAIL, 0x0
    .word CLR_EOL, STORECURSOR, TIB_TAIL, TYPE, FETCHCURSOR, EXIT

    defword "CURSOR>", CURSORGT, 0x0
    .word LIT, 0x1, GTTIB, PLUSSTORE, CURSOR_RIGHT, EXIT

    defword "CURSOR<", CURSORLT, 0x0
    .word LIT, 0x1, GTTIB, MINUSSTORE, CURSOR_LEFT, EXIT

    defword "INSERT", INSERT, 0x0
    .word TIB_TAIL, OVER, ONEPLUS, SWAP, CMOVEGT, LIT, 0x1, TIBNUM, PLUSSTORE, TIB, GTTIB, FETCH, PLUS, CSTORE, EXIT

    defword "DELETE", DELETE, 0x0
    .word LIT, 0x1, TIBNUM, MINUSSTORE, TIB_TAIL, OVER, ONEPLUS, MINUSROT, CMOVE, EXIT

    defword "-START?", MINUSSTARTQ, 0x0
    .word GTTIB, FETCH, ZGT, EXIT

    defword "-END?", MINUSENDQ, 0x0
    .word GTTIB, FETCH, TIBNUM, FETCH, LT, EXIT

    defword "-FULL?", MINUSFULLQ, 0x0
    .word TIBNUM, FETCH, NUMTIB, LT, EXIT

    defword "READLINE-CRSR", READLINE_CRSR, 0x0
    .word LIT, 0x0, TIBNUM, STORE, LIT, 0x0, GTTIB, STORE, KEY, DUP, LIT, 0x20, LIT, 0x7F, WITHIN, MINUSFULLQ, AND, QBRANCH, 0x18, INSERT, DOTTIB_TAIL, CURSORGT, BRANCH, 0x120, DUP, LIT, 0x7F, EQU, MINUSSTARTQ, AND, QBRANCH, 0x1C, DROP, CURSORLT, DELETE, DOTTIB_TAIL, BRANCH, 0xE8, DUP, LIT, 0x8, EQU, OVER, KEY_DELETE, EQU, OR, MINUSENDQ, AND, QBRANCH, 0x18, DROP, DELETE, DOTTIB_TAIL, BRANCH, 0xA4, DUP, LIT, 0xD, EQU, OVER, LIT, 0xA, EQU, OR, QBRANCH, 0x1C, DROP, TIBNUM, FETCH, EXIT, BRANCH, 0x60, DUP, KEY_RIGHT, EQU, MINUSENDQ, AND, QBRANCH, 0x14, DROP, CURSORGT, BRANCH, 0x34, DUP, KEY_LEFT, EQU, MINUSSTARTQ, AND, QBRANCH, 0x14, DROP, CURSORLT, BRANCH, 0x8, DROP, BRANCH, 0xFFFFFEA0, EXIT

    defword "ANSI-IO", ANSI_IO, 0x0
    .word LIT, READWKEY, TICKKEY, STORE, LIT, READLINE_CRSR, TICKACCEPT, STORE, EXIT

    defconst "C/L", CSLASHL, 0x40


    defvar "SCR", SCR, 0x4


    defvar "BLOCK#", BLOCKNUM, 0x4


    defvar "(BLOCK-DIRTY)", LPARENBLOCK_DIRTYRPAREN, 0x4


    defword "BLOCK-DIRTY?", BLOCK_DIRTYQ, 0x0
    .word LPARENBLOCK_DIRTYRPAREN, FETCH, EXIT

    defword "BLOCK-DIRTY", BLOCK_DIRTY, 0x0
    .word LIT, 0xFFFFFFFF, LPARENBLOCK_DIRTYRPAREN, STORE, EXIT

    defword "BLOCK-CLEAN", BLOCK_CLEAN, 0x0
    .word LIT, 0x0, LPARENBLOCK_DIRTYRPAREN, STORE, EXIT

    defword "UPDATE", UPDATE, 0x0
    .word BLOCK_DIRTYQ, QBRANCH, 0x18, LPARENLPARENBLOCKRPARENRPAREN, BLOCKNUM, FETCH, LPARENUPDATERPAREN, BLOCK_CLEAN, EXIT

    defword "BLOCK", BLOCK, 0x0
    .word LPARENLPARENBLOCKRPARENRPAREN, SWAP, DUP, BLOCKNUM, FETCH, LTGT, QBRANCH, 0x20, UPDATE, TWODUP, LPARENBLOCKRPAREN, BLOCKNUM, STORE, BRANCH, 0x8, DROP, EXIT

    defword "(LINE-START)", LPARENLINE_STARTRPAREN, 0x0
    .word CSLASHL, ONEMINUS, INVERT, AND, EXIT

    defword "(LINE-END)", LPARENLINE_ENDRPAREN, 0x0
    .word CSLASHL, ONEMINUS, OR, EXIT

    defword ">BLK", GTBLK, 0x0
    .word LPARENLPARENBLOCKRPARENRPAREN, PLUS, EXIT

    defword "CLR-LAST-CHR", CLR_LAST_CHR, 0x0
    .word LPARENLINE_ENDRPAREN, GTBLK, BL, SWAP, CSTORE, BLOCK_DIRTY, EXIT

    defword ">TAIL-LENGTH", GTTAIL_LENGTH, 0x0
    .word CSLASHL, TUCK, ONEMINUS, AND, MINUS, EXIT

    defword ".TAIL", DOTTAIL, 0x0
    .word STORECURSOR, DUP, GTBLK, SWAP, GTTAIL_LENGTH, TYPE, FETCHCURSOR, EXIT

    defword "TAIL>", TAILGT, 0x0
    .word DUP, GTBLK, DUP, ONEPLUS, ROT, GTTAIL_LENGTH, ONEMINUS, CMOVEGT, BLOCK_DIRTY, EXIT

    defword "TAIL<", TAILLT, 0x0
    .word DUP, DUP, GTBLK, DUP, ONEPLUS, SWAP, ROT, GTTAIL_LENGTH, CMOVE, CLR_LAST_CHR, EXIT

    defword "LL", LL, 0x0
    .word LIT, 0x7C, TUCK, EMIT, SPACE, CSLASHL, MUL, SCR, FETCH, BLOCK, PLUS, CSLASHL, TYPE, SPACE, EMIT, EXIT

    defword "LIST", LIST, 0x0
    .word DUP, SCR, STORE, DOTD, LPARENSQUOTRPAREN, 0x63732004, 0x72, TYPE, CR, LIT, 0x0, DUP, LL, CR, ONEPLUS, DUP, LIT, 0x10, EQU, QBRANCH, 0xFFFFFFDC, DROP, EXIT

    defword "RE", RE, 0x0
    .word SCR, FETCH, EXIT

    defword "L", L, 0x0
    .word LIT, 0x0, DUP, AT_XY, RE, LIST, EXIT

    defword "B", B, 0x0
    .word LIT, 0xFFFFFFFF, SCR, PLUSSTORE, EXIT

    defword "N", N, 0x0
    .word LIT, 0x1, SCR, PLUSSTORE, EXIT

    defword "!XY", STOREXY, 0x0
    .word CSLASHBLK, ONEMINUS, AND, DUP, CSLASHL, SLASHMOD, ONEPLUS, SWAP, LIT, 0x2, PLUS, SWAP, AT_XY, EXIT

    defword "!CH", STORECH, 0x0
    .word DUP, TAILGT, TWODUP, GTBLK, CSTORE, DUP, DOTTAIL, BLOCK_DIRTY, EXIT

    defword "LINE-START", LINE_START, 0x0
    .word LPARENLINE_STARTRPAREN, GTBLK, EXIT

    defword "LINE-END", LINE_END, 0x0
    .word LINE_START, CSLASHL, PLUS, ONEMINUS, EXIT

    defword "BLANK-LINE", BLANK_LINE, 0x0
    .word LINE_START, CSLASHL, ONEMINUS, BLANK, BLOCK_DIRTY, EXIT

    defword "INS-LINE", INS_LINE, 0x0
    .word DUP, LINE_START, DUP, CSLASHL, PLUS, DUP, CSLASHBLK, GTBLK, SWAP, MINUS, CMOVEGT, BLANK_LINE, EXIT

    defword "REMOVE-LINE", REMOVE_LINE, 0x0
    .word LINE_START, DUP, CSLASHL, PLUS, SWAP, OVER, CSLASHBLK, GTBLK, SWAP, MINUS, CMOVE, BLOCK_DIRTY, EXIT

    defword "CLR-LAST-LINE", CLR_LAST_LINE, 0x0
    .word CSLASHL, CSLASHBLK, GTBLK, OVER, MINUS, SWAP, BLANK, BLOCK_DIRTY, EXIT

    defword "?CH", QCH, 0x0
    .word OVER, BL, MINUS, LIT, 0x5F, ULT, QBRANCH, 0x10, STORECH, ONEPLUS, EXIT, OVER, KEY_LEFT, EQU, QBRANCH, 0x8, ONEMINUS, OVER, KEY_RIGHT, EQU, QBRANCH, 0x8, ONEPLUS, OVER, KEY_UP, EQU, QBRANCH, 0xC, CSLASHL, MINUS, OVER, KEY_DOWN, EQU, QBRANCH, 0xC, CSLASHL, PLUS, OVER, KEY_HOME, EQU, QBRANCH, 0x14, CSLASHL, ONEMINUS, INVERT, AND, OVER, KEY_DELETE, EQU, QBRANCH, 0x14, DUP, TAILLT, DUP, DOTTAIL, OVER, KEY_BACKSPACE, EQU, QBRANCH, 0x1C, ONEMINUS, DUP, TAILLT, STOREXY, DUP, DOTTAIL, OVER, KEY_PGUP, EQU, QBRANCH, 0x1C, UPDATE, B, L, DROP, LIT, 0x0, OVER, KEY_PGDOWN, EQU, QBRANCH, 0x1C, UPDATE, N, L, DROP, LIT, 0x0, OVER, LIT, 0x4, EQU, QBRANCH, 0x18, DUP, REMOVE_LINE, CLR_LAST_LINE, L, LPARENLINE_STARTRPAREN, OVER, LIT, 0x9, EQU, QBRANCH, 0x10, DUP, INS_LINE, L, OVER, LIT, 0xB, EQU, QBRANCH, 0x14, DUP, BLANK_LINE, L, LPARENLINE_STARTRPAREN, OVER, LIT, 0xD, EQU, QBRANCH, 0x18, CSLASHL, TWODUP, MOD, MINUS, PLUS, EXIT

    defword "EDIT", EDIT, 0x0
    .word CLS, LIT, 0x0, DUP, AT_XY, LIST, LIT, 0x0, LIT, 0x3F, LIT, 0x0, AT_XY, BLOCK_DIRTYQ, LIT, 0x2A, AND, EMIT, STOREXY, KEY, SWAP, QCH, SWAP, LIT, 0x18, EQU, QBRANCH, 0xFFFFFFB4, UPDATE, DROP, L, EXIT

    defword "INIT-BLOCKS", INIT_BLOCKS, 0x0
    .word LIT, 0xFFFFFFFF, BLOCKNUM, STORE, BLOCK_CLEAN, EXIT

    defword "LOAD", LOAD, 0x0
    .word LIT, 0x0, STATE, STORE, BLOCK, DUP, CSLASHBLK, PLUS, TWODUP, LT, QBRANCH, 0x48, SWAP, CSLASHL, TWODUP, SOURCENUM, STORE, LPARENSOURCERPAREN, STORE, LIT, 0x0, GTSOURCE, STORE, LPARENINTERPRETRPAREN, TWODROP, PLUS, SWAP, BRANCH, 0xFFFFFFB0, TWODROP, EXIT

    defword "THRU", THRU, 0x0
    .word SWAP, LPARENDORPAREN, I, LOAD, LPARENLOOPRPAREN, QBRANCH, 0xFFFFFFF0, EXIT

    defword "PT:", PTCOLON, 0x0
    .word CREATE, HERE, CELL, PLUS, COMMA, RBRAC, LPARENDOESGTRPAREN
    .set PTCOLON_XT, .
    .word 0x47884900, DODOES + 1, FETCH, GTR, EXIT

    defword ";PT", SEMIPT, 0x1
    .word LATEST, FETCH, LINKGT, GTBODY, DUP, CELL, PLUS, LITERAL, LITERAL, LIT, STORE, COMMAXT, LIT, EXIT, COMMAXT, LBRAC, REVEAL, EXIT

    defword "?YIELD", QYIELD, 0x1
    .word LIT, QBRANCH, COMMAXT, HERE, DUP, COMMA, SWAP, LITERAL, LATEST, FETCH, LINKGT, GTBODY, LITERAL, LIT, STORE, COMMAXT, LIT, EXIT, COMMAXT, HERE, OVER, MINUS, SWAP, STORE, EXIT

    defword "FOLLOWER", FOLLOWER, 0x0, USER_XT
    .word 0x0

    defword "STATUS", STATUS, 0x0, USER_XT
    .word 0xFFFFFFFC

    defword "TOS", TOS, 0x0, USER_XT
    .word 0xFFFFFFF8

    defword "WAKE-AT", WAKE_AT, 0x0, USER_XT
    .word 0xFFFFFFF4

    defconst "USER#", USERNUM, 0xC


    defword "TIMEOUT!", TIMEOUTSTORE, 0x0
    .word TICKS, FETCH, PLUS, WAKE_AT, STORE, EXIT

    defword "TIMEOUT@", TIMEOUTFETCH, 0x0
    .word TICKS, FETCH, WAKE_AT, FETCH, MINUS, EXIT

    defword "TIMEOUT?", TIMEOUTQ, 0x0
    .word TIMEOUTFETCH, ZGT, DUP, QBRANCH, 0x14, LIT, 0x0, WAKE_AT, STORE, EXIT

    defvar "LAST-AWAKE", LAST_AWAKE, 0x4


    defword "PAUSE", PAUSE, 0x0
    .word RPFETCH, SPFETCH, TOS, STORE, FOLLOWER, FETCH, GTR, EXIT

    defword "'U", TICKU, 0x0
    .word FOLLOWER, MINUS, PLUS, EXIT

    defword "(WAKE)", LPARENWAKERPAREN, 0x0
    .word RGT, UP, TWODUP, STORE, OVER, LAST_AWAKE, STORE, TOS, FETCH, SPSTORE, RPSTORE, EXIT

    defconst "WAKE", WAKE, LPARENWAKERPAREN


    defword "AWAKE", AWAKE, 0x0
    .word DUP, LAST_AWAKE, STORE, WAKE, SWAP, STATUS, TICKU, STORE, EXIT

    defword "(PASS)", LPARENPASSRPAREN, 0x0
    .word RGT, DUP, WAKE_AT, TICKU, FETCH, QDUP, QBRANCH, 0x20, TICKS, FETCH, LT, QBRANCH, 0xC, DUP, AWAKE, DUP, LAST_AWAKE, FETCH, EQU, QBRANCH, 0x8, WFI, FETCH, GTR, EXIT

    defconst "PASS", PASS, LPARENPASSRPAREN


    defword "STOP", STOP, 0x0
    .word PASS, STATUS, STORE, PAUSE, EXIT

    defword "SLEEP", SLEEP, 0x0
    .word PASS, SWAP, STATUS, TICKU, STORE, EXIT

    defword "ACTIVATE", ACTIVATE, 0x0
    .word DUP, SZ, TICKU, FETCH, CELL, MINUS, OVER, RZ, TICKU, FETCH, RGT, OVER, STORE, OVER, STORE, OVER, TOS, TICKU, STORE, AWAKE, EXIT

    defword "ALSOTASK", ALSOTASK, 0x0
    .word DUP, SLEEP, FOLLOWER, FETCH, OVER, FOLLOWER, TICKU, STORE, STATUS, TICKU, FOLLOWER, STORE, EXIT

    defword "ONLYTASK", ONLYTASK, 0x0
    .word DUP, SLEEP, DUP, STATUS, TICKU, SWAP, FOLLOWER, TICKU, STORE, EXIT

    defword "NEWTASK", NEWTASK, 0x0
    .word CREATE, SWAP, USERNUM, PLUS, CELL, PLUS, HERE, PLUS, DUP, COMMA, LIT, 0x0, COMMA, OVER, PLUS, COMMA, HERE, PASS, COMMA, COMMA, HERE, LIT, 0x2, CELLS, PLUS, COMMA, DUP, HERE, PLUS, COMMA, ALLOT, LPARENDOESGTRPAREN
    .set NEWTASK_XT, .
    .word 0x47884900, DODOES + 1, FETCH, EXIT

    defword ".TASK", DOTTASK, 0x0
    .word CR, DUP, LPARENSQUOTRPAREN, 0x3A44490A, 0x20202020, 0x202020, TYPE, DOT, CR, DUP, ANYGTLINK, LINKGTNAME, LPARENSQUOTRPAREN, 0x6D614E0A, 0x20203A65, 0x202020, TYPE, COUNT, TYPE, CR, DUP, SZ, TICKU, FETCH, OVER, RZ, TICKU, FETCH, LPARENSQUOTRPAREN, 0x6174530A, 0x3A736B63, 0x202020, TYPE, DOT, DOT, CR, DUP, STATUS, TICKU, FETCH, LPARENSQUOTRPAREN, 0x6174530A, 0x3A737574, 0x202020, TYPE, WAKE, EQU, QBRANCH, 0x1C, LPARENSQUOTRPAREN, 0x4B415704, 0x45, TYPE, BRANCH, 0x14, LPARENSQUOTRPAREN, 0x53415004, 0x53, TYPE, CR, DUP, FOLLOWER, TICKU, FETCH, LPARENSQUOTRPAREN, 0x6C6F460A, 0x65776F6C, 0x203A72, TYPE, CELL, PLUS, DOT, CR, DUP, WAKE_AT, TICKU, FETCH, LPARENSQUOTRPAREN, 0x6B61570A, 0x74612065, 0x20203A, TYPE, DOT, CR, TOS, TICKU, FETCH, LPARENSQUOTRPAREN, 0x534F540A, 0x2020203A, 0x202020, TYPE, DOT, CR, EXIT

    defword ".TASKS", DOTTASKS, 0x0
    .word UPFETCH, DUP, DOTTASK, FOLLOWER, TICKU, FETCH, CELL, PLUS, DUP, UPFETCH, EQU, QBRANCH, 0xFFFFFFD4, DROP, EXIT

    defword "STOP-FOR-KEY", STOP_FOR_KEY, 0x0
    .word KEYQ, ZEQU, QBRANCH, 0x10, STOP, BRANCH, 0xFFFFFFE8, EXIT

    defword "MULTITASKING-KEY", MULTITASKING_KEY, 0x0
    .word UPFETCH, UARTZ_TASK, STORE, LIT, STOP_FOR_KEY, TICKWAIT_KEY, STORE, EXIT

    defword "INTERPRET", INTERPRET, 0x0
    .word LIT, 0x0, STATE, STORE, TIB, LPARENSOURCERPAREN, STORE, LIT, 0x0, GTSOURCE, STORE, ACCEPT, SOURCENUM, STORE, SPACE, LPARENINTERPRETRPAREN, QBRANCH, 0x20, DROP, LPARENSQUOTRPAREN, 0x6B6F2004, 0x20, TYPE, BRANCH, 0x18, COUNT, TYPE, LIT, 0x3F, EMIT, CR, EXIT

    defword "QUIT", QUIT, 0x0
    .word INTERPRET, BRANCH, 0xFFFFFFF8, EXIT

    defword "ABORT", ABORT, 0x0
    .word LPARENSQUOTRPAREN, 0x726F4310, 0x726F4665, 0x72206874, 0x79646165, 0x2E, TYPE, CR, QUIT, EXIT

    defword "?ABORT", QABORT, 0x0
    .word ROT, QBRANCH, 0xC, TYPE, ABORT, TWODROP, EXIT

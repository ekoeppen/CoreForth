@ -- vim:syntax=asm:foldmethod=marker:foldmarker=@\ --\ ,@\ ---:

@ ---------------------------------------------------------------------
@ -- Definitions ------------------------------------------------------

    .set UART,        0x400e0800
    .set UART_CR,           0x00
    .set UART_MR,           0x04
    .set UART_IER,          0x08
    .set UART_IDR,          0x0c
    .set UART_IMR,          0x10
    .set UART_SR,           0x14
    .set UART_RHR,          0x18
    .set UART_THR,          0x1c
    .set UART_BRGR,         0x20

    .set _NVIC,       0xe000e000
    .set NVIC_SETENA_BASE, 0x100
    .set NVIC_ACTIVE_BASE, 0x300

    .set STCTRL,      0xe000e010
    .set STRELOAD,    0xe000e014
    .set STCURRENT,   0xe000e018

    .set PMC,         0x400E0600
    .set PMC_SCER,        0x0000
    .set PMC_SCDR,        0x0004
    .set PMC_SCSR,        0x0008
    .set PMC_PCER0,       0x0010
    .set PMC_PCDR0,       0x0014
    .set PMC_PCSR0,       0x0018
    .set CKGR_UCKR,       0x001C
    .set CKGR_MOR,        0x0020
    .set CKGR_MCFR,       0x0024
    .set CKGR_PLLAR,      0x0028
    .set PMC_MCKR,        0x0030
    .set PMC_USB,         0x0038
    .set PMC_PCK0,        0x0040
    .set PMC_PCK1,        0x0044
    .set PMC_PCK2,        0x0048
    .set PMC_IER,         0x0060
    .set PMC_IDR,         0x0064
    .set PMC_SR,          0x0068
    .set PMC_IMR,         0x006C
    .set PMC_FSMR,        0x0070
    .set PMC_FSPR,        0x0074
    .set PMC_FOCR,        0x0078
    .set PMC_WPMR,        0x00E4
    .set PMC_WPSR,        0x00E8
    .set PMC_PCER1,       0x0100
    .set PMC_PCDR1,       0x0104
    .set PMC_PCSR1,       0x0108
    .set PMC_PCR,         0x010C

    .set PIOA,        0x400E0E00
    .set PIOB,        0x400E1000
    .set PIO_PER,         0x0000
    .set PIO_PDR,         0x0004
    .set PIO_PSR,         0x0008
    .set PIO_OER,         0x0010
    .set PIO_ODR,         0x0014
    .set PIO_OSR,         0x0018
    .set PIO_IFER,        0x0020
    .set PIO_IFDR,        0x0024
    .set PIO_IFSR,        0x0028
    .set PIO_SODR,        0x0030
    .set PIO_CODR,        0x0034
    .set PIO_ODSR,        0x0038
    .set PIO_PDSR,        0x003C
    .set PIO_IER,         0x0040
    .set PIO_IDR,         0x0044
    .set PIO_IMR,         0x0048
    .set PIO_ISR,         0x004C
    .set PIO_MDER,        0x0050
    .set PIO_MDDR,        0x0054
    .set PIO_MDSR,        0x0058
    .set PIO_PUDR,        0x0060
    .set PIO_PUER,        0x0064
    .set PIO_PUSR,        0x0068
    .set PIO_ABSR,        0x0070
    .set PIO_SCIFSR,      0x0080
    .set PIO_DIFSR,       0x0084
    .set PIO_IFDGSR,      0x0088
    .set PIO_SCDR,        0x008C
    .set PIO_OWER,        0x00A0
    .set PIO_OWDR,        0x00A4
    .set PIO_OWSR,        0x00A8
    .set PIO_AIMER,       0x00B0
    .set PIO_AIMDR,       0x00B4
    .set PIO_AIMMR,       0x00B8
    .set PIO_ESR,         0x00C0
    .set PIO_LSR,         0x00C4
    .set PIO_ELSR,        0x00C8
    .set PIO_FELLSR,      0x00D0
    .set PIO_REHLSR,      0x00D4
    .set PIO_FRLHSR,      0x00D8
    .set PIO_LOCKSR,      0x00E0
    .set PIO_WPMR,        0x00E4
    .set PIO_WPSR,        0x00E8

@ ---------------------------------------------------------------------
@ -- Interrupt vectors ------------------------------------------------

    .text
    .syntax unified

    .global _start
    .global reset_handler
_start:
    .long addr_TASKZTOS               /* Top of Stack                 */
    .long reset_handler + 1           /* Reset Handler                */
    .long nmi_handler + 1             /* NMI Handler                  */
    .long hardfault_handler + 1       /* Hard Fault Handler           */
    .long memmanage_handler + 1       /* MPU Fault Handler            */
    .long busfault_handler + 1        /* Bus Fault Handler            */
    .long usagefault_handler + 1      /* Usage Fault Handler          */
    .long 0                           /* Reserved                     */
    .long 0                           /* Reserved                     */
    .long 0                           /* Reserved                     */
    .long 0                           /* Reserved                     */

    .org 0x150

@ ---------------------------------------------------------------------
@ -- Board specific code and initialization ---------------------------

init_board:
    push {lr}

    @ safety delay of 3x8000000 ticks (~ 3 seconds)
    ldr r0, =8000000
    bl delay
    b 4f

    @ reset the interrupt vector table
    ldr r0, =addr_IVT
    mov r1, #0
    mov r2, 48
1:  str r1, [r0], #4
    subs r2, r2, #1
    bgt 1b

    @ enable PIC interrupts
    mov r0, #0
    msr primask, r0
    mov r0, #0
    msr basepri, r0
    ldr r0, =(_NVIC + NVIC_SETENA_BASE)
    mov r1, #0
.ifdef UART_USE_INTERRUPTS
    orr r1, #0x20
.endif
    str r1, [r0]

4:
    @ enable clocks on all peripherals
    ldr r0, =(PMC + PMC_PCER0)
    ldr r1, =0xfffffffd
    str r1, [r0]
    ldr r0, =(PMC + PMC_PCER1)
    ldr r1, =0x00001fff
    str r1, [r0]

    mov r0, #32
    bl delay

    @ enable UART pins on PIOA
    ldr r0, =PIOA
    ldr r1, =0x00000300
    str r1, [r0, #PIO_PER]
    str r1, [r0, #PIO_ABSR]
    ldr r1, =0x00000200
    str r1, [r0, #PIO_OER]
    ldr r1, =0x00000100
    str r1, [r0, #PIO_PUER]

    @ enable LED pin on PIOB
    ldr r0, =PIOB
    ldr r1, =0x8000000
    str r1, [r0, #PIO_PER]
    str r1, [r0, #PIO_OER]
    str r1, [r0, #PIO_OWDR]
    str r1, [r0, #PIO_PUDR]
    str r1, [r0, #PIO_SODR]

    mov r0, #32
    bl delay

    @ enable UART
    ldr r0, =UART
    ldr r1, =0x0000015c
    str r1, [r0, #UART_CR]
    ldr r1, =0x00000800
    str r1, [r0, #UART_MR]

    @ set UART baud rate
    ldr r0, =(UART + UART_BRGR)
    ldr r1, =(4000000 / 115200 / 16)
    str r1, [r0, #UART_BRGR]

    @ enable SYSTICK
    ldr r0, =STRELOAD
    ldr r1, =0x00ffffff
    str r1, [r0]
    ldr r0, =STCTRL
    mov r1, #5
    @ str r1, [r0]

6:
    mov r1, #64
    ldr r2, =UART
    str r1, [r2, #UART_THR]
    mov r0, #64
    bl delay
    b 6b

    pop {pc}
    .align 2, 0
    .ltorg

readkey_interrupt:
    mov pc, lr

readkey_polled:
    push {r1, r2, r3, lr}
    ldr r1, =UART
    mov r2, #32
1:  ldr r3, [r1, #UART_SR]
    and r3, r2
    cmp r3, r2
    bne 1b
    ldrb r0, [r1, #UART_RHR]
    pop {r1, r2, r3, pc}

.ifdef UART_USE_INTERRUPTS
    .set readkey, readkey_interrupt
.else
    .set readkey, readkey_polled
.endif

putchar:
    push {r1, r2, r3, lr}
    mov r2, #0x80
    ldr r3, =UART
1:  ldr r1, [r3, #UART_SR]
    and r1, r2
    cmp r1, r2
    bne 1b
    str r0, [r3, #UART_THR]
    pop {r1, r2, r3, pc}

@ ---------------------------------------------------------------------
@ -- IRQ handlers -----------------------------------------------------

@ Generic handler which checks if a Forth word is defined to handle the
@ IRQ. If not, this handler will simply return. Note that this will
@ usually lock up the system as the interrupt will be retriggered, the
@ generic handler is not clearing the interrupt.

generic_forth_handler:
    ldr r0, =addr_IVT
    mrs r1, ipsr
    sub r1, r1, #1
    lsl r1, #2
    add r0, r0, r1
    ldr r2, [r0]
    cmp r2, #0
    beq 1f
    push {r4 - r12, lr}
    ldr r6, =irq_stack_top
    mov r7, r0
    ldr r0, [r7]
    add r7, r7, #4
    ldr r1, [r0]
    add r1, r1, #1
    bx r1
1:  bx lr

nmi_handler:
    b .

hardfault_handler:
    mrs r0, psp
    b .

memmanage_handler:
    b .

busfault_handler:
    b .

usagefault_handler:
    b .

svc_handler:
    b .

debugmon_handler:
    b .

pendsv_handler:
    b .

systick_handler:
    b .

gpioa_handler:
gpiob_handler:
gpioc_handler:
gpiod_handler:
gpioe_handler:
uart0_handler:
uart1_handler:
ssi_handler:
i2c_handler:
pwm0_handler:
pwm1_handler:
pwm2_handler:
adcseq0_handler:
adcseq1_handler:
adcseq2_handler:
adcseq3_handler:
watchdog_handler:
timer0a_handler:
timer0b_handler:
timer1a_handler:
timer1b_handler:
timer2a_handler:
timer2b_handler:
adcomp_handler:
    b generic_forth_handler

@ ---------------------------------------------------------------------
@ -- CoreForth starts here --------------------------------------------

    .ltorg

    .include "CoreForth.s"

@ ---------------------------------------------------------------------
@ -- Board specific words ---------------------------------------------

    .include "arduino_due_words.s"
    .ltorg

    defword "COLD", COLD
    .word LIT, eval_words, EVALUATE
eval_words:
    .include "arduino_due_ram.gen.s"
    .word 0xffffffff

    .set last_word, link
    .set data_start, ram_here

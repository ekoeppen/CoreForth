@ -- vim:syntax=asm:foldmethod=marker:foldmarker=@\ --\ ,@\ ---:

@ ---------------------------------------------------------------------
@ -- Definitions ------------------------------------------------------

    .set UART0,       0x4000c000
    .set UART_DR,           0x00
    .set UART_RSR_ECR,      0x04
    .set UART_FR,           0x18
    .set UART_LPR,          0x20
    .set UART_IBRD,         0x24
    .set UART_FBRD,         0x28
    .set UART_LCRH,         0x2c
    .set UART_CR,           0x30
    .set UART_IFLS,         0x34
    .set UART_IMSC,         0x38
    .set UART_RIS,          0x3c
    .set UART_MIS,          0x40
    .set UART_ICR,          0x44
    .set UART_DMACR,        0x48

    .set UART_RXFE,         0x10
    .set UART_TXFF,         0x20

    .set SYSCTL,      0x400fe000
    .set SYSCTL_RIS,  0x400fe050
    .set SYSCTL_RCC,  0x400fe060
    .set SYSCTL_PLLCFG,0x400fe064
    .set SYSCTL_RCGC0,0x400fe100
    .set SYSCTL_RCGC1,0x400fe104
    .set SYSCTL_RCGC2,0x400fe108

    .set NVIC,        0xe000e000
    .set NVIC_SETENA_BASE, 0x100
    .set NVIC_ACTIVE_BASE, 0x300

    .set _GPIOA,      0x40004000
    .set _GPIOB,      0x40005000
    .set _GPIOC,      0x40006000
    .set _GPIOD,      0x40007000
    .set _GPIOE,      0x40024000
    .set _GPIO_DIR,        0x400
    .set _GPIO_AFSEL,      0x420
    .set _GPIO_IS,         0x404 
    .set _GPIO_IBE,        0x408 
    .set _GPIO_IEV,        0x40c 
    .set _GPIO_IM,         0x410 
    .set _GPIO_RIS,        0x414 
    .set _GPIO_MIS,        0x418 
    .set _GPIO_ICR,        0x41c 
    .set _GPIO_DR2R,       0x500
    .set _GPIO_ODR,        0x50c
    .set _GPIO_PUR,        0x510
    .set _GPIO_PDR,        0x514
    .set _GPIO_DEN,        0x51c

    .set STCTRL,      0xe000e010
    .set STRELOAD,    0xe000e014
    .set STCURRENT,   0xe000e018

@ ---------------------------------------------------------------------
@ -- Interrupt vectors ------------------------------------------------

    .text
    .syntax unified

    .global _start
    .global reset_handler
_start:
    .long addr_TOS                    /* Top of Stack                 */
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
    .long svc_handler + 1             /* SVCall Handler               */
    .long debugmon_handler + 1        /* Debug Monitor Handler        */
    .long 0                           /* Reserved                     */
    .long pendsv_handler + 1          /* PendSV Handler               */
    .long systick_handler + 1         /* SysTick Handler              */
    .long gpioa_handler + 1           /* GPIO A */
    .long gpiob_handler + 1           /* GPIO B */
    .long gpioc_handler + 1           /* GPIO C */
    .long gpiod_handler + 1           /* GPIO D */
    .long gpioe_handler + 1           /* GPIO E */
    .long uart0_key_handler + 1       /* UART 0 */
    .long uart1_handler + 1           /* UART 1 */
    .long ssi_handler + 1             /* SSI */
    .long i2c_handler + 1             /* I2C */
    .long 0                           /* Reserved */
    .long pwm0_handler + 1            /* PWM Generator 0 */
    .long pwm1_handler + 1            /* PWM Generator 1 */
    .long pwm2_handler + 1            /* PWM Generator 2 */
    .long 0                           /* Reserved */
    .long adcseq0_handler + 1         /* ADC0 Sequence 0 */
    .long adcseq1_handler + 1         /* ADC0 Sequence 1 */
    .long adcseq2_handler + 1         /* ADC0 Sequence 2 */
    .long adcseq3_handler + 1         /* ADC0 Sequence 3 */
    .long watchdog_handler + 1        /* Watchdog Timer 0 */
    .long timer0a_handler + 1         /* Timer 0A */
    .long timer0b_handler + 1         /* Timer 0B */
    .long timer1a_handler + 1         /* Timer 1A */
    .long timer1b_handler + 1         /* Timer 1B */
    .long timer2a_handler + 1         /* Timer 2A */
    .long timer2b_handler + 1         /* Timer 2B */
    .long adcomp_handler + 1          /* Analog Comparator 0 */
    .long 0                           /* Reserved */
    .long 0                           /* System Control */
    .long 0                           /* Flash Memory Control */

@ ---------------------------------------------------------------------
@ -- Board specific code and initialization ---------------------------

init_board:
    push {lr}

    @ safety delay of 3x8000000 ticks (~ 3 seconds)
    ldr r0, =8000000
    bl delay

.ifdef USE_50MHZ
    @ switch to 50Mhz SysClock
    ldr r0, =SYSCTL_RCC

    @ set bypass and clear SYSDIV
    ldr r1, [r0]
    ldr r2, =0x00008000
    ldr r3, =0xf83fffff
    and r1, r3
    orr r1, r2
    str r1, [r0]

    @ clear OSC source and power down PLL
    ldr r1, [r0]
    ldr r2, =0x00000000
    ldr r3, =0xffffcfcf
    and r1, r3
    orr r1, r2
    str r1, [r0]

    @ power up PLL and set XTAL and OSC source, set SYSDIV
    ldr r1, [r0]
    ldr r2, =0x01c002c0
    ldr r3, =0xf87ffc3f
    and r1, r3
    orr r1, r2
    str r1, [r0]

    @ wait for PLL to become ready
    ldr r2, =SYSCTL_RIS
2:  ldr r1, [r2]
    ands r1, #0x40
.ifndef PRECOMPILE @ qemu does not support PLL interrupts
    beq 2b
.else
    mov r0, r0
.endif

    @ use the PLL for SysClock
    ldr r1, [r0]
    ldr r2, =0x00000000
    ldr r3, =0xfffff7ff
    and r1, r3
    orr r1, r2
    str r1, [r0]
.else
    @ use 6MHz SysClock
    ldr r0, =SYSCTL_RCC
    ldr r1, =0x078e3ac0
    str r1, [r0]
.endif

    mov r0, #32
    bl delay

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
    ldr r0, =(NVIC + NVIC_SETENA_BASE)
    mov r1, #0x20
    str r1, [r0]

    @ enable clocks on all timers, UARTS, ADC, PWM, SSI and I2C and GPIO ports
    ldr r0, =SYSCTL_RCGC0
    ldr r1, =0x00110000
    str r1, [r0]
    ldr r0, =SYSCTL_RCGC1
    ldr r1, =0x00071013
    str r1, [r0]
    ldr r0, =SYSCTL_RCGC2
    mov r1, #0x1f
    str r1, [r0]

    mov r0, #32
    bl delay

    @ enable pins on _GPIOA
    ldr r0, =_GPIOA
    mov r1, #3
    str r1, [r0, _GPIO_AFSEL]
    mov r1, #0x0
    str r1, [r0, _GPIO_ODR]
    mov r1, #0x0
    str r1, [r0, _GPIO_PDR]
    mov r1, #0xff
    str r1, [r0, _GPIO_DEN]
    mov r1, #0x00
    str r1, [r0, _GPIO_DIR]
    mov r1, #0xff
    str r1, [r0, _GPIO_DR2R]

    mov r0, #32
    bl delay

    @ set UART baud rate
    ldr r0, =UART0
.ifdef USE_50MHZ
    mov r1, #27
    mov r2, #2
.else
    mov r1, #3
    mov r2, #16
.endif
    str r1, [r0, #UART_IBRD]
    str r2, [r0, #UART_FBRD]

    @ set 8N1
    mov r1, #0x60
    str r1, [r0, UART_LCRH]

    @ enable UART interrupts
    mov r1, #0x0    @ trigger after one byte
    str r1, [r0, UART_IFLS]
    mov r1, #0x10   @ trigger only receive interrupts
    str r1, [r0, UART_IMSC]
    mov r1, #0
    ldr r2, =addr_SBUF_HEAD
    str r1, [r2]
    ldr r2, =addr_SBUF_TAIL
    str r1, [r2]

    @ enable the UART
    ldr r1, =0x0301
    str r1, [r0, UART_CR]

    @ enable SYSTICK (without interrupts)
    ldr r0, =STRELOAD
    ldr r1, =0x00ffffff
    str r1, [r0]
    ldr r0, =STCTRL
    mov r1, #5
    str r1, [r0]

    pop {pc}
    .align 2, 0
    .ltorg

read_key:
2:  ldr r1, =addr_SBUF_TAIL
    ldrb r3, [r1]
    ldr r2, =addr_SBUF_HEAD
    ldrb r2, [r2]
    cmp r2, r3
    bne 1f
    wfi
    b 2b
1:  ldr r0, =addr_SBUF
    ldrb r0, [r0, r3]
    add r3, r3, #1
    and r3, #0x0f
    strb r3, [r1]
    mov pc, lr

putchar:
    push {r1, r2, r3, lr}
    ldr r1, =UART0
    mov r2, #UART_TXFF
1:  ldr r3, [r1, #UART_FR]
    ands r3, r3, r2
    bne 1b
    strb r0, [r1, #UART_DR]
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

uart0_key_handler:
2:  ldr r0, =(UART0 + UART_FR)
    ldr r1, [r0]
    ldr r2, =UART_RXFE
    ands r1, r1, r2
    bne 1f
    ldr r0, =(UART0 + UART_DR)
    ldrb r1, [r0]
    ldr r0, =addr_SBUF
    ldr r2, =addr_SBUF_HEAD
    ldrb r3, [r2]
    strb r1, [r0, r3]
    add r3, r3, #1
    and r3, #0x0f
    strb r3, [r2]
    b 2b
1:  bx lr

@ ---------------------------------------------------------------------
@ -- CoreForth starts here --------------------------------------------

    .ltorg

    .include "CoreForth.s"

@ ---------------------------------------------------------------------
@ -- Board specific words ---------------------------------------------

    defconst "GPIOA", GPIOA, _GPIOA
    defconst "GPIOB", GPIOB, _GPIOB
    defconst "GPIOC", GPIOC, _GPIOC
    defconst "GPIOD", GPIOD, _GPIOD
    defconst "GPIOE", GPIOE, _GPIOE

    defword "GPIO-DIR", GPIO_DIR, , DOOFFSET
    .word _GPIO_DIR

    defword "GPIO-AFSEL", GPIO_AFSEL, , DOOFFSET
    .word _GPIO_AFSEL

    defword "GPIO-IS", GPIO_IS, , DOOFFSET
    .word _GPIO_IS

    defword "GPIO-IBE", GPIO_IBE, , DOOFFSET
    .word _GPIO_IBE

    defword "GPIO-IEV", GPIO_IEV, , DOOFFSET
    .word _GPIO_IEV

    defword "GPIO-IM", GPIO_IM, , DOOFFSET
    .word _GPIO_IM

    defword "GPIO-RIS", GPIO_RIS, , DOOFFSET
    .word _GPIO_RIS

    defword "GPIO-MIS", GPIO_MIS, , DOOFFSET
    .word _GPIO_MIS

    defword "GPIO-ICR", GPIO_ICR, , DOOFFSET
    .word _GPIO_ICR

    defword "GPIO-DR2R", GPIO_DR2R, , DOOFFSET
    .word _GPIO_DR2R

    defword "GPIO-ODR", GPIO_ODR, , DOOFFSET
    .word _GPIO_ODR

    defword "GPIO-PUR", GPIO_PUR, , DOOFFSET
    .word _GPIO_PUR

    defword "GPIO-PDR", GPIO_PDR, , DOOFFSET
    .word _GPIO_PDR

    defword "GPIO-DEN", GPIO_DEN, , DOOFFSET
    .word _GPIO_DEN

    defcode "GPIO-DATA!", _GPIO_DATA_STORE @ ( value mask gpio -- )
    pop {r1}
    pop {r0}
    lsl r0, r0, #2
    add r0, r0, r1
    pop {r1}
    strb r1, [r0]
    NEXT

    defconst "UART0", UART_0, UART0

    defword "UART_DR", _UART_DR, , DOOFFSET
    .word UART_DR

    defword "UART-RSR-ECR", _UART_RSR_ECR, , DOOFFSET
    .word UART_RSR_ECR

    defword "UART-FR", _UART_FR, , DOOFFSET
    .word UART_FR

    defword "UART-LPR", _UART_LPR, , DOOFFSET
    .word UART_LPR

    defword "UART-IBRD", _UART_IBRD, , DOOFFSET
    .word UART_IBRD

    defword "UART-FBRD", _UART_FBRD, , DOOFFSET
    .word UART_FBRD

    defword "UART-LCRH", _UART_LCRH, , DOOFFSET
    .word UART_LCRH

    defword "UART-CR", _UART_CR, , DOOFFSET
    .word UART_CR

    defword "UART-IFLS", _UART_IFLS, , DOOFFSET
    .word UART_IFLS

    defword "UART-IMSC", _UART_IMSC, , DOOFFSET
    .word UART_IMSC

    defword "UART-RIS", _UART_RIS, , DOOFFSET
    .word UART_RIS

    defword "UART-MIS", _UART_MIS, , DOOFFSET
    .word UART_MIS

    defword "UART-ICR", _UART_ICR, , DOOFFSET
    .word UART_ICR

    defword "UART-DMACR", _UART_DMACR, , DOOFFSET
    .word UART_DMACR

    defconst "UART-RXFE",  _UART_RXFE, UART_RXFE
    defconst "UART-TXFF", _UART_TXFF, UART_TXFF

    defconst "NVIC", _NVIC, NVIC

    defcode "NVIC-SETENA", NVIC_SETENA
    ldr r0, =NVIC
    ldr r1, =NVIC_SETENA_BASE
    add r0, r1, r0
    push {r0}
    NEXT

    defdata "DISP-FONT", DISP_FONT
    .byte 0x00, 0x00, 0x00, 0x00, 0x00   @ " "
    .byte 0x00, 0x00, 0x4f, 0x00, 0x00   @ !
    .byte 0x00, 0x07, 0x00, 0x07, 0x00   @ "
    .byte 0x14, 0x7f, 0x14, 0x7f, 0x14   @ #
    .byte 0x24, 0x2a, 0x7f, 0x2a, 0x12   @ $
    .byte 0x23, 0x13, 0x08, 0x64, 0x62   @ %
    .byte 0x36, 0x49, 0x55, 0x22, 0x50   @ &
    .byte 0x00, 0x05, 0x03, 0x00, 0x00   @ '
    .byte 0x00, 0x1c, 0x22, 0x41, 0x00   @ (
    .byte 0x00, 0x41, 0x22, 0x1c, 0x00   @ )
    .byte 0x14, 0x08, 0x3e, 0x08, 0x14   @ *
    .byte 0x08, 0x08, 0x3e, 0x08, 0x08   @ +
    .byte 0x00, 0x50, 0x30, 0x00, 0x00   @ ,
    .byte 0x08, 0x08, 0x08, 0x08, 0x08   @ -
    .byte 0x00, 0x60, 0x60, 0x00, 0x00   @ .
    .byte 0x20, 0x10, 0x08, 0x04, 0x02   @ /
    .byte 0x3e, 0x51, 0x49, 0x45, 0x3e   @ 0
    .byte 0x00, 0x42, 0x7f, 0x40, 0x00   @ 1
    .byte 0x42, 0x61, 0x51, 0x49, 0x46   @ 2
    .byte 0x21, 0x41, 0x45, 0x4b, 0x31   @ 3
    .byte 0x18, 0x14, 0x12, 0x7f, 0x10   @ 4
    .byte 0x27, 0x45, 0x45, 0x45, 0x39   @ 5
    .byte 0x3c, 0x4a, 0x49, 0x49, 0x30   @ 6
    .byte 0x01, 0x71, 0x09, 0x05, 0x03   @ 7
    .byte 0x36, 0x49, 0x49, 0x49, 0x36   @ 8
    .byte 0x06, 0x49, 0x49, 0x29, 0x1e   @ 9
    .byte 0x00, 0x36, 0x36, 0x00, 0x00   @ :
    .byte 0x00, 0x56, 0x36, 0x00, 0x00   @ ;
    .byte 0x08, 0x14, 0x22, 0x41, 0x00   @ <
    .byte 0x14, 0x14, 0x14, 0x14, 0x14   @ =
    .byte 0x00, 0x41, 0x22, 0x14, 0x08   @ >
    .byte 0x02, 0x01, 0x51, 0x09, 0x06   @ ?
    .byte 0x32, 0x49, 0x79, 0x41, 0x3e   @ @
    .byte 0x7e, 0x11, 0x11, 0x11, 0x7e   @ A
    .byte 0x7f, 0x49, 0x49, 0x49, 0x36   @ B
    .byte 0x3e, 0x41, 0x41, 0x41, 0x22   @ C
    .byte 0x7f, 0x41, 0x41, 0x22, 0x1c   @ D
    .byte 0x7f, 0x49, 0x49, 0x49, 0x41   @ E
    .byte 0x7f, 0x09, 0x09, 0x09, 0x01   @ F
    .byte 0x3e, 0x41, 0x49, 0x49, 0x7a   @ G
    .byte 0x7f, 0x08, 0x08, 0x08, 0x7f   @ H
    .byte 0x00, 0x41, 0x7f, 0x41, 0x00   @ I
    .byte 0x20, 0x40, 0x41, 0x3f, 0x01   @ J
    .byte 0x7f, 0x08, 0x14, 0x22, 0x41   @ K
    .byte 0x7f, 0x40, 0x40, 0x40, 0x40   @ L
    .byte 0x7f, 0x02, 0x0c, 0x02, 0x7f   @ M
    .byte 0x7f, 0x04, 0x08, 0x10, 0x7f   @ N
    .byte 0x3e, 0x41, 0x41, 0x41, 0x3e   @ O
    .byte 0x7f, 0x09, 0x09, 0x09, 0x06   @ P
    .byte 0x3e, 0x41, 0x51, 0x21, 0x5e   @ Q
    .byte 0x7f, 0x09, 0x19, 0x29, 0x46   @ R
    .byte 0x46, 0x49, 0x49, 0x49, 0x31   @ S
    .byte 0x01, 0x01, 0x7f, 0x01, 0x01   @ T
    .byte 0x3f, 0x40, 0x40, 0x40, 0x3f   @ U
    .byte 0x1f, 0x20, 0x40, 0x20, 0x1f   @ V
    .byte 0x3f, 0x40, 0x38, 0x40, 0x3f   @ W
    .byte 0x63, 0x14, 0x08, 0x14, 0x63   @ X
    .byte 0x07, 0x08, 0x70, 0x08, 0x07   @ Y
    .byte 0x61, 0x51, 0x49, 0x45, 0x43   @ Z
    .byte 0x00, 0x7f, 0x41, 0x41, 0x00   @ [
    .byte 0x02, 0x04, 0x08, 0x10, 0x20   @ "\"
    .byte 0x00, 0x41, 0x41, 0x7f, 0x00   @ ]
    .byte 0x04, 0x02, 0x01, 0x02, 0x04   @ ^
    .byte 0x40, 0x40, 0x40, 0x40, 0x40   @ _
    .byte 0x00, 0x01, 0x02, 0x04, 0x00   @ `
    .byte 0x20, 0x54, 0x54, 0x54, 0x78   @ a
    .byte 0x7f, 0x48, 0x44, 0x44, 0x38   @ b
    .byte 0x38, 0x44, 0x44, 0x44, 0x20   @ c
    .byte 0x38, 0x44, 0x44, 0x48, 0x7f   @ d
    .byte 0x38, 0x54, 0x54, 0x54, 0x18   @ e
    .byte 0x08, 0x7e, 0x09, 0x01, 0x02   @ f
    .byte 0x0c, 0x52, 0x52, 0x52, 0x3e   @ g
    .byte 0x7f, 0x08, 0x04, 0x04, 0x78   @ h
    .byte 0x00, 0x44, 0x7d, 0x40, 0x00   @ i
    .byte 0x20, 0x40, 0x44, 0x3d, 0x00   @ j
    .byte 0x7f, 0x10, 0x28, 0x44, 0x00   @ k
    .byte 0x00, 0x41, 0x7f, 0x40, 0x00   @ l
    .byte 0x7c, 0x04, 0x18, 0x04, 0x78   @ m
    .byte 0x7c, 0x08, 0x04, 0x04, 0x78   @ n
    .byte 0x38, 0x44, 0x44, 0x44, 0x38   @ o
    .byte 0x7c, 0x14, 0x14, 0x14, 0x08   @ p
    .byte 0x08, 0x14, 0x14, 0x18, 0x7c   @ q
    .byte 0x7c, 0x08, 0x04, 0x04, 0x08   @ r
    .byte 0x48, 0x54, 0x54, 0x54, 0x20   @ s
    .byte 0x04, 0x3f, 0x44, 0x40, 0x20   @ t
    .byte 0x3c, 0x40, 0x40, 0x20, 0x7c   @ u
    .byte 0x1c, 0x20, 0x40, 0x20, 0x1c   @ v
    .byte 0x3c, 0x40, 0x30, 0x40, 0x3c   @ w
    .byte 0x44, 0x28, 0x10, 0x28, 0x44   @ x
    .byte 0x0c, 0x50, 0x50, 0x50, 0x3c   @ y
    .byte 0x44, 0x64, 0x54, 0x4c, 0x44   @ z
    .byte 0x00, 0x08, 0x36, 0x41, 0x00   @ {
    .byte 0x00, 0x00, 0x7f, 0x00, 0x00   @ |
    .byte 0x00, 0x41, 0x36, 0x08, 0x00   @ }
    .byte 0x02, 0x01, 0x02, 0x04, 0x02   @ ~

    defcode "RETI", RETI
    pop {r4 - r12, pc}

    defword ";I", SEMICOLONI, F_IMMED
    .word LIT, RETI, COMMAXT, REVEAL, LBRACKET, EXIT

    defvar "SBUF", SBUF, 16
    defvar "SBUF-HEAD", SBUF_HEAD
    defvar "SBUF-TAIL", SBUF_TAIL
    defvar "IVT", IVT, 48 * 4

    .ltorg

    defword "(COLD)", XCOLD
    .word LIT, eval_words, EVALUATE

    defword "(COLD-PRECOMPILE)", XCOLD_PRECOMPILE
    .word PRECOMP_BEGIN
    .word LIT, eval_words, EVALUATE
    .word PRECOMP_END

    defword "COLD", COLD
.ifdef PRECOMPILE
    .word XCOLD_PRECOMPILE
.else
    .word XCOLD
.endif

.ifdef PRECOMPILE
    .set last_rom_word, link
    .set end_of_rom, .

eval_words:
    .include "CoreForth.gen.s"
    .include "lm3s811.gen.s"
    .include "editor.gen.s"
    .word 0xffffffff
.else

    .include "lm3s811.precomp.s"

    .set last_rom_word, link
    .set end_of_rom, .

eval_words:
    .include "lm3s811ram.gen.s"
    .word 0xffffffff
.endif

    .set last_word, link
    .set data_start, compiled_here 


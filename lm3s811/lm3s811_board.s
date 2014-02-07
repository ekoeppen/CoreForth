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

code_start:
init_board:
    push {lr}

    @ safety delay of 3x8000000 ticks (~ 3 seconds)
    ldr r0, =8000000
    bl delay

.ifdef USE_50MHZ
    @ switch to 50Mhz SysClock
    ldr r0, =SYSCTL_RCC

    @ set bypass ands clear SYSDIV
    ldr r1, [r0]
    ldr r2, =0x00008000
    ldr r3, =0xf83fffff
    ands r1, r3
    orrs r1, r2
    str r1, [r0]

    @ clear OSC source ands power down PLL
    ldr r1, [r0]
    ldr r2, =0x00000000
    ldr r3, =0xffffcfcf
    ands r1, r3
    orrs r1, r2
    str r1, [r0]

    @ power up PLL ands set XTAL and OSC source, set SYSDIV
    ldr r1, [r0]
    ldr r2, =0x01c002c0
    ldr r3, =0xf87ffc3f
    ands r1, r3
    orrs r1, r2
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
    ands r1, r3
    orrs r1, r2
    str r1, [r0]
.else
    @ use 6MHz SysClock
    ldr r0, =SYSCTL_RCC
    ldr r1, =0x078e3ac0
    str r1, [r0]
.endif

    movs r0, #32
    bl delay

    @ reset the interrupt vector table
    ldr r0, =addr_IVT
    movs r1, #0
    movs r2, #48
1:  str r1, [r0]
    adds r0, #4
    subs r2, r2, #1
    bgt 1b

    @ enable PIC interrupts
    movs r0, #0
    msr primask, r0
    movs r0, #0
    msr basepri, r0
    ldr r0, =(NVIC + NVIC_SETENA_BASE)
    movs r1, #0x20
    str r1, [r0]

    @ enable clocks on all timers, UARTS, ADC, PWM, SSI ands I2C and GPIO ports
    ldr r0, =SYSCTL_RCGC0
    ldr r1, =0x00110000
    str r1, [r0]
    ldr r0, =SYSCTL_RCGC1
    ldr r1, =0x00071013
    str r1, [r0]
    ldr r0, =SYSCTL_RCGC2
    movs r1, #0x1f
    str r1, [r0]

    movs r0, #32
    bl delay

    @ enable pins on _GPIOA
    ldr r0, =_GPIOA
    movs r1, #3
    str r1, [r0, _GPIO_AFSEL]
    movs r1, #0x0
    str r1, [r0, _GPIO_ODR]
    movs r1, #0x0
    str r1, [r0, _GPIO_PDR]
    movs r1, #0xff
    str r1, [r0, _GPIO_DEN]
    movs r1, #0x00
    str r1, [r0, _GPIO_DIR]
    movs r1, #0xff
    str r1, [r0, _GPIO_DR2R]

    movs r0, #32
    bl delay

    @ set UART baud rate
    ldr r0, =UART0
.ifdef USE_50MHZ
    movs r1, #27
    movs r2, #2
.else
    movs r1, #3
    movs r2, #16
.endif
    str r1, [r0, #UART_IBRD]
    str r2, [r0, #UART_FBRD]

    @ set 8N1
    movs r1, #0x60
    str r1, [r0, UART_LCRH]

    @ enable UART interrupts
    movs r1, #0x0    @ trigger after one byte
    str r1, [r0, UART_IFLS]
    movs r1, #0x10   @ trigger only receive interrupts
    str r1, [r0, UART_IMSC]
    movs r1, #0
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
    movs r1, #5
    str r1, [r0]

    pop {pc}
    .align 2, 0
    .ltorg

readkey:
    push {r1, r2, r3, lr}
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
    adds r3, #1
    movs r2, #0x0f
    ands r3, r2
    strb r3, [r1]
    pop {r1, r2, r3, pc}

putchar:
    push {r1, r2, r3, lr}
    ldr r1, =UART0
    movs r2, #UART_TXFF
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
    subs r1, r1, #1
    lsls r1, #2
    adds r0, r0, r1
    ldr r2, [r0]
    cmp r2, #0
    beq 1f
    push {r4 - r7, lr}
    ldr r6, =irq_stack_top
    mov r7, r0
    ldr r0, [r7]
    adds r7, r7, #4
    ldr r1, [r0]
    adds r1, r1, #1
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
    ands r1, r2
    bne 1f
    ldr r0, =(UART0 + UART_DR)
    ldrb r1, [r0]
    ldr r0, =addr_SBUF
    ldr r2, =addr_SBUF_HEAD
    ldrb r3, [r2]
    strb r1, [r0, r3]
    movs r1, #0x0f
    adds r3, #1
    ands r3, r1
    strb r3, [r2]
    ldr r0, =addr_UARTZ_TASK
    ldr r0, [r0]
    cmp r0, #0
    beq 2b
    ldr r1, =LPARENWAKERPAREN
    sub r0, #4
    str r1, [r0]
    b 2b
1:  bx lr

@ ---------------------------------------------------------------------
@ -- CoreForth starts here --------------------------------------------

    .ltorg

    .include "CoreForth.s"

@ ---------------------------------------------------------------------
@ -- Board specific words ---------------------------------------------

    .include "lm3s811_words.s"
    .ltorg
    .include "precompiled_words.s"
    .ltorg

    defword "COLD", COLD
    .word LIT, eval_words, EVALUATE
eval_words:
    .include "lm3s811_ram.gen.s"
    .word 0xffffffff

    .set last_word, link
    .set data_start, ram_here

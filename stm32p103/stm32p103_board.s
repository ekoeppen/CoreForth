@ -- vim:syntax=asm:foldmethod=marker:foldmarker=@\ --\ ,@\ ---:

@ ---------------------------------------------------------------------
@ -- Definitions ------------------------------------------------------

    .set UART1,       0x40013800
    .set UART2,       0x40004400
    .set UART3,       0x40004800
    .set UART_SR,           0x00
    .set UART_DR,           0x04
    .set UART_BRR,          0x08
    .set UART_CR1,          0x0c
    .set UART_CR2,          0x10
    .set UART_CR3,          0x14
    .set UART_GPTR,         0x18

    .set RCC,         0x40021000
    .set RCC_CR,      0x40021000
    .set RCC_CFGR,    0x40021004
    .set RCC_CIR,     0x40021008
    .set RCC_APB2RSTR,0x4002100c
    .set RCC_APB1RSTR,0x40021010
    .set RCC_AHBENR,  0x40021014
    .set RCC_APB2ENR, 0x40021018
    .set RCC_APB1ENR, 0x4002101c
    .set RCC_BDCR,    0x40021020
    .set RCC_CSR,     0x40021024
    .set RCC_AHBRSTR, 0x40021028
    .set RCC_CFGR2,   0x4002102c

    .set _NVIC,        0xe000e000
    .set NVIC_SETENA_BASE, 0x100
    .set NVIC_ACTIVE_BASE, 0x300

    .set _GPIOA,       0x40010800
    .set _GPIOB,       0x40010c00
    .set _GPIOC,       0x40011000
    .set _GPIOD,       0x40011400
    .set _GPIOE,       0x40011800
    .set _GPIOF,       0x40011c00
    .set _GPIOG,       0x40012000
    .set _GPIO_CRL,         0x000
    .set _GPIO_CRH,         0x004
    .set _GPIO_IDR,         0x008
    .set _GPIO_ODR,         0x00c
    .set _GPIO_BSRR,        0x010
    .set _GPIO_BRR,         0x014
    .set _GPIO_LCKR,        0x018

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

    .org 0x150

@ ---------------------------------------------------------------------
@ -- Board specific code and initialization ---------------------------

init_board:
    push {lr}

    @ safety delay of 3x8000000 ticks (~ 3 seconds)
    ldr r0, =8000000
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
    ldr r0, =(_NVIC + NVIC_SETENA_BASE)
    mov r1, #0
.ifdef UART_USE_INTERRUPTS
    orr r1, #0x20
.endif
    str r1, [r0]

    @ enable clocks on all timers, UARTS, ADC, PWM, SSI and I2C and _GPIO ports
    ldr r0, =RCC_APB2ENR
    ldr r1, =0x4
    str r1, [r0]
    ldr r0, =RCC_APB1ENR
    ldr r1, =0x20000
    str r1, [r0]

    mov r0, #32
    bl delay

    @ enable pins on _GPIOA
    ldr r0, =(_GPIOA + _GPIO_CRL)
    ldr r1, =0x44444b44
    str r1, [r0]

    mov r0, #32
    bl delay

    @ enable UART
    ldr r0, =(UART2 + UART_CR1)
    ldr r1, =0x200c
    str r1, [r0]

    @ set UART baud rate
    ldr r0, =(UART2 + UART_BRR)
    ldr r1, =(8000000 / 115200)
    str r1, [r0]

    @ enable SYSTICK
    ldr r0, =STRELOAD
    ldr r1, =0x00ffffff
    str r1, [r0]
    ldr r0, =STCTRL
    mov r1, #5
    str r1, [r0]

    mov r0, #32
    bl delay

    pop {pc}
    .align 2, 0
    .ltorg

read_key_interrupt:
    mov pc, lr

read_key_polled:
    push {r1, r2, r3, lr}
    ldr r1, =UART2
    mov r2, #32
1:  ldr r3, [r1, #UART_SR]
    and r3, r2
    cmp r3, r2
    bne 1b
    ldrb r0, [r1, #UART_DR]
    pop {r1, r2, r3, pc}

.ifdef UART_USE_INTERRUPTS
    .set read_key, read_key_interrupt
.else
    .set read_key, read_key_polled
.endif

putchar:
    push {r1, r2, r3, lr}
    mov r2, #0x80
    ldr r3, =UART2
1:  ldr r1, [r3, #UART_SR]
    and r1, r2
    cmp r1, r2
    bne 1b
    str r0, [r3, #UART_DR]
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

    .include "stm32p103_words.s"
    .ltorg
    .include "precompiled_words.s"
    .ltorg

    defword "COLD", COLD
    .word LIT, eval_words, EVALUATE
eval_words:
    .include "stm32p103_ram.gen.s"
    .word 0xffffffff

    .set last_word, link
    .set data_start, ram_here

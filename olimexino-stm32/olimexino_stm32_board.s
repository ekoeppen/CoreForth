@ -- vim:syntax=asm:foldmethod=marker:foldmarker=@\ --\ ,@\ ---:

@ ---------------------------------------------------------------------
@ -- Definitions ------------------------------------------------------

    .include "../stm32p103/stm32p103_definitions.s"

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

    @ switch to 72MHz clock
    ldr r0, =FPEC
    mov r1, #0x32
    str r1, [r0, #FLASH_ACR]
    ldr r0, =RCC
    ldr r1, [r0, #RCC_CFGR]
    ldr r2, =0xffc238ff
    ands r1, r2
    ldr r2, =0x001d8400
    orrs r1, r2
    str r1, [r0, #RCC_CFGR]
    ldr r1, =0x00010000
    str r1, [r0, #RCC_CR]
    ldr r2, =0x00020000
1:  ldr r1, [r0, #RCC_CR]
    ands r1, r2
    beq 1b
    ldr r1, =0x01010000
    str r1, [r0, #RCC_CR]
    ldr r2, =0x02000000
2:  ldr r1, [r0, #RCC_CR]
    ands r1, r2
    beq 2b
    ldr r1, [r0, #RCC_CFGR]
    ldr r2, =0xfffffffc
    ands r1, r2
    orrs r1, #0x2
    str r1, [r0, #RCC_CFGR]

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
    mov r1, #0
    str r1, [r0]

    @ enable clocks on all timers, UARTS, ADC, PWM, SSI and I2C and GPIO ports
    ldr r0, =RCC
    ldr r1, =0xffffffff
    str r1, [r0, #RCC_APB1ENR]
    str r1, [r0, #RCC_APB2ENR]

    @ enable pins on GPIOA
    ldr r0, =GPIOA
    ldr r1, =0x444444b4
    str r1, [r0, #GPIO_CRH]

    @ enable UART
    ldr r0, =UART1
    ldr r1, =0x200c
    str r1, [r0, #UART_CR1]

    @ set UART baud rate
    ldr r1, =(72000000 / 115200)
    str r1, [r0, #UART_BRR]

    @ enable SYSTICK
    ldr r0, =STRELOAD
    ldr r1, =0x00ffffff
    str r1, [r0]
    ldr r0, =STCTRL
    mov r1, #5
    str r1, [r0]

    @ unlock flash controller
    ldr r0, =FPEC
    ldr r1, =0x45670123
    str r1, [r0, #FLASH_KEYR]
    ldr r1, =0xcdef89ab
    str r1, [r0, #FLASH_KEYR]

    pop {pc}
    .ltorg

readkey:
    push {r1, r2, lr}
    ldr r1, =UART1
1:  ldr r2, [r1, #UART_SR]
    ands r2, #32
    beq 1b
    ldrb r0, [r1, #UART_DR]
    pop {r1, r2, pc}

putchar:
    push {r1, r2, lr}
    ldr r1, =UART1
1:  ldr r2, [r1, #UART_SR]
    ands r2, #0x80
    beq 1b
    str r0, [r1, #UART_DR]
    pop {r1, r2, pc}

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

    .include "olimexino_stm32_words.s"
    .ltorg
    .include "precompiled_words.s"
    .ltorg

    defword "COLD", COLD
    .word LIT, eval_words, EVALUATE
eval_words:
    .include "olimexino_stm32_ram.gen.s"
    .word 0xffffffff

    .set last_word, link
    .set data_start, ram_here

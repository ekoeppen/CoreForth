@ -- vim:syntax=asm:foldmethod=marker:foldmarker=@\ --\ ,@\ ---:

@ ---------------------------------------------------------------------
@ -- Definitions ------------------------------------------------------

    .include "stm32f030_definitions.s"

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

    @ reset the interrupt vector table
    ldr r0, =addr_IVT
    movs r1, #0
    movs r2, 48
1:  str r1, [r0]
    adds r0, r0, #4
    subs r2, r2, #1
    bgt 1b

    @ enable clocks on UART1 and GPIOA
    ldr r0, =RCC
    ldr r1, =(1 << 17)
    str r1, [r0, #RCC_AHBENR]
    ldr r1, =(1 << 14)
    str r1, [r0, #RCC_APB2ENR]

    @ enable pins on GPIOA
    ldr r0, =GPIOA
    ldr r1, =0x28281400
    str r1, [r0, #GPIO_MODER]
    ldr r1, =0x0c000000
    str r1, [r0, #GPIO_OSPEEDR]
    ldr r1, =0x24000000
    str r1, [r0, #GPIO_PUPDR]
    ldr r1, =0x00000110
    str r1, [r0, #GPIO_AFRH]

    @ enable UART
    ldr r0, =UART1
    ldr r1, =(8000000 / 115200)
    str r1, [r0, #UART_BRR]
    ldr r1, =0x0000000d
    str r1, [r0, #UART_CR1]

    pop {pc}

readkey:
    push {r1, r2, r3, lr}
    ldr r1, =UART1
    movs r2, #32
1:  ldr r3, [r1, #UART_ISR]
    ands r3, r2
    cmp r3, r2
    bne 1b
    ldr r0, [r1, #UART_RDR]
    pop {r1, r2, r3, pc}

putchar:
    push {r2, r3, lr}
    ldr r3, =UART1
    str r0, [r3, #UART_TDR]
    movs r2, #0x40
1:  ldr r0, [r3, #UART_ISR]
    ands r0, r2
    cmp r0, r2
    bne 1b
    pop {r2, r3, pc}

    .ltorg
@ ---------------------------------------------------------------------
@ -- IRQ handlers -----------------------------------------------------

@ Generic handler which checks if a Forth word is defined to handle the
@ IRQ. If not, this handler will simply return. Note that this will
@ usually lock up the system as the interrupt will be retriggered, the
@ generic handler is not clearing the interrupt.

generic_forth_handler:
    ldr r0, =addr_IVT
    mrs r1, ipsr
    subs r1, #1
    lsls r1, #2
    add r0, r0, r1
    ldr r2, [r0]
    cmp r2, #0
    beq 1f
    push {r4 - r7, lr}
    mov r4, r8
    push {r4}
    mov r4, r9
    push {r4}
    mov r4, r10
    push {r4}
    mov r4, r11
    push {r4}
    mov r4, r12
    push {r4}
    ldr r6, =irq_stack_top
    mov r7, r0
    ldr r0, [r7]
    adds r7, #4
    ldr r1, [r0]
    adds r1, #1
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

    .include "stm32f030_words.s"
    .ltorg
    .include "precompiled_words.s"
    .ltorg

    defword "COLD", COLD
    .word LIT, eval_words, EVALUATE
eval_words:
    .include "stm32f030_ram.gen.s"
    .word 0xffffffff

    .set last_word, link
    .set data_start, ram_here

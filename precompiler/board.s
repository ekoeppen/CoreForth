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
    .space 33 * 4
end_of_irq:

@ ---------------------------------------------------------------------
@ -- Board specific code and initialization ---------------------------

init_board:
    mov pc, lr

readkey:
    b .

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

@ ---------------------------------------------------------------------
@ -- CoreForth starts here --------------------------------------------

    .ltorg

    .include "CoreForth.s"
    .include "see.s"

    defword "COLD", COLD
    .word PRECOMP_BEGIN, LIT, precompile_words, EVALUATE, PRECOMP_END

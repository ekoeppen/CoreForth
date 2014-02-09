@ -- vim:syntax=asm:foldmethod=marker:foldmarker=@\ --\ ,@\ ---:

@ ---------------------------------------------------------------------
@ -- Definitions ------------------------------------------------------

    .include "thumbolator_definitions.s"

@ ---------------------------------------------------------------------
@ -- Interrupt vectors ------------------------------------------------

    .text
    .syntax unified

    .global _start
    .global reset_handler
    .global putchar
    .global init_board
    .global readkey
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

    .org 0xc0
    .set end_of_irq, .

@ ---------------------------------------------------------------------
@ -- Board specific code and initialization ---------------------------

code_start:
init_board:
    bx lr

readkey:
    ldr r1, =UART_DR
    ldr r0, [r1]
    bx lr

putchar:
    ldr r1, =UART_DR
    str r0, [r1]
    bx lr

    .ltorg
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


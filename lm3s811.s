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
    .set SYSCTL_RCC,      0x0060
    .set SYSCTL_RCGC1,    0x0104
    .set SYSCTL_RCGC2,    0x0108

    .set NVIC,        0xe000e000
    .set NVIC_SETENA_BASE, 0x100
    .set NVIC_ACTIVE_BASE, 0x300

    .set GPIOA,       0x40004000
    .set GPIOB,       0x40005000
    .set GPIOC,       0x40006000
    .set GPIOD,       0x40007000
    .set GPIOE,       0x40024000
    .set GPIO_DIR,         0x400
    .set GPIO_AFSEL,       0x420
    .set GPIO_IS,          0x404 
    .set GPIO_IBE,         0x408 
    .set GPIO_IEV,         0x40c 
    .set GPIO_IM,          0x410 
    .set GPIO_RIS,         0x414 
    .set GPIO_MIS,         0x418 
    .set GPIO_ICR,         0x41c 
    .set GPIO_DR2R,        0x500
    .set GPIO_ODR,         0x50c
    .set GPIO_PUR,         0x510
    .set GPIO_PDR,         0x514
    .set GPIO_DEN,         0x51c

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
    .long uart0_handler + 1           /* UART 0 */
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
.if UART_USE_INTERRUPTS == 1
    orr r1, #0x20
.endif
    str r1, [r0]

    @ enable clocks on all timers, UARTS, SSI and I2C and GPIO ports
    ldr r0, =(SYSCTL + SYSCTL_RCC)
    ldr r1, =0x078e3ac0
    str r1, [r0]
    ldr r0, =(SYSCTL + SYSCTL_RCGC1)
    ldr r1, =0x0007113
    str r1, [r0]
    ldr r0, =(SYSCTL + SYSCTL_RCGC2)
    mov r1, #63
    str r1, [r0]

    mov r0, #32
    bl delay

    @ enable pins on GPIOA
    ldr r0, =(GPIOA + GPIO_AFSEL)
    mov r1, #3
    str r1, [r0]
    ldr r0, =(GPIOA + GPIO_ODR)
    mov r1, #0x0
    str r1, [r0]
    ldr r0, =(GPIOA + GPIO_PDR)
    mov r1, #0x0
    str r1, [r0]
    ldr r0, =(GPIOA + GPIO_DEN)
    mov r1, #0xff
    str r1, [r0]
    ldr r0, =(GPIOA + GPIO_DIR)
    mov r1, #0x00
    str r1, [r0]
    ldr r0, =(GPIOA + GPIO_DR2R)
    mov r1, #0xff
    str r1, [r0]

    mov r0, #32
    bl delay

    @ set UART baud rate
    ldr r0, =(UART0 + UART_IBRD)
    mov r1, #3
    str r1, [r0]
    ldr r0, =(UART0 + UART_FBRD)
    mov r1, #16
    str r1, [r0]

    @ set 8N1
    ldr r0, =(UART0 + UART_LCRH)
    mov r1, #0x70
    str r1, [r0]

.if UART_USE_INTERRUPTS == 1
    @ enable UART interrupts
    ldr r0, =(UART0 + UART_IFLS)
    mov r1, #0x1    @ trigger after one byte
    str r1, [r0]
    ldr r0, =(UART0 + UART_IMSC)
    mov r1, #0x10   @ trigger only receive interrupts
    str r1, [r0]
    mov r1, #0
    ldr r0, =addr_SBUF_HEAD
    str r1, [r0]
    ldr r0, =addr_SBUF_TAIL
.endif

    @ enable the UART
    ldr r0, =(UART0 + UART_CR)
    ldr r1, =0x0301
    str r1, [r0]

    pop {pc}
    .align 2, 0
    .ltorg

delay:
    push {lr}
    subs r0, r0, #1
    bgt delay
    pop {pc}

read_key_interrupt:
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
    strb r3, [r1]
    mov pc, lr

read_key_polled:
    push {r1, r2, r3, lr}
    ldr r1, =UART0
    mov r2, #UART_RXFE
1:  ldr r3, [r1, #UART_FR]
    ands r3, r3, r2
    bne 1b
    ldrb r0, [r1, #UART_DR]
    pop {r1, r2, r3, pc}

.if UART_USE_INTERRUPTS == 1
    .set read_key, read_key_interrupt
.else
    .set read_key, read_key_polled
.endif

putchar:
    push {r1, r2, r3, lr}
    ldr r1, =UART0
    mov r2, #UART_TXFF
1:  ldr r3, [r1, #UART_FR]
    ands r3, r3, r2
    bne 1b
    strb r0, [r1, #UART_DR]
    pop {r1, r2, r3, pc}

.include "CoreForth.s"

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
    NEXT 
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

.if UART_USE_INTERRUPTS == 1
uart0_handler:
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
    strb r3, [r2]
    b 2b
1:  bx lr
.else
uart0_handler:
    b generic_forth_handler
.endif

gpioa_handler:
gpiob_handler:
gpioc_handler:
gpiod_handler:
gpioe_handler:
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
@ -- Board specific words ---------------------------------------------

    defcode "GPIOA", 5, , GPIO_A
    ldr r0, =GPIOA
    push {r0}
    NEXT

    defcode "GPIOB", 5, , GPIO_B
    ldr r0, =GPIOB
    push {r0}
    NEXT

    defcode "GPIOC", 5, , GPIO_C
    ldr r0, =GPIOC
    push {r0}
    NEXT

    defcode "GPIOD", 5, , GPIO_D
    ldr r0, =GPIOD
    push {r0}
    NEXT

    defcode "GPIOE", 5, , GPIO_E
    ldr r0, =GPIOE
    push {r0}
    NEXT

    defcode "GPIO-DIR", 8, , _GPIO_DIR
    ldr r0, =GPIO_DIR
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-AFSEL", 10, , _GPIO_AFSEL
    ldr r0, =GPIO_AFSEL
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-IS", 7, , _GPIO_IS
    ldr r0, =GPIO_IS
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-IBE", 8, , _GPIO_IBE
    ldr r0, =GPIO_IBE
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-IEV", 8, , _GPIO_IEV
    ldr r0, =GPIO_IEV
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-IM", 7, , _GPIO_IM
    ldr r0, =GPIO_IM
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-RIS", 8, , _GPIO_RIS
    ldr r0, =GPIO_RIS
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-MIS", 8, , _GPIO_MIS
    ldr r0, =GPIO_MIS
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-ICR", 8, , _GPIO_ICR
    ldr r0, =GPIO_ICR
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-DR2R", 9, , _GPIO_DR2R
    ldr r0, =GPIO_DR2R
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-ODR", 8, , _GPIO_ODR
    ldr r0, =GPIO_ODR
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-PUR", 8, , _GPIO_PUR
    ldr r0, =GPIO_PUR
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-PDR", 8, , _GPIO_PDR
    ldr r0, =GPIO_PDR
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-DEN", 8, , _GPIO_DEN
    ldr r0, =GPIO_DEN
    pop {r1}
    add r0, r0, r1
    push {r0}
    NEXT

    defcode "GPIO-DATA!", 10, , _GPIO_DATA_STORE @ ( value mask gpio -- )
    pop {r1}
    pop {r0}
    lsl r0, r0, #2
    add r0, r0, r1
    pop {r1}
    strb r1, [r0]
    NEXT

    defcode "NVIC", 4, , _NVIC
    ldr r0, =NVIC
    push {r0}
    NEXT

    defcode "NVIC-SETENA", 11, , NVIC_SETENA
    ldr r0, =NVIC
    ldr r1, =NVIC_SETENA_BASE
    add r0, r1, r0
    push {r0}
    NEXT

    .ltorg

    defcode "WFI", 3, , WFI
    wfi
    NEXT

    defcode "RETI", 4, , RETI
    pop {r4 - r12, pc}

    defword ";I", 2, F_IMMED, SEMICOLONI
    .word LIT, RETI, COMMA, REVEAL, LBRACKET, EXIT

    defword "COLD", 4, , COLD
    .word LIT, 16, BASE, STORE
    .word LIT, words, EVALUATE
    .word QUIT

words:
    .ascii "
: button0-irq   10 gpioc gpio-icr c! FF pad ! ;i
: button0-enable   nvic-setena dup c@ 4 or swap c! ['] button0-irq ivt 11 cells + ! 10 gpioc gpio-im c! ;
"
    .byte 0
    .align 2, 0

    defvar "SBUF", 4, , SBUF, 128
    defvar "SBUF-HEAD", 9, , SBUF_HEAD
    defvar "SBUF-TAIL", 9, , SBUF_TAIL
    defvar "IVT", 3, , IVT, 48 * 4

    /* Onboard button words */
    /*
        : button0-irq   10 gpioc gpio-icr c! FF pad ! ;i
        : button0-enable   nvic-setena dup c@ 4 or swap c! ['] button0-irq ivt 11 cells + ! 10 gpioc gpio-im c! ;
    */

    .set last_word, link
    .set data_start, compiled_here 


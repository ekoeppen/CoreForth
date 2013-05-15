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
    .long svc_handler + 1             /* SVCall Handler               */
    .long debugmon_handler + 1        /* Debug Monitor Handler        */
    .long 0                           /* Reserved                     */
    .long pendsv_handler + 1          /* PendSV Handler               */
    .long systick_handler + 1         /* SysTick Handler              */
    .long wwdg_handler + 1
    .long pvd_handler + 1
    .long tamper_handler + 1
    .long rtc_handler + 1
    .long flash_handler + 1
    .long rcc_handler + 1
    .long exti0_handler + 1
    .long exti1_handler + 1
    .long exti2_handler + 1
    .long exti3_handler + 1
    .long exti4_handler + 1
    .long dma1_channel1_handler + 1
    .long dma1_channel2_handler + 1
    .long dma1_channel3_handler + 1
    .long dma1_channel4_handler + 1
    .long dma1_channel5_handler + 1
    .long dma1_channel6_handler + 1
    .long dma1_channel7_handler + 1
    .long adc1_2_handler + 1
    .long usb_hp_can_tx_handler + 1
    .long usb_lp_can_rx_handler + 1
    .long can_rx1_handler + 1
    .long can_sce_handler + 1
    .long exti9_5_handler + 1
    .long tim1_brk_handler + 1
    .long tim1_up_handler + 1
    .long tim1_trg_com_handler + 1
    .long tim1_cc_handler + 1
    .long tim2_handler + 1
    .long tim3_handler + 1
    .long tim4_handler + 1
    .long i2c1_ev_handler + 1
    .long i2c1_er_handler + 1
    .long i2c2_ev_handler + 1
    .long i2c2_er_handler + 1
    .long spi1_handler + 1
    .long spi2_handler + 1
    .long usart1_handler + 1
    .long usart2_handler + 1
    .long usart3_handler + 1
    .long exti15_10_handler + 1
    .long rtcalarm_handler + 1
    .long usbwakeup_handler + 1
    .long tim8_brk_handler + 1
    .long tim8_up_handler + 1
    .long tim8_trg_com_handler + 1
    .long tim8_cc_handler + 1
    .long adc3_handler + 1
    .long fsmc_handler + 1
    .long sdio_handler + 1
    .long tim5_handler + 1
    .long spi3_handler + 1
    .long uart4_handler + 1
    .long uart5_handler + 1
    .long tim6_handler + 1
    .long tim7_handler + 1
    .long dma2_channel1_handler + 1
    .long dma2_channel2_handler + 1
    .long dma2_channel3_handler + 1
    .long dma2_channel4_5_handler + 1
end_of_irq:

    .org 0x150

@ ---------------------------------------------------------------------
@ -- Board specific code and initialization ---------------------------

init_board:
    @ clear RAM
    ldr r0, =0x20000000
    ldr r1, =(0x5000 / 4)
    movs r2, #0
1:  str r2, [r0], #4
    subs r1, #1
    bgt 1b

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
    movs r1, #0
    movs r2, #(end_of_irq - _start) / 4
1:  str r1, [r0], #4
    subs r2, r2, #1
    bgt 1b

    @ enable PIC interrupts
    movs r0, #0
    msr primask, r0
    movs r0, #0
    msr basepri, r0
    ldr r0, =(NVIC + NVIC_SETENA_BASE)
    movs r1, #0
    str r1, [r0]

    @ enable clocks
    ldr r0, =RCC

    @ SPI2 PWR BKP WWD USB I2C2 I2C1 USART USART TIM4 TIM3 TIM2
    ldr r1, =0x18e64807
    str r1, [r0, #RCC_APB1ENR]

    @ ADC3 SPI1 TIM1 ADC2 ADC1 IOPE IOPD IOPC IOPB IOPA AFIO TIM1
    ldr r1, =0x00005e7d
    str r1, [r0, #RCC_APB2ENR]


    @ enable pins on GPIOA
    ldr r0, =GPIOA
    ldr r1, =0x444444b4
    str r1, [r0, #GPIO_CRH]

    @ enable UART
    ldr r0, =(NVIC + NVIC_SETENA_BASE)
    movs r1, #0x20
    str r1, [r0, #4]
    ldr r0, =UART1
    ldr r1, =0x206c
    str r1, [r0, #UART_CR1]

    @ set UART baud rate
    ldr r1, =(72000000 / 115200)
    str r1, [r0, #UART_BRR]

    @ enable SYSTICK
    ldr r0, =STRELOAD
    ldr r1, =0x00ffffff
    str r1, [r0]
    ldr r0, =STCTRL
    movs r1, #5
    str r1, [r0]

    @ unlock flash controller
    ldr r0, =FPEC
    ldr r1, =0x45670123
    str r1, [r0, #FLASH_KEYR]
    ldr r1, =0xcdef89ab
    str r1, [r0, #FLASH_KEYR]

    @ reset console buffers
    movs r1, #0
    ldr r2, =addr_CON_RX_TAIL
    str r1, [r2]
    ldr r2, =addr_CON_RX_HEAD
    str r1, [r2]
    ldr r2, =addr_CON_TX_TAIL
    str r1, [r2]
    ldr r2, =addr_CON_TX_HEAD
    str r1, [r2]

    pop {pc}
    .ltorg

readkey_polled:
    push {r1, r2}
    ldr r1, =UART1
1:  ldr r2, [r1, #UART_SR]
    ands r2, #32
    beq 1b
    ldrb r0, [r1, #UART_DR]
    pop {r1, r2}
    bx lr

putchar_polled:
    push {r1, r2}
    ldr r1, =UART1
1:  ldr r2, [r1, #UART_SR]
    ands r2, #0x80
    beq 1b
    str r0, [r1, #UART_DR]
    pop {r1, r2}
    bx lr

readkey:
readkey_int:
    push {r1, r2, r3, lr}
    ldr r1, =addr_CON_RX_TAIL
    ldr r3, [r1]
2:  ldr r2, =addr_CON_RX_HEAD
    ldr r2, [r2]
    cmp r2, r3
    bne 1f
    wfi
    b 2b
1:  ldr r0, =addr_CON_RX
    ldrb r0, [r0, r3]
    adds r3, #1
    ands r3, #0x3f
    str r3, [r1]
    pop {r1, r2, r3, pc}

putchar:
putchar_int:
    push {r1, r2, r3, lr}
    ldr r1, =addr_CON_TX_HEAD
    ldr r2, [r1]
    ldr r3, =addr_CON_TX_TAIL
    ldr r3, [r3]
    cmp r2, r3
    bne 3f
    bl putchar_polled
    b 4f
3:  adds r2, #1
    ands r2, #3f
    str r2, [r1]
2:  ldr r3, =addr_CON_TX_TAIL
    ldr r3, [r3]
    cmp r2, r3
    bne 1f
    wfi
    b 2b
1:  ldr r3, =addr_CON_TX
    strb r0, [r3, r2]
4:  pop {r1, r2, r3, pc}

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
    adds r7, #4
    ldr r1, [r0]
    adds r1, #1
    bx r1
1:  bx lr

nmi_handler:
    b .

hardfault_handler:
    tst lr, #4
    ite eq
    mrseq r0, msp
    mrsne r0, psp
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

usart1_handler:
    ldr r1, =(UART1 + UART_SR)
    ldr r1, [r1]
    tst r1, #0x20
    beq 1f
    ldr r0, =addr_CON_RX
    ldr r1, =addr_CON_RX_HEAD
    ldr r2, [r1]
    ldr r3, =(UART1 + UART_DR)
    ldrb r3, [r3]
    strb r3, [r0, r2]
    adds r2, #1
    ands r2, #0x3f
    str r2, [r1]
1:  ldr r1, =(UART1 + UART_SR)
    ldr r1, [r1]
    tst r1, #0x60
    beq 2f
    ldr r1, =addr_CON_TX_HEAD
    ldr r1, [r1]
    ldr r2, =addr_CON_TX_TAIL
    ldr r3, [r2]
    cmp r1, r3
    beq 2f
    ldr r0, =addr_CON_TX
    ldrb r1, [r0, r3]
    ldr r0, =(UART1 + UART_DR)
    strb r1, [r0]
    adds r3, #1
    ands r3, #0x3f
    str r3, [r2]
2:  movs r0, #0
    ldr r1, =(UART1 + UART_SR)
    str r0, [r1]
    bx lr
    .align 2,0

systick_handler:
adc1_2_handler:
adc3_handler:
can_rx1_handler:
can_sce_handler:
dma1_channel1_handler:
dma1_channel2_handler:
dma1_channel3_handler:
dma1_channel4_handler:
dma1_channel5_handler:
dma1_channel6_handler:
dma1_channel7_handler:
dma2_channel1_handler:
dma2_channel2_handler:
dma2_channel3_handler:
dma2_channel4_5_handler:
exti0_handler:
exti15_10_handler:
exti1_handler:
exti2_handler:
exti3_handler:
exti4_handler:
exti9_5_handler:
flash_handler:
fsmc_handler:
i2c1_er_handler:
i2c1_ev_handler:
i2c2_er_handler:
i2c2_ev_handler:
pvd_handler:
rcc_handler:
rtc_handler:
rtcalarm_handler:
sdio_handler:
spi1_handler:
spi2_handler:
spi3_handler:
tamper_handler:
tim1_brk_handler:
tim1_cc_handler:
tim1_trg_com_handler:
tim1_up_handler:
tim2_handler:
tim3_handler:
tim4_handler:
tim5_handler:
tim6_handler:
tim7_handler:
tim8_brk_handler:
tim8_cc_handler:
tim8_trg_com_handler:
tim8_up_handler:
uart4_handler:
uart5_handler:
usart2_handler:
usart3_handler:
usb_hp_can_tx_handler:
usb_lp_can_rx_handler:
usbwakeup_handler:
wwdg_handler:
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

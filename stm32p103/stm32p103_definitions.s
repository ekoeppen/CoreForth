    .set UART1,         0x40013800
    .set UART2,         0x40004400
    .set UART3,         0x40004800
    .set UART_SR,             0x00
    .set UART_DR,             0x04
    .set UART_BRR,            0x08
    .set UART_CR1,            0x0c
    .set UART_CR2,            0x10
    .set UART_CR3,            0x14
    .set UART_GPTR,           0x18

    .set RCC,           0x40021000
    .set RCC_CR,              0x00
    .set RCC_CFGR,            0x04
    .set RCC_CIR,             0x08
    .set RCC_APB2RSTR,        0x0c
    .set RCC_APB1RSTR,        0x10
    .set RCC_AHBENR,          0x14
    .set RCC_APB2ENR,         0x18
    .set RCC_APB1ENR,         0x1c
    .set RCC_BDCR,            0x20
    .set RCC_CSR,             0x24
    .set RCC_AHBRSTR,         0x28
    .set RCC_CFGR2,           0x2c

    .set NVIC,          0xe000e000
    .set NVIC_SETENA_BASE,   0x100
    .set NVIC_ACTIVE_BASE,   0x300

    .set GPIOA,         0x40010800
    .set GPIOB,         0x40010c00
    .set GPIOC,         0x40011000
    .set GPIOD,         0x40011400
    .set GPIOE,         0x40011800
    .set GPIOF,         0x40011c00
    .set GPIOG,         0x40012000
    .set GPIO_CRL,           0x000
    .set GPIO_CRH,           0x004
    .set GPIO_IDR,           0x008
    .set GPIO_ODR,           0x00c
    .set GPIO_BSRR,          0x010
    .set GPIO_BRR,           0x014
    .set GPIO_LCKR,          0x018

    .set STCTRL,        0xe000e010
    .set STRELOAD,      0xe000e014
    .set STCURRENT,     0xe000e018

    .set FPEC,          0x40022000
    .set FLASH_ACR,           0x00
    .set FLASH_KEYR,          0x04
    .set FLASH_OPTKEYR,       0x08
    .set FLASH_SR,            0x0C
    .set FLASH_CR,            0x10
    .set FLASH_AR,            0x14
    .set FLASH_OBR,           0x1C
    .set FLASH_WRPR,          0x20

    .set CPUID,         0xe000ed00
    .set EMULATOR_UART, 0xe0000000

Overview
========

This is a simple Forth for the ARM Cortex M3. It can currently run on the [Stellaris LM3S811 evaluation
kit](http://www.ti.com/tool/ek-lm3s811), the Arduino Due, the Olimex STM32-P103 and the Olimexino STM32/LeafLabs Maple or qemu. Other targets like STM32 based boards should be easy to add.

CoreForth started based on [JonesForth](http://rwmj.wordpress.com/2010/08/07/jonesforth-git-repository/), but evolved to be closer
to Forth-79. Some words and ideas were taken also directly from [CamelForth](http://www.camelforth.com/) and the [excellent article
series](http://www.bradrodriguez.com/papers/moving1.htm) by CamelForth's author Brad Rodriguez.

The motivation behind CoreForth is to provide a simple platform to explore Cortex M3 based development boards, not so much to be a
fully fledged Forth implementation (neither is ANS Forth compliance a goal), but there is nothing preventing CoreForth to be taken
into that direction.

Forth Implementation
====================

CoreForth is an indirect threaded Forth. Register r7 is holding the instruction pointer, register r6 is the return stack pointer,
and the parameter stack is handled via register sp (r13).

Four macros are used to define words within the assembler source:

* defcode: Define a word implemented in assembler. The code field pointer points to the words' body.
* defword: Define a word implemented in indirected threaded code, each cell contains the code field pointer of the word to invoke.
  The code field pointer points to the DOCOL function
* defvar: Define a variable, the space is allocated at HERE from RAM.
* defconst: Define a constant

Board Dependent Code
====================

The CoreForth source is split into two parts. The actual Forth implementation in CoreForth.s, and the board dependent code in e.g.
lm3s811.s. The board dependent code uses .include to bring in the Forth kernel, this is neccessary in order to be able to add new
words to the board code due to the way the words are defined using macros.

The code to initialize the LM3S811 (and similar chips) covers three main areas:

* Interrupt handling: The board specific code starts with the interrupt vectors and default handlers.
* Board initialization: The reset\_handler function in CoreForth.s calls the init\_board function which sets up the system clocks,
  enables the peripherals and needed interrupts.
* Core input/output functions: CoreForth expects the two functions putchar and read\_key to be defined. Currently, a simple
  blocking implementation is used for running on hardware, and an interrupt based implemenation for qemu (this should be the default
later on). 

Building and Running
====================

CoreForth is written in GNU Assembler, and the easiest way of compiling and running is to use the bare metal CodeSourcery tool
chain and qemu-system-arm. The Makefile will generate ELF and binary files, the latter can be flashed using e.g. OpenOCD, the former
can be run in qemu. A good overview of bare metal programming and qemu can be found on [Franceso Balduzzi's
blog](http://balau82.wordpress.com/2010/02/14/simplest-bare-metal-program-for-arm/), and using OpenOCD with hardware is explained in
more detail on [Johan Simonsson's pages](http://fun-tech.se/stm32/index.php).

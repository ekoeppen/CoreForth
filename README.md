Overview
========

This is a simple Forth for the ARM Cortex M0/M3. It can currently run on the
the Olimex STM32-P103 and the Olimexino STM32/LeafLabs Maple and supports
generic STM32F103 and STM32F030 boards. Other targets boards should be easy to
add. CoreForth consists of a small core written in ARM assembler, and
additional Forth words which are compiled on the host for the target using a
slightly modified version of
[thumbulator](https://github.com/ekoeppen/thumbulator).

CoreForth started based on
[JonesForth](http://rwmj.wordpress.com/2010/08/07/jonesforth-git-repository/),
but evolved to be closer to Forth-79. Some words and ideas were taken also
directly from [CamelForth](http://www.camelforth.com/) and the [excellent
article series](http://www.bradrodriguez.com/papers/moving1.htm) by
CamelForth's author Brad Rodriguez.

The motivation behind CoreForth is to provide a simple platform to explore
Cortex M0/3 based development boards, not so much to be a fully fledged Forth
implementation (neither is ANS Forth compliance a goal), but there is nothing
preventing CoreForth to be taken into that direction.

Forth Implementation
====================

CoreForth is an indirect threaded Forth. Register r7 is holding the instruction
pointer, register r6 is the return stack pointer, and the parameter stack is
handled via register sp (r13).

Four macros are used to define words within the assembler source:

* defcode: Define a word implemented in assembler. The code field pointer
  points to the words' body.
* defword: Define a word implemented in indirected threaded code, each cell
  contains the code field pointer of the word to invoke.  The code field
  pointer points to the DOCOL function
* defvar: Define a variable, the space is allocated at HERE from RAM.
* defconst: Define a constant

Board Dependent Code
====================

The CoreForth source is split into two parts. The actual Forth implementation
under generic in CoreForth.s and a number of Forth source files, and the board
dependent code under e.g. olimexino-stm32. The board dependent code uses
.include to bring in the Forth kernel, this is neccessary in order to be able
to add new words to the board code due to the way the words are defined using
macros.

Building
========

CoreForth is written in GNU Assembler, and requires the [ARM GCC cross
compiler](https://launchpad.net/gcc-arm-embedded) as well as
[thumbulator](https://github.com/ekoeppen/thumbulator).  The Makefile will
generate ELF and binary files, which can be flashed using e.g. OpenOCD. A good
overview of bare metal programming and qemu can be found on [Franceso
Balduzzi's
blog](http://balau82.wordpress.com/2010/02/14/simplest-bare-metal-program-for-arm/),
and using OpenOCD with hardware is explained in more detail on [Johan
Simonsson's pages](http://fun-tech.se/stm32/index.php).

CoreForth makes use of Forth words for the non-core functionality. The Forth
sources are compiled into binary form using thumbulator as a runtime
environment. The compiled assembler code and Forth sources are loaded into the
thumbulator memory. The Forth core executes the Forth sources, building the
target dictionary in memory as it processes the input data. At the end of the
compilation, the Forth core will dump itself plus the compiled dictionary into
one binary. For that purpose, thumbulator supports semihosting, including
console output.

This target compilation step is automated, adding new Forth sources for target
compilation is as simple as adding them as parameters to the thumbulator
invocation in the Makefile.

Previous Versions
=================

The branch "1.0" contains the previous, qemu based version of CoreForth. That
branch is not actively maintained anymore, but can serve as an example for an
alternative cross compilation approach.

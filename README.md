# Cellular Automaton Processor

The Cellular Automaton Processor is an experimental application-specific processor designed for solving problems that can be modelled as cellular automata. It consists of a large number of cores that can only interact with their immediate neighbors. The capabilities of individual cores are limited to simple math and logic operations. Each core can only access its own registers and the shared registers of the neighbouring cores. Even though cellular automata can be Turing-complete, the processor is not intended to be used for general purpose computation. It is suitable for numerical solution of partial differential equations and various cellular automaton based programs.

## Instruction Format (16 Bits)

R-type 4 Bit Opcode; 4 Bit Target; 4 Bit First Source; 4 Bit Second Source
I-type 4 Bit Opcode; 4 Bit Target; 8 Bit Immediate
J-type 4 Bit Opcode; 12 Bit Address

## Registers (Represented in 4 Bits)

0 my
1 r1
2 r2
3 r3
4 r4
5 r5
6 r6
7 r7
8 r8

9 zero
10 x
11 y
12 x-
13 x+
14 y-
15 y+


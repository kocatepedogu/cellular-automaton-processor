# Cellular Automaton Processor

The Cellular Automaton Processor is an experimental application-specific processor designed for solving problems that can be modelled as cellular automata. It consists of a large number of cores that can only interact with their immediate neighbors. The capabilities of individual cores are limited to simple math and logic operations. Each core can only access its own registers and the shared registers of the neighbouring cores. Even though cellular automata can be Turing-complete, the processor is not intended to be used for general purpose computation. It is suitable for numerical solution of partial differential equations and various cellular automaton based programs.

## Examples

<img src="./examples/wave-equation.png" width="300px"><br>
Two-dimensional wave equation solution in Verilator. The simulation starts with two close wave sources that produce interfering waves.

<img src="./examples/heat-equation.png" width="300px"><br>
Two-dimensional heat equation solution. Initially, there was a circle with high temperature surrounded by a very cold environment. The screenshot was taken a few seconds after the beginning.</p>

<img src="./examples/game-of-life.png" width="300px"><br>
Glider pattern in Conway's Game of Life. The space is a toroidal array, so the pattern repeats itself forever.

The above screenshots are taken from Verilator simulations. Assembly language sources can be found in examples directory. C++ and Verilog sources for the Verilator are available under targets/verilator. The total number of cores in the simulations are 25x25=625. Register lengths need to be at least 32 bits for the PDE examples to run, but the Game of Life example can run even with 4 bits, which can also tested on Basys3 FPGA board with F4PGA/Symbiflow toolchain.

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


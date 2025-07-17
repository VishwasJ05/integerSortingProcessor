
This project implements a simple RISC-V-based processor using Verilog, designed primarily for educational purposes and demonstration of low-level algorithm execution. The processor supports a basic subset of RISC-V instructions and can simulate programs like sorting algorithms directly in machine code. Key modules include the program counter, instruction memory (IMEM), data memory (DRAM), register file, ALU, sign extender, and a control decoder, all integrated within a custom datapath.

The processor has been tested with the following programs, written in RISC-V machine code:

1.  **Insertion Sort**
2.  **Bubble Sort**

3.  **Maximum Element Finder**
4.  **Loop Counter**

The instruction set includes R-type (`add`, `sub`), I-type (`addi`, `lw`), S-type (`sw`), B-type (`beq`, `blt`, `bge`), and J-type (`jal`). Functional highlights include register updates, ALU operations, memory accesses, and branching logic. These can be tracked cycle-by-cycle using the provided testbench.

This project provides a solid foundation for understanding processor internals and RISC-V instruction behavior. It is ideal for beginners who want to explore how sorting logic can be executed at the hardware level. Future improvements include adding pipeline support, extending the instruction set, integrating waveform viewers like GTKWave, and improving performance analysis tools. Contributions and experimentation are encouraged! 

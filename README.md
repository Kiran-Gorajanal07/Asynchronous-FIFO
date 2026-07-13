# Asynchronous FIFO Design and Verification

## Overview

This project implements an **Asynchronous FIFO (First-In, First-Out)** using Verilog/SystemVerilog. The FIFO enables reliable data transfer between two independent clock domains using Gray code pointer synchronization to minimize metastability issues.

The project includes both the RTL implementation and a self-checking testbench for functional verification.

---

## Features

- Dual clock asynchronous FIFO
- Independent read and write clocks
- Gray code pointer synchronization
- Two-stage synchronizers for clock domain crossing
- FIFO Full and Empty flag generation
- Parameterized design
- SystemVerilog testbench
- Functional simulation in Vivado

---

## Project Structure

```
Asynchronous-FIFO
│
├── rtl
│   ├── asynchronous_fifo.sv
│   ├── fifo_mem.sv
│   ├── synchronizer.v
│   ├── rptr_handler.v
│   └── wptr_handler.sv
│
├── tb
│   └── async_fifo_tb.sv
│
├── .gitignore
└── README.md
```

---

## RTL Modules

| Module | Description |
|---------|-------------|
| asynchronous_fifo.sv | Top-level FIFO module |
| fifo_mem.sv | FIFO memory implementation |
| synchronizer.v | Two-stage synchronizer for clock domain crossing |
| rptr_handler.v | Read pointer and Empty flag logic |
| wptr_handler.sv | Write pointer and Full flag logic |

---

## Simulation

### Tool

- AMD Vivado 2024.1

### Run Simulation

1. Open Vivado.
2. Create a project.
3. Add RTL files from the **rtl** directory.
4. Add the testbench from the **tb** directory.
5. Set `async_fifo_tb.sv` as the top simulation module.
6. Run **Behavioral Simulation**.

---

## Verification

The testbench verifies:

- FIFO Write Operation
- FIFO Read Operation
- FIFO Empty Condition
- FIFO Full Condition
- Simultaneous Read/Write
- Different Read and Write Clock Frequencies
- Reset Functionality

---

## Design Flow

```
Write Clock Domain
        │
        ▼
Write Pointer
        │
Gray Code Conversion
        │
Synchronizer
        │
Read Clock Domain
```

Similarly,

```
Read Pointer
        │
Gray Code Conversion
        │
Synchronizer
        │
Write Clock Domain
```

---

## Applications

- Network-on-Chip (NoC)
- DMA Controllers
- UART
- SPI
- AXI Clock Domain Crossing
- High-Speed Digital Systems

---

## Future Improvements

- Parameterized FIFO depth and data width
- UVM-based verification environment
- Functional coverage
- Assertions (SVA)
- FPGA implementation
- Synthesis and timing analysis

---

## Author

**Kiran Gorajanal**

Electronics and Communication Engineering

Interested in RTL Design, FPGA Design, Digital Design and Verification.

---

## License

This project is intended for learning and educational purposes.

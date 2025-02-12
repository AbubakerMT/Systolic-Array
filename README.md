# 🖥️ Systolic Array Matrix Multiplication on DE1-SoC

This project implements a **systolic array matrix multiplication** algorithm on the **DE1-SoC board**. The goal was to handle matrix multiplication for matrices up to **10x10 dimensions** with efficient hardware implementation using **Verilog**. The project explores the transition from a high-level Python algorithm to a low-level hardware design, simulating and testing with tools like **iVerilog** and **ModelSim**.

## 🛠️ Features
- 🔄 **Systolic Array Architecture:** Efficient matrix multiplication using parallel processing.
- ⚙️ **Python to Verilog Transition:** Initial algorithm developed in Python, then translated to Verilog for hardware.
- 📊 **Matrix Sizes:** Handles matrix multiplication for matrices of sizes up to 10x10.
- 🧑‍💻 **Simulation & Testing:** Verified functionality using iVerilog and ModelSim with instructor-provided test cases.

## 🎨 Design & Implementation
- **Datapath & Control Unit Design:** Developed and optimized datapath components such as registers and adders.
- **Algorithmic State Machine (ASM):** Designed state transitions for efficient hardware control.
- **Resource Constraints:** Optimized for FPGA's memory limitations, restricting matrix size to 10x10.

## 🔄 Simulation & Testing
### ✅ **Initial Python Tests**
- **Matrix Multiplication Algorithm**: Verified correctness in Python before transitioning to Verilog.
  
### 🎉 **Verilog Simulation**
- **Matrix Multiplication**: Tests were successful, confirming the correct functionality of the matrix multiplication algorithm in hardware.
- **Test Cases**: Ran test cases provided by the instructor to validate the functionality of the design.

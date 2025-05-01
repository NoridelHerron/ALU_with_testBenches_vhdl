# ALU's

## ALU_8bits
A beginner-friendly 8-bit ALU written in VHDL. This module was used as a foundation for learning how to build and test ALU functionality using arithmetic and logic operations.
---

## ALU_32bits
An extended 32-bit ALU designed for integration into a 5-stage pipelined RISC-V CPU. This version builds on the 8-bit implementation and introduces scalable logic for real CPU datapath usage, complete with a randomized self-checking testbench.
---

## Supported Operations for ALU_32bits

| Operation | f3 code | f7 code      | Description                 |
|----------:|:--------|:-------------|-----------------------------|
| ADD       | `000`   | `000000`     | Signed addition             |
| SUB       | `000`   | `100000`     | Signed subtraction          |
| SLL       | `001`   | `000000`     | Shift Logical Left          |
| SLT       | `010`   | `000000`     | Set if less than (signed)   |
| SLTU      | `011`   | `000000`     | Set if less than (unsigned) |
| XOR       | `100`   | `000000`     | Bitwise XOR                 |
| SRL       | `101`   | `000000`     | Shift Right Logical         |
| SRA       | `101`   | `100000`     | Shift Right Arithmetic      |
| OR        | `110`   | `000000`     | Bitwise OR                  |
| AND       | `111`   | `000000`     | Bitwise AND                 |

## Project Structure
ALU_with_testBenches_vhdl/
├── ALU_8bits
    ├── images/
    │   ├── ALU_TCL.png
    │   ├── ALU_WAVE.png
    ├── src/
    │   ├── adder_8bits.vhd
    │   ├── ALU_8bits.vhd
    │   ├── FullAdder.vhd
    │   ├── FullSubtractor.vhd
    │   ├── sub_8bits.vhd
    ├── test_benches/
    │   ├── adder_subtractor/
    │   │   ├── tb_adder_8bits.vhd
    │   │   ├── tb_sub_8bits.vhd
    │   ├── ALU_manually/
    │   │   ├── tb_ALU.vhd
    │   │   ├── tb_ALU_ext.vhd
    │   │   ├── tb_ALU_v2.vhd
    │   ├── ALU_random/
    │       ├── tb_ALU_rand.vhd
    │       ├── tb_ALU_random.vhd
├── ALU_32bits
    ├── images/
    |   ├── passed100_test.png
    |   ├── passed5000_test.png
    |   ├── wave_32bits.png
    ├── src/
    │   ├── adder_32bits.vhd
    │   ├── ALU_32bits.vhd
    │   ├── FullAdder.vhd
    │   ├── FullSubtractor.vhd
    │   ├── sub_32bits.vhd
    ├── test_bench/
    |   ├── tb_ALU_rand.vhd
├── .gitignore/
├── README.md/
---

## Testbench Strategy
Multiple testing approaches were used to validate the ALU:
- **Unit testbenches**: Verified individual operations (e.g., ADD, SUB, SLL) with fixed input vectors and edge cases
- **Randomized testing**: Generated 5000+ randomized test cases across all operations using `uniform()` and golden reference models
- **Self-checking logic**: Expected results and flags are calculated internally and compared per test
- **Per-operation counters**: Failures are tracked by operation to help isolate bugs and validate coverage

## Key Learnings
- Gained experience handling both signed and unsigned arithmetic in VHDL
- Learned the importance of timing differences between `signal` and `variable`
- Built confidence in writing randomized self-checking testbenches
- Used `math_real.uniform()` to generate high-coverage input distributions
- Implemented per-operation pass/fail tracking for targeted debugging
- Discovered that certain edge case failures were caused by rounding errors in floating-point to integer conversion
- Learned how to scale and adjust an existing 8-bit ALU design into a 32-bit version to support my main goal: building a 5-stage pipelined RISC-V processor

## Simulation Results
### Tcl Console Output
This shows the final test summary from the randomized testbench 

**5000/5000** randomized test cases passed for the ALU_8bits:
![Tcl Output](ALU_8bits/images/ALU_TCL.png)

**5000/5000**  randomized test cases passed for the ALU_32bits:
![Tcl Output](ALU_32bits/images/passed5000_test.png)

**100/100** randomized test cases passed for the ALU_32bits:
![Tcl Output](ALU_32bits/images/passed100_test.png)

### Waveform Example
Captured waveform for a successful OR operation showing `result`, control signals, and flags:

For the ALU_8bits:
![Waveform](ALU_8bits/images/ALU_WAVE.png)

For the ALU_32bits:
![Waveform](ALU_32bits/images/wave_32bits.png)


## How to Run

1. Launch **Vivado 2024.2**
2. Open the project or create a new one and add the files from either ALU_8bits or ALU_32bits.
3. Set the any of the test bench of your choice as the top simulation unit
4. Go to **Flow → Run Simulation → Run Behavioral Simulation** or 
    in the **project manager, you can directly click the run simulation -> Run Behavioral Simulation**.
    **Note:** For the randomized testing, the simulation runtime need to be adjusted based on the number of tests.
    Click the in the project manager, click the **Simulation -> simulation settings** then, in the lower right,
    there are COMPILATION | ELABORATION | SIMULATION | and so on, click the **Simulation -> xsim.simulate.runtime** modify the value.
5. Open the **Waveform Viewer** to inspect signal transitions and flags
6. View the test results in the **Tcl Console**

## Author

**Noridel Herron** (@MIZZOU)  
Senior in Computer Engineering  
noridel.herron@gmail.com

## Disclaimer

This project is developed solely for educational and personal learning purposes.  
It may contain unfinished or experimental features and is not intended for commercial or production use.

## MIT License

Copyright (c) 2025 Noridel Herron

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

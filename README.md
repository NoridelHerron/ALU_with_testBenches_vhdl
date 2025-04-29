# ALU_with_testBenches_vhdl
A VHDL-based 8-bit ALU supporting RISC-V-style operations including arithmetic, logic, and shift instructions. Includes a randomized, self-checking testbench that verifies ALU correctness over 5000+ test cases using a golden model. Signals are validated per cycle, and pass/fail counters are maintained per operation. Tool: Vivado
---

## 🔧 Supported Operations

| Operation | f3 code | f7 code     | Description                 |
|----------:|:--------|:------------|-----------------------------|
| ADD       | `000`   | `00000`     | Signed addition             |
| SUB       | `000`   | `10100`     | Signed subtraction          |
| SLL       | `001`   | `00000`     | Shift Logical Left          |
| SLT       | `010`   | `00000`     | Set if less than (signed)   |
| SLTU      | `011`   | `00000`     | Set if less than (unsigned) |
| XOR       | `100`   | `00000`     | Bitwise XOR                 |
| SRL       | `101`   | `00000`     | Shift Right Logical         |
| SRA       | `101`   | `10100`     | Shift Right Arithmetic      |
| OR        | `110`   | `00000`     | Bitwise OR                  |
| AND       | `111`   | `00000`     | Bitwise AND                 |

## 📂 Project Structure

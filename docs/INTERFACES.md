# Course interface contract

These are the public interfaces, not implementation solutions. Keep module/port/type names unchanged so the tests can instantiate your work. Compile as SystemVerilog (`.sv`). Read [the eight-week scope](../COURSE_MAP.md) first.

## Clock, memory and observability

State changes on the rising edge; CPU/PC/register-file reset is synchronous and has priority over enable/write. Testbenches change inputs away from that edge and sample after nonblocking updates. `timeunit 1ns; timeprecision 1ps;` belongs in modules/packages.

Separate instruction and data memories provide asynchronous combinational reads; data stores occur on a rising edge. There is no ready/valid wait-state protocol. This is a small distributed-memory teaching model, not a claim that FPGA block RAM has zero-cycle reads. Moving to synchronous block RAM requires changing the pipeline and tests.

| Module | Inputs / role | Outputs / contract |
|---|---|---|
| `alu` | 32-bit `a,b`; 4-bit `op` | 32-bit `result`; defaults to zero for invalid op |
| `pc` | `clk,reset,enable,next_pc` | `value`: reset 0, otherwise capture only when enabled |
| `imem` | 32-bit byte `address`; parameter `IMAGE` | `instruction,access_fault,misaligned`; 256 words named `words` |
| `regfile` | `clk,reset,write_en`; 5-bit `ra,rb,rd`; `write_data`; parameter `BYPASS` | `a,b,debug_regs[0:31]`; x0 always 0; all registers reset 0 |
| `decode` | 32-bit `instr` | `rv32_pkg::decoded_t decoded` |
| `execute_stage` | `decoded,pc,a,b` | `rv32_pkg::exec_result_t result` |
| `forwarding` | used/source/captured plus EX/MEM and MEM/WB writer metadata | `value`; newest matching writer wins; never forward a load's address |
| `hazard` | ID valid/source-use bits and ID/EX load destination | `load_use`; only a real used nonzero source match stalls |
| `cpu_single / cpu_pipeline` | Clock/reset; instruction/data responses | Requests, retirement events, halt/debug outputs below |
| `teaching_memory` | Requests, clk/reset, switches; `IMEM_FILE` | Responses, faults, LEDs; arrays `imem[0:255],dmem[0:255]` used by harness |
| `basys3_top` | `clk,btnC,sw[15:0]` (100 MHz board clock) | `led[15:0]`; `PIPELINED=1` selects final CPU |

ALU op numbers: 0 ADD, 1 SUB, 2 AND, 3 OR, 4 XOR, 5 signed SLT, 6 unsigned SLTU, 7 SLL, 8 SRL, 9 SRA. Shift by `b[4:0]`; comparison results are 0 or 1. Week 1 exercises all ALU operations even though only a subset is needed for the minimum CPU.

With `BYPASS=1`, a same-cycle enabled nonzero write matching a read address is visible on that read before the edge (unless reset). With `BYPASS=0`, read stored state only. Writes still occur only at the edge. This makes WB→ID timing explicit, not dependent on simulation scheduling.

## Decode and execution types

`rtl/common/rv32_pkg.sv` supplies **types/constants only**. A learner must still implement the decoder and datapaths.

- `decoded_t`: legal/unsupported status; uses_rs1/uses_rs2; reg_write/mem_read/mem_write/branch; jal/jalr/lui/auipc/alu_imm; rs1/rs2/rd; funct3; sign-extended imm; alu_op. An unused source must not create a false dependency.
- `exec_result_t`: value (register/ALU/link result), addr (byte address), store_data (unshifted source value), next_pc, redirect, fault.
- Normal next PC is PC+4; taken branch/JAL targets add their immediate to the instruction's PC. JALR clears target bit 0 and still checks 4-byte alignment. Links use PC+4, including when rd equals rs1. LUI uses its U-immediate; AUIPC adds it to the instruction's PC.

Required 14 instructions: ADD, SUB, AND, OR, XOR, SLT, ADDI, LW, SW, BEQ, JAL, JALR, LUI, AUIPC. NOP is ADDI x0,x0,0. No M/A/C, CSRs, interrupts, privileged traps or OS support is required. Full 37-operation integer support and byte/halfword lanes are an optional extension; the teacher reference implements them.

## CPU memory ports

`imem_addr` is a byte address. `imem_rdata` and `imem_fault[3:0]` are combinational responses.

Data request: `dmem_valid,dmem_write,dmem_funct3,dmem_addr,dmem_wdata`. A baseline LW/SW uses funct3=010 and a word-aligned byte address. Responses: `dmem_rdata,dmem_fault[3:0]`. A valid nonfaulting write is accepted exactly once on the edge. Do not gate the request with its returned fault and create a combinational loop; memory gates its **accepted write**. Suppress requests during reset, after halt, and for invalid/squashed work.

| Address | Meaning |
|---|---|
| Instruction bytes 0..0x3ff | 256 words; last legal aligned fetch 0x3fc |
| Data bytes 0..0x3ff | Separate 1 KiB RAM; full-address bounds check before index truncation |
| 0x10000000 | Word-only LED register: read zero-extended LEDs; write low 16 bits |
| 0x10000004 | Word-only read-only switches; stores fault |
| Anything else | Deterministic access fault; no aliasing |

RAM initializes to zero, but **CPU reset does not clear RAM**. Reset clears LED state, registers and pipeline valid bits. For week 2, `imem` initializes unused words to NOP and reads `IMAGE`; misaligned addresses report `misaligned` with zero instruction, aligned out-of-range addresses report `access_fault` with zero instruction.

## Retirement and safe stopping

`retire_valid` is a registered one-edge event for an instruction reaching architectural completion, in order. The single-cycle core emits it at its execution edge; the pipeline emits it from the current MEM/WB payload at the WB edge. Bubble/squash entries emit nothing.

Associated fields: `retire_pc,instr,next_pc`; `retire_rd_write,rd,rd_data`; `retire_mem_valid,mem_write,mem_funct3,mem_addr,mem_wdata,mem_rdata`; `retire_fault[3:0]`. Nonapplicable fields are zero. Memory trace data is unshifted store data / returned load value. Loads to x0 still access memory and may fault. Physical stores happen at MEM's edge, one cycle before their pipeline retirement; the checker separately verifies accepted store order so wrong-path side effects cannot hide behind final RAM equality.

The course terminates a test program with EBREAK (0x00100073), reported as unsupported fault 2. This is a **teaching stop protocol**, not an implemented architectural debugger/trap mechanism. Emit one terminal fault token with next_pc equal to its PC, no destination write, then assert `halted` and stay quiet until reset. Faulting memory attempts retain their attempted memory metadata in the trace, but faulting reads return trace data zero and cannot change state. All older work must complete, and faulting/younger instructions must not produce side effects.

Fault codes: 0 none; 1 illegal encoding; 2 unsupported instruction (including EBREAK/ECALL/FENCE); 3 instruction misalignment; 4 instruction access; 5 load misalignment; 6 load access; 7 store misalignment; 8 store access. Check alignment before bounds. Tests require these baseline outcomes; richer trap handling is outside scope.

## Five-stage contract

The final implementation has IF, ID, EX, MEM, WB and four **real state boundaries**, not renamed signals around a single-cycle core.

- `debug_stage_valid[0..3]` and `debug_stage_pc[0..3]` expose IF/ID, ID/EX, EX/MEM, MEM/WB respectively.
- From an empty pipeline, the first independent instruction retires on the fifth active edge. After fill, independent instructions retire one per edge.
- A load-use interlock holds PC/IF-ID, inserts an invalid ID/EX bubble, and allows older work to advance.
- EX resolves taken branches/jumps and invalidates younger IF/ID and ID/EX work. Store data and branch/JALR operands participate in dependency handling.
- Fault/halt/reset priority must prevent younger memory/MMIO effects, including when an older fault coincides with a younger redirect.
- `stall` and `redirect` expose the active decision before the edge. The public depth test plus functional regression checks both structure timing and architectural results.

The checked-in `tests/programs.json` contains public machine-code programs and expected traces/stores/final state, not a CPU implementation. Week 3 uses a supplied arithmetic-only memory fixture; later checkpoints compile your real memory module. See `tests/checkpoints.json` for the exact source list and gate cases.

# Eight-week course map

End goal: a working IF/ID/EX/MEM/WB pipeline. The single-cycle CPU is the halfway reference, not the endpoint. Plan two 90–120 minute sessions per week plus preparation; extend a week when its gate fails.

| Week | Build | Reading (Harris & Harris, RISC-V edition) | Gate |
|---|---|---|---|
| [1: Combinational RTL and a trustworthy testbench](labs/week01/README.md) | ALU + tests | 1.2–1.4 skim; 2.1–2.2, 2.8; 4.1–4.3, 4.5, 4.9 | `make week01` |
| [2: Clocked state, fetch and the register file](labs/week02/README.md) | PC, ROM, register file | 3.1–3.3, 3.5; 4.4, 4.9; 5.4–5.5 | `make week02` |
| [3: Decode and execute arithmetic instructions](labs/week03/README.md) | Decode + arithmetic | 6.1–6.2, 6.4; 6.5 skim; App. B | `make week03` |
| [4: Finish and freeze the single-cycle baseline](labs/week04/README.md) | 14-op single-cycle CPU | 7.1–7.3; 7.6 single-cycle | `make week04` |
| [5: Build the real five-stage pipeline](labs/week05/README.md) | Four pipeline boundaries | 7.2; 7.5 basic pipeline | `make week05` |
| [6: Forwarding, load stalls and control flushes](labs/week06/README.md) | Forwarding, stalls, flushes | 7.5 hazards | `make week06` |
| [7: Verify the complete pipeline](labs/week07/README.md) | Architecture comparison | 7.6 pipeline; 6.4 review | `make week07` |
| [8: Deploy the pipelined SoC](labs/week08/README.md) | Pipelined MMIO + FPGA | 8.1–8.2 skim; 9.1–9.2; A.1, A.3 | `make week08` |

## Scope contract

Required instructions: ADD SUB AND OR XOR SLT ADDI LW SW BEQ JAL JALR LUI AUIPC. Both cores must implement the same subset. Mandatory pipeline features: IF/ID, ID/EX, EX/MEM, MEM/WB; valid bits; EX/MEM + MEM/WB forwarding; WB→ID bypass; load-use interlock; store dependencies; branch/jump flushes; deterministic side-effect-free errors and preservation of older work.

The private completed design supports 37 integer operations; `make extended` tests those extras. More instructions, byte/halfword lanes and rich fault diagnostics may be deferred, but pipeline correctness and safe invalid-access handling may not. This is an educational RV32I subset, not a compliance-certified full RISC-V core.

Use [INTERFACES](docs/INTERFACES.md) while coding, [setup](docs/SETUP.md) before week 1, and [progress](PERSONAL_PROGRESS.md) after each session. The supplied retirement interface and simulator memory model are course-specific; compare concepts with the book rather than copying its CPU's port names.

## Sources and reading policy

Section numbering checked against the authors' [published table of contents](https://pages.hmc.edu/harris/research/WCAE_paper8_ddcariscv_HarrisHarris.pdf). Use the [official companion](https://pages.hmc.edu/harris/ddca/ddcarv.html) for Chapter 9, Appendix A/B and errata. In this edition testbenches are §4.9, machine encoding §6.4, and MMIO §9.2; Chapter 8 is memory systems. Read the SystemVerilog examples only; VHDL is not an extra requirement. Page numbers are intentionally omitted because printings differ. The course assignments are original; do not redistribute textbook PDFs or solutions.

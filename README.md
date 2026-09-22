# RISC-V FPGA — eight-week learner course

Build your own SystemVerilog CPU, ending with a **real five-stage IF/ID/EX/MEM/WB pipeline**. Start here, not in the historical lab documents.

1. [Set up Verilator](docs/SETUP.md) and run `make setup-check`.
2. Read the [eight-week plan and textbook assignments](COURSE_MAP.md).
3. Start [week 1](labs/week01/README.md), use [interfaces](docs/INTERFACES.md), and keep your [progress record](PERSONAL_PROGRESS.md).

```sh
make setup-check  # working simulator, assertions and waveform generation
make test         # starter infrastructure/syntax checks
make week01       # intentionally fails until YOU implement the ALU
```

This is a cumulative **starter**, not a completed CPU. `rtl/` contains interfaces and TODOs; tests contain expected results, not future hardware solutions. Later weekly targets stay red until you build those modules. A green starter CI result does not certify processor correctness.

| Weeks | Milestone |
|---|---|
| 1–2 | Combinational HDL, tests, state, fetch and register file |
| 3–4 | Decode/execution and a 14-operation single-cycle reference |
| 5–6 | Five pipeline stages, forwarding, load stalls, redirects/flushes |
| 7–8 | Architectural regression, pipeline MMIO and honest FPGA evidence |

Use Harris & Harris, *Digital Design and Computer Architecture, RISC-V Edition*, alongside each lab; the [chapter map](COURSE_MAP.md) gives stopping points. The core subset is mandatory; full 37-operation support is optional.

Both active course repositories are private at this revision. Your instructor must grant Practice access; the private Teacher repository is not a prerequisite for learners. Old six-lab documentation is supplemental historical material, not the active schedule.

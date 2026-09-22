# Week 3: Decode and execute arithmetic instructions

[Course map](../../COURSE_MAP.md) · Prerequisite: week 2's gate passes.

## Read before building

§§6.1–6.2 and 6.4; skim §6.5. Consult Appendix B for encodings. Read §6.3 only for an unfamiliar assembly construct.

Read for the circuit you will build, not to finish a chapter. Spend about 30–45 minutes per session on targeted reading; if the concepts remain unclear, reduce the coding scope and repeat the session.

## Session A

Use the types in rv32_pkg.sv as an interface contract. Implement decode.sv for ADDI and the six baseline register operations; extract registers, validate funct7/funct3, and sign-extend immediates.

## Session B

Wire pc, regfile, decode and execute_stage into cpu_single.sv. Implement the registered retirement outputs using docs/INTERFACES.md. Recognize EBREAK as the course's terminal unsupported-instruction fault, not as a implemented debugger instruction.

## Predict before running

ADDI x1,0,5; ADDI x2,0,7; ADD x3,x1,x2 leaves x3=12. A destination x0 never changes architectural state.

Draw the relevant gates/registers or datapath. Mark combinational wires and stored state in different colors. Write one expected edge or truth-table row without consulting the solution.

## Files and commands

Work in: `rtl/common/decode.sv`, `rtl/common/execute_stage.sv`, `rtl/single_cycle/cpu_single.sv`. Preserve the declared ports and types; see [interfaces](../../docs/INTERFACES.md).

From the repository root:

```sh
make week03
# Fix the first failed check, then rerun the same target.
```

Fresh starters are intentionally unfinished: they compile, but these behavioral gates fail until implemented. `make setup-check` checks the toolchain independently; it is not a completed exercise. Generated C++ and logs are under `build/`. No cross-assembler is needed for these provided vectors.

## Debugging

Watch: imem_addr, decoded, source_a/source_b, result, retire_valid, retire_rd_data. Compare a pre-edge request with the post-edge state; sample registered results after nonblocking updates settle. Use the first mismatch, not the last bad register.

Deliberate bug: Zero-extend the ADDI immediate instead of sign-extending it. The negative immediate in core_alu must expose the error. Introduce it only in a disposable copy/branch, confirm a failing test, then undo just your mutation and rerun.

## Done when

Pass first_arithmetic and core_alu on the single-cycle CPU. Trace instruction bits to a writeback without reading the private solution.

Before advancing, explain the new hardware without reading the answer key, predict one unseen input, and record the commit, exact command, result, and one repaired bug in [your progress log](../../PERSONAL_PROGRESS.md).

## Stretch

Add one boundary case to the tests, or explain a trade-off between the textbook and this implementation. Do not sacrifice the required five-stage end goal for optional features.

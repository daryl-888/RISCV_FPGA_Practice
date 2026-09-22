# Week 1: Combinational RTL and a trustworthy testbench

[Course map](../../COURSE_MAP.md) · Prerequisite: make setup-check passes.

## Read before building

§§1.2–1.4 (skim abstraction and two’s complement), §§2.1–2.2 and 2.8, §§4.1–4.3, 4.5, 4.9. Read only the SystemVerilog column.

Read for the circuit you will build, not to finish a chapter. Spend about 30–45 minutes per session on targeted reading; if the concepts remain unclear, reduce the coding scope and repeat the session.

## Session A

Draw a 2:1 mux and a 32-bit ALU. Implement ADD and SUB in rtl/common/alu.sv, preserving the declared operation numbers. Predict 7+5 and 0−1 before running.

## Session B

Add AND, OR, XOR, signed/unsigned comparisons and shifts. Keep a default result. Finish all 21 ALU checks; add one handwritten test vector of your own.

## Predict before running

7+5=12; 0−1=0xffffffff; signed −1<1 is true but unsigned 0xffffffff<1 is false.

Draw the relevant gates/registers or datapath. Mark combinational wires and stored state in different colors. Write one expected edge or truth-table row without consulting the solution.

## Files and commands

Work in: `rtl/common/alu.sv`, `tests/week01/alu_tb.sv`. Preserve the declared ports and types; see [interfaces](../../docs/INTERFACES.md).

From the repository root:

```sh
make week01
make waves CASE=alu
```

Fresh starters are intentionally unfinished: they compile, but these behavioral gates fail until implemented. `make setup-check` checks the toolchain independently; it is not a completed exercise. Generated C++ and logs are under `build/`. No cross-assembler is needed for these provided vectors.

## Debugging

Watch: a, b, op, result. Compare a pre-edge request with the post-edge state; sample registered results after nonblocking updates settle. Use the first mismatch, not the last bad register.

Deliberate bug: Replace the signed comparison with an unsigned comparison; the −1 versus +1 test must fail. Introduce it only in a disposable copy/branch, confirm a failing test, then undo just your mutation and rerun.

## Done when

Explain why always_comb describes gates, why a missing assignment can infer storage, and why a green test is evidence rather than proof.

Before advancing, explain the new hardware without reading the answer key, predict one unseen input, and record the commit, exact command, result, and one repaired bug in [your progress log](../../PERSONAL_PROGRESS.md).

## Stretch

Write three additional ALU cases around signed overflow and a shift amount of 32.

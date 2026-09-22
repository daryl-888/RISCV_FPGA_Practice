# Week 2: Clocked state, fetch and the register file

[Course map](../../COURSE_MAP.md) · Prerequisite: week 1's gate passes.

## Read before building

§§3.1–3.3 and 3.5, §4.4 and revisit §4.9, §§5.4–5.5. Defer FSM design (§3.4/4.6).

Read for the circuit you will build, not to finish a chapter. Spend about 30–45 minutes per session on targeted reading; if the concepts remain unclear, reduce the coding scope and repeat the session.

## Session A

Implement rtl/common/pc.sv and imem.sv. Reset wins over enable; addresses are bytes and advance by four. Load programs/fetch.hex and guard bounds before selecting address[9:2].

## Session B

Implement regfile.sv: 32 words, two asynchronous reads, one rising-edge write, synchronous reset, x0 protection. Add the small BYPASS parameter for same-edge WB→ID visibility; keep it off in the single-cycle core.

## Predict before running

Fetch PCs 0,4,8 contain 00500093,00700113,002081b3. Enable=0 holds PC; reset still clears it. Address 0x400 must not alias zero.

Draw the relevant gates/registers or datapath. Mark combinational wires and stored state in different colors. Write one expected edge or truth-table row without consulting the solution.

## Files and commands

Work in: `rtl/common/pc.sv`, `rtl/common/imem.sv`, `rtl/common/regfile.sv`. Preserve the declared ports and types; see [interfaces](../../docs/INTERFACES.md).

From the repository root:

```sh
make week02
# Fix the first failed check, then rerun the same target.
```

Fresh starters are intentionally unfinished: they compile, but these behavioral gates fail until implemented. `make setup-check` checks the toolchain independently; it is not a completed exercise. Generated C++ and logs are under `build/`. No cross-assembler is needed for these provided vectors.

## Debugging

Watch: clk, reset, enable, value, address, instruction, regfile write_en/rd/write_data. Compare a pre-edge request with the post-edge state; sample registered results after nonblocking updates settle. Use the first mismatch, not the last bad register.

Deliberate bug: Increment PC by one, then test a reset while enable=0. Both mistakes must be caught. Introduce it only in a disposable copy/branch, confirm a failing test, then undo just your mutation and rerun.

## Done when

Draw one clock edge, explain old versus new state, pass fetch/reset/hold/bounds and register-file tests, and distinguish bytes from word indices.

Before advancing, explain the new hardware without reading the answer key, predict one unseen input, and record the commit, exact command, result, and one repaired bug in [your progress log](../../PERSONAL_PROGRESS.md).

## Stretch

Add one boundary case to the tests, or explain a trade-off between the textbook and this implementation. Do not sacrifice the required five-stage end goal for optional features.

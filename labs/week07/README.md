# Week 7: Verify the complete pipeline

[Course map](../../COURSE_MAP.md) · Prerequisite: week 6's gate passes.

## Read before building

§7.6 pipelined HDL; revisit §6.4 and Appendix B for each failing instruction. §7.7 advanced topics is optional, not required reading for the gate.

Read for the circuit you will build, not to finish a chapter. Spend about 30–45 minutes per session on targeted reading; if the concepts remain unclear, reduce the coding scope and repeat the session.

## Session A

Run the ordered single-cycle/pipeline comparison over the required baseline. Inspect PC, result and memory effects at the first mismatch. Keep physical store checks separate from retirement checks.

## Session B

Rerun five-stage latency, reset/retained-RAM and invalid-access checks. Make one deliberate forwarding mutation and prove a test fails. Restore, rerun and save the passing commit.

## Predict before running

Both cores finish with identical registers/RAM and ordered architectural effects despite different cycle counts. A faulting store has zero accepted writes.

Draw the relevant gates/registers or datapath. Mark combinational wires and stored state in different colors. Write one expected edge or truth-table row without consulting the solution.

## Files and commands

Work in: `rtl/pipeline/cpu_pipeline.sv`, `tests/reference_tb.sv`, `tests/programs.json`. Preserve the declared ports and types; see [interfaces](../../docs/INTERFACES.md).

From the repository root:

```sh
make week07
make waves CASE=load_add
```

Fresh starters are intentionally unfinished: they compile, but these behavioral gates fail until implemented. `make setup-check` checks the toolchain independently; it is not a completed exercise. Generated C++ and logs are under `build/`. No cross-assembler is needed for these provided vectors.

## Debugging

Watch: retire_pc/instr/rd_data/fault, dmem_valid/write/fault, test case prefix. Compare a pre-edge request with the post-edge state; sample registered results after nonblocking updates settle. Use the first mismatch, not the last bad register.

Deliberate bug: Disable EX/MEM forwarding for newest_writer. Final state and the first incorrect retirement should expose it. Introduce it only in a disposable copy/branch, confirm a failing test, then undo just your mutation and rerun.

## Done when

make regression passes including the five-stage test. Core correctness is mandatory; the full 37-operation suite is an additional make extended milestone.

Before advancing, explain the new hardware without reading the answer key, predict one unseen input, and record the commit, exact command, result, and one repaired bug in [your progress log](../../PERSONAL_PROGRESS.md).

## Stretch

Implement the remaining 23 operations and byte/halfword memory lanes; run make extended.

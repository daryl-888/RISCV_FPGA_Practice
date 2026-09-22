# Week 5: Build the real five-stage pipeline

[Course map](../../COURSE_MAP.md) · Prerequisite: week 4's gate passes.

## Read before building

§7.2 and §7.5 through the basic pipeline datapath/control discussion. Stop before hazard solutions. Revisit §4.4.

Read for the circuit you will build, not to finish a chapter. Spend about 30–45 minutes per session on targeted reading; if the concepts remain unclear, reduce the coding scope and repeat the session.

## Session A

Draw IF → ID → EX → MEM → WB and label IF/ID, ID/EX, EX/MEM, MEM/WB. Implement those four state bundles in cpu_pipeline.sv, with a valid bit and matching PC, controls and data.

## Session B

Connect the existing decode/execute/register-file modules. Run independent ADDI instructions. Expose debug_stage_valid and debug_stage_pc so the test can inspect overlap and registered latency.

## Predict before running

The instruction first fetched at edge 1 retires at edge 5. At edge 4, PCs 12,8,4,0 occupy the four boundary registers.

Draw the relevant gates/registers or datapath. Mark combinational wires and stored state in different colors. Write one expected edge or truth-table row without consulting the solution.

## Files and commands

Work in: `rtl/pipeline/cpu_pipeline.sv`, `tests/week05/pipeline_depth_tb.sv`. Preserve the declared ports and types; see [interfaces](../../docs/INTERFACES.md).

From the repository root:

```sh
make week05
# Fix the first failed check, then rerun the same target.
```

Fresh starters are intentionally unfinished: they compile, but these behavioral gates fail until implemented. `make setup-check` checks the toolchain independently; it is not a completed exercise. Generated C++ and logs are under `build/`. No cross-assembler is needed for these provided vectors.

## Debugging

Watch: debug_stage_valid, debug_stage_pc[0..3], imem_addr, retire_valid, retire_pc. Compare a pre-edge request with the post-edge state; sample registered results after nonblocking updates settle. Use the first mismatch, not the last bad register.

Deliberate bug: Advance control bits without the matching destination/PC, or make retirement immediate. The boundary/latency gate must fail. Introduce it only in a disposable copy/branch, confirm a failing test, then undo just your mutation and rerun.

## Done when

Pass the five-stage overlap test. Explain why throughput can reach one instruction/cycle while latency remains five stages. Do not claim dependent execution yet.

Before advancing, explain the new hardware without reading the answer key, predict one unseen input, and record the commit, exact command, result, and one repaired bug in [your progress log](../../PERSONAL_PROGRESS.md).

## Stretch

Add one boundary case to the tests, or explain a trade-off between the textbook and this implementation. Do not sacrifice the required five-stage end goal for optional features.

# Week 6: Forwarding, load stalls and control flushes

[Course map](../../COURSE_MAP.md) · Prerequisite: week 5's gate passes.

## Read before building

Finish §7.5, focusing on data/control hazards, forwarding and stalls. Revisit §3.5 for same-edge reasoning.

Read for the circuit you will build, not to finish a chapter. Spend about 30–45 minutes per session on targeted reading; if the concepts remain unclear, reduce the coding scope and repeat the session.

## Session A

Implement forwarding.sv and hazard.sv, connect both to the real pipeline, and use BYPASS=1 in its register file. EX/MEM's newest eligible producer beats MEM/WB. Include store data and address consumers.

## Session B

Hold PC and IF/ID on a real load-use dependency, inject an invalid ID/EX bubble, and let older stages advance. Resolve redirects in EX, kill two younger slots, and keep older work. Safe fault draining remains required.

## Predict before running

LW x1,[0] with RAM[0]=9 then ADD x2,x1,x1 needs one stall and yields 18. A branch over SW must cause zero physical writes.

Draw the relevant gates/registers or datapath. Mark combinational wires and stored state in different colors. Write one expected edge or truth-table row without consulting the solution.

## Files and commands

Work in: `rtl/pipeline/forwarding.sv`, `rtl/pipeline/hazard.sv`, `rtl/pipeline/cpu_pipeline.sv`. Preserve the declared ports and types; see [interfaces](../../docs/INTERFACES.md).

From the repository root:

```sh
make week06
make waves CASE=load_add
```

Fresh starters are intentionally unfinished: they compile, but these behavioral gates fail until implemented. `make setup-check` checks the toolchain independently; it is not a completed exercise. Generated C++ and logs are under `build/`. No cross-assembler is needed for these provided vectors.

## Debugging

Watch: load_use, stall, redirect, source_a/source_b, stage valid bits, physical dmem_write. Compare a pre-edge request with the post-edge state; sample registered results after nonblocking updates settle. Use the first mismatch, not the last bad register.

Deliberate bug: Forward an EX/MEM load address, select an older writer, or freeze the producing load. Use the named dependency cases to locate the first wrong event. Introduce it only in a disposable copy/branch, confirm a failing test, then undo just your mutation and rerun.

## Done when

Pass unit controls and integrated hazard cases, including load-to-store, branch/JALR operands, false rs2 matches, x0 and wrong-path stores.

Before advancing, explain the new hardware without reading the answer key, predict one unseen input, and record the commit, exact command, result, and one repaired bug in [your progress log](../../PERSONAL_PROGRESS.md).

## Stretch

Add one boundary case to the tests, or explain a trade-off between the textbook and this implementation. Do not sacrifice the required five-stage end goal for optional features.

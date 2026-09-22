# Week 8: Deploy the pipelined SoC

[Course map](../../COURSE_MAP.md) · Prerequisite: week 7's gate passes.

## Read before building

§§8.1–8.2 (overview only), companion §§9.1–9.2, Appendix A §§A.1 and A.3. Review official errata. No cache or virtual-memory implementation required.

Read for the circuit you will build, not to finish a chapter. Spend about 30–45 minutes per session on targeted reading; if the concepts remain unclear, reduce the coding scope and repeat the session.

## Session A

Add word-only MMIO, input synchronization and conditioned reset. Wire basys3_top to the pipelined core (PIPELINED=1). Pass switch-copy, prohibited-access and wrong-path-MMIO tests.

## Session B

In a supported Windows/Linux Vivado installation, source fpga/create_project.tcl. Inspect inference, CDC, setup/hold and unconstrained paths. Program Basys 3 only after constraints and implemented timing are satisfactory.

## Predict before running

LW 0x10000004 reads synchronized switches; SW 0x10000000 changes LEDs. Reset clears LEDs and restarts the pipeline while retaining RAM.

Draw the relevant gates/registers or datapath. Mark combinational wires and stored state in different colors. Write one expected edge or truth-table row without consulting the solution.

## Files and commands

Work in: `rtl/soc/teaching_memory.sv`, `rtl/soc/basys3_top.sv`, `fpga/create_project.tcl`, `fpga/basys3_minimal.xdc`. Preserve the declared ports and types; see [interfaces](../../docs/INTERFACES.md).

From the repository root:

```sh
make week08
make waves CASE=load_add
```

Fresh starters are intentionally unfinished: they compile, but these behavioral gates fail until implemented. `make setup-check` checks the toolchain independently; it is not a completed exercise. Generated C++ and logs are under `build/`. No cross-assembler is needed for these provided vectors.

## Debugging

Watch: reset synchronizer, sw_sync, dmem_addr, LED latch, PIPELINED parameter. Compare a pre-edge request with the post-edge state; sample registered results after nonblocking updates settle. Use the first mismatch, not the last bad register.

Deliberate bug: Disable writes to the LED register. The nonzero switch patterns in the board test must fail. Introduce it only in a disposable copy/branch, confirm a failing test, then undo just your mutation and rerun. Separately inspect the real 100 MHz timing report: simulation cannot establish physical timing.

## Done when

make week08 and make regression pass. Record separate simulation and physical-board statuses. A simulation-only result is not hardware completion.

Before advancing, explain the new hardware without reading the answer key, predict one unseen input, and record the commit, exact command, result, and one repaired bug in [your progress log](../../PERSONAL_PROGRESS.md).

## Stretch

Add one boundary case to the tests, or explain a trade-off between the textbook and this implementation. Do not sacrifice the required five-stage end goal for optional features.

# Week 4: Finish and freeze the single-cycle baseline

[Course map](../../COURSE_MAP.md) · Prerequisite: week 3's gate passes.

## Read before building

§§7.1–7.3; §7.6 single-cycle HDL only. Revisit §5.5 and relevant §6.4 encodings. Skip §7.4 multicycle for this course.

Read for the circuit you will build, not to finish a chapter. Spend about 30–45 minutes per session on targeted reading; if the concepts remain unclear, reduce the coding scope and repeat the session.

## Session A

Implement teaching_memory.sv for aligned LW/SW in the 1 KiB data memory. Add I/S immediates, effective addresses, clocked store enables and load writeback. Reset must retain RAM contents.

## Session B

Add BEQ, JAL, JALR, LUI and AUIPC. Form B/J immediates with the low zero once; JALR clears bit zero but still checks word alignment. Gate faulting effects and freeze a passing commit.

## Predict before running

Store 42 at byte address 12 changes data word 3, not instruction word 3. JAL writes the instruction's PC+4. JALR(9) targets 8.

Draw the relevant gates/registers or datapath. Mark combinational wires and stored state in different colors. Write one expected edge or truth-table row without consulting the solution.

## Files and commands

Work in: `rtl/soc/teaching_memory.sv`, `rtl/common/decode.sv`, `rtl/common/execute_stage.sv`, `rtl/single_cycle/cpu_single.sv`. Preserve the declared ports and types; see [interfaces](../../docs/INTERFACES.md).

From the repository root:

```sh
make week04
# Fix the first failed check, then rerun the same target.
```

Fresh starters are intentionally unfinished: they compile, but these behavioral gates fail until implemented. `make setup-check` checks the toolchain independently; it is not a completed exercise. Generated C++ and logs are under `build/`. No cross-assembler is needed for these provided vectors.

## Debugging

Watch: dmem_valid/write/addr/fault, current_fault, result.next_pc, retire_pc. Compare a pre-edge request with the post-edge state; sample registered results after nonblocking updates settle. Use the first mismatch, not the last bad register.

Deliberate bug: Index RAM before checking the full address: test 0x400, −4 and a misaligned word. No invalid store may change memory. Introduce it only in a disposable copy/branch, confirm a failing test, then undo just your mutation and rerun.

## Done when

All required 14 operations pass the selected single-cycle programs and safety checks. Save this version; it becomes the comparison reference.

Before advancing, explain the new hardware without reading the answer key, predict one unseen input, and record the commit, exact command, result, and one repaired bug in [your progress log](../../PERSONAL_PROGRESS.md).

## Stretch

Add one boundary case to the tests, or explain a trade-off between the textbook and this implementation. Do not sacrifice the required five-stage end goal for optional features.

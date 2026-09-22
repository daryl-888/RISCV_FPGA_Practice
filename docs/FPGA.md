# Basys 3: simulation, then hardware evidence

The required board-wrapper gate is `make week08`. It exercises **both** CPU choices, including the final pipelined one, against seven switch patterns and reset. It is not a synthesis, timing or board test.

For hardware use a licensed/authorized Vivado installation with Artix-7 support on a supported Windows/Linux machine. The top is `basys3_top`, clock `clk` at 100 MHz, center pushbutton `btnC`, switches `sw[15:0]` and LEDs `led[15:0]`. Two-flop synchronizers handle asynchronous inputs; each switch is independent, so this is not a coherent multi-bit bus transfer protocol.

## Procedure

1. Pass `make week07 week08` on your actual design and commit it.
2. In Vivado's Tcl console, with no project open, source `fpga/create_project.tcl` (Teacher: `course/fpga/create_project.tcl`). Quote the absolute path if it contains spaces. Default `course_pipeline=1`; optional single-cycle comparison sets it to 0 before sourcing.
3. The script creates a new non-overwriting project for `xc7a35tcpg236-1`, adds all modular RTL, `programs/boot.hex`, and Basys 3 constraints. Check compile order, top and PIPELINED generic. Existing output projects are never silently replaced.
4. Open elaborated design, inspect ROM initialization and memory inference, then run synthesis. Record errors/warnings and utilization. These small **asynchronous-read distributed memories** are intentional; do not change to block RAM without adapting the processor.
5. Run implementation and inspect timing/CDC/unconstrained-path reports. The supplied XDC has verified board pin mapping and the 10 ns clock, but asynchronous boundary timing needs an explicit reviewed treatment; do not claim full timing closure just from an internal-clock summary or add broad false paths to hide problems.
6. Only after reviewing reports, generate the bitstream, connect your own board through Hardware Manager, program it, and try 0000/0001/8000/ffff/a5a5/5a5a/1234. LEDs should eventually match stable switches. Press/release reset and repeat.
7. Record commit, tool/version/OS, PIPELINED choice, reports, worst slack, unresolved warnings, bitstream and physical observations in your progress record (Teacher: `evidence/FPGA_RECORD.md`).

`boot.hex` is supplied so no cross-assembler is needed to run the example. It loops over word loads from switches at 0x10000004 and stores to LEDs at 0x10000000.

No Vivado run or physical-board success is asserted by this course migration. Browser Codespaces does not automatically expose your local USB FPGA; perform hardware programming on the supported machine physically connected to the board.

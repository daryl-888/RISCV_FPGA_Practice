# Setup: use the same checks on every development machine

Start with `make setup-check`. It compiles and runs a **standalone** SystemVerilog test with a clock, delays, nonblocking assignments, assertions and VCD output. It also deliberately triggers an assertion and verifies a failing process. It does not certify the learner's unfinished CPU.

Supported baseline: Verilator 5.020 or newer, Python 3.10+, GNU Make, Perl and a C++20-capable compiler. The first compile takes longer; repeat simulations use a local build cache. No proprietary simulator, GUI or RISC-V cross-compiler is needed for the weekly tests.

## Choose one environment

| Device | Recommended route | Important limit |
|---|---|---|
| Ubuntu 24.04 / other Linux | Native packages or the dev container | Use native packages on ARM |
| Windows | Ubuntu 24.04 in WSL2, or VS Code Dev Containers | Do not run these Makefiles in PowerShell |
| macOS Intel / Apple Silicon | Homebrew + Apple command-line tools, or dev container | Vivado is a separate supported Windows/Linux workflow |
| Chromebook, tablet, phone | Browser-based GitHub Codespaces, or SSH to your Linux machine | Simulation runs on the remote host, not natively on iOS/Android |
| Restricted Linux x86-64 account | Optional local wheel below, if compiler/Python already exist | No permission bypass; otherwise use a permitted remote environment |

"Any device" means access to a supported local or remote environment, not a promise that every device can install Verilator or program an FPGA. Cloud availability, repository access and billing/quota depend on your GitHub account.

### Ubuntu / WSL2

If needed, install WSL using [Microsoft's instructions](https://learn.microsoft.com/en-us/windows/wsl/install). In Ubuntu:

```sh
sudo apt-get update
sudo apt-get install -y verilator build-essential python3 python3-venv git perl
make setup-check
make test
```

Run those commands from the **practice repository root**, or the **teacher repository root**. Keep the checkout in the WSL Linux filesystem for simulation; use a separate synchronized checkout for Windows Vivado if necessary. Administrative installation must be performed by someone authorized to manage that machine.

### macOS

Install [Apple command-line tools](https://developer.apple.com/xcode/resources/) and [Homebrew](https://brew.sh/) using their official instructions, then:

```sh
brew install verilator python
make setup-check
make test
```

### Dev container / browser route

Both repositories include `.devcontainer/`. In VS Code, open the repository and choose **Dev Containers: Reopen in Container**. Docker or a compatible supported container host must already be available.

For a browser-only device, open the private repository in GitHub, use **Code → Codespaces → Create codespace**, and wait for the container setup. The configured post-create check runs `make setup-check`; run it again yourself, then `make test`. The learner needs access to the practice repository only. A private teacher repository and its solution files must not be shared with them.

A Codespace is a remote Linux computer; a browser is sufficient for the editor and terminal. Prefer a physical keyboard for HDL work. No physical FPGA/USB connection is implied.

### Optional non-admin Linux x86-64 setup

Use this only if Python with venv/pip, GNU g++, Make and Perl are already installed. This explicitly installs the third-party [verilator-python wheel](https://pypi.org/project/verilator/5.32.0/), pinned to 5.32.0, into a repository-local virtual environment. It is **not** the upstream Verilator package distribution.

Practice repository:

```sh
bash scripts/bootstrap-local.sh
source .venv/bin/activate
make setup-check
make test
```

Teacher repository:

```sh
bash course/scripts/bootstrap-local.sh
source course/.venv/bin/activate
make setup-check
make test
```

Activate the same environment again in every new terminal. Use activation as above, or pass an **absolute** path via `PYTHON=/absolute/path/to/.venv/bin/python`. Teacher root commands change directory, so a relative Python path is not portable.

The launcher prefers an installed native `verilator`, then the activated Python environment's wheel. Its Linux-wheel C++20/PCH workaround is scoped to that command and never modifies system settings. On ARM/macOS use the native/container route, not this x86-64 wheel. The wheel may print an unhelpful "UNKNOWN.REV" version; the real compile-and-run smoke test remains the capability check.

## Daily commands

```sh
make setup-check          # environment is usable
make test                 # Python/tool tests + smoke test + scaffold syntax
make week01               # current week's actual hardware gate
make waves CASE=alu       # requires a working ALU; build/waves/alu.vcd
make week05               # stage-depth and independent-instruction gate
make regression           # required 14-operation, hazard and safety baseline
make extended             # optional 37-operation extension
```

Teacher root commands delegate to `course/`; its artifacts are under `course/build/`. Practice artifacts are under `build/`. Each simulator build has a `build.log`. VCD files can be opened locally with GTKWave or a trusted VS Code waveform viewer. Do not upload private teacher HDL/waveforms to a public viewer. Headless tests need no display server.

**Expected on a fresh learner clone:** setup/scaffold checks pass; `make week01` fails until the ALU is implemented. Later weekly checks similarly remain red until their cumulative work is complete. A green infrastructure CI badge is not a finished processor.

## Troubleshooting

- "Verilator not found": install one supported route or activate the correct virtual environment. `python3 scripts/verilator.py --version` (under `course/` for teacher) checks discovery.
- `VERILATOR` can name **one executable path**, including spaces, not a shell command with flags. An invalid explicit override fails rather than silently choosing another tool. Unset stale `VERILATOR` or `VERILATOR_ROOT` settings.
- Coroutine/PCH compiler errors on the optional wheel: use the supplied launcher/Make targets and GNU g++; do not invoke its internal binary directly.
- A weekly failure after successful setup usually means an unfinished or incorrect circuit. Read the first assertion and inspect the named signals; do not weaken the expected result.
- Tool/compiler changed: `make clean` in the course directory (or practice root), then rerun. Never commit build output or `.venv`.
- No desktop/wave viewer: tests still work. Copy only your own VCD to a trusted desktop, or use an editor extension in the remote environment.
- Cross-assembler missing: weekly cases already include machine words. Optional `make program PROGRAM=arithmetic` requires an RV32-capable bare-metal toolchain; on Ubuntu install `gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf`.

Upstream installation reference: [Verilator](https://verilator.org/guide/latest/install.html). Hardware work is separate: [FPGA procedure](FPGA.md).

#!/usr/bin/env bash
# Optional no-admin fallback. Native packages / Codespaces are preferred elsewhere.
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo 'This wheel fallback supports Linux x86_64 only. Use docs/SETUP.md for native macOS/ARM or Codespaces.' >&2
  exit 2
fi
for tool in python3 g++ make perl; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing $tool. See docs/SETUP.md, or use the browser/Codespaces route." >&2
    exit 2
  fi
done
python3 -c 'import sys; assert sys.version_info >= (3,10), "Python 3.10+ required"'
if [[ ! -d .venv ]]; then python3 -m venv .venv; fi
if [[ ! -x .venv/bin/python ]]; then
  echo '.venv exists but is not a usable Linux environment; choose a clean clone. Nothing overwritten.' >&2
  exit 2
fi
.venv/bin/python -m pip install --only-binary=:all: 'verilator==5.32.0'
echo 'Installed third-party verilator-python distribution (not the upstream package manager).'
printf 'Next: source %q\n' "$PWD/.venv/bin/activate"
echo 'Then: make setup-check'

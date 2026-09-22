"""Run a native Verilator, or an explicitly installed local wheel, without sudo."""
from importlib import metadata
import os
from pathlib import Path
import shutil
import subprocess
import sys

def resolve_tool():
    override = os.environ.get('VERILATOR')
    if override:
        found = shutil.which(override)
        if not found:
            raise RuntimeError('VERILATOR must name one executable, not a shell command. See docs/SETUP.md.')
        return found, None
    native = shutil.which('verilator')
    if native:
        return native, None
    try:
        dist = metadata.distribution('verilator')
        root = Path(dist.locate_file('verilator')).resolve()
        binary = root/'bin/verilator'
        if binary.is_file():
            return str(binary), str(root)
    except metadata.PackageNotFoundError:
        pass
    raise RuntimeError('Verilator not found. Activate your .venv or follow docs/SETUP.md (native, Docker, or Codespaces).')

def main(args):
    try:
        binary, root = resolve_tool()
        env = os.environ.copy()
        if root:
            env['VERILATOR_ROOT'] = root
        # Some third-party wheels omit their build-time coroutine flags.
        # Explicit C++20 fixes this without changing compiler/system settings.
        if '--binary' in args or '--cc' in args:
            args = ['-CFLAGS', '-std=c++20', *args]
            if root and sys.platform.startswith('linux'):
                # The pinned Linux wheel leaves its PCH include option empty.
                # Keep the workaround local to this invocation; native installs
                # keep their own compiler configuration.
                args = ['-MAKEFLAGS', 'CFG_CXXFLAGS_PCH_I=-include CXX=g++', *args]
        return subprocess.run([binary, *args], env=env).returncode
    except (RuntimeError, OSError) as error:
        print(f'{error}\nSetup help: docs/SETUP.md', file=sys.stderr)
        return 2

if __name__ == '__main__':
    raise SystemExit(main(sys.argv[1:]))

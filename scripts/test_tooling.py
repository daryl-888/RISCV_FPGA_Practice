"""Contract tests for tool discovery: explicit overrides are never silently ignored."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

class ToolingTests(unittest.TestCase):
    def test_make_accepts_python_executable_path_with_spaces(self):
        with tempfile.TemporaryDirectory(prefix='course interpreter ') as folder:
            interpreter = Path(folder)/'python with spaces'
            interpreter.write_text('#!/bin/sh\nprintf "%s\\n" "$@"\n')
            interpreter.chmod(0o755)
            roots = [ROOT]
            if ROOT.name == 'course':
                roots.append(ROOT.parent)  # Also exercise recursive Teacher Make.
            for root in roots:
                result = subprocess.run(['make', 'setup-check', f'PYTHON={interpreter}'],
                    cwd=root, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn('scripts/course.py\nsetup-check', result.stdout)

    def test_missing_explicit_tool_fails_with_setup_guidance(self):
        run = subprocess.run([sys.executable, str(ROOT/'scripts/verilator.py'), '--version'],
            env={**os.environ, 'VERILATOR': '/no/such/verilator'}, capture_output=True, text=True)
        self.assertNotEqual(run.returncode, 0)
        self.assertIn('SETUP.md', run.stderr)

    def test_override_path_with_spaces_and_child_exit_are_preserved(self):
        with tempfile.TemporaryDirectory(prefix='verilator test ') as folder:
            tool = Path(folder)/'test simulator'
            tool.write_text('#!/bin/sh\nprintf "%s\\n" "$1"\nexit 17\n')
            tool.chmod(0o755)
            run = subprocess.run([sys.executable, str(ROOT/'scripts/verilator.py'), 'argument with spaces'],
                env={**os.environ, 'VERILATOR': str(tool)}, capture_output=True, text=True)
            self.assertEqual(run.returncode, 17)
            self.assertEqual(run.stdout.strip(), 'argument with spaces')

if __name__ == '__main__':
    unittest.main()

"""A cached simulator must match the selected source set and toolchain."""
import os
import sys
import unittest
from unittest.mock import patch
from course import build_signature

class CacheTests(unittest.TestCase):
    def test_same_top_different_sources_cannot_reuse_binary(self):
        with patch('course.resolve_tool', return_value=(sys.executable, None)):
            a = build_signature({'top': 'single_tb', 'sources': ['fixture.sv']})
            b = build_signature({'top': 'single_tb', 'sources': ['real_memory.sv']})
            self.assertNotEqual(a, b)

    def test_explicit_tool_environment_changes_cache(self):
        job = {'top': 'single_tb', 'sources': ['cpu.sv']}
        with patch('course.resolve_tool', return_value=(sys.executable, None)):
            with patch.dict(os.environ, {'VERILATOR': '/one/tool'}):
                a = build_signature(job)
            with patch.dict(os.environ, {'VERILATOR': '/another/tool'}):
                b = build_signature(job)
            self.assertNotEqual(a, b)

if __name__ == '__main__':
    unittest.main()

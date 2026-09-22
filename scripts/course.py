"""Compile exactly a checkpoint's inputs; failures are never converted to passes."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
from verilator import resolve_tool

ROOT = Path(__file__).resolve().parents[1]

def run(command, *, log=None, timeout=180):
    result = subprocess.run(command, cwd=ROOT, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, timeout=timeout)
    if log:
        log.write_text(result.stdout)
    if result.returncode:
        print(result.stdout[-16000:])
        raise RuntimeError(f'Command failed (exit {result.returncode}); log: {log or "see above"}')
    if not log:
        print(result.stdout, end='')
    return result.stdout

def build_signature(job):
    binary, root = resolve_tool()
    environment = {key: os.environ.get(key, '') for key in
                   ('VERILATOR', 'VERILATOR_ROOT', 'CXX', 'CC', 'CXXFLAGS',
                    'CPPFLAGS', 'CFLAGS', 'MAKEFLAGS', 'PATH')}
    identity = json.dumps([job, sys.executable, binary, root,
                           Path(binary).stat().st_mtime_ns, environment], sort_keys=True)
    return hashlib.sha256(identity.encode()).hexdigest()[:10]

def build(job, lint=False):
    # Week 3 and 4 share a test top but intentionally use different memory sources.
    # Include the source selection in the cache key, not only the top name.
    signature=build_signature(job)
    output = ROOT/'build'/(job['top']+'-'+signature)
    output.mkdir(parents=True, exist_ok=True)
    (ROOT/'build/waves').mkdir(parents=True, exist_ok=True)
    args = [sys.executable, str(ROOT/'scripts/verilator.py'),
            '--lint-only' if lint else '--binary', '--timing', '--assert', '--trace',
            '-Wall', '-Wno-DECLFILENAME', '-Wno-UNUSEDSIGNAL', '-Wno-UNUSEDPARAM',
            '-Wno-PINCONNECTEMPTY', '-Wno-BLKSEQ', '--top-module', job['top'],
            '--Mdir', str(output.relative_to(ROOT)), *job['sources']]
    binary = output/('V'+job['top'])
    inputs = [ROOT/p for p in job['sources']] + [Path(__file__), ROOT/'scripts/verilator.py']
    if lint or not binary.exists() or any(p.stat().st_mtime > binary.stat().st_mtime for p in inputs):
        run(args, log=output/('lint.log' if lint else 'build.log'), timeout=300)
    return binary

def hex_file(path, values):
    path.write_text(''.join(f'{v & 0xffffffff:08x}\n' for v in values))

def run_case(binary, case, waves=False):
    output=ROOT/'build/cases'; output.mkdir(parents=True, exist_ok=True)
    prefix=output/case['name']
    hex_file(prefix.with_suffix('.hex'), case['words']+[0]*(256-len(case['words'])))
    initial=[0]*256
    for addr,value in case['initial'].items(): initial[int(addr)//4]=value
    hex_file(prefix.with_suffix('.data'), initial)
    hex_file(prefix.with_suffix('.trace'), [v for row in case['trace'] for v in row])
    hex_file(prefix.with_suffix('.stores'), [v for row in case['stores'] for v in row] or [0,0,0])
    hex_file(prefix.with_suffix('.state'), case['regs']+case['ram']+[case['led']])
    args=[str(binary), f'+prefix={prefix}', f'+count={len(case["trace"])}',
          f'+stores={len(case["stores"])}', f'+stalls={case["stalls"]}']
    if waves: args.append(f'+wave=build/waves/{case["name"]}.vcd')
    run(args, timeout=30)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', choices=['setup-check','scaffold-check','regression','extended','waves']+
                        [f'week{n:02}' for n in range(1,9)])
    parser.add_argument('--case', default='load_add')
    args=parser.parse_args()
    jobs=json.loads((ROOT/'tests/checkpoints.json').read_text())
    cases={c['name']:c for c in json.loads((ROOT/'tests/programs.json').read_text())}
    if args.target=='setup-check':
        binary=build(jobs['smoke'])
        run([str(binary)])
        negative=subprocess.run([str(binary), '+fail'],cwd=ROOT,capture_output=True,text=True,timeout=30)
        if negative.returncode==0 or 'deliberate smoke failure' not in negative.stdout+negative.stderr:
            raise RuntimeError('Assertions/failure propagation are not working')
        if not (ROOT/'build/waves/tool_smoke.vcd').is_file():
            raise RuntimeError('VCD was not generated')
        print('PASS: setup; this does NOT certify learner RTL')
        return
    if args.target=='scaffold-check':
        for name,job in jobs.items():
            if 'sources' in job:
                build(job,lint=True)
        print('PASS: scaffold lint; unimplemented weekly exercises still need to pass')
        return
    if args.target=='waves':
        if args.case=='alu':
            run([str(build(jobs['alu'])), '+trace']); return
        if args.case not in cases:
            parser.error('Unknown case. See tests/programs.json for available names.')
        run_case(build(jobs['cpu_both']), cases[args.case], True); return
    if args.target=='extended':
        binary=build(jobs['cpu_both'])
        for case in cases.values(): run_case(binary,case)
        print(f'PASS: {len(cases)} extension cases'); return
    target='week07' if args.target=='regression' else args.target
    for entry in jobs[target]['jobs']:
        job=jobs[entry['job']]; binary=build(job)
        if 'cases' in entry:
            for name in entry['cases']: run_case(binary,cases[name])
        else: run([str(binary)])
    print(f'PASS: {target}')

if __name__=='__main__':
    try: main()
    except (RuntimeError, OSError, subprocess.TimeoutExpired) as error:
        print(f'FAIL: {error}',file=sys.stderr)
        raise SystemExit(1)

#!/usr/bin/python3
import subprocess
import os
import params as P
import benchs as B
from pathlib import Path

EXE = "binsec-rel "

# Get the command from params
def get_cmd(executable, params):
    exec_file = executable.get_exec_file()
    entrypoint = executable.get_entrypoint()
    high_syms = executable.get_high_syms()
    memory_file = str(executable.get_memory_file())
    prefix = Path(exec_file).stem + "_" + entrypoint
    args = params.get_args()
    cmd = EXE + str(exec_file) + " " + args + " -entrypoint " + entrypoint + \
        (" -relse-high-sym " + high_syms if high_syms != "" else "") + \
        (" -sse-memory " + memory_file if memory_file != "" else "") + \
        " -relse-stat-prefix " + prefix
    print(cmd)
    return cmd


def run(executable, params):
    print("\n----------\nAnalyzing " + str(executable.get_exec_file())
          + " at " + executable.get_entrypoint())
    cmd = get_cmd(executable, params)
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0 and result.returncode != 7 and \
       result.returncode != 8:
        raise ValueError('Unknown return code from Binsec !')
    subprocess.run("killall boolector", shell=True)

# Run all the experiments
def xp_runner(bench, params):
    for i in range(params.n_iter):
        for executable in bench.get_executables():
            run(executable, params)

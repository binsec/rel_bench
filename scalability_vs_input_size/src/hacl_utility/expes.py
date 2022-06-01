#!/usr/bin/python3
import sys
sys.path.insert(1, '../../python_scripts/')
from libxp import *
import params
import benchs

TIMEOUT=3600
N_ITER=5
STAT_FILE="stats/2022_27_05.csv"

## Use cases
base_exec=["cmp_bytes_O0", "cmp_bytes_O3"]
sizes=[ 500, 1000, 1500, 2000, 2500, 3000 ]

if __name__ == '__main__':
    executables = benchs.get_executable_names_with_size(base_exec, sizes)
    benchs = benchs.BenchsMultiExec(executables)
    params = params.Params(timeout=TIMEOUT, n_iter=N_ITER, stat_file=STAT_FILE)

    # Run expes for CT
    xp_runner(benchs, params)

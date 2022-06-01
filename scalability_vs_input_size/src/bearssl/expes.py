#!/usr/bin/python3
import sys
sys.path.insert(1, '../../python_scripts/')
from libxp import *
import params
import benchs

TIMEOUT=3600
N_ITER=5
STAT_FILE="stats/2022_29_05.csv"

## Use cases

if __name__ == '__main__':

    # Run expes for DES
    base_exec=["des_ct"]
    sizes=[ 8, 16, 24, 32, 40, 48 ]
    executables = benchs.get_executable_names_with_size(base_exec, sizes)

    base_exec=["aes_ct"]
    sizes=[ 16, 32, 48, 64, 80, 96 ]
    executables = executables + benchs.get_executable_names_with_size(base_exec, sizes)

    # Run expes
    benchs = benchs.BenchsMultiExec(executables)
    params = params.Params(timeout=TIMEOUT, n_iter=N_ITER, stat_file=STAT_FILE)
    xp_runner(benchs, params)

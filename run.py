#!/usr/bin/python3
import subprocess
import os
import argparse
import copy
from datetime import date
import experiments as E

today = date.today()

####
# Run script to test a file
####

# Range of values
SOLVER_SET = ['boolector', 'z3', 'cvc4', 'yices']
FP_RANGE = ['never', 'instr', 'block']
FP_RANGE_NOZERO = ['instr', 'block']
DD_RANGE = [0, 1, 2, 3, 5, 10, -1]
DEPTH_RANGE = [1000, 10000, 100000, 1000000, 10000000, 100000000]
#                1k,   10k,   100k,      1M,      10M,      100M

# Predefined symbolic stores
store_sse = "sse"
store_sse_opt = "sse-opt"
store_sc = "sc"
store_std_rel = "std-rel"
store_bin_rel = "bin-rel"
STORE_SET = [store_sc, store_std_rel, store_bin_rel]
DEF_STORE = store_bin_rel
prop_ct = "ct"
prop_secret_erasure = "secret-erasure"
DEF_PROP = prop_ct

# Default values
DEF_TO = '3600'        # 1 hour (3600s)
DEF_SOLVER_TO = '0'    # 0
DEF_DEPTH = '0'        # 0
DEF_PATHS = '0'        # 0
DEF_COUNT = 5
DEF_NC = True          # Nocomment

DEF_FP = 'instr'
DEF_DD = 1
DEF_SOLVER = 'boolector'
DEF_LEAKINFO = 'instr'  # {halt|instr|unique-leak}
DEF_PRINTMODEL = True
DEF_LOWDECL = False
DEF_OPTIMS = False
DEF_UNTAINTING = True  # Set untainting parameter

PWD = "./"

# Set parameters to run Binsec
class Params(object):

    def dated_output(self, prefix):
        self.output_file = prefix + "_" + str(today.isoformat())

    def set_store(self, store=DEF_STORE):
        if store == store_sse:
            self.store = "sse"
            self.canonical = False
            self.memory = "std"
        elif store == store_sse_opt:
            self.store = "sse"
            self.canonical = True
            self.memory = "row-map"
        elif store == store_sc:
            self.store = "sc"
            self.canonical = False
            self.memory = "std"
        elif store == store_std_rel:
            self.store = "rel"
            self.canonical = False
            self.memory = "std"
        elif store == store_bin_rel:
            self.store = "rel"
            self.canonical = True
            self.memory = "row-map"
        else:
            raise Exception('Invalid store: ' + str(store))

    def __init__(self, output_file="", smtdir="", fp=DEF_FP,
                 dd=DEF_DD, nc=DEF_NC, timeout=DEF_TO,
                 solver_timeout=DEF_SOLVER_TO, depth=DEF_DEPTH,
                 paths=DEF_PATHS, solver=DEF_SOLVER,
                 leak_info=DEF_LEAKINFO, print_model=DEF_PRINTMODEL,
                 store=DEF_STORE, debug=0, optims=DEF_OPTIMS,
                 untainting=DEF_UNTAINTING, low_decl=DEF_LOWDECL,
                 trace="", prop=DEF_PROP):
        if fp not in FP_RANGE:
            raise Exception('Invalid fp parameter: ' + str(fp))
        if dd not in DD_RANGE:
            raise Exception('Invalid dd parameter: ' + str(dd))
        self.fp = fp
        self.dd = dd
        if output_file == "":
            self.dated_output("")
        else:
            self.output_file = output_file
        self.smtdir = smtdir
        self.nc = nc
        self.timeout = timeout
        self.solver_timeout = solver_timeout
        self.depth = depth
        self.paths = paths
        self.solver = solver
        self.leak_info = leak_info
        self.print_model = print_model
        self.debug = debug
        self.optims = optims
        self.trace = trace
        self.low_decl = low_decl
        self.untainting = untainting
        self.set_store(store)
        self.prop = prop



######################
#     Runner
######################
def __clear_folder(folder):
    if os.path.isdir(folder):
        for myfile in os.listdir(folder):
            file_path = os.path.join(folder, myfile)
            try:
                if os.path.isfile(file_path):
                    os.unlink(file_path)
            except Exception as e:
                print(e)


def __make_cmd(exp, params):
    prefix = E.Experiment.name(exp)
    name = PWD + E.Experiment.folder(exp) + '/' + E.Experiment.name(exp)
    if params.smtdir != "" and not os.path.isdir(params.smtdir):
        os.makedirs(params.smtdir)
    if params.trace != "" and not os.path.isdir(params.trace):
        os.makedirs(params.trace)

    __clear_folder(params.smtdir + "/binsec_sse")
    __clear_folder(params.trace)
    highs = E.Experiment.high(exp)

    cmd = 'binsec -relse' + \
          ' -fml-solver-timeout ' + str(params.solver_timeout) + \
          (' -fml-optim-all' if params.optims else '') + \
          ' -relse-timeout ' + str(params.timeout) + \
          ' -relse-debug-level ' + str(params.debug) + \
          ' -sse-depth ' + str(params.depth) + \
          (' -sse-memory ' + E.Experiment.memory_file(exp)
           if E.Experiment.memory_file(exp) != '' else '') + \
          ' -relse-paths ' + str(params.paths) + \
          (' -sse-comment' if not params.nc else '') + \
          ' -sse-load-ro-sections' + \
          ' -sse-load-sections .got.plt,.data,.plt' + \
          ('' if E.Experiment.entrypoints(exp) == ''
           else ' -entrypoint ' + E.Experiment.entrypoints(exp)) + \
          ('' if E.Experiment.avoids(exp) == ''
           else ' -sse-no-explore ' + E.Experiment.avoids(exp)) + \
          (' -relse-stat-prefix ' + prefix if prefix != '' else '') + \
          (' -relse-stat-file ' + params.output_file + ".csv"
           if params.output_file != '' else '') + \
          (' -sse-smt-dir ' + params.smtdir
           if params.smtdir != '' else '') + \
          (' -fml-solver ') + params.solver + \
          (' -sse-address-trace-file ' + params.trace
           if params.trace != '' else '') + \
          ' -relse-store-type ' + params.store + \
          ' -relse-memory-type ' + params.memory + \
          ' -relse-property ' + params.prop + \
          ('' if E.Experiment.critical_func(exp) == ''
           else ' -relse-critical-func ' + E.Experiment.critical_func(exp)) + \
          (' -relse-no-canonical' if not params.canonical else '') + \
          (' -relse-high-var ' + highs if highs != '' else '') + \
          ' -relse-dedup ' + str(params.dd) + \
          ' -relse-fp ' + str(params.fp) + \
          (' -relse-leak-info ' + params.leak_info if params.leak_info != '' else '') + \
          (' -relse-print-model' if params.print_model else '') + \
          (' -relse-low-decl' if params.low_decl else '') + \
          (' -relse-no-untainting ' if not params.untainting else '') + \
          ' ' + name
    return cmd


# Run the experiments
def run(exp, params, check):
    relse = (params.store != store_sse and params.store != store_sse_opt)
    check = check and relse

    cmd = __make_cmd(exp, params)

    print("[__________RUNNING__________]\n")
    print(cmd)
    check = relse and params.fp != 'never'
    secure = 0
    insecure = 7
    none = 8
    to = 9
    process = subprocess.run(cmd, shell=True)
    ret = process.returncode

    wrong_secure = check and ret == secure and E.Experiment.secure(exp) is E.Status.FALSE
    wrong_insecure = (check and ret == insecure and
                      E.Experiment.secure(exp) is E.Status.TRUE)
  
    if ret != secure and ret != insecure and ret != none and ret != to:
        raise Exception('Unknown return code: ' + str(ret))
    elif wrong_secure:
        raise Exception('Program ' + E.Experiment.name(exp) + ' should\
        be insecure.')
    elif wrong_insecure:
        raise Exception('Program ' + E.Experiment.name(exp) + ' should\
        not be insecure.')
    else:
        print("[__________Program " + E.Experiment.name(exp) +
              " -> OK__________]\n\n")
    return ret


###############
#  EXPERIMENTS
#
def run_exp_with_params(exp, params, n):
    for i in range(n):
        run(exp, params, True)

# Self-composition
def exp_self_comp(exp, params, n):
    params.fp = 'instr'
    params.untainting = False
    params.optims = False        # Benjamin's ROW optim
    params.set_store(store_sc)
    run_exp_with_params(exp, params, n)

# Std Relse
def exp_std_relse(exp, params, n):
    params.fp = 'instr'
    params.untainting = False
    params.optims = False        # Benjamin's ROW optim
    params.set_store(store_std_rel)
    run_exp_with_params(exp, params, n)

# Std Relse + Untainting
def exp_std_relse_unt(exp, params, n):
    params.fp = 'instr'
    params.untainting = True
    params.optims = False        # Benjamin's ROW optim
    params.set_store(store_std_rel)
    run_exp_with_params(exp, params, n)

# Std Relse + Untainting + Fault-Packing
def exp_std_relse_unt_fp(exp, params, n):
    params.fp = 'block'
    params.untainting = True
    params.optims = False        # Benjamin's ROW optim
    params.set_store(store_std_rel)
    run_exp_with_params(exp, params, n)

# Relse + Flyrow
def exp_brelse(exp, params, n):
    params.fp = 'instr'
    params.untainting = False
    params.optims = False        # Benjamin's ROW optim
    params.set_store(store_bin_rel)
    run_exp_with_params(exp, params, n)

# Relse + Flyrow + Untainting
def exp_brelse_unt(exp, params, n):
    params.fp = 'instr'
    params.untainting = True
    params.optims = False        # Benjamin's ROW optim
    params.set_store(store_bin_rel)
    run_exp_with_params(exp, params, n)

# Relse + Flyrow + Untainting + FP
def exp_brelse_unt_fp(exp, params, n):
    params.fp = 'block'
    params.untainting = True
    params.optims = False        # Benjamin's ROW optim
    params.set_store(store_bin_rel)
    run_exp_with_params(exp, params, n)

# RelSE + PostRow
def exp_std_relse_postrow(exp, params, n):
    params.fp = 'instr'
    params.untainting = False
    params.optims = True        # Benjamin's ROW optim
    params.set_store(store_std_rel)
    run_exp_with_params(exp, params, n)

# SSE
def exp_sse(exp, params, n):
    params.untainting = False
    params.fp = 'never'
    params.optims = False        # Benjamin's ROW optim
    params.set_store(store_sse)
    run_exp_with_params(exp, params, n)

# Compare Sse + Postrow
def exp_sse_postrow(exp, params, n):
    params.untainting = False
    params.fp = 'never'
    params.optims = True        # Benjamin's ROW optim
    params.set_store(store_sse)
    run_exp_with_params(exp, params, n)

# SSE + FlyRow
def exp_sse_flyrow(exp, params, n):
    params.untainting = False
    params.fp = 'never'
    params.optims = False        # Benjamin's ROW optim
    params.set_store(store_sse_opt)
    run_exp_with_params(exp, params, n)


# Run on insecure examples to get a counterexample
def exp_insecure(exp, params, n):
    params.fp = 'instr'
    params.leak_info = 'instr'
    params.print_model = True
    params.low_decl = True
    params.trace = './__results__/insecure/trace/' + E.Experiment.name(exp) + '/'
    params.untainting = True
    run_exp_with_params(exp, params, n)


# Setting for testing the Relse
def exp_test(exp, params, n):
    params.nc = False
    params.print_model = True
    params.debug = 0
    params.smtdir = '/tmp/SMTDIR'
    params.trace = '/tmp/SMTDIR/trace/'
    params.untainting = True
    run_exp_with_params(exp, params, n)


def exp_scale_std(exp, params, n):
        exp_self_comp(exp, params, n)
        exp_std_relse(exp, params, n)
        exp_std_relse_unt(exp, params, n)
        exp_std_relse_unt_fp(exp, params, n)

def exp_scale_brelse(exp, params, n):
        exp_brelse(exp, params, n)
        exp_brelse_unt(exp, params, n)
        exp_brelse_unt_fp(exp, params, n)

def exp_scale_sse(exp, params, n):
        exp_std_relse_postrow(exp, params, n)
        exp_sse(exp, params, n)
        exp_sse_postrow(exp, params, n)
        exp_sse_flyrow(exp, params, n)
    

##########
# DO EXPE
##########
def unit_testing(exps, params):
    for exp in exps:
        run(exp, params, (params.store != store_sse and params.store != store_sse_opt))


def run_experiments(data_list, run_list, params, n):
    run_switcher = {
        "sc": exp_self_comp,
        "relse": exp_std_relse,
        "relse_unt": exp_std_relse_unt,
        "relse_unt_fp": exp_std_relse_unt_fp,
        "relse_flyrow": exp_brelse,
        "relse_flyrow_unt": exp_brelse_unt,
        "relse_flyrow_unt_fp": exp_brelse_unt_fp,
        "relse_postrow": exp_std_relse_postrow,
        "se": exp_sse,
        "se_postrow": exp_sse_postrow,
        "se_flyrow": exp_sse_flyrow,
        "best": exp_brelse_unt_fp,
        "test": exp_test,
        "insecure": exp_insecure,
        "scale_std": exp_scale_std,
        "scale_brelse": exp_scale_brelse,
        "scale_sse": exp_scale_sse,
    }
    for data in data_list:
        exps = E.data_switcher.get(data)
        for run in run_list:
            fun = run_switcher.get(run)
            for e in exps:
                fun(e, params, n)


######################
#     Main
#
def main():
    parser = argparse.ArgumentParser(description='Run Binsec/RelSE experiements.')
    parser.add_argument('-t', '--test', action='store_true',
                        help="Run test specified in run.py")
    parser.add_argument('-d', '--data', action='store', nargs="*",
                        help="Dataset to run (see data_switcher in experiments.py for datasets)")
    parser.add_argument('-e', '--exps', action='store', nargs="*",
                        help="Experiments to run { sc | relse | relse_unt | relse_unt_fp | \
                              relse_flyrow | relse_flyrow_unt | binsecrel | se | \
                              se_postrow | se_flyrow | relse_postrow | insecure | best | test \
                              scale_std | scale_brelse | scale_sse }")
    parser.add_argument('-o', "--out", action='store', nargs="?",
                        help="Name of the output file", default='')
    parser.add_argument('-to', action='store', nargs="?", type=int,
                        help="Timeout of the RelSE")
    parser.add_argument('-fp', action='store', nargs="?", type=str,
                        help="Fault-packing parameter")
    parser.add_argument('-dd', action='store', nargs="?", type=int,
                        help="Deduplication parameter")
    parser.add_argument('-n', action='store', nargs="?", type=int,
                        help="Number of iterations")
    parser.add_argument('-depth', action='store', nargs="?", type=int,
                        help="Exploration depth")
    parser.add_argument('-paths', action='store', nargs="?", type=int,
                        help="Number of paths to explore")
    parser.add_argument('-unt', action='store', nargs="?", type=int,
                        help="Untainting parameter (0 to unset)")
    parser.add_argument('-store', action='store', nargs="?", type=str,
                        help="The type of store { sse | sse-opt | sc | std-rel | bin-rel }")
    parser.add_argument('-prop', action='store', nargs="?", type=str,
                        help="Property to check { secret-erasure | ct }")

    args = parser.parse_args()

    params = Params()
    params.dated_output("/tmp/out" if args.out is None else args.out)
    params.timeout = DEF_TO if args.to is None else args.to
    params.untainting = (DEF_UNTAINTING if args.unt is None else
                         (False if args.unt == 0 else True))
    params.fp = DEF_FP if args.fp is None else args.fp
    params.dd = DEF_DD if args.dd is None else args.dd
    params.depth = DEF_DEPTH if args.depth is None else args.depth
    params.paths = DEF_PATHS if args.paths is None else args.paths
    params.set_store(DEF_STORE if args.store is None else args.store)
    params.prop = DEF_PROP if args.prop is None else args.prop
        
    print("[__________BEGIN__________]")
    if args.test:
        # Global options
        params.solver = 'boolector'
        params.solver_timeout = 0
        params.leak_info = 'instr'
        params.optims = False

        # Verbose options
        params.low_decl = False  # True
        params.nc = False
        params.print_model = True
        params.debug = 0
        params.smtdir = '/tmp/SMTDIR'
        params.trace = params.smtdir + '/trace/'

        # Experiments
        exps = [E.donna_0]
        unit_testing(exps, params)

    else:
        n = 1 if args.n is None else args.n
        if args.data is not None and len(args.data) > 0:
            dataset = args.data
        else:
            print("Please, give me a dataset to analyse with [-d].")
            exit(1)
        if args.exps is not None and len(args.exps) > 0:
            exps = args.exps
        else:
            print("Please, give me an experiment to run with [-e].")
            exit(1)

        run_experiments(dataset, exps, params, n)

    print("[__________End__________]")


main()

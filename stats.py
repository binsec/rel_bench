#!/usr/bin/python
import pandas as pd
import numpy as np
import argparse as argp
import matplotlib.pyplot as plt
import re
from os import walk
# import seaborn as sns

TARGET_DIR = "./__results__/"
FILES=["scale_tea",
       "scale_donna",
       "scale_aes_ct",
       "scale_aes_big",
       "scale_des_ct",
       "scale_des_tab",
       "scale_hacl_chacha20",
       "scale_hacl_sha256",
       "scale_hacl_sha512",
       "scale_hacl_curve25519",
       "scale_nacl_salsa20",
       "scale_nacl_chacha20",
       "scale_nacl_sha256",
       "scale_nacl_sha512",
       "scale_openssl_almeida"]

FILES_AGGR = [ "scale_ct_select", "scale_ct_sort",
               "scale_utility_hacl", "scale_utility_openssl"]

FILES_ALL = FILES + FILES_AGGR



############
# Useful projections
############
PROJ_FULL = ['x86instructions', 'paths', 'transient_paths_pht',
             'transient_paths_stl', 'Explor total', 'Insec total',
             'Total total', 'Explor time', 'Insec time', 'wall time',
             'violations', 'timeouts']
PROJ_MINIMAL = ['store_type', 'x86instructions', 'wall time', 'secure',
                'insecure', 'unknown', 'violations', 'timeouts']


def embellish_df(df, attributes):
    df = df.round({'x86instructions': 0, 'Total total': 0, '#I/s': 1,
                   'Explor total': 0, 'Insec total': 0, 'Explor time':
                   1, 'Insec time': 1, 'wall time': 1, 'paths': 0,
                   'secure': 0, 'insecure': 0, 'unknown': 0,
                   'violations': 0, 'timeouts': 0})
    cols_to_int = ['x86instructions', 'Total total', 'Explor total',
                   'Insec total', 'paths', 'timeouts',
                   'violations', 'secure', 'insecure', 'unknown']
    df[cols_to_int] = df[cols_to_int].astype('Int64')
    return df[attributes]


def pp_df(df, attributes):
    print(embellish_df(df, attributes).to_string())


def pp_df_tolatex(df, attributes):
    print(embellish_df(df, attributes).to_latex())


PRINT = pp_df_tolatex
 
############
# Category of optimizations
############
def store_type(store, mem_type, canonical, untaint, fp, bopt):
    store = ('SE' if (store == 'sse') else ('SC' if store == 'self-comp' else 'RelSE'))
    row = ('NoRow' if (mem_type == 'std' and canonical == 0 and bopt == 0) else
          ('FlyRow' if (mem_type == 'row-map' and canonical == 1 and bopt == 0) else 
          ('PostRow' if (mem_type == 'std' and canonical == 0 and bopt == 1) else 
           ("Undef(" + mem_type + str(canonical) + str(bopt) + ")"))))
    untaint = ('+Unt' if untaint == 1 else '')
    return (store + "+" + row + str(untaint) + "+Fp" + str(fp))

store_category = [
    "SE+NoRow+FpNever",
    "SE+PostRow+FpNever",
    "SE+FlyRow+FpNever",
    "SC+NoRow+FpInstr",
    "RelSE+NoRow+FpInstr",
    "RelSE+NoRow+Unt+FpInstr",
    "RelSE+NoRow+Unt+FpBlock",
    "RelSE+FlyRow+FpInstr",
    "RelSE+FlyRow+Unt+FpInstr",
    "RelSE+PostRow+FpInstr",
    "RelSE+FlyRow+Unt+FpBlock"]

def add_store_type(df):
    df['store_type'] = np.vectorize(store_type)(df['store'],
                                                df['mem_type'],
                                                df['canonical'],
                                                df['untainting'],
                                                df['fp'],
                                                df['bopt'])
    df['store_type'] = pd.Categorical(df['store_type'], store_category)
    return df



############
# Compute status
############
def add_status(df):
    df['timeouts'] = df['status'].apply(lambda x: 1 if x != 0 else 0)
    df['secure'] = df['exit code'].apply(lambda x: 1 if x == 0 else 0)
    df['insecure'] = df['violations'].apply(lambda x: 1 if x > 0 else 0)
    df['unknown'] = np.vectorize((lambda x, y: 1 if x != 0 and y != 1 else 0))(df['status'], df['insecure'])
    return df


############
# Restrict dataset to category
############
def insecure(df):
    return df[df['insecure'] > 0]

def secure(df):
    return df[df['insecure'] == 0]

def full(df):
    return df

def assert_unique_value(df, column_name):
    result_column = df[column_name] == df[column_name].iloc[0]
    if (not result_column.all()):
        raise ValueError('Value in column ' + column_name + ' sould be \
        unique.')


############
# DFs from files
############
# Compute new label
def label_from_filename(file_name):
    return re.sub('^scale_', '', re.sub('_[0-9]{4}-[0-9]{2}-[0-9]{2}.csv$', '', file_name))

# Compute new label
def label_concat_filename(df, file_name):
    df['label'] = np.vectorize(lambda l: label_from_filename(file_name) + "_" + l)(df['label'])
    return df

def label_filename_only(df, file_name):
    df['label'] = label_from_filename(file_name)
    return df

def add_df(df_list, path, target, label_func):
    df = pd.read_csv(path + target)
    # Compute new label
    df = label_func(df, target)
    # Compute new store_type column
    df = add_store_type(df)
    # Compute status
    df = add_status(df)
    # Add to df_list
    df_list.append(df)
    return df_list
   
def get_df(path, file_list, restriction=full):
    df_list = []
    for (_, _, filenames) in walk(path): break
    # For each file in __results__
    for filename in filenames:
        # If the filename matches one on the file to process
        for file_to_process in file_list:
            regex = re.compile(file_to_process + '_[0-9]{4}-[0-9]{2}-[0-9]{2}.csv')
            if regex.match(filename):
                df_list = add_df(df_list, path, filename, label_concat_filename)
                break
    df = pd.concat(df_list).set_index('label')
    df = restriction(df)
    return df

# Sum aggregate grouped on label and store_type
def get_aggregated_df_sum(path, file_list, restriction=full):
    df_list = []
    for (_, _, filenames) in walk(path): break
    # For each file in __results__
    for filename in filenames:
        # If the filename matches one on the file to process
        for file_to_process in file_list:
            regex = re.compile(file_to_process + '_[0-9]{4}-[0-9]{2}-[0-9]{2}.csv')
            if regex.match(filename):
                df_list = add_df(df_list, path, filename, label_filename_only)
                break
    df = pd.concat(df_list)
    df = restriction(df)
    df = df.groupby(['label', 'store_type']).sum().reset_index()
    return df.set_index('label')

def print_total(df, attributes):
    # Print total
    total = df.reset_index()
    total['label'] = "Total"
    total = total.groupby('label').sum()
    PRINT(total, attributes)


############
# Print Tables
############
def print_bv_stats():
    df1 = get_df(TARGET_DIR, FILES, restriction=secure)
    df2 = get_aggregated_df_sum(TARGET_DIR, FILES_AGGR, restriction=secure)
    df = pd.concat([df1, df2], sort=True)

    attributes = ['x86instructions', 'wall time', 'secure', 'unknown']
    # Restrict df to interesting stores
    df = df[df['store_type'] == "RelSE+FlyRow+Unt+FpBlock"]
    # Print
    PRINT(df, attributes)
    print_total(df, attributes)


def print_bf_stats():
    df1 = get_df(TARGET_DIR, FILES, restriction=insecure)
    df2 = get_aggregated_df_sum(TARGET_DIR, FILES_AGGR, restriction=insecure)
    df = pd.concat([df1, df2], sort=True)
    
    attributes = ['x86instructions', 'wall time', 'insecure', 'violations']
    # Restrict df to interesting stores
    df = df[df['store_type'] == "RelSE+FlyRow+Unt+FpInstr"]
    # Print
    PRINT(df, attributes)
    print_total(df, attributes)


def print_comp_sdt_stats():
    # Import data in a dataframe
    df1 = get_df(TARGET_DIR, FILES)
    df2 = get_aggregated_df_sum(TARGET_DIR, FILES_AGGR)
    df = pd.concat([df1, df2], sort=True)
    
    # Group by store_type
    total = df.groupby('store_type').sum()

    # Drop uninteresting stores
    interesting_stores = [    "SC+NoRow+FpInstr",
                              "RelSE+NoRow+FpInstr",
                              "RelSE+FlyRow+Unt+FpBlock"]
    total = total.loc[total.index.isin(interesting_stores, level="store_type")]

    # Compute I/s
    total['#I/s'] = total['x86instructions'] / total['wall time']
    
    # Print
    attributes = ['x86instructions', '#I/s', 'Total total', \
                  'Explor total', 'Insec total', 'wall time', 'timeouts', \
                  'secure', 'insecure']
    PRINT(total, attributes)


def print_comp_options_stats():
    # Import data in a dataframe
    df1 = get_df(TARGET_DIR, FILES)
    df2 = get_aggregated_df_sum(TARGET_DIR, FILES_AGGR)
    df = pd.concat([df1, df2], sort=True)
    
    # Group by store_type
    total = df.groupby('store_type').sum()

    # Drop uninteresting stores
    interesting_stores = [ "RelSE+NoRow+FpInstr",
                           "RelSE+NoRow+Unt+FpInstr",
                           "RelSE+NoRow+Unt+FpBlock",
                           "RelSE+FlyRow+FpInstr",
                           "RelSE+FlyRow+Unt+FpInstr",
                           "RelSE+FlyRow+Unt+FpBlock"]
    total = total.loc[total.index.isin(interesting_stores, level="store_type")]

    # Compute I/s
    total['#I/s'] = total['x86instructions'] / total['wall time']
    
    # Print
    attributes = ['x86instructions', '#I/s', 'Total total', \
                  'Explor total', 'Insec total', 'wall time', 'timeouts', \
                  'secure', 'insecure']
    PRINT(total, attributes)


def print_comp_sse_stats():
    # Import data in a dataframe
    df1 = get_df(TARGET_DIR, FILES)
    df2 = get_aggregated_df_sum(TARGET_DIR, FILES_AGGR)
    df = pd.concat([df1, df2], sort=True)
    
    # Group by store_type
    total = df.groupby('store_type').sum()

    # Drop uninteresting stores
    interesting_stores = [ "SE+NoRow+FpNever",
                           "SE+PostRow+FpNever",
                           "SE+FlyRow+FpNever",
                           "RelSE+NoRow+FpInstr",
                           "RelSE+PostRow+FpInstr",
                           "RelSE+FlyRow+Unt+FpBlock"]
    total = total.loc[total.index.isin(interesting_stores, level="store_type")]

    # Compute I/s
    total['#I/s'] = total['x86instructions'] / total['wall time']
    
    # Print
    attributes = ['x86instructions', '#I/s', 'Total total', 'wall time', 'timeouts']
    PRINT(total, attributes)


def main():

    parser = argp.ArgumentParser(description='Which stats would you like to see ?')
    parser.add_argument('-bv', action='store_true', help="Show bounded-verification stats.")
    parser.add_argument('-bf', action='store_true', help="Show bug-finding stats.")
    parser.add_argument('-sc', action='store_true', help="Show scale stats.")
    parser.add_argument('-sse', action='store_true', help="Show sse scale stats.")
    args = parser.parse_args()
 
    # --- Bounded verification
    if args.bv:
        print("\n\n--- BV")
        print_bv_stats()

    if args.bf:
        print("\n\n--- BF")
        print_bf_stats()

    # --- Scale experiments
    if args.sc:
        print("\n\n--- Scale")
        print_comp_sdt_stats()
        print("\n\n--- Scale-options")
        print_comp_options_stats()

    # --- Comparison with SE
    if args.sse:
        print("\n\n--- SE")
        print_comp_sse_stats()

    plt.close('all')

main()

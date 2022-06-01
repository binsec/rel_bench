import numpy as np
import pandas as pd
import sys
from scipy import stats

############
# Useful projections
############
PROJ_FULL = ['x86instructions', 'paths', 'Explor total', 'Insec total',
             'Total total', 'Explor time', 'Insec time', 'wall time', 'timeouts']
PROJ_MINIMAL = ['x86instructions', 'Total total', 'wall time']

TIME_PROJ=['T_1', 'T_2', 'T_3', 'T_4', 'T_5', 'T_6']
FULL_TIME_PROJ=['label','BS'] + TIME_PROJ

FACTOR_PROJ=['BT', 'IF_2', 'IF_3', 'IF_4', 'IF_5', 'IF_6']
FULL_FACTOR_PROJ=['label', 'BS'] + FACTOR_PROJ

def embellish_df(df, attributes):
    df = df.round({'x86instructions': 0, 'Total total': 0,
                   'Explor total': 0, 'Insec total': 0, 'Explor time': 3,
                   'Insec time': 3, 'wall time': 3, 'paths': 0,
                   'secure': 0, 'insecure': 0, 'unknown': 0,
                   'violations': 0, 'timeouts': 0})
    cols_to_int = ['x86instructions', 'Total total', 'Explor total',
                   'Insec total', 'paths',  'timeouts',
                   'violations', 'secure', 'insecure', 'unknown']
    df[cols_to_int] = df[cols_to_int].astype('Int64')
    return df[attributes]

def pp_df(df, attributes):
    print(embellish_df(df, attributes).to_string())

def pp_df_tolatex(df, attributes):
    print(embellish_df(df, attributes).to_latex(index=False))

def pp_df_time_tolatex(df):
    tmp = df.round(1)
    print(tmp.to_latex(index=False))

def pp_df_if_tolatex(df):
    tmp = df.round(1)
    print(tmp.to_latex(index=False))


############
# Store type category
############
def store_type(store, mem_type, canonical, untaint, fp, bopt):
    # Sse
    if (store == 'sse' and mem_type == 'std' and bopt != 1):
        return "0-sse"
    elif (store == 'sse' and mem_type == 'std' and bopt == 1):
        return "0-sse-bopt"
    elif (store == 'sse' and mem_type == 'row-map' and bopt != 1):
        return "1-bin-sse"
    # Self-comp
    elif (store == 'self-comp' and mem_type == "std" and canonical == 0 and
          untaint == 0 and fp == 1 and bopt != 1):
        return "2-sc"
    elif (store == 'self-comp' and mem_type == "std" and canonical == 0 and
          fp == 0 and bopt != 1):
        return "2-sc-no-check"
    # RelSE
    elif (store == 'relational' and mem_type == "std" and canonical == 0 and
          untaint == 0 and fp == 1 and bopt != 1):
        return "3-relse"
    elif (store == 'relational' and mem_type == "std" and canonical == 0 and
          untaint == 0 and fp == 1 and bopt == 1):
        return "3-relse-bopt"
    elif (store == 'relational' and mem_type == "std" and canonical == 0 and
          untaint == 1 and fp == 1 and bopt != 1):
        return "3-relse-unt"
    elif (store == 'relational' and mem_type == "std" and canonical == 0 and
          untaint == 1 and fp == 2 and bopt != 1):
        return "3-relse-unt-fp"
    elif (store == 'relational' and mem_type == "std" and canonical == 0 and
          fp == 0 and bopt != 1):
        return "3-relse-no-check"
    # BinRelSE
    elif (store == 'relational' and mem_type == "row-map" and
          canonical == 1 and untaint == 0 and fp == 1 and bopt != 1):
        return "4-bin-relse"
    elif (store == 'relational' and mem_type == "row-map" and
          canonical == 1 and untaint == 1 and fp == 1 and bopt != 1):
        return "4-bin-relse-unt"
    elif (store == 'relational' and mem_type == "row-map" and
          canonical == 1 and untaint == 1 and fp == 2 and bopt != 1):
        return "4-bin-relse-unt-fp"
    elif (store == 'relational' and mem_type == "row-map" and
          canonical == 1 and fp == 0 and bopt != 1):
        return "4-bin-relse-no-check"
    else:
        return "undef"


def add_store_type(df):
    if not ('bopt' in df.columns):
        df['bopt'] = 0
    df['store_type'] = np.vectorize(store_type)(df['store'],
                                                df['mem_type'],
                                                df['canonical'],
                                                df['untainting'],
                                                df['fp'],
                                                df['bopt'])
    return df


############
# Compute status
############
def add_status(df):
    df['timeouts'] = df['status'].apply(lambda x: 0 if x == 0 else 1)
    df['secure'] = df['exit code'].apply(lambda x: 1 if x == "Secure" else 0)
    df['insecure'] = df['exit code'].apply(lambda x: 1 if x ==
                                           "Insecure" else 0)
    df['unknown'] = df['exit code'].apply(lambda x: 1 if x == "Unknown" else 0)
    return df

############
# Add size as column
############
def add_size(df):
    df['size'] = df['label'].apply(lambda x: int(x.split('_')[-2]))
    df['label'] = df['label'].apply(lambda x: '_'.join(x.split('_')[:-2]))
    return df

############
# Add directory to label
############
def add_directory(df, path):
    directory = path.split('/')[-3]
    df['label'] = df['label'].apply(lambda x: directory + '_' + x)
    return df

############
# DFs from files
############
def assert_unique_value(df, column_name):
    result_column = df[column_name] == df[column_name].iloc[0]
    if (not result_column.all()):
        raise ValueError('Value in column ' + column_name + ' sould be \
        unique.')

def get_df_from_files(path, file_list):
    df_list = []
    for file_name in file_list:
        target = path + file_name + '.csv'
        df = pd.read_csv(target)
        # Compute new store_type column
        df = add_store_type(df)
        # Check if all store elements are equal
        assert_unique_value(df, "store_type")
        # Compute status
        df = add_status(df)
        df = add_size(df)
        df = add_directory(df,path)
        # Add to df_list
        df_list.append(df)

    return pd.concat(df_list)


############
# Useful aggregates
############
def aggregate_label_size(df):
    # Compute mean per label
    df = df.groupby(['label','size']).median()
    return df

def table_time(df, sizes):
    df = df['wall time']
    df = df.rename(level=1, index=dict(zip(sizes, TIME_PROJ)))
    df = df.unstack('size').reset_index(drop=False)
    df['BS'] = sizes[0]
    df = df.reindex(columns=FULL_TIME_PROJ)
    return df

def table_factor(df, sizes):
    df = df['wall time']
    for label in df.index.get_level_values('label').unique():
        df_label = df.loc[label]
        base_value = df_label.loc[sizes[0]]
        df[label,FACTOR_PROJ[0]] = base_value
        for size in range(2,7):
            idx = sizes[size-1]
            scaled_value = df_label.loc[idx] / base_value
            df.loc[label,FACTOR_PROJ[size-1]]=scaled_value
    df = df.unstack('size').reset_index(drop=False)
    df['BS'] = sizes[0]
    df = df.reindex(columns=FULL_FACTOR_PROJ)
    return df

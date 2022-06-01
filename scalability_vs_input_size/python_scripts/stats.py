import sys
import import_csv as I
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import numpy as np

pp = I.pp_df


def get_stat_dir(name):
    return "../src/" + name + "/stats/"


def get_df_aggregate(directory, files):
    # Get the dataframe
    stat_dir = get_stat_dir(directory)
    df = I.get_df_from_files(stat_dir, files)
    # pht = I.aggregate_spectre_pht(df, dyn="Full")
    # pht = I.total_sum_spectre_pht(pht)
    # pht['label'] = directory
    df = I.aggregate_label_size(df)
    return df

def pp_stl(df):
    pp(df, I.PROJ_FULL_STL)


def pp_total_pht(df_list):
    print("\n\n### TOTAL PHT\n\n")
    df = pd.concat(df_list, sort=False)
    df = I.total_sum_spectre_pht(df)
    pp_pht(df)


def pp_total_stl(df_list):
    print("\n\n### TOTAL STL\n\n")
    df = pd.concat(df_list, sort=False)
    df = I.total_sum_spectre_stl(df)
    pp_stl(df)


def pp_overhead(df_list):
    print("\n\n### TOTAL PHT\n\n")
    df = pd.concat(df_list, sort=False)
    I.compute_time_overhead(df)
    # df = I.total_sum_spectre_pht(df)
    # pp_pht(df)

    
# ------------ Get STAT files
directory = "hacl_utility"
files = ["2022_27_05"]
hacl_cmp = get_df_aggregate(directory, files)

directory = "hacl"
files = ["2022_27_05"]
hacl = get_df_aggregate(directory, files)

directory = "libsodium"
files = ["2022_27_05"]
libsodium = get_df_aggregate(directory, files)

directory = "bearssl"
files = ["2022_29_05"]
bearssl = get_df_aggregate(directory, files)

directory = "openssl_almeida"
files = ["2022_29_05"]
openssl = get_df_aggregate(directory, files)
# ------------


def main():
    stream_cipher_sizes = [500, 1000, 1500, 2000, 2500, 3000]
    des_sizes = [ 8, 16, 24, 32, 40, 48 ]
    aes_sizes = [ 16, 32, 48, 64, 80, 96 ]
    openssl_sizes = [ 64, 128, 192, 256, 320, 384 ]

    print("\n\n### Hacl-cmp\n\n")
    pp(hacl_cmp, I.PROJ_MINIMAL)
    hacl_cmp_time = I.table_time(hacl_cmp, stream_cipher_sizes)
    I.pp_df_time_tolatex(hacl_cmp_time)
    hacl_cmp_factor = I.table_factor(hacl_cmp, stream_cipher_sizes)
    I.pp_df_if_tolatex(hacl_cmp_factor)

    print("\n\n### Hacl\n\n")
    pp(hacl, I.PROJ_MINIMAL)
    hacl_time = I.table_time(hacl, stream_cipher_sizes)
    I.pp_df_time_tolatex(hacl_time)
    hacl_factor = I.table_factor(hacl, stream_cipher_sizes)
    I.pp_df_if_tolatex(hacl_factor)

    print("\n\n### Libsodium\n\n")
    pp(libsodium, I.PROJ_MINIMAL)
    libsodium_time = I.table_time(libsodium, stream_cipher_sizes)
    I.pp_df_time_tolatex(libsodium_time)
    libsodium_factor = I.table_factor(libsodium, stream_cipher_sizes)
    I.pp_df_if_tolatex(libsodium_factor)

    print("\n\n### Bearssl\n\n")
    pp(bearssl, I.PROJ_MINIMAL)
    bearssl_aes=bearssl[bearssl.index.get_level_values(0).isin(['bearssl_aes_ct'])].copy()
    bearssl_aes_time = I.table_time(bearssl_aes, aes_sizes)
    I.pp_df_time_tolatex(bearssl_aes_time)
    bearssl_aes_factor = I.table_factor(bearssl_aes, aes_sizes)
    I.pp_df_if_tolatex(bearssl_aes_factor)
    bearssl_des=bearssl[bearssl.index.get_level_values(0).isin(['bearssl_des_ct'])].copy()
    bearssl_des_time = I.table_time(bearssl_des, des_sizes)
    I.pp_df_time_tolatex(bearssl_des_time)
    bearssl_des_factor = I.table_factor(bearssl_des, des_sizes)
    I.pp_df_if_tolatex(bearssl_des_factor)


    print("\n\n### Openssl-almeida\n\n")
    pp(openssl, I.PROJ_MINIMAL)
    openssl_time = I.table_time(openssl, openssl_sizes)
    I.pp_df_time_tolatex(openssl_time)
    openssl_factor = I.table_factor(openssl, openssl_sizes)
    I.pp_df_if_tolatex(openssl_factor)

    all_time=[hacl_cmp_time,hacl_time,libsodium_time,bearssl_aes_time,bearssl_des_time,openssl_time]
    I.pp_df_time_tolatex(pd.concat(all_time))
    all_factor=[hacl_cmp_factor,hacl_factor,libsodium_factor,bearssl_aes_factor,bearssl_des_factor,openssl_factor]
    I.pp_df_time_tolatex(pd.concat(all_factor))

    df = pd.concat(all_factor)
    df = df.set_index('label')
    df = df.drop(['BS','BT'], axis = 1)
    df['IF_last'] = 1
    df.columns = [2, 3, 4, 5, 6, 1]
    df = df.transpose().reset_index()
    df = df.sort_values(by=['index'])
    df = df.rename(columns={'openssl_almeida_tls1_cbc_remove_padding_patch': 'openssl_tls-remove-padding-patch',
                            'hacl_utility_cmp_bytes_O0': 'hacl-utility_cmp-bytes-O0',
                            'hacl_utility_cmp_bytes_O0': 'hacl-utility_cmp-bytes-O3',
                            'bearssl_aes_ct': 'bearssl_aes-ct',
                            'bearssl_des_ct': 'bearssl_des-ct'})
    df['index'] = ['S1', 'S2', 'S3', 'S4', 'S5', 'S6']

    # plt.scatter(df['index'],y=[df["hacl_utility_cmp_bytes_O0"]])
    # plt.scatter(df['index'],y=[df["hacl_utility_cmp_bytes_O3"]])
    # plt.scatter(df['index'],y=[df["libsodium_chacha20"]])
  #  # plt.plot(df['index'],df["cmp_bytes_O0" ])
    # plt.show()
    # df.plot(x="index", y=["hacl_utility_cmp_bytes_O0"], kind="scatter", style='-o', figsize=(10, 9))
    y_axis = df.columns.values.tolist()[1:]
    print(y_axis)
    styles = ['d', 'v', '^', '<', '>', 's', 'p', 'P', '*', 'H', 'D', 'o']
    i = 0
    for label in y_axis:
        plt.scatter(df['index'], df[label], marker=styles[i], label=label)
        plt.plot(df['index'], df[label])
        i = i + 1


    # df.plot(x="index", y=y_axis, kind="line", style='-o', figsize=(10, 9))
    # plt.title("Sports Watch Data", loc = 'left')
    from matplotlib import rc
    # rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
    # plt.xlabel('Size')  # Add an x-label to the axes.
    plt.ylabel('Ratio of execution time compared to S1')  # Add a y-label to the axes.
    plt.legend(loc="upper left", bbox_to_anchor=[0, 1],
               ncol=1, fontsize='small', markerscale=0.6)
    plt.grid(axis='y')
    # plt.show()
    plt.savefig("scale_size.png", transparent=True, dpi=1000,
                bbox_inches='tight', pad_inches=0)
    exit(0)


main()

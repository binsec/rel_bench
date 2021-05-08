from enum import Enum

#################
#     UTILS
#################
default_mem_file = "memory.txt"


class Status(Enum):
    TRUE = 1
    FALSE = 2
    UNKNOWN = 3


def array_byte(addr, size):
    if size > 0:
        out = ''
        for off in range(0, size):
            out += hex(addr - off) + ','
        return out[:-1]
    else:
        return ''


int_size = 32
byte_size = 8


def array_int(addr, size):
    return array_byte(addr, size * (int_size // byte_size))


######################
#     EXPERIMENTS
######################
class Experiment(object):

    def __init__(self, folder, name, secure, entrypoints='',
                 avoids='', high='', spectre_secure=Status.TRUE,
                 critical_func=''):
        self.__folder = folder
        self.__name = name
        self.__entrypoints = entrypoints
        self.__avoids = avoids
        self.__high = high
        self.__secure = secure
        self.__spectre_secure = spectre_secure
        self.__memory_file = ""
        self.__critical_func = critical_func

    # Add a high variable at address [adr] of size [sz] bytes
    def add_high(self, adr, sz):
        self.__high += "," + array_byte(adr, sz)

    # Add [sz] high 32-bits integers at address [adr]
    def add_high_int(self, adr, sz):
        self.__high += "," + array_int(adr, sz)

    def add_avoids(self, adr):
        self.__avoids += "," + adr

    def set_memory_file(self, name):
        self.__memory_file = name

    # --- Accessors

    def folder(self): return self.__folder

    def name(self): return self.__name

    def entrypoints(self): return self.__entrypoints

    def avoids(self): return self.__avoids

    def high(self): return self.__high

    def secure(self): return self.__secure

    def spectre_secure(self): return self.__spectre_secure

    def memory_file(self):
        if self.__memory_file != '':
            return self.__folder + '/' + self.__memory_file
        else:
            return self.__folder + '/' + default_mem_file

    def critical_func(self): return self.__critical_func


def make_compiler_expes(directory, file_name):
    cl30_0 = Experiment(directory, file_name + '_cl30_O0', Status.UNKNOWN)
    cl30_3 = Experiment(directory, file_name + '_cl30_O3', Status.UNKNOWN)
    cl39_0 = Experiment(directory, file_name + '_cl39_O0', Status.UNKNOWN)
    cl39_3 = Experiment(directory, file_name + '_cl39_O3', Status.UNKNOWN)
    cl7_0 = Experiment(directory, file_name + '_cl7_O0', Status.UNKNOWN)
    cl7_3 = Experiment(directory, file_name + '_cl7_O3', Status.UNKNOWN)
    gcc5_0 = Experiment(directory, file_name + '_gcc5_O0', Status.UNKNOWN)
    gcc5_3 = Experiment(directory, file_name + '_gcc5_O3', Status.UNKNOWN)
    gcc8_0 = Experiment(directory, file_name + '_gcc8_O0', Status.UNKNOWN)
    gcc8_3 = Experiment(directory, file_name + '_gcc8_O3', Status.UNKNOWN)
    return [cl30_0, cl30_3, cl39_0, cl39_3, cl7_0, cl7_3, gcc5_0,
            gcc5_3, gcc8_0, gcc8_3]


###########
# Toys New
###########
directory = 'src/ct/toys'
conditional_insec = Experiment(directory, 'conditional_insecure_O0', Status.FALSE)
conditional_sec = Experiment(directory, 'conditional_secure_O0', Status.TRUE)
function_call_insec = Experiment(directory, 'function_call_insecure_O0', Status.FALSE)
function_call_sec = Experiment(directory, 'function_call_secure_O0', Status.TRUE)
function_return_insec = Experiment(directory, 'function_return_insecure_O0', Status.FALSE)
function_return_sec = Experiment(directory, 'function_return_secure_O0', Status.TRUE)
loop_insec = Experiment(directory, 'loop_insecure_O0', Status.FALSE)
loop_sec = Experiment(directory, 'loop_secure_O0',  Status.TRUE)
memory_access_insec = Experiment(directory, 'memory_access_insecure_O0', Status.FALSE)
memory_access_sec = Experiment(directory, 'memory_access_secure_O0', Status.TRUE)
double_insecure = Experiment(directory, 'double_insecure_O0', Status.FALSE)
toys = [conditional_insec, conditional_sec, function_call_insec,
        function_call_sec, function_return_insec,
        function_return_sec, loop_insec, loop_sec,
        memory_access_insec, memory_access_sec, double_insecure]


##########
# TEA New
##########
directory = 'src/ct/tea'
tea_enc = Experiment(directory, 'tea_encrypt_O0', Status.TRUE)
tea_dec_0 = Experiment(directory, 'tea_decrypt_O0', Status.TRUE)
tea_dec_1 = Experiment(directory, 'tea_decrypt_O1', Status.TRUE)
tea_dec_2 = Experiment(directory, 'tea_decrypt_O2', Status.TRUE)
tea_dec_3 = Experiment(directory, 'tea_decrypt_O3', Status.TRUE)
tea_dec_f = Experiment(directory, 'tea_decrypt_Of', Status.TRUE)
teas = [tea_enc, tea_dec_0, tea_dec_1, tea_dec_2, tea_dec_3, tea_dec_f]


############
# Donna new
############
directory = 'src/ct/donna'
donna_0 = Experiment(directory, 'donna_O0', Status.TRUE)
donna_1 = Experiment(directory, 'donna_O1', Status.TRUE)
donna_2 = Experiment(directory, 'donna_O2', Status.TRUE)
donna_3 = Experiment(directory, 'donna_O3', Status.TRUE)
donna_f = Experiment(directory, 'donna_Of', Status.TRUE)
donnas = [donna_0, donna_1, donna_2, donna_3, donna_f]


#########
# HACL*
#########
directory = 'src/ct/hacl'
hacl_chacha20 = Experiment(directory, 'chacha20', Status.TRUE)
hacl_chacha20.set_memory_file("chacha20.mem")
hacl_curve25519 = Experiment(directory, 'curve25519', Status.TRUE)
hacl_curve25519.set_memory_file("curve25519.mem")
hacl_sha256 = Experiment(directory, 'sha256', Status.TRUE)
hacl_sha256.set_memory_file("sha256.mem")
hacl_sha512 = Experiment(directory, 'sha512', Status.TRUE)
hacl_sha512.set_memory_file("sha512.mem")
hacls = [hacl_chacha20, hacl_curve25519, hacl_sha256, hacl_sha512]


#########
# ct-select
#########
directory = 'src/ct/ct-select'
# select v1
ct_select_v1_cl30_0 = Experiment(directory, 'ct_select_v1_cl30_O0', Status.TRUE)
ct_select_v1_cl30_3 = Experiment(directory, 'ct_select_v1_cl30_O3', Status.FALSE)
ct_select_v1_cl39_0 = Experiment(directory, 'ct_select_v1_cl39_O0', Status.TRUE)
ct_select_v1_cl39_3 = Experiment(directory, 'ct_select_v1_cl39_O3', Status.FALSE)
ct_select_v1_gcc_0 = Experiment(directory, 'ct_select_v1_gcc_O0', Status.TRUE)
ct_select_v1_gcc_3 = Experiment(directory, 'ct_select_v1_gcc_O3', Status.TRUE)
# select v2
ct_select_v2_cl30_0 = Experiment(directory, 'ct_select_v2_cl30_O0', Status.TRUE)
ct_select_v2_cl30_3 = Experiment(directory, 'ct_select_v2_cl30_O3', Status.FALSE)
ct_select_v2_cl39_0 = Experiment(directory, 'ct_select_v2_cl39_O0', Status.TRUE)
ct_select_v2_cl39_3 = Experiment(directory, 'ct_select_v2_cl39_O3', Status.FALSE)
ct_select_v2_gcc_0 = Experiment(directory, 'ct_select_v2_gcc_O0', Status.TRUE)
ct_select_v2_gcc_3 = Experiment(directory, 'ct_select_v2_gcc_O3', Status.TRUE)
# select v3
ct_select_v3_cl30_0 = Experiment(directory, 'ct_select_v3_cl30_O0', Status.TRUE)
ct_select_v3_cl30_3 = Experiment(directory, 'ct_select_v3_cl30_O3', Status.TRUE)
ct_select_v3_cl39_0 = Experiment(directory, 'ct_select_v3_cl39_O0', Status.TRUE)
ct_select_v3_cl39_3 = Experiment(directory, 'ct_select_v3_cl39_O3', Status.FALSE)
ct_select_v3_gcc_0 = Experiment(directory, 'ct_select_v3_gcc_O0', Status.TRUE)
ct_select_v3_gcc_3 = Experiment(directory, 'ct_select_v3_gcc_O3', Status.TRUE)
# select v4
ct_select_v4_cl30_0 = Experiment(directory, 'ct_select_v4_cl30_O0', Status.TRUE)
ct_select_v4_cl30_3 = Experiment(directory, 'ct_select_v4_cl30_O3', Status.FALSE)
ct_select_v4_cl39_0 = Experiment(directory, 'ct_select_v4_cl39_O0', Status.TRUE)
ct_select_v4_cl39_3 = Experiment(directory, 'ct_select_v4_cl39_O3', Status.FALSE)
ct_select_v4_gcc_0 = Experiment(directory, 'ct_select_v4_gcc_O0', Status.TRUE)
ct_select_v4_gcc_3 = Experiment(directory, 'ct_select_v4_gcc_O3', Status.TRUE)
# Naive select
ct_select_naive_cl30_0 = Experiment(directory, 'naive_select_cl30_O0', Status.FALSE)
ct_select_naive_cl30_3 = Experiment(directory, 'naive_select_cl30_O3', Status.FALSE)
ct_select_naive_cl39_0 = Experiment(directory, 'naive_select_cl39_O0', Status.FALSE)
ct_select_naive_cl39_3 = Experiment(directory, 'naive_select_cl39_O3', Status.FALSE)
ct_select_naive_gcc_0 = Experiment(directory, 'naive_select_gcc_O0', Status.FALSE)
ct_select_naive_gcc_3 = Experiment(directory, 'naive_select_gcc_O3', Status.FALSE)

# Better way
ct_select_v1 = make_compiler_expes(directory, 'ct_select_v1')
ct_select_v2 = make_compiler_expes(directory, 'ct_select_v2')
ct_select_v3 = make_compiler_expes(directory, 'ct_select_v3')
ct_select_v4 = make_compiler_expes(directory, 'ct_select_v4')
ct_select_naive = make_compiler_expes(directory, 'naive_select')
ct_select = ct_select_v1 + ct_select_v2 + ct_select_v3 + ct_select_v4 + ct_select_naive


#########
# ct-sort
#########
directory = 'src/ct/ct-sort'
# sort
sort_cl30_0 = Experiment(directory, 'sort_cl30_O0', Status.TRUE)
sort_cl30_3 = Experiment(directory, 'sort_cl30_O3', Status.FALSE)
sort_cl39_0 = Experiment(directory, 'sort_cl39_O0', Status.TRUE)
sort_cl39_3 = Experiment(directory, 'sort_cl39_O3', Status.FALSE)
sort_cl7_0 = Experiment(directory, 'sort_cl7_O0', Status.TRUE)
sort_cl7_3 = Experiment(directory, 'sort_cl7_O3', Status.TRUE)
sort_gcc5_0 = Experiment(directory, 'sort_gcc5_O0', Status.FALSE)
sort_gcc5_3 = Experiment(directory, 'sort_gcc5_O3', Status.TRUE)
sort_gcc8_0 = Experiment(directory, 'sort_gcc8_O0', Status.FALSE)
sort_gcc8_3 = Experiment(directory, 'sort_gcc8_O3', Status.TRUE)
# sort_multiplex
sort_multiplex_cl30_0 = Experiment(directory, 'sort_multiplex_cl30_O0', Status.TRUE)
sort_multiplex_cl30_3 = Experiment(directory, 'sort_multiplex_cl30_O3', Status.FALSE)
sort_multiplex_cl39_0 = Experiment(directory, 'sort_multiplex_cl39_O0', Status.TRUE)
sort_multiplex_cl39_3 = Experiment(directory, 'sort_multiplex_cl39_O3', Status.FALSE)
sort_multiplex_cl7_0 = Experiment(directory, 'sort_multiplex_cl7_O0', Status.TRUE)
sort_multiplex_cl7_3 = Experiment(directory, 'sort_multiplex_cl7_O3', Status.TRUE)
sort_multiplex_gcc5_0 = Experiment(directory, 'sort_multiplex_gcc5_O0', Status.FALSE)
sort_multiplex_gcc5_3 = Experiment(directory, 'sort_multiplex_gcc5_O3', Status.TRUE)
sort_multiplex_gcc8_0 = Experiment(directory, 'sort_multiplex_gcc8_O0', Status.FALSE)
sort_multiplex_gcc8_3 = Experiment(directory, 'sort_multiplex_gcc8_O3', Status.TRUE)
# sort_negative
sort_negative_cl30_0 = Experiment(directory, 'sort_negative_cl30_O0', Status.FALSE)
sort_negative_cl30_3 = Experiment(directory, 'sort_negative_cl30_O3', Status.FALSE)
sort_negative_cl39_0 = Experiment(directory, 'sort_negative_cl39_O0', Status.FALSE)
sort_negative_cl39_3 = Experiment(directory, 'sort_negative_cl39_O3', Status.FALSE)
sort_negative_cl7_0 = Experiment(directory, 'sort_negative_cl7_O0', Status.FALSE)
sort_negative_cl7_3 = Experiment(directory, 'sort_negative_cl7_O3', Status.FALSE)
sort_negative_gcc5_0 = Experiment(directory, 'sort_negative_gcc5_O0', Status.FALSE)
sort_negative_gcc5_3 = Experiment(directory, 'sort_negative_gcc5_O3', Status.FALSE)
sort_negative_gcc8_0 = Experiment(directory, 'sort_negative_gcc8_O0', Status.FALSE)
sort_negative_gcc8_3 = Experiment(directory, 'sort_negative_gcc8_O3', Status.FALSE)
ct_sort = [sort_cl7_0,  sort_multiplex_cl7_0,  sort_negative_cl7_0,
           sort_cl39_0, sort_multiplex_cl39_0, sort_negative_cl39_0,
           sort_cl30_0, sort_multiplex_cl30_0, sort_negative_cl30_0,
           sort_gcc5_0, sort_multiplex_gcc5_0, sort_negative_gcc5_0,
           sort_gcc8_0, sort_multiplex_gcc8_0, sort_negative_gcc8_0,
           sort_cl7_3,  sort_multiplex_cl7_3,  sort_negative_cl7_3,
           sort_cl39_3, sort_multiplex_cl39_3, sort_negative_cl39_3,
           sort_cl30_3, sort_multiplex_cl30_3, sort_negative_cl30_3,
           sort_gcc5_3, sort_multiplex_gcc5_3, sort_negative_gcc5_3,
           sort_gcc8_3, sort_multiplex_gcc8_3, sort_negative_gcc8_3]


#############
# Utility-hacl
#############
directory = 'src/ct/hacl_utility'
ct_cmp_hacl = make_compiler_expes(directory, 'cmp_bytes')
uint16_gte_mask = make_compiler_expes(directory, 'uint16_gte_mask')
uint8_eq_mask = make_compiler_expes(directory, 'uint8_eq_mask')
uint32_eq_mask = make_compiler_expes(directory, 'uint32_eq_mask')
uint8_gte_mask = make_compiler_expes(directory, 'uint8_gte_mask')
rotate32_left = make_compiler_expes(directory, 'rotate32_left')
uint32_gte_mask = make_compiler_expes(directory, 'uint32_gte_mask')
rotate32_right = make_compiler_expes(directory, 'rotate32_right')
uint64_eq_mask = make_compiler_expes(directory, 'uint64_eq_mask')
uint16_eq_mask = make_compiler_expes(directory, 'uint16_eq_mask')
uint64_gte_mask = make_compiler_expes(directory, 'uint64_gte_mask')
hacl_utility = uint16_gte_mask + uint8_eq_mask + uint32_eq_mask + \
               uint8_gte_mask + rotate32_left + uint32_gte_mask + rotate32_right + \
               uint64_eq_mask + uint16_eq_mask + uint64_gte_mask  + ct_cmp_hacl


###################
# BearSSL aes & des
###################
directory = 'src/ct/bearssl'
aes_big = Experiment(directory, 'aes_big', Status.FALSE)
aes_big.set_memory_file("memory_aes_big.txt")
aes_ct = Experiment(directory, 'aes_ct', Status.TRUE)
des_tab = Experiment(directory, 'des_tab', Status.FALSE)
des_tab.set_memory_file("memory_des_tab.txt")
des_ct = Experiment(directory, 'des_ct', Status.TRUE)
bearssl = [aes_big, aes_ct, des_tab, des_ct]


###################
# Libsodium
###################
directory = 'src/ct/libsodium'
nacl_chacha20 = Experiment(directory, 'chacha20', Status.TRUE)
nacl_salsa20 = Experiment(directory, 'salsa20', Status.TRUE)
nacl_sha256 = Experiment(directory, 'sha256', Status.TRUE)
nacl_sha512 = Experiment(directory, 'sha512', Status.TRUE)
libsodium = [nacl_chacha20, nacl_salsa20, nacl_sha256, nacl_sha512]


#######################
# Openssl - almeida
######################
directory = 'src/ct/openssl_almeida'
tls1_cbc_remove_padding_patch = Experiment(directory, 'tls1_cbc_remove_padding_patch', Status.TRUE)
tls1_cbc_remove_padding_lucky13 = Experiment(directory, 'tls1_cbc_remove_padding_lucky13', Status.FALSE)
tls1_cbc_remove_padding_lucky13.set_memory_file("tls1_cbc_remove_padding_lucky13.mem")
tls1_cbc_remove_padding = [tls1_cbc_remove_padding_patch, tls1_cbc_remove_padding_lucky13]
openssl_almeida = tls1_cbc_remove_padding


######################
# Openssl - Utility
######################
directory = 'src/ct/openssl_utility'
openssl_ct_eq = make_compiler_expes(directory, 'ct_eq')
openssl_ct_eq_8 = make_compiler_expes(directory, 'ct_eq_8')
openssl_ct_eq_int = make_compiler_expes(directory, 'ct_eq_int')
openssl_ct_eq_int_8 = make_compiler_expes(directory, 'ct_eq_int_8')
openssl_ct_lt = make_compiler_expes(directory, 'ct_lt')
openssl_ct_lt_8 = make_compiler_expes(directory, 'ct_lt_8')
openssl_ct_ge = make_compiler_expes(directory, 'ct_ge')
openssl_ct_ge_8 = make_compiler_expes(directory, 'ct_ge_8')
openssl_ct_is_zero = make_compiler_expes(directory, 'ct_is_zero')
openssl_ct_is_zero_8 = make_compiler_expes(directory, 'ct_is_zero_8')
openssl_ct_msb = make_compiler_expes(directory, 'ct_msb')
openssl_ct_select = make_compiler_expes(directory, 'ct_select')
openssl_ct_select_8 = make_compiler_expes(directory, 'ct_select_8')
openssl_utility = openssl_ct_eq_8 + openssl_ct_eq_int + openssl_ct_is_zero_8 + \
                  openssl_ct_lt + openssl_ct_select + openssl_ct_eq + openssl_ct_ge_8 + \
                  openssl_ct_is_zero + openssl_ct_msb + openssl_ct_eq_int_8 + \
                  openssl_ct_ge + openssl_ct_lt_8 + openssl_ct_select_8


######################
# Secret erasure
######################
directory = 'src/secret-erasure'
secret_erasure_0 = Experiment(directory, './bin/secret-erasure_O0', Status.TRUE)
secret_erasure_1 = Experiment(directory, './bin/secret-erasure_O1', Status.TRUE)
secret_erasure_2 = Experiment(directory, './bin/secret-erasure_O2', Status.FALSE)
secret_erasure_3 = Experiment(directory, './bin/secret-erasure_O3', Status.FALSE)
secret_erasure_f = Experiment(directory, './bin/secret-erasure_Of', Status.FALSE)
secret_erasure_all = [secret_erasure_0, secret_erasure_1,
                      secret_erasure_2, secret_erasure_3,
                      secret_erasure_f]

data_switcher = {
    # Toys
    "toys": toys,
    # Tea
    "teas": teas,
    "tea_0": [tea_dec_0],
    "tea_3": [tea_dec_3],
    # Donna
    "donnas": donnas,
    "donna_0": [donna_0],
    "donna_3": [donna_3],
    # HACL*
    "hacl": hacls,
    "hacl_chacha20": [hacl_chacha20],
    "hacl_curve25519": [hacl_curve25519],
    "hacl_sha256": [hacl_sha256],
    "hacl_sha512": [hacl_sha512],
    # Utility
    "openssl_utility": openssl_utility,
    "hacl_utility": hacl_utility,
    # ct-select / ct-sort / ct-hacl*
    "ct-sort": ct_sort,
    "ct-select": ct_select,
    "ct-cmp": ct_cmp_hacl,
    # BearSSL
    "bearssl": bearssl,
    "des_tab": [des_tab],
    "des_ct": [des_ct],
    "aes_big": [aes_big],
    "aes_ct": [aes_ct],
    # Libsodium
    "libsodium": libsodium,
    "nacl_chacha20": [nacl_chacha20],
    "nacl_salsa20": [nacl_salsa20],
    "nacl_sha256": [nacl_sha256],
    "nacl_sha512": [nacl_sha512],
    # Openssl-almeida
    "tls1_cbc_remove_padding_patch": [tls1_cbc_remove_padding_patch],
    "tls1_cbc_remove_padding_lucky13": [tls1_cbc_remove_padding_lucky13],
    "openssl_almeida": openssl_almeida,
    # Secret erasure
    # "secret-erasure": [secret_erasure_2],
    "secret-erasure": secret_erasure_all,
}

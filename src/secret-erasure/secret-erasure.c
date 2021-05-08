#define __STDC_WANT_LIB_EXT1__ 1
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include "safeclib/include/safe_mem_lib.h"
#include "../__libsym__/sym.h"

/* --------------- SCRUBBING FUNCTIONS ------------------ */
/* Implement your own using the following declaration */
void scrub(char *buf, size_t size);


/* Scrubbing function using a simple for loop */
#if LOOP
void scrub(char *buf, size_t size) {
  for (int i = 0; i < size; ++i) buf[i] = 0;
}
#endif


/* Scrubbing function using memset */
#if MEMSET
void scrub(char *buf, size_t size) {
  memset(buf, 0, size);
}
#endif


/* Scrubbing function using memset_s from safeclib                   */
/* https://github.com/rurban/safeclib/blob/master/src/mem/memset_s.c */
#if MEMSET_S
void scrub(char *buf, size_t size) {
  memset_s(buf, size, 0, size);
}
#endif

/* bzero: sets memory to zero                         */
/* https://man7.org/linux/man-pages/man3/bzero.3.html */
#if BZERO
void scrub(char *buf, size_t size) {
  bzero(buf, size);
}
#endif


/* explicit_bzero: same as bzero but not iptimized away by compiler */
/* https://man7.org/linux/man-pages/man3/bzero.3.html               */
#if EXPLICIT_BZERO
void scrub(char *buf, size_t size) {
  explicit_bzero(buf, size);
}
#endif


/* Using weak symbols https://en.wikipedia.org/wiki/Weak_symbol */
/* From https://github.com/jedisct1/libsodium/blob/ae4add868124a32d4e54da10f9cd99240aecc0aa/src/libsodium/sodium/utils.c */
#if WEAK_SYMBOLS
__attribute__((weak)) void
_sodium_dummy_symbol_to_prevent_memzero_lto(void *const  pnt,
                                            const size_t len);
__attribute__((weak)) void
_sodium_dummy_symbol_to_prevent_memzero_lto(void *const  pnt,
                                            const size_t len)
{
    (void) pnt; /* LCOV_EXCL_LINE */
    (void) len; /* LCOV_EXCL_LINE */
}

void scrub(char *buf, size_t size) {
  memset(buf, 0, size);
  _sodium_dummy_symbol_to_prevent_memzero_lto(buf, size);
}
#endif

/* Using weak symbols + memory barrier */
/* From https://github.com/jedisct1/libsodium/blob/ae4add868124a32d4e54da10f9cd99240aecc0aa/src/libsodium/sodium/utils.c */
#if WEAK_SYMBOLS_BARRIER
__attribute__((weak)) void
_sodium_dummy_symbol_to_prevent_memzero_lto(void *const  pnt,
                                            const size_t len);
__attribute__((weak)) void
_sodium_dummy_symbol_to_prevent_memzero_lto(void *const  pnt,
                                            const size_t len)
{
    (void) pnt; /* LCOV_EXCL_LINE */
    (void) len; /* LCOV_EXCL_LINE */
}

void scrub(char *buf, size_t size) {
  memset(buf, 0, size);
  _sodium_dummy_symbol_to_prevent_memzero_lto(buf, size);
  __asm__ __volatile__ ("" : : "r"(buf) : "memory");
}
#endif

/* Supposedly insecure (from Dead Store Elimination (Still) Considered Harmful) */
/* Used in safeclib https://github.com/rurban/safeclib/blob/7ef68891f130e257bf7e442b0dce626df7dcf068/src/mem/mem_primitives_lib.h */
#if MEMORY_BARRIER_SIMPLE
void scrub(char *buf, size_t size) {
  memset(buf, 0, size);
  __asm__ __volatile__("":::"memory");
}
#endif


/* Supposedly secure (from Dead Store Elimination (Still) Considered Harmful) */
#if MEMORY_BARRIER_PTR
void scrub(char *buf, size_t size) {
  memset(buf, 0, size);
  __asm__ __volatile__("": :"r"(buf) :"memory");
}
#endif


/* Used in safeclib https://github.com/rurban/safeclib/blob/7ef68891f130e257bf7e442b0dce626df7dcf068/src/mem/mem_primitives_lib.h */
#if MEMORY_BARRIER_MFENCE
void scrub(char *buf, size_t size) {
  memset(buf, 0, size);
  __asm__ __volatile__("mfence" ::: "memory");
}
#endif

/* Used in safeclib https://github.com/rurban/safeclib/blob/7ef68891f130e257bf7e442b0dce626df7dcf068/src/mem/mem_primitives_lib.h */
#if MEMORY_BARRIER_LOCK
void scrub(char *buf, size_t size) {
  memset(buf, 0, size);
  __asm__ __volatile__("lock; addl $0,0(%%esp)" ::: "memory");
}
#endif

/* Use volatile functions (used e.g. in OpenSSL
   https://github.com/openssl/openssl/blob/13a574d8bb2523181f8150de49bc041c9841f59d/crypto/mem_clr.c) */
#if VOLATILE_FUNC
typedef void *(*memset_t)(void *, int, size_t);
static volatile memset_t memset_func = memset;

void scrub(char *buf, size_t size) {
  memset_func(buf, 0, size);
}
#endif

/* Casts to pointer-to-volatile and uses for loop */
#if VOLATILE_PTR_LOOP
void scrub(char *buf, size_t size) {
  char * volatile vbuf = (char * volatile) buf;
  for (int i = 0; i < size; ++i) vbuf[i] = 0;
}
#endif

/* Casts to pointer-to-volatile and uses for memset (insecure because volatile
   qualifier is discarded) */
#if VOLATILE_PTR_MEMSET
void scrub(char *buf, size_t size) {
  char * volatile vbuf = (char * volatile) buf;
  memset(vbuf, 0, size);
}
#endif

/* Casts to volatile pointer and uses for loop (insecure with gcc) */
#if PTR_TO_VOLATILE_LOOP
void scrub(char *buf, size_t size) {
  volatile char *vbuf = (volatile char *) buf;
  for (int i = 0; i < size; ++i) vbuf[i] = 0;
}
#endif

/* Casts to volatile pointer and uses memset (insecure with gcc) */
#if PTR_TO_VOLATILE_MEMSET
void scrub(char *buf, size_t size) {
  volatile char *vbuf = (volatile char *) buf;
  memset(vbuf, 0, size);
}
#endif

/* libsodium_memzero (fallback when nothing else is available) */
/* Casts to volatile pointer to  */
/* See: https://github.com/jedisct1/libsodium/blame/be58b2e6664389d9c7993b55291402934b43b3ca/src/libsodium/sodium/utils.c#L78:L101 */
/* Also used in HACL* (https://github.com/project-everest/hacl-star/blob/master/lib/c/Lib_Memzero0.c) */
#if VOL_PTR_TO_VOL_LOOP
void scrub(char *buf, size_t size) {
  volatile unsigned char *volatile vbuf =
    (volatile unsigned char *volatile) buf;
  for (int i = 0; i < size; ++i) vbuf[i] = 0;
}
#endif


#if VOL_PTR_TO_VOL_MEMSET
void scrub(char *buf, size_t size) {
  volatile unsigned char *volatile vbuf =
    (volatile unsigned char *volatile) buf;
  memset(vbuf, 0, size);
}
#endif
/* --------------- END OF SCRUBBING FUNCTIONS ------------------ */






#define PASSWORD_SIZE 32

/* Volatile so everything is not optimized away */
volatile char good = 0;

void get_secret(char *bufer) {
  // This function is stubbed in SE and puts secret data into bufer
  HIGH_INPUT(PASSWORD_SIZE)(bufer);
}

/* Function that read and check the password */
void __attribute__ ((noinline)) password_checker(char *attempt) {
  char password[PASSWORD_SIZE];

  /* Put secret data in [password] */
  get_secret(password);

  /* Compares attempt to the secret password */
  good = 1;
  for (unsigned int i = 0; i < PASSWORD_SIZE; ++i) {
    good = good & (password[i] == attempt[i]);
  }
  
  // Scrubs secret from memory
  scrub(password, PASSWORD_SIZE);
}


int main () {
  char attempt[PASSWORD_SIZE];
  LOW_INPUT(PASSWORD_SIZE)(attempt);
  
  password_checker(attempt);

  /* Ideally we should declassify good */
  scrub((char *) &good, 1);
  return 0;
}

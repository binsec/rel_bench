/*------------------------------------------------------------------
 * test_memccpy_s
 * File 'memccpy_s.c'
 * Lines executed:96.88% of 32
 *
 *------------------------------------------------------------------
 */

#include "test_private.h"
#include "test_expmem.h"
#ifndef __KERNEL__
#include <stdlib.h>
#ifdef HAVE_VALGRIND_VALGRIND_H
#include <valgrind/valgrind.h>
#endif
#endif

#define LEN (128)

static char str1[LEN];
static char str2[LEN];
static char dest[LEN];
int test_memccpy_s(void);

int test_memccpy_s(void) {
    errno_t rc;
    rsize_t nlen;
    int errs = 0;

    /*--------------------------------------------------*/

    nlen = 5;
#ifndef HAVE_CT_BOS_OVR
    EXPECT_BOS("empty dest")
    rc = memccpy_s(NULL, LEN, str2, 0, nlen);
    ERR(ESNULLP);

#if 0 && defined(HAVE_MEMCCPY)
    {
        /* SEGV */  /* __MINGW_ATTRIB_DEPRECATED_MSVC2005 */
        char *sub = (char*)memccpy(NULL, str2, 0, nlen);
        SUBNULL();
    }
#endif

    /*--------------------------------------------------*/

    strcpy(str1, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");

    nlen = 5;
    EXPECT_BOS("empty src")
    rc = memccpy_s(str1, 5, NULL, 0, nlen);
    ERR(ESNULLP);
    CHECK_SLACK(str1, 5);
#if 0 && defined(HAVE_MEMCCPY)
    {
        /* also SEGV */
        char *sub = (char*)memccpy(str1, NULL, 0, nlen);
        SUBNULL();
    }
#endif
#endif

    strcpy(str1, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    str2[0] = '\0';

    rc = memccpy_s(str1, 5, str2, 0, 0);
    ERR(EOK);
    EXPSTR(str1, "");
#if !defined(__KERNEL__) && defined(HAVE_MEMCCPY)
    {
        char *sub = (char *)memccpy(str1, str2, 0, 0);
        EXPSTR(str1, "");
        /* but with musl the result is a copy of str1 */
#if defined(__GLIBC__) || defined(BSD_ALL_LIKE) || defined(_WIN32)
        SUBNULL();
#endif
    }
#endif

    /*--------------------------------------------------*/

#ifndef HAVE_CT_BOS_OVR
    nlen = 5;
    EXPECT_BOS("empty dest or dmax")
    rc = memccpy_s(str1, 0, str2, 0, nlen);
    ERR(ESZEROL)

    /*--------------------------------------------------*/

    EXPECT_BOS("dest overflow")
    rc = memccpy_s(str1, RSIZE_MAX_MEM + 1, str2, 0, nlen);
    ERR(ESLEMAX)

    strcpy(str1, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    strcpy(str2, "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");

    EXPECT_BOS("n overflow >dmax")
    rc = memccpy_s(str1, 5, str2, 0, 6);
    ERR(ESNOSPC)
    CHECK_SLACK(str1, 5);

    strcpy(str1, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    strcpy(str2, "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");

    EXPECT_BOS("src overflow") EXPECT_BOS("n overflow >dmax")
    rc = memccpy_s(str1, 5, str2, 0, RSIZE_MAX_MEM + 1);
    ERR(ESLEMAX)
    CHECK_SLACK(str1, 5);
#endif

    /*--------------------------------------------------*/

    strcpy(str1, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    str2[0] = '\0';
    nlen = 5;

    rc = memccpy_s(&str1[0], LEN / 2, &str2[0], 0, nlen);
    ERR(EOK)
    CHECK_SLACK(str1, nlen);

    /*--------------------------------------------------*/

    strcpy(str1, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    nlen = 5;

    /* test overlap */
    rc = memccpy_s(str1, LEN, str1, 0, nlen);
    ERR(ESOVRLP)
    CHECK_SLACK(str1, nlen);
#if !defined(__KERNEL__) && defined(HAVE_MEMCCPY) &&                           \
    (defined(__GLIBC__) || defined(_WIN32))
    /* Ignore on smoker under valgrind */
    if (!(getenv("TRAVIS") && getenv("VG")))
      {
#if defined(HAVE_VALGRIND_VALGRIND_H) &&                                       \
    (__VALGRIND_MAJOR__ > 3 ||                                                 \
     (__VALGRIND_MAJOR__ == 3 && __VALGRIND_MINOR__ >= 13))
      if (!RUNNING_ON_VALGRIND)
#endif
      {
        /* with glibc/windows overlap allowed, &str[1] returned.
         * an darwin/bsd fails the __memccpy_chk().
         * fails also since valgrind 3.13, 3.12 was ok.
         */
        GCC_PUSH_WARN_RESTRICT
        char *sub = (char *)memccpy(str1, str1, 0, nlen);
        GCC_POP_WARN_RESTRICT
        printf("memccpy overlap: %p <=> %p\n", (void *)sub, (void *)str1);
      }
    }
#endif

    /*--------------------------------------------------*/

    strcpy(str1, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    nlen = 18;

    rc = memccpy_s(&str1[0], LEN, &str1[5], 0, nlen);
    ERR(ESOVRLP)
    CHECK_SLACK(str1, LEN);
#if !defined(__KERNEL__) && defined(HAVE_MEMCCPY)
    {
        /* overlap allowed, &str[1] returned */
        char *sub = (char *)memccpy(&str1[0], &str1[5], 0, nlen);
        printf("memccpy overlap: %p <=> %p\n", (void *)sub, (void *)str1);
    }
#endif

    /*--------------------------------------------------*/

    strcpy(str1, "keep it simple");
    str2[0] = '\0';

    nlen = 10;
    rc = memccpy_s(str1, LEN, str2, 0, nlen);
    ERR(EOK)
    CHECK_SLACK(str1, nlen);

    /*--------------------------------------------------*/

    str1[0] = '\0';
    strcpy(str2, "keep it simple");

    nlen = 20;
    rc = memccpy_s(str1, LEN, str2, 0, nlen);
    ERR(EOK)
    EXPSTR(str1, str2)
    CHECK_SLACK(&str1[14], nlen - 14);

    /*--------------------------------------------------*/

    strcpy(str1, "qqweqeqeqeq");
    strcpy(str2, "keep it simple");

    nlen = 32;
    rc = memccpy_s(str1, LEN, str2, 0, nlen);
    ERR(EOK)
    EXPSTR(str1, str2)
    CHECK_SLACK(&str1[14], nlen - 14);

    /*--------------------------------------------------*/

    strcpy(str1, "qqweqeqeqeq");
    strcpy(str2, "keep it simple");

    rc = memccpy_s(str1, 1, str2, 0, nlen);
    ERR(ESNOSPC)

    /*--------------------------------------------------*/

    strcpy(str1, "qqweqeqeqeq");
    strcpy(str2, "keep it simple");

    rc = memccpy_s(str1, 2, str2, 0, nlen);
    ERR(ESNOSPC)
    if (*str1 != '\0') {
        debug_printf("%s %u -%s-  Error rc=%u \n", __FUNCTION__, __LINE__, str1,
                     rc);
        errs++;
    }
    /*--------------------------------------------------*/
    /* TR example */

    strcpy(dest, "                            ");
    strcpy(str1, "hello");

    rc = memccpy_s(dest, 6, str1, 0, 6);
    ERR(EOK)
    EXPSTR(dest, str1)
    CHECK_SLACK(&str1[5], 1);

    /*--------------------------------------------------*/

    strcpy(dest, "                            ");
    strcpy(str2, "goodbye");

    rc = memccpy_s(dest, 5, str2, 0, 5);
    ERR(ESNOSPC)

    /*--------------------------------------------------*/

    strcpy(dest, "                            ");
    strcpy(str2, "goodbye");

    rc = memccpy_s(dest, 5, str2, 0, 4);
    ERR(EOK)
    EXPSTR(dest, "good")
    CHECK_SLACK(&dest[4], 5 - 4);

    /*--------------------------------------------------*/

    strcpy(dest, "                            ");
    strcpy(str2, "good");

    /*   strnlen("good") < 5   */
    rc = memccpy_s(dest, 5, str2, 0, 5);
    ERR(EOK)
    EXPSTR(dest, "good")
    CHECK_SLACK(&dest[4], 5 - 4);

    /*--------------------------------------------------*/

    strcpy(str1, "qq12345weqeqeqeq");
    strcpy(str2, "it");

    nlen = 10;
    rc = memccpy_s(str1, 10, str2, 0, nlen);
    ERR(EOK)
    EXPSTR(str1, str2)

    /*--------------------------------------------------*/

    return (errs);
}

#ifndef __KERNEL__
/* simple hack to get this to work for both userspace and Linux kernel,
   until a better solution can be created. */
int main(void) { return (test_memccpy_s()); }
#endif

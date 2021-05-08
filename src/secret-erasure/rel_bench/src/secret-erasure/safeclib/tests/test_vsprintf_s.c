/*------------------------------------------------------------------
 * test_vsprintf_s
 * File 'str/vsprintf_s.c'
 * Lines executed:83.33% of 30
 *
 *------------------------------------------------------------------
 */

#include "test_private.h"
#include "safe_str_lib.h"
#include <stdarg.h>
#if defined(TEST_MSVCRT) && defined(HAVE_VSPRINTF_S)
#undef vsprintf_s
EXTERN int vsprintf_s(char *restrict dest, rsize_t dmax,
                      const char *restrict fmt, va_list ap);
#endif

#ifdef HAVE_VSPRINTF_S
#define HAVE_NATIVE 1
#else
#define HAVE_NATIVE 0
#endif
#include "test_msvcrt.h"

#define LEN (128)

static char str1[LEN];
static char str2[LEN];
static inline int vtprintf_s(char *restrict dest, rsize_t dmax,
                             const char *restrict fmt, ...);
int test_vsprintf_s(void);

static inline int vtprintf_s(char *restrict dest, rsize_t dmax,
                             const char *restrict fmt, ...) {
    int rc;
    va_list ap;
    va_start(ap, fmt);
    rc = vsprintf_s(dest, dmax, fmt, ap);
    va_end(ap);
    return rc;
}

int test_vsprintf_s(void) {
    errno_t rc;
    int32_t len2;
    int32_t len3;
    int errs = 0;

    /*--------------------------------------------------*/

    /* not testable, and not implemented.
      rc = vtprintf_s(str1, LEN, "%s", NULL);
      ERR(0);
      ERRNO(ESNULLP);
    */

    /*--------------------------------------------------*/

    print_msvcrt(use_msvcrt);
    /* wine msvcrt doesn't check fmt==NULL */
#if !(defined(_WINE_MSVCRT) && defined(TEST_MSVCRT) && defined(HAVE_VSPRINTF_S))
    rc = vtprintf_s(str1, LEN, NULL);
    init_msvcrt(rc == -ESNULLP, &use_msvcrt);
    ERR_MSVC(-ESNULLP, -1);
    ERRNO_MSVC(0, EINVAL);
#elif defined(_MSC_VER)
    use_msvcrt = 1;
#else
    use_msvcrt = 0;
#endif
    /* Unknown error: 400 */
    /* debug_printf("%s %u  strerror(ESNULLP): %s\n", __FUNCTION__, __LINE__,
       strerror(errno)); */

    rc = vtprintf_s(NULL, LEN, "%s", str2);
    ERR_MSVC(-ESNULLP, -1);
    ERRNO_MSVC(0, EINVAL);

    /*--------------------------------------------------*/

    rc = vtprintf_s(str1, 0, "%s", str2);
    ERR_MSVC(-ESZEROL, -1);
    ERRNO_MSVC(0, EINVAL);
    /* Unknown error: 401 */
    /* debug_printf("%s %u  strerror(ESZEROL): %s\n", __FUNCTION__, __LINE__,
       strerror(errno)); */

    /*--------------------------------------------------*/

    rc = vtprintf_s(str1, (RSIZE_MAX_STR + 1), "%s", str2);
    ERR_MSVC(-ESLEMAX, 0);
    ERRNO(0);

    /*--------------------------------------------------*/

    str2[0] = '\0';
    /* wine msvcrt doesn't check %n neither */
#if !(defined(_WINE_MSVCRT) && defined(TEST_MSVCRT) && defined(HAVE_VSPRINTF_S))
    rc = vtprintf_s(str1, LEN, "%s %n", str2);
    ERR(-1);
    ERRNO_MSVC(0, EINVAL);
#endif

    rc = vtprintf_s(str1, LEN, "%s %%n", str2);
    ERR(3)

    rc = vtprintf_s(str1, LEN, "%%n");
    ERR(2);

    /*--------------------------------------------------*/

    strcpy(str1, "aaaaaaaaaa");
    strcpy(str2, "keep it simple");

    rc = vtprintf_s(str1, 1, "%s", str2);
#ifdef _WIN32
    init_msvcrt(rc == -ESNOSPC, &use_msvcrt);
#endif
    ERR_MSVC(-ESNOSPC, -1);
    ERRNO_MSVC(0, ERANGE);
    EXPNULL(str1)

    /*--------------------------------------------------*/

    strcpy(str1, "aaaaaaaaaa");
    strcpy(str2, "keep it simple");

    rc = vtprintf_s(str1, 2, "%s", str2);
    ERR_MSVC(-ESNOSPC, -1);
    ERRNO_MSVC(0, ERANGE);
    EXPNULL(str1)

    /*--------------------------------------------------*/

    strcpy(str1, "aaaaaaaaaa");
    strcpy(str2, "keep it simple");

    len2 = strlen(str2);

    rc = vtprintf_s(str1, 50, "%s", str2);
    ERR(len2)
    len3 = strlen(str1);
    if (len3 != len2) {
#ifdef DEBUG
        int len1 = strlen(str1);
        debug_printf("%s %u lengths wrong: %d  %u  %u \n", __FUNCTION__,
                     __LINE__, len1, len2, len3);
#endif
        errs++;
    }

    /*--------------------------------------------------*/

    str1[0] = '\0';
    strcpy(str2, "keep it simple");

    rc = vtprintf_s(str1, 1, "%s", str2);
    ERR_MSVC(-ESNOSPC, -1);
    ERRNO_MSVC(0, ERANGE);
    EXPNULL(str1)

    /*--------------------------------------------------*/

    str1[0] = '\0';
    strcpy(str2, "keep it simple");

    rc = vtprintf_s(str1, 2, "%s", str2);
    ERR_MSVC(-ESNOSPC, -1);
    ERRNO_MSVC(0, ERANGE);
    EXPNULL(str1)

    /*--------------------------------------------------*/

    str1[0] = '\0';
    strcpy(str2, "keep it simple");

    rc = vtprintf_s(str1, 20, "%s", str2);
    NOERR()
    EXPSTR(str1, str2)

    /*--------------------------------------------------*/

    str1[0] = '\0';
    str2[0] = '\0';

    rc = vtprintf_s(str1, LEN, "%s", str2);
    ERR(0)
    EXPNULL(str1)

    /*--------------------------------------------------*/

    str1[0] = '\0';
    strcpy(str2, "keep it simple");

    rc = vtprintf_s(str1, LEN, "%s", str2);
    NOERR()
    EXPSTR(str1, str2)

    /*--------------------------------------------------*/

    strcpy(str1, "qqweqq");
    strcpy(str2, "keep it simple");

    rc = vtprintf_s(str1, LEN, "%s", str2);
    NOERR()
    EXPSTR(str1, str2)

    /*--------------------------------------------------*/

    strcpy(str1, "1234");
    strcpy(str2, "keep it simple");

    rc = vtprintf_s(str1, 12, "%s", str2);
    ERR_MSVC(-ESNOSPC, -1);
    ERRNO_MSVC(0, ERANGE);

    /*--------------------------------------------------*/

    strcpy(str1, "1234");
    strcpy(str2, "keep it simple");

    rc = vtprintf_s(str1, 52, "%s", str2);
    NOERR()
    EXPSTR(str1, str2)

    /*--------------------------------------------------*/

    strcpy(str1, "12345678901234567890");

    rc = vtprintf_s(str1, 8, "%s", &str1[7]);
    ERR_MSVC(-ESNOSPC, -1);
    ERRNO_MSVC(0, ERANGE);
    EXPNULL(str1)

    /*--------------------------------------------------*/

    strcpy(str1, "123456789");

    rc = vtprintf_s(str1, 9, "%s", &str1[8]);
    ERR(1) /* overlapping allowed */
    EXPSTR(str1, "9")

    /*--------------------------------------------------*/

    strcpy(str2, "123");
    strcpy(str1, "keep it simple");

    rc = vtprintf_s(str2, 31, "%s", &str1[0]);
    NOERR()
    EXPSTR(str2, "keep it simple");

    /*--------------------------------------------------*/

    strcpy(str2, "1234");
    strcpy(str1, "56789");

    rc = vtprintf_s(str2, LEN, "%s", str1);
    NOERR();
    EXPSTR(str2, "56789");

    /*--------------------------------------------------*/

    /* everybody incorrectly accepts illegal % specifiers, only musl not. */
    rc = vtprintf_s(str1, LEN, "%y");
    /* TODO: dietlibc, uClibc, minilibc */
#if defined(__GLIBC__) || defined(BSD_ALL_LIKE) /* and older mingw versions    \
                                                 */
    /* they print unknown formats verbatim */
    NOERR();
#else
    /* only musl and msvcrt sec_api correctly rejects illegal format specifiers
     */
    ERR(-1);
    EXPNULL(str1)
#endif

    /*--------------------------------------------------*/

    return (errs);
}

#ifndef __KERNEL__
/* simple hack to get this to work for both userspace and Linux kernel,
   until a better solution can be created. */
int main(void) { return (test_vsprintf_s()); }
#endif

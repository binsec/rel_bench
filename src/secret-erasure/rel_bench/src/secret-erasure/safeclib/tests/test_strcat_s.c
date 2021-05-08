/*------------------------------------------------------------------
 * test_strcat_s
 * File 'str/strcat_s.c'
 * Lines executed:90.16% of 61
 *
 *------------------------------------------------------------------
 */

#include "test_private.h"
#include "safe_str_lib.h"
#if defined(TEST_MSVCRT) && defined(HAVE_STRCAT_S)
#undef HAVE_CT_BOS_OVR
#undef strcat_s
EXTERN errno_t strcat_s(char *restrict dest, rsize_t dmax,
                        const char *restrict src);
#endif

#ifdef HAVE_STRCAT_S
#define HAVE_NATIVE 1
#else
#define HAVE_NATIVE 0
#endif
#include "test_msvcrt.h"

#define LEN (128)

static char str1[LEN];
static char str2[LEN];
int test_strcat_s(void);

int test_strcat_s(void) {
    errno_t rc;
    int32_t len1;
    int32_t len2;
    int32_t len3;
    int errs = 0;

    /*--------------------------------------------------*/

    strcpy(str1, "");
    strcpy(str2, "aaaa");
#if defined(TEST_MSVCRT) && defined(HAVE_STRNCPY_S)
    use_msvcrt = true;
#endif
    print_msvcrt(use_msvcrt);

#ifndef HAVE_CT_BOS_OVR
    EXPECT_BOS("empty dest")
    rc = strcat_s(NULL, LEN, str2);
    init_msvcrt(rc == ESNULLP, &use_msvcrt);
    ERR_MSVC(ESNULLP, EINVAL);
    EXPSTR(str1, "");

    /*--------------------------------------------------*/

    strcpy(str1, "aaaa");
    EXPECT_BOS("empty src")
    rc = strcat_s(str1, LEN, NULL);
    ERR_MSVC(ESNULLP, EINVAL);
    EXPSTR(str1, "");
    CHECK_SLACK(str1, LEN);

    /*--------------------------------------------------*/

    strcpy(str1, "aaaa");
    EXPECT_BOS("empty dest or dmax")
    rc = strcat_s(str1, 0, str2);
    ERR_MSVC(ESZEROL, EINVAL);
    EXPSTR(str1, "aaaa");

    /*--------------------------------------------------*/

    strcpy(str1, "abc");
    /*printf("** bos(str1) %ld [%s:%u]\n", BOS(str1), __FUNCTION__, __LINE__);*/
    if (_BOS_KNOWN(str1)) {
        EXPECT_BOS("dest overflow")
        rc = strcat_s(str1, LEN + 1, str2);
        ERR(EOVERFLOW); /* dmax exceeds dest */
        if (!use_msvcrt) {
            EXPSTR(str1, ""); /* cleared */
            CHECK_SLACK(str1, 4);
        }

        rc = strcat_s(str1, LEN, str2);
        ERR(0);
    } else {
#ifdef HAVE___BUILTIN_OBJECT_SIZE
        debug_printf("%s %u  Error unknown str1 object_size\n", __FUNCTION__,
                     __LINE__);
        errs++;
#endif
    }

    strcpy(str1, "a");
    EXPECT_BOS("dest overflow")
    rc = strcat_s(str1, (RSIZE_MAX_STR + 1), str2);
    ERR_MSVC(ESLEMAX, 0);
    /* some not so good compilers have destbos == BOS_UNKNOWN, like pgcc.
       hence they do just CHK_DMAX_MAX, and don't clear str1 at all */
    if (_BOS_KNOWN(str1))
      EXPSTR(str1, !use_msvcrt ? "" : "aaaaa")
#endif

    /*--------------------------------------------------*/

    strcpy(str1, "aaaaaaaaaa");
    strcpy(str2, "keep it simple");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(str1, 1, str2);
#ifdef HAVE_CT_BOS_OVR
    init_msvcrt(rc == ESUNTERM, &use_msvcrt);
#endif
    GCC_POP_WARN_DMAX
    ERR_MSVC(ESUNTERM, ERANGE);
    EXPNULL(str1)
    CHECK_SLACK(str1, 1);

    /*--------------------------------------------------*/

    strcpy(str1, "aaaaaaaaaa");
    strcpy(str2, "keep it simple");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(str1, 2, str2);
    GCC_POP_WARN_DMAX
    ERR_MSVC(ESUNTERM, ERANGE);
    EXPNULL(str1)
    CHECK_SLACK(str1, 2);

    /*--------------------------------------------------*/

    strcpy(str1, "abcd");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(&str1[0], 8, &str1[3]);
    GCC_POP_WARN_DMAX
    ERR_MSVC(ESOVRLP, ERANGE);
    EXPNULL(str1);
    CHECK_SLACK(str1, 8);

    strcpy(str1, "abcd");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(&str1[0], 4, &str1[3]);
    GCC_POP_WARN_DMAX
    ERR_MSVC(ESOVRLP, ERANGE);
    EXPNULL(str1);
    CHECK_SLACK(str1, 4);

    /*--------------------------------------------------*/

    strcpy(str1, "abcdefgh");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(&str1[3], 5, &str1[0]);
    GCC_POP_WARN_DMAX
    ERR_MSVC(ESUNTERM, ERANGE);
    EXPNULL(&str1[3])
    CHECK_SLACK(&str1[3], 5);

    /*--------------------------------------------------*/

    strcpy(str1, "abcdefgh");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(&str1[3], 12, &str1[0]);
    GCC_POP_WARN_DMAX
    ERR_MSVC(ESOVRLP, ERANGE);
    EXPNULL(&str1[3]);
    CHECK_SLACK(&str1[3], 12);

    /*--------------------------------------------------*/

    strcpy(&str1[0], "aaaaaaaaaa");
    strcpy(&str2[0], "keep it simple");

    len1 = strlen(str1);
    len2 = strlen(str2);

    rc = strcat_s(str1, LEN, str2);
    ERR(EOK)
    len3 = strlen(str1);
    if (len3 != (len1 + len2)) {
        debug_printf("%s %u lengths wrong: %u  %u  %u \n", __FUNCTION__,
                     __LINE__, len1, len2, len3);
        errs++;
    }
    CHECK_SLACK(&str1[len3], LEN - len3);

    /*--------------------------------------------------*/

    str1[0] = '\0';
    strcpy(str2, "keep it simple");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(str1, 1, str2);
    GCC_POP_WARN_DMAX
    ERR_MSVC(ESNOSPC, ERANGE);
    EXPNULL(str1)
    CHECK_SLACK(str1, 1);

    /*--------------------------------------------------*/

    str1[0] = '\0';
    strcpy(str2, "keep it simple");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(str1, 2, str2);
    GCC_POP_WARN_DMAX
    ERR_MSVC(ESNOSPC, ERANGE);
    EXPNULL(str1)
    CHECK_SLACK(str1, 2);

    /*--------------------------------------------------*/

    str1[0] = '\0';
    strcpy(str2, "keep it simple");

    rc = strcat_s(str1, LEN, str2);
    ERR(EOK)
    EXPSTR(str1, str2)
    len1 = strlen(str1);
    CHECK_SLACK(&str1[len1], LEN - len1);

    /*--------------------------------------------------*/

    str1[0] = '\0';
    str2[0] = '\0';

    rc = strcat_s(str1, LEN, str2);
    ERR(EOK)
    EXPNULL(str1)
    CHECK_SLACK(str1, LEN);

    /*--------------------------------------------------*/

    str1[0] = '\0';
    strcpy(str2, "keep it simple");

    rc = strcat_s(str1, LEN, str2);
    ERR(EOK)
    EXPSTR(str1, str2)
    len1 = strlen(str1);
    CHECK_SLACK(&str1[len1], LEN - len1);

    /*--------------------------------------------------*/

    strcpy(str1, "qqweqq");
    strcpy(str2, "keep it simple");

    rc = strcat_s(str1, LEN, str2);
    ERR(EOK)
    EXPSTR(str1, "qqweqqkeep it simple")
    len1 = strlen(str1);
    CHECK_SLACK(&str1[len1], LEN - len1);

    /*--------------------------------------------------*/

    strcpy(str1, "1234");
    strcpy(str2, "keep it simple");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(str1, 12, str2);
    GCC_POP_WARN_DMAX
    ERR_MSVC(ESNOSPC, ERANGE);
    EXPNULL(str1)
    CHECK_SLACK(str1, 12);

    /*--------------------------------------------------*/

    strcpy(str1, "1234");
    strcpy(str2, "keep it simple");

    rc = strcat_s(str1, LEN, str2);
    ERR(EOK)
    EXPSTR(str1, "1234keep it simple")
    len1 = strlen(str1);
    CHECK_SLACK(&str1[len1], LEN - len1);

    /*--------------------------------------------------*/

    strcpy(str1, "12345678901234567890");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(str1, 8, &str1[7]);
    GCC_POP_WARN_DMAX
    ERR_MSVC(ESOVRLP, ERANGE);
    EXPNULL(str1)
    CHECK_SLACK(str1, 8);

    /*--------------------------------------------------*/

    strcpy(str1, "123456789");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(str1, 9, &str1[8]);
    GCC_POP_WARN_DMAX
    ERR_MSVC(ESOVRLP, ERANGE);
    EXPNULL(str1)
    CHECK_SLACK(str1, 9);

    /*--------------------------------------------------*/

    strcpy(str1, "12345678901234567890");

    rc = strcat_s(str1, LEN, &str1[4]);
    ERR_MSVC(ESOVRLP, ERANGE);
    EXPNULL(str1)
    CHECK_SLACK(str1, LEN);

    /*--------------------------------------------------*/

    strcpy(str1, "12345678901234567890");
    len1 = strlen(str1);

    rc = strcat_s(&str1[5], LEN - 5, &str1[4]);
    ERR_MSVC(ESOVRLP, ERANGE);
    EXPNULL(&str1[5])
    CHECK_SLACK(&str1[5], LEN - 5);

    /*--------------------------------------------------*/

    strcpy(str2, "123");
    strcpy(str1, "keep it simple");

    rc = strcat_s(str2, LEN, &str1[0]);
    ERR(EOK)
    EXPSTR(str2, "123keep it simple")
    len2 = strlen(str2);
    CHECK_SLACK(&str2[len2], LEN - len2);

    /*--------------------------------------------------*/

    strcpy(str2, "1234");
    strcpy(str1, "56789");

    GCC_PUSH_WARN_DMAX
    rc = strcat_s(str2, 10, str1);
    GCC_POP_WARN_DMAX
    ERR(EOK)
    EXPSTR(str2, "123456789")
    len2 = strlen(str2);
    CHECK_SLACK(&str2[len2], 10 - len2);

    /*--------------------------------------------------*/

    return (errs);
}

#ifndef __KERNEL__
/* simple hack to get this to work for both userspace and Linux kernel,
   until a better solution can be created. */
int main(void) { return (test_strcat_s()); }
#endif

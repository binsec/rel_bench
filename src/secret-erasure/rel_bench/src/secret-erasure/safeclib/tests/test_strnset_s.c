/*------------------------------------------------------------------
 * test_strnset_s
 * File 'strnset_s.c'
 * Lines executed:95.00% of 20
 *
 *------------------------------------------------------------------
 */

#include "test_private.h"
#include "safe_str_lib.h"

#define LEN (128)

int main(void) {
    errno_t rc;
    rsize_t max_len = 5;
    char str1[LEN];
    int value = 0;
    uint32_t j;
    int errs = 0;

    /*--------------------------------------------------*/

#ifndef HAVE_CT_BOS_OVR
    EXPECT_BOS("empty dest") EXPECT_BOS("dest overflow or empty")
    rc = strnset_s(NULL, 5, value, 5);
    ERR(ESNULLP)

    EXPECT_BOS("empty dest or dmax") EXPECT_BOS("n overflow >dmax")
    rc = strnset_s(str1, 0, 0, 5);
    ERR(ESZEROL)

    EXPECT_BOS("dest overflow")
    rc = strnset_s(str1, RSIZE_MAX_STR + 1, 0, 5);
    ERR(ESLEMAX);

#ifdef HAVE___BUILTIN_OBJECT_SIZE
    EXPECT_BOS("dest overflow")
    rc = strnset_s(str1, LEN + 1, 0, 5);
    ERR(EOVERFLOW);
#endif

    EXPECT_BOS("value overflow >255")
    rc = strnset_s(str1, LEN, 256, 5);
    ERR(ESLEMAX);

    strcpy(str1, "abc");
    EXPECT_BOS("n overflow >dmax")
    rc = strnset_s(str1, 5, 0, 6);
    ERR(ESNOSPC);
#endif

    /*--------------------------------------------------*/

    strcpy(str1, "abc");
    value = 20;
    max_len = 1;
    rc = strnset_s(str1, LEN, value, max_len);
    ERR(EOK)
    for (j = 0; j < max_len; j++) {
        if (str1[j] != (char)value) {
            debug_printf("%s %u   Error rc=%u \n", __FUNCTION__, __LINE__, rc);
            errs++;
        }
    }

    /*--------------------------------------------------*/

    strcpy(str1, "abc");
    value = 0;
    max_len = 2;
    rc = strnset_s(str1, LEN, value, max_len);
    ERR(EOK)
    for (j = 0; j < max_len; j++) {
        if (str1[j] != (char)value) {
            debug_printf("%s %u   Error rc=%u \n", __FUNCTION__, __LINE__, rc);
            errs++;
        }
    }

    /*--------------------------------------------------*/

    strcpy(str1, "abc");
    max_len = 3;
    rc = strnset_s(str1, LEN, value, max_len); /* !! */
    ERR(EOK)
    for (j = 0; j < max_len; j++) {
        if (str1[j] != (char)value) {
            debug_printf("%s %u   Error rc=%u \n", __FUNCTION__, __LINE__, rc);
            errs++;
        }
    }
    CHECK_SLACK(&str1[3], LEN - 3);

    /*--------------------------------------------------*/

    strcpy(str1, "abc");
    max_len = 4;
    rc = strnset_s(str1, LEN, value, max_len);
    ERR(EOK)
    for (j = 0; j < max_len; j++) {
        if (str1[j] != (char)value) {
            debug_printf("%s %u   Error rc=%u \n", __FUNCTION__, __LINE__, rc);
            errs++;
        }
    }
    CHECK_SLACK(&str1[3], LEN - 3);

    /*--------------------------------------------------*/

    strcpy(str1, "abc");
    max_len = 5;
    rc = strnset_s(str1, LEN, value, max_len);
    ERR(EOK)
    for (j = 0; j < 3; j++) {
        if (str1[j] != (char)value) {
            debug_printf("%s %u   Error rc=%u \n", __FUNCTION__, __LINE__, rc);
            errs++;
        }
    }
    CHECK_SLACK(&str1[3], LEN - 3);

    /*--------------------------------------------------*/

    strcpy(str1, "abc");
    max_len = LEN;
    rc = strnset_s(str1, LEN, value, max_len);
    ERR(EOK)
    for (j = 0; j < 3; j++) {
        if (str1[j] != (char)value) {
            debug_printf("%s %u   Error rc=%u \n", __FUNCTION__, __LINE__, rc);
            errs++;
        }
    }
    CHECK_SLACK(&str1[3], LEN - 3);

    /*--------------------------------------------------*/

    strcpy(str1, "Now is the time for all data to be zeroed");
    max_len = strlen("Now is the ");

    rc = strnset_s(str1, LEN, 0, max_len);
    ERR(EOK)
    if (strcmp(&str1[max_len], "time for all data to be zeroed")) {
        debug_printf("%s %u ERROR  --%s-- \n", __FUNCTION__, __LINE__,
                     &str1[max_len]);
        errs++;
    }

    /*--------------------------------------------------*/

    return (errs);
}

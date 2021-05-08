/*------------------------------------------------------------------
 * test_memmove16_s
 * File 'extmem/memmove16_s.c'
 * Lines executed:83.33% of 18
 *
 *------------------------------------------------------------------
 */

#include "test_private.h"
#include "test_expmem.h"

#define LEN (1024)
#define MAX (LEN * 2)

int main(void) {
    errno_t rc;
    uint32_t len;
    uint32_t i;

    uint16_t mem1[LEN];
    uint16_t mem2[LEN];
    rsize_t count = LEN;
    int errs = 0;

    /*--------------------------------------------------*/

    for (i = 0; i < LEN; i++) {
        mem1[i] = 33;
    }

    rc = memmove16_s(NULL, MAX, mem2, count);
    ERR(ESNULLP);
    /*--------------------------------------------------*/

    rc = memmove16_s(mem1, 0, mem2, count);
    ERR(ESZEROL); /* and untouched */
    EXPMEM(mem1, 0, LEN, 33, 2);
    /*--------------------------------------------------*/

#ifndef HAVE_CT_BOS_OVR
    rc = memmove16_s(mem1, RSIZE_MAX_MEM + 1, mem2, count);
    ERR(ESLEMAX); /* and untouched */
    EXPMEM(mem1, 0, LEN, 33, 2);
#endif

    /*--------------------------------------------------*/

    for (i = 0; i < LEN; i++) {
        mem1[i] = 33;
    }
    rc = memmove16_s(mem1, MAX, NULL, count);
    ERR(ESNULLP); /* and cleared */
    EXPMEM(mem1, 0, LEN, 0, 2);
    /*--------------------------------------------------*/

    for (i = 0; i < 10; i++) {
        mem1[i] = 33;
    }
    rc = memmove16_s(mem1, 10, mem2, 0);
    ERR(EOK); /* and untouched */
    EXPMEM(mem1, 0, 10, 33, 2);

    /*--------------------------------------------------*/

#ifndef HAVE_CT_BOS_OVR
    EXPECT_BOS("src overflow or empty") EXPECT_BOS("slen overflow >dmax / 2")
    rc = memmove16_s(mem1, MAX, mem2, RSIZE_MAX_MEM16 + 1);
    ERR(ESLEMAX); /* and cleared */
    EXPMEM(mem1, 0, LEN, 0, 2);
#endif

    /*--------------------------------------------------*/

    for (i = 0; i < LEN; i++) {
        mem1[i] = 33;
    }
    for (i = 0; i < LEN; i++) {
        mem2[i] = 44;
    }

    len = 1;
    rc = memmove16_s(mem1, MAX, mem2, len);
    ERR(EOK); /* and copied */
    EXPMEM(mem1, 0, len, 44, 2);
    EXPMEM(mem1, len, LEN - len, 33, 2);

    for (i = 0; i < LEN; i++) {
        mem1[i] = 33;
    }
    for (i = 0; i < LEN; i++) {
        mem2[i] = 44;
    }

    len = 2;
    rc = memmove16_s(mem1, MAX, mem2, len);
    ERR(EOK); /* and copied */
    EXPMEM(mem1, 0, len, 44, 2);
    EXPMEM(mem1, len, LEN - len, 33, 2);

    for (i = 0; i < LEN; i++) {
        mem1[i] = 33;
    }
    for (i = 0; i < LEN; i++) {
        mem2[i] = 44;
    }

    /* a valid move */
    len = LEN;
    rc = memmove16_s(mem1, MAX, mem2, len);
    ERR(EOK); /* and copied */
    EXPMEM(mem1, 0, len, 44, 2);

    /*--------------------------------------------------*/

    for (i = 0; i < LEN; i++) {
        mem1[i] = 33;
    }
    for (i = 0; i < LEN; i++) {
        mem2[i] = 44;
    }

    /* count*2 greater than dmax */
    rc = memmove16_s(mem1, MAX, mem2, count + 1);
    ERR(ESNOSPC); /* and cleared */
    EXPMEM(mem1, 0, LEN, 0, 2);

    /*--------------------------------------------------*/

    for (i = 0; i < LEN; i++) {
        mem1[i] = 33;
    }
    for (i = 0; i < LEN; i++) {
        mem2[i] = 44;
    }

    /* empty count */
    rc = memmove16_s(mem1, MAX, mem2, 0);
    ERR(EOK); /* and untouched */
    EXPMEM(mem1, 0, LEN, 33, 2);

    /*--------------------------------------------------*/

    for (i = 0; i < LEN; i++) {
        mem1[i] = 33;
    }
    for (i = 0; i < LEN; i++) {
        mem2[i] = 44;
    }

    /* same ptr - no move */
    rc = memmove16_s(mem1, MAX, mem1, count);
    ERR(EOK); /* and untouched */
    EXPMEM(mem1, 0, LEN, 33, 2);
    /*--------------------------------------------------*/

    for (i = 0; i < LEN; i++) {
        mem1[i] = 25;
    }
    for (i = 10; i < LEN - 10; i++) {
        mem1[i] = 35;
    }

    /* overlap move + */
    len = 20;
    rc = memmove16_s(&mem1[0], LEN, &mem1[10], len);
    ERR(EOK); /* and copied */
    EXPMEM(mem1, 0, len, 35, 2);
    EXPMEM(mem1, len, LEN, 35, 2);

    /*--------------------------------------------------*/

    for (i = 0; i < LEN; i++) {
        mem1[i] = 25;
    }
    for (i = 10; i < LEN - 10; i++) {
        mem1[i] = 35;
    }

    /* overlap move - */
    len = 20;
    rc = memmove16_s(&mem1[10], (LEN - 10) * 2, &mem1[0], len);
    ERR(EOK);
    EXPMEM(mem1, 0, 10, 25, 2);
    EXPMEM(mem1, len, LEN, 35, 2);

    /*--------------------------------------------------*/

    return (errs);
}

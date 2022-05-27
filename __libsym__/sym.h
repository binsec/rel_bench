#define CAT(x,y) x##y

/* Call the functions*/
#define HIGH_INPUT(size) CAT(high_input_, size)
#define LOW_INPUT(size) CAT(low_input_, size)

/* Define the functions */
#define DEF_HIGH(size) void CAT(high_input_,size) (void* );
#define DEF_LOW(size) void CAT(low_input_,size) (void* );

DEF_HIGH(1)
DEF_LOW(1)

DEF_HIGH(2)
DEF_LOW(2)

DEF_HIGH(4)
DEF_LOW(4)

DEF_HIGH(8)
DEF_LOW(8)

DEF_HIGH(12)
DEF_LOW(12)

DEF_HIGH(16)
DEF_LOW(16)

DEF_HIGH(32)
DEF_LOW(32)

DEF_HIGH(40)
DEF_LOW(40)

DEF_HIGH(48)
DEF_LOW(48)

DEF_HIGH(63)
DEF_LOW(63)

DEF_HIGH(64)
DEF_LOW(64)

DEF_HIGH(80)
DEF_LOW(80)

DEF_HIGH(160)
DEF_LOW(160)

DEF_HIGH(200)
DEF_LOW(200)

DEF_HIGH(240)
DEF_LOW(240)

DEF_HIGH(256)
DEF_LOW(256)

DEF_HIGH(384)
DEF_LOW(384)

DEF_HIGH(131072)               /* 256 * 512 */
DEF_LOW(131072)                /* 256 * 512 */

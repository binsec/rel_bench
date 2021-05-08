#include "../../__libsym__/sym.h"
#include "hacl-c/hacl-c/Hacl_Policies.h"
#include <stdint.h>

#define LEN 40

int main() {
  uint8_t b1[LEN];
  uint8_t b2[LEN];

  HIGH_INPUT(LEN)(b1);
  HIGH_INPUT(LEN)(b2);

  Hacl_Policies_cmp_bytes(b1,b2,LEN);

  return 0;
}

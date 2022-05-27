#include "../../__libsym__/sym.h"
#include "kremlib_base.h"
#include <stdint.h>

int main() {
  uint64_t x;
  uint64_t y;

  HIGH_INPUT(8)(&x);
  HIGH_INPUT(8)(&y);

  return FStar_UInt64_gte_mask(x,y);
}

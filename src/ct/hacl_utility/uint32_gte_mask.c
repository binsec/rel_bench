#include "../../__libsym__/sym.h"
#include "kremlib_base.h"
#include <stdint.h>

int main() {
  uint32_t x;
  uint32_t y;

  HIGH_INPUT(4)(&x);
  HIGH_INPUT(4)(&y);

  return FStar_UInt32_gte_mask(x,y);
}

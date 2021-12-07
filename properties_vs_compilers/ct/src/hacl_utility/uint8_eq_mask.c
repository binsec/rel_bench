#include "../__libsym__/sym.h"
#include "kremlib_base.h"
#include <stdint.h>

int main() {
  uint8_t x;
  uint8_t y;

  HIGH_INPUT(1)(&x);
  HIGH_INPUT(1)(&y);

  return FStar_UInt8_eq_mask(x,y);
}

#include "../../__libsym__/sym.h"
#include "kremlib_base.h"
#include <stdint.h>

int main() {
  uint16_t x;
  uint16_t y;

  HIGH_INPUT(2)(&x);
  HIGH_INPUT(2)(&y);

  return FStar_UInt16_eq_mask(x,y);
}

#include "../../__libsym__/sym.h"
#include "kremlib_base.h"
#include <stdint.h>

int main() {
  uint32_t x;
  uint32_t n;

  HIGH_INPUT(4)(&x);
  HIGH_INPUT(4)(&n);

  return rotate32_left(x,n);
}

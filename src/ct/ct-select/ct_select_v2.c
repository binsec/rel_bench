#include <stdint.h>
#include <stdbool.h>
#include "../../__libsym__/sym.h"
#include "lib.h"


int main() {
  bool bit;       // private
  uint32_t x, y;  // public

  high_input_1(&bit);
  low_input_4(&x);
  low_input_4(&y);

  return ct_select_u32_v2(x, y, bit);
}

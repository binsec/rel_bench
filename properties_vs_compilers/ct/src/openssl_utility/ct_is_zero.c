#include "../__libsym__/sym.h"
#include "lib.h"

int main() {
  unsigned int x;  // private

  high_input_4(&x);
  
  return constant_time_is_zero(x);
}

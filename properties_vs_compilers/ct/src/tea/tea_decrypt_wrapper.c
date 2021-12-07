#include "../__libsym__/sym.h"
#include "tea.h"

int main() {

  unsigned long key[4];     // The secret
  unsigned long data[2];    // The message to encrypt/decrypt
  unsigned long out[2];     // The output buffer

  high_input_16(key);
  high_input_8(data);
  high_input_8(out);
  
  decipher(data, out, key);

  return 0;
}

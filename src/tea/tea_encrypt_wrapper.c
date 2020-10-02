#include "tea.c"

int main() {

  unsigned long key[4];     // The secret
  unsigned long data[2];    // The message to encrypt/decrypt
  unsigned long out[2];     // The output buffer
  
  encipher(data, out, key);

  return 0;
}

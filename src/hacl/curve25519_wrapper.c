#include "../../__libsym__/sym.h"
#include "hacl-c/hacl-c/Hacl_Curve25519.h"
#include <stdint.h>

#define SIZE 32

int main() {
  uint8_t mypublic[SIZE];   // private (but declassified in output)
  uint8_t secret[SIZE];     // private
  uint8_t basepoint[SIZE];  // public
  
  HIGH_INPUT(SIZE)(mypublic);
  HIGH_INPUT(SIZE)(secret);
  HIGH_INPUT(SIZE)(basepoint);

  Hacl_Curve25519_crypto_scalarmult(mypublic, secret, basepoint);
  return 0;
}

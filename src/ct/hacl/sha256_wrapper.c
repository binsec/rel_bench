#include "../../__libsym__/sym.h"
#include "hacl-c/hacl-c/Hacl_SHA2_256.h"
#include <stdint.h>

#define MESSAGE_LEN 256
#define Hacl_SHA2_256_size_hash 32

int main() {
  uint8_t input[MESSAGE_LEN];             // private
  uint8_t hash1[Hacl_SHA2_256_size_hash]; // private
  uint32_t len = MESSAGE_LEN;             // public

  HIGH_INPUT(MESSAGE_LEN)(input);
  HIGH_INPUT(Hacl_SHA2_256_size_hash)(input);
 
  Hacl_SHA2_256_hash(hash1, input, len);
  return 0;
}

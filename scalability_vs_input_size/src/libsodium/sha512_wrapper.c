#include "../../../__libsym__/sym.h"
#include <sodium.h>

#define BYTES 64                /* crypto_hash_sha512_BYTES */

int main() {
  unsigned char message[MSG_LEN];
  unsigned char out[crypto_hash_sha512_BYTES];

  HIGH_INPUT(MSG_LEN)(message);
  HIGH_INPUT(BYTES)(out);
  
  return crypto_hash_sha512(out, message, MSG_LEN);
}

#include "../../../__libsym__/sym.h"
#include <sodium.h>

#define BYTES 32                /* crypto_hash_sha256_BYTES */

int main() {
  unsigned char message[MSG_LEN];              // private
  unsigned char out[crypto_hash_sha256_BYTES]; // private

  HIGH_INPUT(MSG_LEN)(message);
  HIGH_INPUT(BYTES)(out);
  
  return crypto_hash_sha256(out, message, MSG_LEN);
}

/* Source: https://github.com/imdea-software/verifying-constant-time/blob/master/examples/sort/sort.c 

(Modified by Lesly-Ann Daniel)
*/
#include "../../__libsym__/sym.h"
#include "lib.h"

int main() {
  int conds[3];
  int out[3];
  int in[3];

  high_input_12(&conds);
  high_input_12(&out);
  high_input_12(&in);

  sort3(conds,out,in);
  return 0;
}

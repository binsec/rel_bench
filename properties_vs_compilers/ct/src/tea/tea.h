#ifndef TEA_H_
#define TEA_H_

void encipher(unsigned long *const v,unsigned long *const w,
const unsigned long *const k);

void decipher(unsigned long *const v,unsigned long *const w,
const unsigned long *const k);

#endif // TEA_H_

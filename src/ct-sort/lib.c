/* https://github.com/imdea-software/verifying-constant-time/blob/master/examples/sort/sort.c */
int sort2(int *out2, int *in2) {
  int a, b;
  a = in2[0];
  b = in2[1];
  if (a < b) {
    out2[0] = in2[0];
    out2[1] = in2[1];
  } else {
    out2[0] = in2[1];
    out2[1] = in2[0];
  }
  return (a < b);
}

void sort3(int *conds, int *out3, int *in3) {
  conds[0] = sort2(out3,in3);
  in3[1] = out3[1];
  conds[1] = sort2(out3+1,in3+1);
  in3[0] = out3[0];
  in3[1] = out3[1];
  conds[2] = sort2(out3,in3);
}


/* https://github.com/imdea-software/verifying-constant-time/blob/master/examples/sort/sort_multiplex.c */
void sort2_multiplex(int *out2, int *in2) {
  signed char c;
  c = (in2[0] < in2[1]) - 1;
  out2[0] = (~c & in2[0]) | (c & in2[1]);
  out2[1] = (~c & in2[1]) | (c & in2[0]);
  return;
}

void sort3_multiplex(int *out3, int *in3) {
  sort2_multiplex(out3,in3);
  in3[1] = out3[1];
  sort2_multiplex(out3+1,in3+1);
  in3[0] = out3[0];
  in3[1] = out3[1];
  sort2_multiplex(out3,in3);
}

/* https://github.com/imdea-software/verifying-constant-time/blob/master/examples/sort/sort_negative.c */
void sort2_negative(int *out2, int *in2) {
  int a, b;
  a = in2[0];
  b = in2[1];
  if (a < b) {
    out2[0] = in2[0];
    out2[1] = in2[1];
  } else {
    out2[0] = in2[1];
    out2[1] = in2[0];
  }
  return;
}

void sort3_negative(int *out3, int *in3) {
  sort2_negative(out3,in3);
  in3[1] = out3[1];
  sort2_negative(out3+1,in3+1);
  in3[0] = out3[0];
  in3[1] = out3[1];
  sort2_negative(out3,in3);
}

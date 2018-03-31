#include <stdio.h>
#include <sys/stat.h>

int foo(int a){
  return ++a;
}

int main(){

  printf("%lu\n", sizeof(struct stat) );

  int array[2];
  array[0] = foo(2);
  for (size_t i = 0; i < 2; i++) {
    printf("%d\n", array[i]);
  }

  return 0;
}

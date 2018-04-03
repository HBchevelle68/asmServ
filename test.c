#include <stdio.h>
#include <sys/stat.h>

int foo(int a){
  return ++a;
}

int main(){

  printf("%lu\n", sizeof(struct stat) );

  return 0;
}

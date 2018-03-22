#include <stdio.h>
#include <sys/stat.h>

int main(){

  printf("%lu\n", sizeof(struct stat) );

  return 0;
}

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int foo(int a){
  return ++a;
}

char *filename = "testfile.txt";
int main(){
  printf("%lu\n", sizeof(struct stat) );
  struct stat buf;
  printf("%lu\n", sizeof(buf.st_dev));
  printf("%lu\n", sizeof(buf.st_ino));
  printf("%lu\n", sizeof(buf.st_mode));
  printf("%lu\n", sizeof(buf.st_nlink));
  printf("%lu\n", sizeof(buf.st_uid));
  printf("%lu\n", sizeof(buf.st_gid));
  printf("%lu\n", sizeof(buf.st_rdev));
  printf("%lu\n", sizeof(buf.st_size));
  printf("%lu\n", sizeof(buf.st_blksize));
  printf("%lu\n", sizeof(buf.st_blocks));
  printf("%lu\n", sizeof(buf.st_atime));
  printf("%lu\n", sizeof(buf.st_mtime));
  printf("%lu\n", sizeof(buf.st_ctime));


  int fd = open(filename, 'r');
  fstat(fd, &buf);

  printf("buf.st_size: %lu\n", buf.st_size);
  return 0;
}

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>

char *filename = "testfile.txt";
int main(){
  printf("sizeof struct timespec: %lu\n", sizeof(struct timespec) );
  printf("sizeof struct stat: %lu\n", sizeof(struct stat) );

  struct stat buf;
  printf("%lu\n", sizeof(buf.st_dev));
  printf("%lu\n", sizeof(buf.st_ino));
  printf("%lu\n", sizeof(buf.st_nlink));
  printf("%lu\n", sizeof(buf.st_mode));
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
  printf("buf.st_dev:     0x%016x\n", buf.st_dev);
  printf("buf.st_ino:     0x%016x\n", buf.st_ino);
  printf("buf.st_nlink:   0x%016x\n", buf.st_nlink);
  printf("buf.st_mode:    0x%08x\n", buf.st_mode);
  printf("buf.st_uid:     0x%08x\n", buf.st_uid);
  printf("buf.st_gid:     0x%08x\n", buf.st_gid);
  printf("buf.st_rdev:    0x%016x\n", buf.st_rdev);
  printf("buf.st_size:    0x%016x\n", buf.st_size);
  printf("buf.st_blksize: 0x%016x\n",  buf.st_blksize);
  printf("buf.st_blocks:  0x%016x\n",  buf.st_blocks);
  printf("buf.st_atime:   0x%016x\n",  buf.st_atime);
  printf("buf.st_mtime:   0x%016x\n",  buf.st_mtime);
  printf("buf.st_ctime:   0x%016x\n",  buf.st_ctime);
  return 0;
}

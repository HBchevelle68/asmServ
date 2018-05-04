global _start

%define F_OK      0
%define O_RDONLY  0
%define O_WRONLY  1
%define O_RDWR    2

%define O_CREAT   100o
%define O_TRUNC   1000o
%define O_APPEND  2000o

section .data
  string: db "This is a test 120591", 0xa, 0x0
  .len: equ $ - string
  buffer: times 50 db 0x0
  .len: equ $ - buffer

section .bss
  file: resq 1
  fd:   resd 1
  var:  resd 1
  tmp:  resd 1


section .text

;;rdi points to string
string_length:
  xor    rax, rax
  .loop:
  cmp    byte [rdi+rax], 0
  je     .end
  inc    rax
  jmp    .loop
  .end:
  ret

;;rdi points to string
print_string:
  xor rax, rax
  push rdi
  call string_length
  pop rsi
  mov rdx, rax
  mov rdi, 1
  mov rax, 1
  syscall
  ret

;; struct stat -> 144 bytes
;; rdi-> char* filename
filesize:
  mov    rax, 4   ;;sys_stat
  ;;rdi
  mov    rbp, rsp ;;save stack pointer
  sub    rsp, 144 ;;allocate memory on stack for struct stat
  mov    rsi, rsp ;;rsi now points to allocated mem for struct stat
  syscall
  test   ax, ax
  js     err
  mov    QWORD rax, [rsp+48] ;; save stat->st_size
  mov    rsp, rbp ;; deallocate memory
  ret


_start:
  nop
  nop

  ;;Make sure enough args passed
  mov    rsi, [rsp] ;; argc
  cmp    rsi, 2
  jnz    err2

  ;;Get the file
  mov    rsi, [rsp+16] ;; *argv[1]
  mov    QWORD [file], rsi

  ;; print file name
  mov    rax, 1
  mov    rdi, 1
  mov    rsi, [file]
  mov    rdx, 12
  syscall
  ;; testing string length function
  ;;mov rdi, [file]
  ;;call string_length


  ;; sys_access
  ;; uses F_OK mode to retrieve wether or not file exists
  ;; rax will return 0 if succesful and file exists || -1 if file does not exist
fileaccess:
  mov rax, 21 ;; sys_access
  mov rdi, [file] ;; rdi -> char* of file
  mov rsi, F_OK
  syscall
  test al, al
  js err2

  ;;get file size
  mov rdi, [file]
  call filesize


  ;; fopen
  ;; on ret, rax will contain fd || -1 if error
fileopen:
  mov rax, 2
  mov rdi, [file] ;; rdi -> filename/filepath
  mov rsi, O_CREAT | O_RDWR ;; modes
  mov rdx, 0666o ;;read write for all
  syscall
  test al, al
  js  err2     ;; test for error
  mov [fd], al ;; Save fd

  ;; sys_pwrite64
  ;; rdi -> fd of file
  ;; rsi -> buffer
  ;; rdx -> buffer size
  ;; r10 -> offset
  ;; rax will contain # bytes written to buffer || -1 on error
writetofile:
  mov rax, 18
  mov rdi, [fd]
  mov rsi, string
  mov rdx, string.len
  mov r10, 5
  syscall

err:
  mov rax, 3
  mov rdi, [fd]
  syscall
err2:
  mov rax, 60
  mov rdi, rax
  syscall

global _start

%define F_OK      0
%define O_RDONLY  0
%define O_WRONLY  1
%define O_RDWR    2

%define O_CREAT   100o
%define O_TRUNC   1000o
%define O_APPEND  2000o

section .data
  string: db "This is a test 129373456", 0xa, 0x0
  .len: equ $ - string
  buffer: times 50 db 0x0
  .len: equ $ - buffer

section .bss
  fd:  resd 1
  var: resd 1
  tmp: resd 1

section .text
_start:
  nop
  nop

  ;; Get file name from user
  mov rax, 0
  mov rdi, 0
  mov rsi, buffer
  mov rdx, buffer.len
  syscall
  mov [var], rax ;; save num bytes
  mov [buffer+rax-1], BYTE 0x0 ;; remove /n from buffer

;;%if 0
  ;; sys_access
  ;; uses F_OK mode to retrieve wether or not file exists
  ;; rax will return 0 if succesful and file exists || -1 if file does not exist
filestatus:
  mov rax, 21 ;; sys_access
  mov rdi, buffer ;; rdi -> char* of file
  mov rsi, F_OK
  syscall
  test al, al
  js err2
;;%endif
  ;; fopen
  ;; on ret, rax will contain fd || -1 if error
fileopen:
  mov rax, 2
  mov rdi, buffer ;; rdi -> filename/filepath
  mov rsi, O_CREAT | O_TRUNC | O_RDWR ;; modes
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
  mov r10, 0
  syscall

err:
  mov rax, 3
  mov rdi, [fd]
  syscall
err2:
  mov rax, 60
  mov rdi, rax
  syscall

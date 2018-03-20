global _start

extern fopen
extern close
extern writetfd
extern exit
extern readtfd

section .data
  testfile: db "testfile.txt", 0x0
  .len: equ $ - testfile
  string: db "This is a test 129373456", 0xa, 0x0
  .len: equ $ - string
  buffer: times 50 db 0
  .len: equ $ - buffer

section .bss
  fd: resd 1

section .rodata


section .text
_start:
  nop
  nop

  mov rdi, testfile
  call fopen
  test al, al
  js .err
  mov [fd], al

  mov rdi, [fd]
  mov rsi, string
  mov rdx, string.len
  mov r10, 0
  call writetfd
  test eax, eax
  js .err

  mov rdi, [fd]
  mov rsi, buffer
  mov rdx, buffer.len
  mov r10, 0
  call readtfd
  test eax, eax
  js .err

  mov rax, 1
  mov rdi, 1
  mov rsi, buffer
  mov rdx, buffer.len
  syscall

  mov rdi, rax
  call close
  test al, al
  js .err



.err:
  mov  dil, al
  call exit

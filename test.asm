global _start

extern fopen
extern close
extern write
extern exit

section .data
  testfile: db "testfile.txt", 0x0
  .len: equ $ - testfile
  string: db "This is a test 129373456", 0xa, 0x0
  .len: equ $ - string

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
  call write
  test eax, eax
  js .err

  mov rdi, [fd]
  call close
  test al, al
  js .err



.err:
  mov  dil, al
  call exit

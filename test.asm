global _start

extern fopen
extern close
extern writetfd
extern exit
extern readtfd
extern filestatus

section .data
  testfile: db "testfile.txt", 0x0
  .len: equ $ - testfile
  string: db "This is a test 129373456", 0xa, 0x0
  .len: equ $ - string
  buffer: times 50 db 0x0
  .len: equ $ - buffer

section .bss
  fd:  resd 1
  var: resd 1
  tmp: resd 1

section .rodata


section .text
_start:
  nop
  nop

  mov rax, 0
  mov rdi, 0
  mov rsi, buffer
  mov rdx, buffer.len
  syscall
  mov [var], rax ;; save num bytes
  mov [buffer+rax-1], BYTE 0x0 ;; remove /n from buffer
  jmp false

%if 0
  mov rdi, buffer
  call filestatus
  test al, al
  js .err
%endif
false:
  mov rdi, [buffer]
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


.err:
  mov rdi, [fd]
  call close
  mov  rdi, rax
  call exit

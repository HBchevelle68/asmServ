global _start

extern csocket
extern csetsockopt
extern cbind
extern clisten
extern caccept
extern exit
extern cconnect
extern cwrite
extern close

section .data
;; Nothing currently, possible use later
string: db "This is a test 129373456", 0xa, 0x0
.len: equ $ - string

section .bss
fd: resd 1
file: resq 1

section .rodata
;; Nothing currently, possible use later

section .text

_start:
  nop
  nop
  nop


  mov rsi, [rsp] ;; argc
  cmp rsi, 2
  jl  .err
  mov rsi, [rsp+16] ;; *argv[0]
  mov QWORD [file], rsi

  call   csocket
  test   ax, ax
  js     .err
  mov    [fd], ax


  mov    rdi, [fd]
  mov    rsi, 0xE110
  mov    rdx, 0x0100007f
  call   cconnect
  test   ax, ax
  js     .err

  mov    rdi, [fd]
  mov    rsi, string
  mov    rdx, string.len
  call   cwrite
  test   ax, ax
  js     .err

.err:
  mov    dil, al
  call   exit

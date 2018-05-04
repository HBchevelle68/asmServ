global _start

 %include "socklib.inc"
 %include "filelib.inc"

section .data
  fileReq:       times 100 db 0
  .len:          equ $- fileReq

section .bss
  open_f_fd:     resd 1 ;;Open file file descriptor
  servfd:        resd 1 ;;Server socket file desc
  clifd:         resd 1 ;;Temp socket file desc
  bytesRecvd:    resd 1 ;;Bytes Recieved over the wire

section .rodata
;; Nothing currently, possible use later

section .text

_start:
debug: ;; added to help gdb since setting break on _start isn't working
  nop
  nop
  nop


  ;; create socket
  call    csocket
  test    ax, ax
  js      err
  mov     [servfd], ax

  ;; set socket opts
  mov     rdi, [servfd]
  call    csetsockopt
  test    ax, ax
  js     err

  ;; bind to addr space
  mov    rdi, [servfd]
  mov    rsi, 0xE110
  call   cbind
  test   ax, ax
  js     err

  ;; begin listen
  mov    rdi, [servfd]
  call   clisten
  test   ax, ax
  js     err

acceptLoop:
  ;; accept connections
  mov    rdi, [servfd]
  call   caccept
  test   ax, ax
  js     err
  mov    [clifd], rax

  ;; recv file request
  mov    rdi, [clifd]
  mov    rsi, fileReq
  mov    rdx, fileReq.len
  call   cread
  test   ax, ax
  js     err
  ;;Need to make sure null terminated string
  mov    [bytesRecvd], rax ;; save num bytes
  mov    [fileReq+rax], BYTE 0x0

  ;;check for file
  mov    rdi, fileReq
  call   fileaccess
  test   al, al
  jnz    err

  ;; test print
  mov    rdi, 1
  mov    rsi, fileReq
  mov    rdx, [bytesRecvd] ;; print number of bytes recv'd
  call   cwrite
  test   ax, ax
  js     err

  ;;open file
  mov    rdi, fileReq
  call   fopen
  test   ax, ax
  js     err
  mov    [open_f_fd], rax ;;save open file's fd

  ;;close file
  ;;Keep this here until send loop is built
  mov    rdi, [open_f_fd]
  call   close

  ;; temp error label/exit until specfic error msgs built

err:
  mov    r10, rax
  mov    rdi, [clifd]
  call   close
  mov    rdi, [servfd]
  mov    rax, r10
  call   close
  call   exit

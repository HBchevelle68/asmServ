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
  fsize:         resd 1

section .rodata
;; Nothing currently, possible use later

section .text

_start:
  nop
  nop
  nop

debug: ;; added to help gdb since setting break on _start isn't working
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
  ;; rax -> read syscall
  ;; rdi -> fd
  ;; rsi -> buffer
  ;; rdx -> buffer size
  ;; on ret, rax will contain # of bytes read || -1 if error
recv:
  mov    rax, 0
  mov    rdi, [clifd]
  mov    rsi, fileReq
  mov    rdx, fileReq.len
  syscall
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

  ;;file exists, get file size
  mov    rdi, fileReq
  call   filesize
  test   rax, rax
  js     err
  mov    [fsize], rax


  ;; test print**********************************************************
  mov    rax, 1
  mov    rdi, 1
  mov    rsi, fileReq
  mov    rdx, [bytesRecvd] ;; print number of bytes recv'd
  syscall
  test   ax, ax
  js     err
  ;;*********************************************************************

  ;;open file
  mov    rdi, fileReq
  call   fopen
  test   ax, ax
  js     err
  mov    [open_f_fd], rax ;;save open file's fd

  ;;close file
  ;;Keep this here until send loop is built
  mov    rax, 3
  mov    rdi, [open_f_fd]
  syscall

  ;; temp error label/exit until specfic error msgs built
err:
  push   rax
  .closeClientSock:
    mov  rax, 3
    mov  rdi, [clifd]
    syscall
  .closeServerSock:
    mov  rax, 3
    mov  rdi, [servfd]
    syscall
  pop    rdi ;;return value for exit call

  ;; rax -> exit syscall
  ;; rdi -> return value
  ;; on syscall exits and returns passed value
exit:
  mov    rax, 60
  syscall

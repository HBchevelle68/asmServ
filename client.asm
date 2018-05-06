global _start

%include "socklib.inc"
%include "filelib.inc"

section .data
;; Nothing currently, possible use later
string: db "This is a test 129373456", 0xa, 0x0
.len: equ $ - string

section .bss
fd:      resd 1
file:    resq 1

section .rodata
;; Nothing currently, possible use later

section .text

string_length:
  xor    rax, rax
  .loop:
  cmp    byte [rdi+rax], 0
  je     .end
  inc    rax
  jmp    .loop
  .end:
  ret


_start:
debug:
  nop
  nop
  nop

  ;;Make sure enough args passed
  mov    rsi, [rsp] ;; argc
  cmp    rsi, 2
  jnz    err

  ;;Get the file
  mov    rsi, [rsp+16] ;; *argv[1]
  mov    QWORD [file], rsi

  ;;create socket
  call   csocket
  test   ax, ax
  js     err
  mov    [fd], ax

  ;;connect to server
  mov    rdi, [fd]
  mov    rsi, 0xE110 ;; hardcoded port 4321 for now
  mov    rdx, 0x0100007f ;; hardcoded ip 127.0.0.1 for now
  call   cconnect
  test   ax, ax
  js     err

  ;;Get legth of filename to send
  mov    rdi, [file]
  call   string_length
  push   rax
  ;;Send filename
  ;; rdi -> fd
  ;; rsi -> buffer
  ;; rdx -> buffer size
  ;; on ret, rax will contain # of bytes read || -1 if error
send:
  mov    rax, 1
  mov    rdi, [fd]
  mov    rsi, [file]
  pop    rdx
  syscall
  test   ax, ax
  js     err

close:

err:
  push   rax
%if 0
  .close:
    mov  rax, 3
    mov  rdi, [fd]
    syscall
%endif
  pop    rdi
  ;; rax _> exit syscall
  ;; rdi -> return value
  ;; on syscall exits and returns passed value
exit:
  mov    rax, 60
  syscall

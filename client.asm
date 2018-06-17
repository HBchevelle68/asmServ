global _start

%include "socklib.inc"
%include "filelib.inc"

%define fileNotFound 0
%define fileFound    1

section .data
;; Nothing currently, possible use later
  tbuff:     times 100 db 0
  .len:      equ $ - tbuff

section .bss
  sockfd:    resd 1 ;;integer variable to hold socket file desc
  fStrPtr:   resq 1 ;;File string pointer to cmd arg provided

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
;----------------------------------------------------------------------
  mov    rsi, [rsp] ;; argc
  cmp    rsi, 2
  jnz    err

;;Get the file
;----------------------------------------------------------------------
  mov    rsi, [rsp+16] ;; *argv[1]
  mov    QWORD [fStrPtr], rsi

;;create socket
;----------------------------------------------------------------------
  call   csocket
  test   ax, ax
  js     err
  mov    [sockfd], ax

;;connect to server
;----------------------------------------------------------------------
  mov    rdi, [sockfd]
  mov    rsi, 0xE110     ;; hardcoded port 4321 for now
  mov    rdx, 0x0100007f ;; hardcoded ip 127.0.0.1 for now
  call   cconnect
  test   ax, ax
  js     err

;;Get legth of filename to send
;----------------------------------------------------------------------
  mov    rdi, [fStrPtr]
  call   string_length
  push   rax

;;Send filename
;; rdi -> fd
;; rsi -> buffer
;; rdx -> buffer size
;; on ret, rax will contain # of bytes sent || -1 if error
;----------------------------------------------------------------------
;----------------------------------------------------------------------
send:
  mov    rax, 1
  mov    rdi, [sockfd]
  mov    rsi, [fStrPtr]
  pop    rdx
  syscall
  test   ax, ax
  js     err

;; Recv file found or file doesnt exist
;; rax -> read syscall
;; rdi -> fd
;; rsi -> buffer
;; rdx -> buffer size
;; on ret, rax will contain # of bytes read || -1 if error
;----------------------------------------------------------------------
;----------------------------------------------------------------------
recv:
   mov    rax, 0
   mov    rdi, [sockfd]
   mov    rsi, tbuff
   mov    rdx, tbuff.len
   syscall
   test   ax, ax
   js     err

;;Teardown
;----------------------------------------------------------------------
err:
  push   rax

  .close:
    mov  rax, 3
    mov  rdi, [sockfd]
    syscall

  pop    rdi
  ;; rax _> exit syscall
  ;; rdi -> return value
  ;; on syscall exits and returns passed value
exit:
  mov    rax, 60
  syscall

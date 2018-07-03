global _start

%include "socklib.inc"
%include "filelib.inc"

%define fileNotFound  0x00
%define fileFound     0x01
%define respCodeSz    6
%define defaultBuffSz 1500

section .data
;; Nothing currently, possible use later

section .bss
  ;; Network Vars
  sockfd:        resd 1 ;;integer variable to hold socket file desc

  ;; File Vars
  fStrPtr:       resq 1 ;;Pointer to file cmd arg provided
  new_f_fd:      resd 1 ;;Newly created, opened file, file descriptor
  fsize:         resd 1 ;;Size of file in Bytes

  ;; Mem Alloc Vars
  initAddr:      resq 1 ;;initial addr of prog break (data seg end)
  currAddr:      resq 1 ;;current addr of prog break

section .text

string_length:
  xor     rax, rax
  .loop:
  cmp     byte [rdi+rax], 0
  je      .end
  inc     rax
  jmp     .loop
  .end:
  ret


_start:
debug:
  nop
  nop
  nop

;;Make sure enough args passed
;----------------------------------------------------------------------
  mov     rsi, [rsp] ;; argc
  cmp     rsi, 2
  jnz     err

;;Get the file
;----------------------------------------------------------------------
  mov     rsi, [rsp+16] ;; *argv[1]
  mov     QWORD [fStrPtr], rsi

;;create socket
;----------------------------------------------------------------------
  call    csocket
  test    ax, ax
  js      err
  mov     [sockfd], ax

;;connect to server
;----------------------------------------------------------------------
  mov     rdi, [sockfd]
  mov     rsi, 0xE110     ;; hardcoded port 4321 for now
  mov     rdx, 0x0100007f ;; hardcoded ip 127.0.0.1 for now
  call    cconnect
  test    ax, ax
  js      err

;;Get legth of filename to send
;----------------------------------------------------------------------
  mov     rdi, [fStrPtr]
  call    string_length
  push    rax

;;Send filename
;; rdi -> fd
;; rsi -> buffer
;; rdx -> buffer size
;; on ret, rax will contain # of bytes sent || -1 if error
;----------------------------------------------------------------------
send:
  mov     rax, 1
  mov     rdi, [sockfd]
  mov     rsi, [fStrPtr]
  pop     rdx
  syscall
  test    ax, ax
  js      err

;; Allocate memory for buffer
;; after syscall rax will contain addr || -1 for error
;----------------------------------------------------------------------
allocMem:

.getCurrBrk:
  mov     rax, 12 ;; sys_brk
  mov     rdi, 0  ;; 0 returns current heap break addr
  syscall
  mov     [initAddr], rax ;; update vars
  mov     [currAddr], rax

  ;; For now just alloc 1.5 KB

  ;; TODO
  ;; Increase size and add check to see if full size is needed

.alloc:
  mov     rax, 12 ;; sys_brk
  mov     rdi, [currAddr]
  add     rdi, 1500 ;; allocate 1500 bytes
  syscall
  mov     [currAddr], rax

;; Recv file found or file doesnt exist
;; rax -> read syscall
;; rdi -> fd
;; rsi -> buffer
;; rdx -> buffer size
;; on ret, rax will contain # of bytes read || -1 if error
;----------------------------------------------------------------------
recv:
  mov    rax, 0
  mov    rdi, [sockfd]   ;; sock fd w/ connection to server
  mov    rsi, [initAddr] ;; pointer to buffer
  mov    rdx, respCodeSz ;; response code size
  syscall
  test   ax, ax
  js     err

checkCode:
  cmp    BYTE [rsi], fileFound ;; check response code
  je     found ;; file found == 0x1
  jne    notFound ;; file NOT found == 0x0



found:

.stripFileSize:
  mov    DWORD eax, [rsi+2] ;; get dword in buff containing file size
  mov    DWORD [fsize], eax ;; save file size

;; Create new file to write downloaded file
.createFile:
  mov    rsi, [fStrPtr] ;; get file name
  call   fopen_create  ;; create file
  test   ax, ax
  js     err
  mov    DWORD [new_f_fd], eax ;; save new file fd

.recv:
  mov    rax, 0
  mov    rdi, [sockfd]      ;; sock fd w/ connection to server
  mov    rsi, [initAddr]    ;; pointer to buffer
  mov    rdx, defaultBuffSz ;; buffer size
  syscall
  test   ax, ax
  js     err




notFound:
  nop
  nop
  nop




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

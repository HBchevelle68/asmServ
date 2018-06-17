global _start

%include "socklib.inc"
%include "filelib.inc"

%define fileNotFound 0
%define fileFound    1


section .data
  fileToGet:     times 100 db 0
  .len:          equ $ - fileToGet

section .bss
  ;; File Vars
  open_f_fd:     resd 1 ;;Open file file descriptor
  fsize:         resd 1 ;;Size of file in Bytes
  bytesRead:     resd 1 ;;Number of bytes read/offset

  ;; Network Vars
  servfd:        resd 1 ;;Server socket file desc
  clifd:         resd 1 ;;Client socket file desc
  bytesRecvd:    resd 1 ;;Bytes Recieved over the wire

  ;; Mem Alloc Vars
  addrPtr:       resq 1 ;;Starting addr of allocated mem
  initAddr:      resq 1 ;;initial addr of prog break (data seg end)
  currAddr:      resq 1 ;;current addr of prog break

section .text

_start:
  nop
  nop
  nop

debug: ;; added to help gdb since setting break on _start isn't working

;; create socket
;----------------------------------------------------------------------
  call    csocket
  test    ax, ax
  js      err
  mov     [servfd], ax

;; set socket opts
;----------------------------------------------------------------------
  mov     rdi, [servfd]
  call    csetsockopt
  test    ax, ax
  js      err

;; bind to addr space
;----------------------------------------------------------------------
  mov    rdi, [servfd]
  mov    rsi, 0xE110
  call   cbind
  test   ax, ax
  js     err

;; begin listen
;----------------------------------------------------------------------
  mov    rdi, [servfd]
  call   clisten
  test   ax, ax
  js     err

;; accept connections
;----------------------------------------------------------------------
acceptLoop:
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
;----------------------------------------------------------------------
.recv:
   mov    rax, 0
   mov    rdi, [clifd]
   mov    rsi, fileToGet
   mov    rdx, fileToGet.len
   syscall
   test   ax, ax
   js     err

   ;;Need to make sure null terminated string
   mov    [bytesRecvd], rax ;; save num bytes
   cmp    rax, 100          ;; CONDITIONAL check that file name recv fits in buf
   jge    err
   mov    [fileToGet+rax], BYTE 0x0

;; Check if file even exists with sys_access syscall
;----------------------------------------------------------------------
fileExists:
  mov    rdi, fileToGet
  call   fileaccess
  test   al, al
  jnz    err

;; Get the size of the file to track progress
;----------------------------------------------------------------------
getFileSize:
  mov    rdi, fileToGet
  call   filesize
  test   rax, rax
  js     err
  mov    [fsize], rax

;; Allocate memory for buffer
;; after syscall rax will contain addr || -1 for error
;----------------------------------------------------------------------
allocMem:

.getCurrBrk:
  mov    rax, 12 ;; sys_brk
  mov    rdi, 0  ;; 0 returns current heap break addr
  syscall
  mov    [initAddr], rax ;; update vars
  mov    [currAddr], rax

  ;; For now just alloc 1.5 KB

  ;; TODO
  ;; Increase size and add check to see if full size is needed

.alloc:
  mov    rax, 12 ;; sys_brk
  mov    rdi, [currAddr]
  add    rdi, 1500 ;; allocate 1500 bytes
  syscall
  mov    [currAddr], rax


;; rdi -> fd
;; rsi -> buffer
;; rdx -> buffer size
;; on ret, rax will contain # of bytes sent || -1 if error
;----------------------------------------------------------------------
sendFileExists:


%if 0
  xor    rax, rax ;;clear register
  xor    rdi, rdi ;;clear register
  mov    rax, [fsize]
  or     rdi, 0x01 ;
  rol    rdi, 8  ;; rotate one byte left
  or     rdi, 0x24
  rol    rdi, 48 ;; rotate one byte right
  or     rdi, rax

  ;; 8-byte response in rdi
  ;; Move to buff
  mov    rax, [initAddr]
  mov    QWORD [rax], rdi ;; 8-byte response
%endif
.formatMsg:
  mov    rsi,  [initAddr] ;;point to alloc'd mem buff
  mov    BYTE  [rsi], 0x01
  mov    BYTE  [rsi+1], '$'
  mov    eax, [fsize]
  mov    DWORD [rsi+2], eax

.send:
  mov    rax, 1          ;; sys_send
  mov    rdi, [clifd]    ;; clinet sock addr
  mov    rsi, [initAddr] ;; allocated mem buff
  mov    rdx, 6
  syscall


        ;; TO DO

sendFileNotFound:




  ;; test print**********************************************************
  mov    rax, 1
  mov    rdi, 1
  mov    rsi, fileToGet
  mov    rdx, [bytesRecvd] ;; print number of bytes recv'd
  syscall
  test   ax, ax
  js     err
  ;;*********************************************************************



;;Open file prior to ReadnSendLoop
;----------------------------------------------------------------------
openfile:
  mov    rdi, fileToGet
  call   fopen
  test   ax, ax
  js     err
  mov    [open_f_fd], rax ;;save open file's fd

%if 0
ReadnSendLoop:
  push rbp
  mov  rbp, rsp  ;; save stack ptr
  sub  rsp, 1500 ;; allocate mem
  mov  [sframeptr], rsp ;; mov stack ptr to var
  mov  DWORD [bytesRead], 0 ;; set offset var to 0

  ;; sys_pread64
  ;; params:
  ;; rdi -> fd of file
  ;; rsi -> buffer
  ;; rdx -> buffer size
  ;; r10 -> offset
  ;; on ret, rax will contain # bytes written || -1 on error
  .pread:
    mov  rax, 17
    mov  rdi, [open_f_fd]
    mov  rsi, [sframeptr]
    mov  rdx, 1500
    mov  r10, [bytesRead]
    syscall

    ;; Test that pread has no error
    test rax, rax
    js   closefile

    ;; r10 hold total bytes read
    add  r10, rax  ;; add bytes read to update offset
    mov  rax, [fsize]
    cmp  r10, rax ;; check to see if the whole file has been read





    mov  [bytesRead], r10 ;; update offset var







%endif





closefile:
  ;;Keep this here until send loop is built
  mov    rax, 3
  mov    rdi, [open_f_fd]
  syscall

  ;; temp error label/exit until specfic error msgs built
err:
  push   rax

  .freeMem:
    mov  rax, 12
    mov  rdi, [initAddr]
    syscall

  .closeClientSock:
    mov  rax, 3
    mov  rdi, [clifd]
    syscall

  .closeServerSock:
    mov  rax, 3
    mov  rdi, [servfd]
    syscall

  pop    rdi ;; pop return value for exit call

  ;; rax -> exit syscall
  ;; rdi -> return value
  ;; on syscall exits and returns passed value
exit:
  mov    rax, 60
  syscall

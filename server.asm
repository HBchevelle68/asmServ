global _start

%include "socklib.inc"
%include "filelib.inc"

%define fileNotFound  0
%define fileFound     1
%define respCodeSz    6
%define defaultBuffSz 4000

section .data
  reqStr: db "Request recieved for ", 0x0
  .len: equ $ - reqStr
  doneStr: db "...done!", 0xa, 0x0
  .len: equ $ - doneStr
  errStr: db "...oh shit, I broke!", 0xa, 0x0
  .len: equ $ - errStr
  restStr: db "Cleaning mem and sockets...Restarting...", 0xa, 0x0
  .len: equ $ - restStr


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
  initAddr:      resq 1 ;;initial addr of prog break (data seg end)
  currAddr:      resq 1 ;;current addr of prog break

section .text

_start:
  nop
  nop
  nop

debug: ;; added to help gdb since setting break on _start isn't working


;; Allocate memory for buffer
;; after syscall rax will contain addr || -1 for error
;----------------------------------------------------------------------
allocMem:

.getCurrBrk:
  mov    rax, 12 ;; sys_brk
  mov    rdi, 0  ;; 0 returns current heap break addr
  syscall
  mov    QWORD [initAddr], rax ;; update vars
  mov    QWORD [currAddr], rax

  ;; For now just alloc 1.5 KB

  ;; TODO
  ;; Increase size and add check to see if full size is needed

.alloc:
  mov    rax, 12 ;; sys_brk
  mov    rdi, [currAddr]
  add    rdi, defaultBuffSz ;; allocate 1500 bytes
  syscall
  mov    [currAddr], rax


;; create socket
;----------------------------------------------------------------------
socket:
  call    csocket
  test    ax, ax
  js      err
  mov     [servfd], ax

;; set socket opts
;----------------------------------------------------------------------
setsockopts:
  mov     edi, DWORD [servfd]
  call    csetsockopt
  test    ax, ax
  js      err

;; bind to addr space
;----------------------------------------------------------------------
bind:
  mov    edi, DWORD [servfd]
  mov    rsi, 0xE110
  call   cbind
  test   ax, ax
  js     err

;; begin listen
;----------------------------------------------------------------------
listen:
  mov    edi, DWORD [servfd]
  call   clisten
  test   ax, ax
  js     err

;; accept connections
;----------------------------------------------------------------------
acceptLoop:
  mov    edi, DWORD [servfd]
  call   caccept
  test   ax, ax
  js     err
  mov    DWORD [clifd], eax

;; recv file request
;; rax -> read syscall
;; rdi -> fd
;; rsi -> buffer
;; rdx -> buffer size
;; on ret, rax will contain # of bytes read || -1 if error
;----------------------------------------------------------------------
.recv:
   mov    rax, 0
   mov    edi, DWORD [clifd]
   mov    rsi, fileToGet
   mov    rdx, fileToGet.len
   syscall
   test   ax, ax
   js     err

   ;;Need to make sure null terminated string
   mov    DWORD [bytesRecvd], eax ;; save num bytes
   cmp    rax, 100 ;; CONDITIONAL check that file name recv'd fits in buf
   jge    err
   mov    [fileToGet+rax], BYTE 0x0

;; Check if file even exists with sys_access syscall
;----------------------------------------------------------------------
fileExists:
  mov    rdi, fileToGet
  call   fileaccess
  test   al, al ;; see if file found, 0 if true, -1 if false or error
  jnz    sendFileNotFound ;; jump if false

;; Get the size of the file to track progress
;----------------------------------------------------------------------
getFileSize:
  mov    rdi, fileToGet
  call   filesize
  test   rax, rax
  js     err
  mov    DWORD [fsize], eax

;; rdi -> fd
;; rsi -> buffer
;; rdx -> buffer size
;; on ret, rax will contain # of bytes sent || -1 if error
;----------------------------------------------------------------------
sendFileExists:

.formatMsg:
  mov    rsi,  [initAddr] ;;point to alloc'd mem buff
  mov    BYTE  [rsi], 0x01
  mov    BYTE  [rsi+1], '$'
  mov    eax,  DWORD [fsize]
  mov    DWORD [rsi+2], eax

.send:
  mov    rax, 1          ;; sys_send
  mov    edi, DWORD [clifd]    ;; clinet sock addr
  mov    rsi, [initAddr] ;; allocated mem buff
  mov    rdx, respCodeSz
  syscall
  jmp debugPrint


;----------------------------------------------------------------------
sendFileNotFound:

.formatMsg:
  mov    rsi,  [initAddr] ;;point to alloc'd mem buff
  mov    BYTE  [rsi], 0x00
  mov    BYTE  [rsi+1], '$'

.send:
  mov    rax, 1          ;; sys_send
  mov    edi, DWORD [clifd]    ;; clinet sock addr
  mov    rsi, [initAddr] ;; allocated mem buff
  mov    rdx, respCodeSz
  syscall

debugPrint:

  mov    rax, 1
  mov    rdi, 1
  mov    rsi, reqStr
  mov    rdx, reqStr.len ;; print number of bytes recv'd
  syscall
  test   ax, ax
  js     err


  ;; test print**********************************************************
  mov    rax, 1
  mov    rdi, 1
  mov    rsi, fileToGet
  mov    edx, DWORD [bytesRecvd] ;; print number of bytes recv'd
  syscall
  test   ax, ax
  js     err
  ;;*********************************************************************

;;Open file prior to ReadnSendLoop
;----------------------------------------------------------------------
openfile:
  mov    rdi, fileToGet
  call   fopen
  test   al, al
  js     err
  mov    DWORD [open_f_fd], eax ;;save open file's fd

;;Read and send loop
rNSLoop:

  mov  DWORD [bytesRead], 0 ;; set offset var to 0

;; sys_pread64
;; params:
;; rdi -> fd of file
;; rsi -> buffer
;; rdx -> buffer size
;; r10 -> offset
;; on ret, rax will contain # bytes written || -1 on error
.pread:
  mov    rax, 17
  mov    edi, DWORD [open_f_fd]        ;; opened file file descriptor
  mov    rsi, [initAddr]         ;; pointer to buffer
  mov    rdx, defaultBuffSz      ;; buffer Size
  mov    r10d, DWORD [bytesRead] ;; read offset
  syscall
  ;; Test that pread has no error
  test   ax, ax
  js     closefile
  push   rax      ;; push number of bytes read from file for later comparision
  mov    rdx, rax ;; move number of bytes read from file into buffsize reg
.send:
  mov    rax, 1          ;; sys_send
  mov    edi, DWORD [clifd]    ;; clinet sock addr
  mov    rsi, [initAddr] ;; allocated mem buff
  ;; rdx
  syscall

.checkSentNum:
  pop    r10       ;; get number of bytes read from file
  cmp    r10, rax  ;; compare # bytes read from file to bytes sent over wire
  jne    closefile ;; if not equal error has occured
  ;; jump to close file until proper error messages made

.updateVar:
  mov    eax, DWORD [bytesRead]
  add    eax, r10d ;; rax now has running total of bytes read from file
  mov    DWORD [bytesRead], eax ;; update total of bytes read from file

.checkDone:
  mov    r10d, DWORD [fsize] ;; get file size from var
  cmp    r10d, eax ;; check to see if the whole file has been read
  jg     .pread ;; if fsize > bytesRead; more bytes to read
  je     closefile ;; if fsize == brecvd; file transfer complete

closefile:
  ;;Keep this here until send loop is built
  mov    rax, 3
  mov    edi, DWORD [open_f_fd]
  syscall

done:
  mov    rax, 1
  mov    rdi, 1
  mov    rsi, doneStr
  mov    rdx, doneStr.len ;; print number of bytes recv'd
  syscall
  test   ax, ax
  js     err
  jmp    acceptLoop

  ;; temp error label/exit until specfic error msgs built
err:

  mov    rax, 1
  mov    rdi, 1
  mov    rsi, errStr
  mov    rdx, errStr.len ;; print number of bytes recv'd
  syscall
  push   rax
  mov    rax, 1
  mov    rdi, 1
  mov    rsi, restStr
  mov    rdx, restStr.len ;; print number of bytes recv'd
  syscall

  .freeMem:
    mov  rax, 12
    mov  rdi, [initAddr]
    syscall

  .closeClientSock:
    mov  rax, 3
    mov  edi, DWORD [clifd]
    syscall

  .closeServerSock:
    mov  rax, 3
    mov  edi, DWORD [servfd]
    syscall

  jmp _start

;; rax -> exit syscall
;; rdi -> return value
;; on syscall exits and returns passed value
exit:
  mov    rax, 60
  syscall

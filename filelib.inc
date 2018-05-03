;;
;;   syscall wrappers
;;
%ifndef FILELIB.INC
  %define FILELIB.INC

    ;     modes
    ;read-only
    ;wirte-only
    ;read and write
    %define F_OK      0
    %define O_RDONLY  0
    %define O_WRONLY  1
    %define O_RDWR    2

    ;set file offset to offset
    ;set file offset to current plus offset
    ;set file offset to EOF plus offset
    %define SEEK_SET 0
    %define SEEK_CUR 1
    %define SEEK_END 2

    ;;   flags
    ;create file if file doesnt exists
    ;truncate file
    ;append to file
    %define O_CREAT  100o
    %define O_TRUNC  1000o
    %define O_APPEND 2000o

    ;; params:
    ;; rdi -> filename/filepath
    ;; on ret, rax will contain fd || -1 if error
    fopen:
      mov rax, 2
      ;; rdi
      mov rsi, O_RDWR
      mov rdx, 0666o
      syscall
      ret

    ;; params:
    ;; rdi -> fd of file to close
    ;; on ret, rax will contain 0 || -1 if error
    close:
      mov rax, 3
      ;; rdi
      syscall
      ret

    ;; sys_pwrite64
    ;; params:
    ;; rdi -> fd of file
    ;; rsi -> buffer
    ;; rdx -> buffer size
    ;; r10 -> offset
    ;; on ret, rax will contain # bytes written to buffer || -1 on error
    writetfd:
      mov rax, 18
      ;; rdi
      ;; rsi
      ;; rdx
      ;; r10
      syscall
      ret


    ;; sys_pread64
    ;; params:
    ;; rdi -> fd of file
    ;; rsi -> buffer
    ;; rdx -> buffer size
    ;; r10 -> offset
    ;; on ret, rax will contain # bytes written || -1 on error
    readtfd:
      mov rax, 17
      ;; rdi
      ;; rsi
      ;; rdx
      ;; r10
      syscall
      ret

      ;; sys_access
      ;; uses F_OK mode to retrieve wether or not file exists
      ;; rdi -> char* of file
      ;; on ret, rax will return 0 if succesful and file exists || -1 if file does not exist
    filestatus:
      mov rax, 21
      ;; rdi
      mov rsi, F_OK
      syscall
      ret

%endif

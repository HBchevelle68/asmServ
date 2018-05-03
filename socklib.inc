;;
;;   syscall wrappers
;;
%ifndef SOCKLIB.INC
  %define SOCKLIB.INC

    ;;Domains/Family
    %define AF_INET         2
    ;;Types
    %define SOCK_STREAM     1
    ;;Protocols
    %define IPPROTO_IP      0
    ;;Socket options
    %define SOL_SOCKET      1
    %define SO_REUSEADDR    2
    ;;Addresses
    %define INADDR_ANY      0

    section .text

    ;; no params passed
    ;; on ret rax will contain fd || -1 if error
    csocket:
      mov rax, 41
      mov rdi, AF_INET
      mov rsi, SOCK_STREAM
      mov rdx, IPPROTO_IP
      syscall
      ret

    ;; params:
    ;; rdi -> socket fd
    ;; on ret rax will contain 0 || -1 if error
    csetsockopt:
      mov rax, 54
      mov rsi, SOL_SOCKET
      mov rdx, SO_REUSEADDR
      mov r8, 4
      push QWORD 4
      mov r10, rsp

      syscall
      add rsp, 8
      ret

    ;; params:
    ;; rdi -> socket fd
    ;; rsi -> port number in reverse byte order
    ;;       (port 4321 = 0x10E1, in reverse byte order = 0xE110)
    ;; on ret rax will contain 0 || -1 if error
    cbind:
      mov rbp, rsp
      mov rax, 49
      ;;rdi
      ;; Build struct sockaddr_in
      push DWORD INADDR_ANY
      push WORD si
      push WORD AF_INET
      mov rsi, rsp

      mov rdx, 16
      syscall
      mov rsp, rbp
      ret

    ;; params:
    ;; rdi -> socket fd
    ;; on ret rax will contain 0 || -1 if error
    clisten:
      mov rax, 50
      ;;rdi-> passed param
      mov rsi, 5 ;; number of connections to buffer
      syscall
      ret

    ;; params:
    ;; rdi-> socket fd
    ;; on ret rax will contain fd || -1 if error
    caccept:
      mov rax, 43
      xor rsi, rsi
      xor rdx, rdx
      syscall
      ret
    ;; params:
    ;; rdi -> socket fd
    ;; rsi -> port number in reverse byte order
    ;;       (port 4321 = 0x10E1, in reverse byte order = 0xE110)
    ;; rdx -> IP addr in reverse byte order
    ;; on ret rax will contain 0 || -1 if error
    cconnect:
      mov rbp, rsp
      push QWORD 0
      push rdx
      push rsi
      push WORD AF_INET

      mov rax, 42
      ;; rdi-> passed param
      mov rsi, rsp
      mov rdx, 16
      syscall
      mov rsp, rbp
      ret

    ;; params:
    ;; rdi -> fd
    ;; rsi -> buffer
    ;; rdx -> buffer size
    ;; on ret, rax will contain # of bytes read || -1 if error
    cread:
      mov rax, 0
      ;; rdi-> passed param
      ;; rsi-> passed param
      ;; rdx-> passed param
      syscall
      ret

    ;; params:
    ;; rdi -> fd
    ;; rsi -> buffer
    ;; rdx -> buffer size
    ;; on ret, rax will contain # of bytes read || -1 if error
    cwrite:
      mov rax, 1
      ;; rdi-> passed param
      ;; rsi-> passed param
      ;; rdx-> passed param
      syscall
      ret

    ;; params:
    ;; rdi -> return value
    ;; on syscall exits and returns passed value
    exit:
      mov rax, 60
      syscall
      ret

%endif

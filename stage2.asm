[BITS 16]
[ORG 0x7E00]

stage2_start:
    mov si, msg_stage2
    call print_string
    call show_system_info
    call shell
    jmp halt

show_system_info:
    pusha
    mov si, msg_separator
    call print_string
    mov si, msg_memory
    call print_string
    int 0x12
    call print_decimal
    mov si, msg_kb
    call print_string

    ; CPUID tespiti
    mov si, msg_cpu
    call print_string
    call detect_cpu

    mov si, msg_separator
    call print_string
    popa
    ret

detect_cpu:
    pusha
    ; CPUID destegi var mi kontrol et
    pushf
    pop ax
    mov cx, ax
    xor ax, 0x200000
    push ax
    popf
    pushf
    pop ax
    push cx
    popf
    xor ax, cx
    jz .no_cpuid

    mov eax, 0
    cpuid
    mov [cpu_vendor], ebx
    mov [cpu_vendor+4], edx
    mov [cpu_vendor+8], ecx
    mov byte [cpu_vendor+12], 0
    mov si, cpu_vendor
    call print_string
    jmp .done
.no_cpuid:
    mov si, msg_no_cpuid
    call print_string
.done:
    mov si, msg_newline
    call print_string
    popa
    ret

shell:
    mov si, msg_shell_help
    call print_string
.prompt:
    mov si, msg_prompt
    call print_string
    mov di, input_buffer
    call read_line
    cmp byte [input_buffer], 0
    je .prompt.
    mov si, input_buffer
    mov di, cmd_help
    call strcmp
    cmp ax, 1
    je .do_help

    mov si, input_buffer
    mov di, cmd_info
    call strcmp
    cmp ax, 1
    je .do_info

    mov si, msg_unknown
    call print_string
    jmp .prompt

.do_help:
    mov si, msg_shell_help
    call print_string
    jmp .prompt

.do_info:
    call show_system_info
    jmp .prompt

strcmp:
    ; String karsilastirma mantigi (case insensitive)
    push si
    push di
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, 'a'
    jb .next
    cmp al, 'z'
    ja .next
    sub al, 32
.next:
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal
    inc si
    inc di
    jmp .loop
.equal:
    pop di
    pop si
    mov ax, 1
    ret
.not_equal:
    pop di
    pop si
    xor ax, ax
    ret

; Helpers
read_line:
    pusha
    xor cx, cx
.loop:
    mov ah, 0x00
    int 0x16
    cmp al, 13 ; Enter?
    je .done
    cmp al, 8  ; Backspace?
    je .backspace
    cmp cx, 62
    jge .loop
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .loop
.backspace:
    test cx, cx
    jz .loop
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .loop
.done:
    mov byte [di], 0
    mov si, msg_newline
    call print_string
    popa
    ret

print_string:
    pusha
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

print_decimal:
    pusha
    xor cx, cx
    mov bx, 10
.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .divide
.print:
    pop ax
    add al, '0'
    mov ah, 0x0E
    int 0x10
    loop .print
    popa
    ret

halt:
    cli
    hlt
    jmp halt

; Global Mesajlar
msg_stage2:     db "STAGE2 Successfully loaded!", 13, 10, 0
msg_separator:  db "----------------------------------------", 13, 10, 0
msg_memory:     db "  Memory    : ", 0
msg_kb:         db " KB (conventional)", 13, 10, 0
msg_cpu:        db "  CPU       : ", 0
msg_no_cpuid:   db "CPUID not supported", 0
msg_newline:    db 13, 10, 0
msg_shell_help: db "Commands: HELP, INFO, CLEAR, REBOOT", 13, 10, 0
msg_prompt:     db "boot> ", 0
msg_unknown:    db "Unknown command.", 13, 10, 0

cmd_help:       db "HELP", 0
cmd_info:       db "INFO", 0

cpu_vendor:     times 13 db 0
input_buffer:   times 64 db 0

times 2048 - ($ - $$) db 0.

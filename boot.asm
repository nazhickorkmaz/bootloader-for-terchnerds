[BITS 16]
[ORG 0x7C00]

jmp 0:start

; ============================================
; BIOS Parameter Block (BPB) - FAT12 compatible
; ============================================
OEMLabel            db "MYBOOT  "
BytesPerSector      dw 512
SectorsPerCluster   db 1
ReservedSectors     dw 1
NumberOfFATs        db 2
RootEntries         dw 224
TotalSectors        dw 2880
MediaType           db 0xF0
SectorsPerFAT       dw 9
SectorsPerTrack     dw 18
NumberOfHeads       dw 2
HiddenSectors       dd 0
TotalSectorsBig     dd 0
DriveNumber         db 0
Reserved            db 0
BootSignature       db 0x29
VolumeID            dd 0x12345678
VolumeLabel         db "BOOTLOADER "
FileSystem          db "FAT12   "

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [DriveNumber], dl.

    ; (Text mode 80x25)
    mov ax, 0x0003
    int 0x10

    mov si, msg_stage1
    call print_string
.
    mov di, 3               
.retry_load:
    push di
    
    ; reload the disk
    xor ax, ax
    mov dl, [DriveNumber]
    int 0x13
    
    ; 4 sector readin
    mov ax, 0x0204          
    mov ch, 0               
    mov cl, 2               
    mov dh, 0               
    mov dl, [DriveNumber]
    mov bx, STAGE2_OFFSET   
    int 0x13
    
    jnc .load_success
    
    pop di
    dec di
    jnz .retry_load
    jmp disk_error

.load_success:
    pop di
    mov si, msg_jumping
    call print_string
    jmp STAGE2_OFFSET

disk_error:
    mov si, msg_disk_error
    call print_string
    mov ah, 0x01            
    int 0x13
    mov al, ah
    call print_hex_byte
    jmp halt

halt:
    mov si, msg_halt
    call print_string
.loop:
    cli
    hlt
    jmp .loop

; helper functions
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

print_hex_byte:
    pusha
    mov cl, al
    shr al, 4
    call .nibble
    mov al, cl
    and al, 0x0F
    call .nibble
    popa
    ret
.nibble:
    cmp al, 9
    jbe .digit
    add al, 7
.digit:
    add al, 0x30
    mov ah, 0x0E
    int 0x10
    ret

msg_stage1:     db "[STAGE1] Bootloader initialized", 13, 10, 0
msg_jumping:    db "[STAGE1] Jumping to Stage 2...", 13, 10, 0
msg_disk_error: db "[ERROR] Disk read failed: 0x", 0
msg_halt:       db 13, 10, "System Halted.", 0

STAGE2_OFFSET   equ 0x7E00

times 510 - ($ - $$) db 0
dw 0xAA55

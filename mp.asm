; MARTINEZ, FRANCIS BENEDICT 
; WONG, KRIZCHELLE DANIELLE 
; S15

%include "io64.inc"

section .data
reversedResult times 256 db 0
result times 256 dq 0
buf: times 101 db 0x0a
numout db ""

section .text
global main

main:
    mov rbp, rsp; for correct debugging
    ; show menu GUI
    JMP show_menu
    
show_menu:
    PRINT_STRING "--Number Base Conversion--"
    NEWLINE
    NEWLINE
    
    PRINT_STRING "1. Decimal to Radix-N"
    NEWLINE
    
    PRINT_STRING "2. Radix-N to Decimal"
    NEWLINE
    NEWLINE
    NEWLINE
    JMP modeio
    
terminate_program:
    ; this section terminates the program
    NEWLINE
    PRINT_STRING "--Program terminated--"
    NEWLINE
    
    xor rax, rax
    ret
    
modeio:
    ; this section is for inputting modes from the menu
    PRINT_STRING "Select mode: "
    GET_DEC 1, r8
    PRINT_DEC 1, r8
    NEWLINE
    
    ; if 1, then DEC->RADIX
    CMP r8, 1
    JE decimal_to_radix
    
    ; if 2, then RADIX->DEC
    CMP r8, 2
    JE radix_to_decimal 
    
    ; else, jump to error thrower
    JMP invalid_mode

; !!!====================== BEGINNING OF DECIMAL to RADIX-N SECTIONS
decimal_to_radix:
    ; this section converts dec to radix
    ; asks for dec number
    PRINT_STRING "Enter a decimal number: "
    GET_DEC 8, r9
    PRINT_DEC 8, r9 ; for removal due to CLI
    NEWLINE
    
    ; asks for radix to convert to
    PRINT_STRING "Enter a desired radix: "
    GET_DEC 1, r10
    PRINT_DEC 1, r10
    NEWLINE
    
    NEWLINE
    PRINT_STRING "Output (radix-"
    PRINT_DEC 8, r10
    PRINT_STRING "):"    
    
    

    ; NOTE: Should this be moved to a sort of function?
    ; Check if radix is in range [2, 16]
    cmp r10, 2  ; Check if radix < 2
    jl invalid_radix_mode_1
    cmp r10, 16 ; Check if radix > 16
    jg invalid_radix_mode_1

    JMP d_to_r_conversion
    
    
d_to_r_conversion:
    MOV RAX, r9 ; dividend
    MOV RCX, r10 ; divisor
    MOV RDX, 0 ; remainder
    MOV RSI, 0 ; store length temporarily
    ; PRINT_DEC 1, r9

d_to_r_loop:
    
    MOV RDX, 0
    DIV RCX
    MOV [reversedResult + RSI], DL
    INC RSI   
    
    CMP RAX, 0
    JE buffer
    
    JMP d_to_r_loop
    
buffer: 
    DEC RSI ; get rid of the padded 0
    JMP flip_result_loop    
    
flip_result_loop:
    MOV DL, [reversedResult + RSI] 
    PRINT_HEX 8, DL
    DEC RSI
    CMP RSI, -1
    JE terminate_program
    JMP flip_result_loop


; !!!====================== END OF DECIMAL to RADIX-N SECTIONS

invalid_mode: 
    PRINT_STRING "Invalid mode!"
    NEWLINE
    JMP terminate_program

invalid_radix_mode_1:
    PRINT_STRING "Invalid radix!"
    NEWLINE
    JMP terminate_program

invalid_radix_mode_2:
    PRINT_STRING "Invalid radix-"
    PRINT_DEC 1, r10
    PRINT_STRING " number!"
    NEWLINE
    JMP terminate_program
    
    

  
; !!!====================== BEGINNING OF RADIX-N TO DECIMAL SECTIONS
radix_to_decimal:
    ; asks for radix-N number
    PRINT_STRING "Enter a number: "
    
    ; for some reason, this one would
    ; try to read the \n or the EOF from the first GET_DEC
    ; very weird...
    GET_STRING buf, 2      
    GET_STRING buf, 101 ; because of that, i need to call it twice but it works

    ; clear register and input string
    xor rax, rax
    call in_iter
    
    ; add terminator to output string
    mov byte [numout + rax + 7], 0xa
    
    xor rax, rax ; clear register and print string
    call out_iter
    
    NEWLINE
    
    ; asks for its radix to convert to decimal properly
    PRINT_STRING "Enter a desired radix: "
    GET_DEC 1, r10
    PRINT_DEC 1, r10
    NEWLINE

    ; NOTE: Should this be moved to a sort of section?
    ; Check if radix is in range [2, 16]
    cmp r10, 2  ; Check if radix < 2
    jl invalid_radix_mode_1
    cmp r10, 16 ; Check if radix > 16
    jg invalid_radix_mode_1

    ; do conversion work here
    
    
    
    PRINT_STRING "Output (Decimal): "
    ret
    
; this section inputs each character and copies it to numout
in_iter:
        mov byte ch, [buf + rax]           ; copy character from buffer
        mov byte [numout + rax + 7], ch    ; writing one char from name to output
        inc rax
        cmp byte [buf + rax], 0x0          ; GET_STRING terminating char 0
        jne in_iter                        ; if not terminate, keep on reading
        ret

; this section outputs input strings
out_iter:
        PRINT_CHAR [numout + rax]        ; char given to out
        inc rax
        cmp byte [numout + rax], 0xa     ; if char is NULL, STOP
        jne out_iter                    
        ret
    

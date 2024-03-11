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
    
    ;exit with error level 0
    mov ax,0x4c00
    int 0x21
    
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
    
    call radix_err_chk
    
    NEWLINE
    PRINT_STRING "Output (radix-"
    PRINT_DEC 8, r10
    PRINT_STRING "):"    
    
    

    JMP d_to_r_conversion
    
    
d_to_r_conversion:
    MOV RAX, r9 ; dividend
    MOV RCX, r10 ; divisor
    MOV RDX, 0 ; remainder
    MOV RSI, 0 ; store length temporarily
        

d_to_r_loop:

    CMP RAX, 0
    JE buffer
    
    MOV RDX, 0
    DIV RCX
    
    MOV [reversedResult + RSI], DL
    INC RSI   
    
    JMP d_to_r_loop
    
capitalize_mode1: 
    CMP DL, 10
    JE cap_a
    CMP DL, 11
    JE cap_b
    CMP DL, 12
    JE cap_c
    CMP DL, 13
    JE cap_d
    CMP DL, 14
    JE cap_e
    CMP DL, 15
    JE cap_f
 
    
cap_a:
    PRINT_STRING "A"
    JMP flip_result_loop
cap_b:
    PRINT_STRING "B"
    JMP flip_result_loop
cap_c:
    PRINT_STRING "C"
    JMP flip_result_loop
cap_d:
    PRINT_STRING "D"
    JMP flip_result_loop
cap_e:
    PRINT_STRING "E"
    JMP flip_result_loop 
cap_f:
    PRINT_STRING "F"
    JMP flip_result_loop  
    
buffer: 
    DEC RSI ; get rid of the padded 0
    JMP flip_result_loop    
    
flip_result_loop:
    CMP RSI, -1
    JE terminate_program
    
    
    MOV DL, [reversedResult + RSI]
    
    DEC RSI
    CMP DL, 9
    JG capitalize_mode1 
    PRINT_HEX 8, DL
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
    
invalid_rad_number:
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

    xor rax, rax ; clear register and print string
    call out_iter
    
    NEWLINE
    
    ; asks for its radix to convert to decimal properly
    PRINT_STRING "Enter a desired radix: "
    GET_DEC 1, r10
    PRINT_DEC 1, r10
    NEWLINE

    call radix_err_chk

    ; don't forget to verify if all digits are valid
    ; if 13, max character should be D
    ; do conversion work here
    
    xor rax, rax ; clear register and print string
    
; get the count
scan_string:
    inc rax
    mov rsi, rax
    cmp byte [numout + rax], 0xa
    jne scan_string

xor rax, rax

; r11 is our exponent
; r15 is the output of the conversion
xor r11, r11
xor r15, r15

; rsi is our loop counter    
to_dec:   
    ; to convert from N to DEC
    ; (i_0 * N^3) + ... + (i_3 * N^0)
    ; rax is the i
    ; r12 is the exponent for a singular term 
    mov rax, r10 
    mov r12, r11
    
    ; call pow to calculate one term
    call pow
    
    ; call bam to extract the digit and properly
    ; convert from character to its digit
    call bam
    
    ; add to sum
    add r15, rax
    xor rax, rax
    inc r11 ; move to the next exponent
  
    ; reduce counter
    sub rsi, 1
    jnz to_dec
    
    NEWLINE
    PRINT_STRING "Output (Decimal): "
    PRINT_DEC 8, r15
    NEWLINE
    
    ; clear registers
    xor rax, rax
    xor r11, r11
    xor r12, r12
    xor r15, r15
    
    call terminate_program
    ret

bam:
    ; move character to RCX and convert to its equivalent in decimal
    movzx rcx, byte [numout + rsi - 1]
    
    
    ; check if lowercase, then capitalize
    cmp rcx, 97
    jge capitalize
    
    capped:
    sub rcx, '0'
    
    cmp rcx, 17 ; if greater than A or equal to
    jge num
    
    ; multiple that to rax, the product of N^X
    reduced:
        ; check if allowedFFF
        cmp rcx, r10
        jge invalid_rad_number
        
    mul rcx
    
    ret
    
capitalize:
    ; if lower, make bigger
    sub rcx, 32
    jmp capped

num:
    ; there is a gap between 9 and A in ASCII of 7, so subtract if
    ; it is A+
    sub rcx, 7 
    jmp reduced
                    
pow:
    mov rax, 1
    mov rcx, r10
    je done
    
    pow_loop:
        mul rcx
        
        dec r12
   
        jg pow_loop
    
    done:
        ;PRINT_DEC 2, r10
        ;PRINT_STRING " raised to "
        ;PRINT_DEC 2, r11
        ;NEWLINE
        ;PRINT_DEC 8, rax
        ;NEWLINE
        ret
    
; this section inputs each character and copies it to numout
in_iter:
        mov byte ch, [buf + rax]           ; copy character from buffer
        mov byte [numout + rax], ch    ; writing one char from name to output
        
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
    
radix_err_chk:
    ; NOTE: Should this be moved to a sort of function?
    ; Check if radix is in range [2, 16]
    cmp r10, 2  ; Check if radix < 2
    jl invalid_radix_mode_1
    cmp r10, 16 ; Check if radix > 16
    jg invalid_radix_mode_1
    
    ret

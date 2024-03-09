; MARTINEZ, FRANCIS BENEDICT 
; WONG, KRIZCHELLE DANIELLE 
; S15

%include "io64.inc"

section .data
reversedResult db "" ;converted string (reserved)
reversedLen db 0
result db ""


section .text
global main

main:
    mov rbp, rsp; for correct debugging
    ;write your code here
    JMP show_menu
    
modeio:
    PRINT_STRING "Select mode: "
    GET_DEC 1, r8
    PRINT_DEC 1, r8
    NEWLINE
    
    CMP r8, 1
    JE decimal_to_radix
    ;CMP r8, 2
    ;JE radix_to_decimal
    JMP invalid_mode

decimal_to_radix:
    PRINT_STRING "Enter a decimal number: "
    GET_DEC 8, r9
    PRINT_DEC 8, r9
    NEWLINE
    
    PRINT_STRING "Enter a desired radix: "
    GET_DEC 1, r10
    PRINT_DEC 1, r10
    NEWLINE

        
    ; Check if radix is in range [2, 16]
    cmp r10, 2  ; Check if radix < 2
    jl invalid_radix_mode_1
    cmp r10, 16 ; Check if radix > 16
    jg invalid_radix_mode_1

    JMP d_to_r_conversion

d_to_r_conversion:
    LEA RBX, reversedResult ; store address of reversedResult to rbx
    MOV RAX, r9 ; dividend
    MOV RCX, r10 ; divisor
    MOV RDX, 0 ; remainder
    ; PRINT_DEC 1, r9

d_to_r_loop:
    XOR RDX, RDX
    DIV RCX
    PRINT_DEC 8, RDX
    MOV [RBX], RDX
    PRINT_STRING reversedResult
    INC RBX
    INC byte [reversedLen]
    OR RAX, RAX
    JZ end_conversion
    JMP d_to_r_loop
    
flip_converted:
    LEA RAX, reversedResult ; store address of reversed
    ADD RAX, reversedLen ; go to end of reversedResult
    LEA RBX, result ; start of result string
    JMP flip_loop
    
flip_loop:
    MOV RCX, [reversedLen]
    CMP RAX, 0
    JZ end_conversion
    MOV RDI, [RAX]  
    MOV [RBX], RDI
    PRINT_STRING result
    INC RBX
    DEC RAX
    DEC byte [reversedLen]
    JMP flip_loop

end_conversion:    
    NEWLINE
    PRINT_STRING "Output (radix-"
    PRINT_DEC 8, r10
    PRINT_STRING "):"    
    PRINT_STRING reversedResult
    NEWLINE
    
    JMP terminate_program
    

;convert_loop:

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
    NEWLINE
    PRINT_STRING "Program terminated"
    NEWLINE
    ret

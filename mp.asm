; MARTINEZ, FRANCIS BENEDICT S15

%include "io64.inc"

section .data
;write variables here

section .text
global main

main:
    ;write your code here
    JMP show_menu
    
modeio:
    PRINT_STRING "Select mode: "
    GET_DEC 1, r8
    PRINT_DEC 1, r8
    NEWLINE
    
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
    jl invalid_radix
    cmp r10, 16 ; Check if radix > 16
    jg invalid_radix

    ret

invalid_radix:
    cmp r8, 1
    je invalid_radix_mode_1
    cmp r8, 2
    je invalid_radix_mode_2

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
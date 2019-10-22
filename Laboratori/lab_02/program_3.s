; Gastaldi Paolo
; s277393
; lab_02, program_3.s
; 22-10-19

.data
    X: .byte 1, 2, 3, 4, 5, 6, 7, 8
        .byte 1, 2, 3, 4, 5, 6, 7, 8
        .byte 1, 2, 3, 4, 5, 6, 7, 8
        .byte 1, 2, 3, 4, 5, 6
    even_counter: .byte 0
    odd-counter. .byte 0
    
.text
    ; r1: indice ciclo
    ; r2: indice vettore
    ; r3: contatore pari
    ; r4: contatore dispari
    
    
    main:
        daddi r1, r0, 30
        dadd r2, r0, r0
        dadd r3, r0, r0
        dadd r4, r0, r0
    
        lb r6, X(r2)
        daddi r2, r2, 1
    loop:
        lb r5, X(r2)
        daddi r2, r2, 1        
        xor r7, r5, r6
        
        srl r8, r7, 1
        
        lb r6, X(r2)
        daddi r2, r2, 1        
        xor r7, r5, r6
        
        bnez r1, loop
        
        sb r3, even_counter
        sb r4, odd-counter
    
    halt

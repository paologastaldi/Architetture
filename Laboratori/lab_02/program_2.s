; Gastaldi Paolo
; lab_02, program_2.s
; 22-10-19

; nella formula di Amdahl
; frazione: # colpi di clock

; v5 non contiene valori = 0

.data
    v1: .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6    
    v2: .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6
    v3: .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6
    v4: .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6, 7, 8
        .double 1, 2, 3, 4, 5, 6
    v5: .space 240 ; = 8*30
    v6: .space 240 ; = 8*30
    
.text
    
    ; r1: indice loop
    ; r2: indice vettori
    ; f1: registro valori v1
    ; f2: registro valori v2
    ; f3: registro valori v3
    ; f4: registro valori v4
    ; f5: registro valori v5
    ; f6: registro valori v6
    
    main:
        daddi r1, r0, 30
        dadd r2, r0, r0
        
    loop:
        l.d f1, v1(r2)
        l.d f2, v2(r2)
        l.d f3, v3(r2)
        l.d f4, v4(r2)
        
        mul.d f7, f1, f2
        add.d f5, f7, f3
        s.d f5, v5(r2)
        
        mul.d f8, f3, f4
        div.d f6, f8, f5
        s.d f6, v6(r2)
        
        daddi r2, r2, 8
        daddi r1, r1, -1
        bnez r1, loop
    
    halt
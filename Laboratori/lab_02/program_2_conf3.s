; Gastaldi Paolo
; lab_02, program_2_conf3.s
; 22-10-19

; nella formula di Amdahl
; frazione: # colpi di clock

; configurazione 2:
; add FP: 6 clock cycle
; mul FP: 8 clock cycle
; div FP: 24 -> 12 clock cycle

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
        daddi r1, r0, 30 ; F D E M W +5
        dadd r2, r0, r0 ;    F D E M W+1
        
    loop:
        l.d f1, v1(r2) ;             F D E M W +1
        l.d f2, v2(r2) ;               F D E M W +1
        ;									   |
        mul.d f7, f1, f2 ;               F D s m m m m m m m m M W +9
		;													   |
        l.d f3, v3(r2) ;                   F D E M W +0        |
        l.d f4, v4(r2) ;                     F D E M W +0      |
		;											 |		   |
        add.d f5, f7, f3 ;                     F D s s s s s s a a a a a a M W +6
        ;											 |					   |
        mul.d f8, f3, f4 ;                       F D m m m m m m m m M W +0|
        div.d f6, f8, f5 ;                         F D s s s s s s s s s s d d d d d d d d d d d d M W +12
		
		daddi r1, r1, -1 ;                           F D E M W +0
		
        s.d f5, v5(r2) ;                               F D E M W +0
        s.d f6, v6(r2);                                  F D s s s s s s s s s s s s s s s s s s s E M W +1
        
        daddi r2, r2, 8 ;                                  F D s s s s s s s s s s s s s s s s s s s E M W +1
		
        bnez r1, loop ; +1
		; +1 (ciclo perso, eccetto per l'ultima iterazione)
    
    halt ; +0 (gia' contato prima)
	
; main: 5+1 = 6
; loop: 1+1+9 +0+0+6+0 +12+0+0+1+1 +1+1 = 33
; totale: 6 +33*30 = 996 clock cycle

; calcolato da winMips: 996 clock cycle
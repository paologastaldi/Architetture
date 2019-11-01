; Gastaldi Paolo
; lab_02, program_2_b.s
; 29-10-19
; re-scheduling per eliminare piu' hazard possibili

; add FP: 4 clock cycle
; mul FP: 8 clock cycle
; div FP: 12 clock cycle
; architettura con forwarding, delay slot

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
	
	; add FP: 4 stage
	; mul FP: 8 stage
	; div FP: 12 clock cycle
    
    main:
        daddi r1, r0, 30 ; F D E M W +5
        dadd r2, r0, r0 ;    F D E M W +1
        
        l.d f1, v1(r2) ;       F D E M W +1
        l.d f2, v2(r2) ;    	 F D E M W +1
    loop: ;								 |
		nop ; 					   F D E M W +1
        mul.d f7, f1, f2 ; 		     F D m m m m m m m m M W +8
		;												 |
        l.d f3, v3(r2) ;     		   F D E M W +0      |
        l.d f4, v4(r2) ;         	 	 F D E M W +0    |
        ;										 |		 |
		nop;							   F D E M W +0	 |
        mul.d f8, f3, f4 ;       		     F D m m m m m m m m m M W +5
		; 												 |		   |
		nop;							       F D E M W +0		   |
		nop;							   		 F D E M W +0	   |
		nop;							   		   F D E M W +0 (causa 1 structural stall)
        add.d f5, f7, f3 ;         			         F D a a a a M W +0
        ;												         | |
        l.d f1, v1(r2) ;             				   F D E M W +0|
        l.d f2, v2(r2) ;               					 F D E M W +0
		; 												         | |
		daddi r1, r1, -1 ;               				   F D E s s M W +1 (causa 2 structural stall)
		;												 		 | |
		div.d f6, f8, f5 ;                       			 F D s d d d d d d d d d d d d M W +11 (non posso evitare questa RAW)
        s.d f5, v5(r2) ;                     				   F D E s M W +0 (no stallo, ma stage bloccato)
        s.d f6, v6(r2) ;                       					 F D s s s s s s s s s s s E M W +1 (no 1 stallo, ma stage bloccato) (non posso evitare questi 9 RAW) (causa 1 structural stall)
		
		bnez r1, loop ;											   F D E M W+1
        daddi r2, r2, 8; 										     F D E M W +1
    
    halt ; +1 (gia' contato prima)
	
; main: 5+1+1+1 = 8 clock cycle
; loop: 1+8 +0+0+5 0+0+0+0+0+0 +1+11 +0 +1+1+1 = 29 clock cycle
; totale: 8 +30*30 +1 = 879 clock cycle

; calcolato da winMips: 879 clock cycle

; RAW non evitabili: (1+9)*30 = 300
	
; 300 RAW stalls
; 0 WAW stalls
; 0 WAR stalls
; 150 structural stalls
; 0 branch taken stalls
; 0 branch misprediction stalls
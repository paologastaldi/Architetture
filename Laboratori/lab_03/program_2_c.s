; Gastaldi Paolo
; lab_02, program_2_c.s
; 29-10-19
; re-scheduling per eliminare piu' hazard possibili

; nella formula di Amdahl
; frazione: # colpi di clock

; add FP: 4 clock cycle
; mul FP: 8 clock cycle
; div FP: 12 clock cycle
; architettura con forwarding, delay slot
; unroll del ciclo 3 volte

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
		
	; (m.n): iterazione m (1, 2, 3), riga n (1, 2)
    
    ; r1: indice loop
	
    ; f1: registro valori v1 (1.1)
    ; f2: registro valori v2 (1.1)
    ; f3: registro valori v3 (1.1)
    ; f4: registro valori v4 (1.2)
    ; f5: registro valori v5 (1.2)
    ; f6: registro valori v6 (1.2)
	; f7, f8: riservati per risultati intermedi
	; r2: indice vettore (1)
	
	; f9: registro valori v1 (2.1)
    ; f10: registro valori v2 (2.1)
    ; f11: registro valori v3 (2.1)
    ; f12: registro valori v4 (2.2)
    ; f13: registro valori v5 (2.2)
    ; f14: registro valori v6 (2.2)
	; f15, 16: riservati per risultati intermedi
	; r3: indice vettore (2)
	
	; f17: registro valori v1 (3.1)
    ; f18: registro valori v2 (3.1)
    ; f19: registro valori v3 (3.1)
    ; f20: registro valori v4 (3.2)
    ; f21: registro valori v5 (3.2)
    ; f22: registro valori v6 (3.2)
	; f23, f24: riservati per risultati intermedi
	; r4: indice vettore (3)
	
	; add FP: 4 stage
	; mul FP: 8 stage
	; div FP: 12 clock cycle
    
    main:
        daddui r1, r0, 9 ; 				F D E M W +5
		; 10 cicli da 3 passi alla volta        
		; -1 ciclo perche' il contatore viene decrementato nel delay slot
		;								  |
		daddui r2, r0, +0 ;				  F D E M W +1
		daddui r3, r0, +8 ; 				F D E M W +1
		daddui r4, r0, +16 ; 			   	  F D E M W +1
        ;										|
        l.d f1, v1(r2) ; 						F D E M W +1
        l.d f2, v2(r2) ; 						  F D E M W +1
        l.d f9, v1(r3) ;							F D E M W +1
        l.d f10, v2(r3) ;							  F D E M W +1		
        l.d f17, v1(r4) ;								F D E M W +1
        l.d f18, v2(r4) ;							  	  F D E M W +1 [TOT: 14]
    loop: ;													|
        mul.d f7, f1, f2 ; (1.1)       						F D m m m m m m m m M W +8
		mul.d f15, f9, f10 ; (2.1)       				  	  F D m m m m m m m m M W +1
		mul.d f23, f17, f18 ; (3.1)       						F D m m m m m m m m M W +1 [TOT: 24] -> totale contando anche i clock cycle del main, sono serviti per il confronto con WinMips
		;														  |					  |
        l.d f3, v3(r2) ; (1.1)									  F D E M W +0		  |
        l.d f4, v4(r2) ; (1.1)									  	F D E M W +0	  |
		l.d f11, v3(r3) ; (2.1)									  	  F D E M W +0	  |
		l.d f12, v4(r3) ; (2.1)									  	    F D E M W +0  |
		l.d f19, v3(r3) ; (2.1)									  		  F D E s s s M W +1 (3 structural stalls su M, W)
		l.d f20, v4(r3) ; (2.1)									  			F D s s s E M W +1 (stop su D 3 cicli) [TOT: 26]
        ;																	  |
        mul.d f8, f3, f4 ; (1.2)											  F s s s D m m m m m m m m M W +8 (stop su S 3 cicli)
        mul.d f16, f11, f12 ; (2.2)											  		  F D m m m m m m m m M W +1
        mul.d f24, f19, f20 ; (3.2)											  	  		F D m m m m m m m m M W +1 [TOT: 36]
		;																				  |					  |
        add.d f5, f7, f3 ; (1.1)														  F D a a a a M W +0  |
		add.d f13, f15, f11 ; (1.1)													  		F D a a a a s s s M W +1 (3 structural stalls su M, W)
		add.d f21, f23, f19 ; (1.1)														      F D a a a a s s s M W +1 (3 structural stalls su M, W) [TOT: 38]
		;																				  		|			  |
        l.d f1, v1(r2) ; (1.1 - prossimo ciclo)											  		F D E s s s s s s M W +1 (6 structural stalls su M, W)
        l.d f2, v2(r2) ; (1.1 - prossimo ciclo)													  F D s s s s s s E M W +1 (stop su D 6 cicli)
        l.d f9, v1(r3) ; (2.1 - prossimo ciclo)												  		F s s s s s s D E M W +1 (stop su F 6 cicli)
        l.d f10, v2(r3) ; (2.1 - prossimo ciclo)											  		  			  F D E M W +1
        l.d f17, v1(r4) ; (3.1 - prossimo ciclo)											  	  					F D E M W +1
        l.d f18, v2(r4) ; (3.1 - prossimo ciclo)											  			  			  F D E M W +1 [TOT: 44]
		;																							  	    			|
		div.d f6, f8, f5 ; (1.2)																	  					F D d d d d d d d d d d d d M W +12 [TOT: 56]
		div.d f14, f16, f13 ; (2.2)																			  			  F D s s s s s s s s s s s d d d d d d d d d d d d M W +12 [TOT: 68]
		div.d f22, f24, f21 ; (3.2)																		  					F s s s s s s s s s s s D s s s s s s s s s s s d d d d d d d d d d d d M W +12 [TOT: 80]
        s.d f5, v5(r2) ; 																						  									F s s s s s s s s s s s D E M W +0
        s.d f13, v5(r3) ;  																					  	    								  						F D E M W +0
        s.d f21, v5(r4) ; 																							  														  F D E M W +0
		s.d f6, v6(r2) ; 																					  	  	    								  						F D E M W +0
        s.d f14, v6(r3) ; 																						    	  														  F D E M W +0
        s.d f22, v6(r4) ; 																							  										  						F D E s s s s s s M W +1 [TOT: 81]
		;																													  														  |
        daddi r2, r2, 8 ; 																									  														  F D s s s s s s E M W +1
        daddi r3, r3, 8 ; 																							  	  										  						F s s s s s s D E M W +1
        daddi r4, r4, 8 ; 																							  	    	  														  			  F D E M W +1
		;																																																|
		bnez r1, loop ; 																							  	      										  									F D E M W +1
		daddi r1, r1, -1 ; delay slot																																						  			  F D E M W +1 [TOT: 86]
    
    halt ; +1
	
; main: 5 +1+1+1 +1+1+1+1+1+1 = 14 clock cycle
; loop: 8+1+1 +0+0+0+0+1+1 +8+1+1 +0+1+1 +1+1+1+1+1+1 +12+12+12 +0+0+0+0+0+1 +1+1+1 +1+1 = 72 clock cycle
; totale: 14 +72*10 +1 = 735 clock cycle

; calcolato da winMips: 735 clock cycle

; attenzione alla LOAD: durante M accede alla memoria, quindi il valore e' disponibile solo in W
		
; 50 RAW stalls
; 0 WAW stalls
; 0 WAR stalls
; 130 structural stalls
; 0 branch taken stalls
; 0 branch misprediction stalls
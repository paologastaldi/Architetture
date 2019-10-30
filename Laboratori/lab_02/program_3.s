; Gastaldi Paolo
; s277393
; lab_02, program_3.s
; 22-10-19

; architettura con forwarding

; differenza di Hamming

.data
    X: .byte 1, 2, 3, 4, 5, 6, 7, 8
        .byte 1, 2, 3, 4, 5, 6, 7, 8
        .byte 1, 2, 3, 4, 5, 6, 7, 8
        .byte 1, 2, 3, 4, 5, 6 ; vettore di 30 elementi => 29 confronti
    even_counter: .byte 0
    odd_counter: .byte 0
	
	; 1^2 = 3: pari
	; 2^3 = 1: dispari
	; 3^4 = 7: dispari
	; 4^5 = 1: dispari
	; 5^6 = 3: pari
	; 6^7 = 1: dispari
	; 7^8 = F: pari
	; 8^1 = 9: pari
	; 4 pari, 4 dispari
	; totale: 15 dispari, 14 pari (29 confronti)
    
.text
    init:
        daddui r1, r0, 29 ; contatore loop                F D E M W +5
        dadd r2, r0, r0 ; indice vettore                    F D E M W +1
        dadd r3, r0, r0 ; contatore pari                      F D E M W +1
        dadd r4, r0, r0 ; contatore dispari                     F D E M W +1
		;                                                           |
        lb r5, X(r2) ;                                            F D E M W +1
        daddui r2, r2, 1 ;                                          F D E M W +1
        
    loop:
        lb r6, X(r2) ;                                 			      F D E M W +1
        daddi r2, r2, 1 ; 												F D E M W +1
        
        xor r7, r5, r6 ;                            					  F D E M W +1
        
        dadd r30, r0, r0 ; contatore numero bit a 1                         F D E M W +1
        daddi r29, r0, 4 ; contatore loop interno (coppie di bit, loop unroll)F D E M W +1
        
        bitLoop:
        	; r7: byte da shiftare
		    andi r8, r7, 1 ; mask 0b00000001                                    F D E M W +1
		    dadd r30, r30, r8 ;                       						      F D E M W +1
		    dsrl r9, r7, 1 ; shift right		                    				F D E M W +1
		    
        	; r9: byte da shiftare
		    andi r10, r9, 1 ; mask 0b00000001                                         F D E M W +1
		    dadd r30, r30, r10 ; 										                F D E M W +1
		    dsrl r7, r9, 1 ; shift right							                      F D E M W +1
		    
		    daddi r29, r29, -1 ; 												            F D E M W +1
		    bnez r29, bitLoop ; 									                          F D E M W +1
			;																					F D +1 (ciclo perso, eccetto per l'ultima iterazione)
	    
	    andi r28, r30, 1 ; verifico se il numero di bit a 1 e' dispari                          F D E M W +0 (contato gia' prima)
	    daddi r27, r0, 1 ;                     													  F D E M W +1
	    daddi r26, r0, 1 ; 															                F D E M W +1
	    daddi r25, r0, 0 ;																              F D E M W +1
	    movz r26, r0, r28; se e' dispari (r28 = 1), r26 = 1, altrimenti = 0							    F D E M W +1
	    movz r25, r27, r28; se e' pari (r28 = 0), r25 = 1, altrimenti = 0								  F D E M W +1
	    dadd r3, r3, r25 ; incremento contatore pari														F D E M W +1
	    dadd r4, r4, r26 ; incremento contatore dispari												   		  F D E M W +1
        
        dadd r5, r0, r6 ; shift da r6 a r5																        F D E M W +1
        
        daddi r1, r1, -1; 																                          F D E M W +1
        bnez r1, loop ; 																		                    F D E M W +1
		; 																											  F D +1 (ciclo perso, eccetto per l'ultima iterazione)
        
	writeback:
        sb r3, even_counter(r0); 																                      F D E M W +0 (contato gia' prima)
        sb r4, odd_counter(r0) ; 																                    	F D E M W +1
    
    halt ; 																												  F D E M W +1
	
; init: 10 clock cycle
; bitLoop: (8 +1) *4 = 36 clock cycle
; loop: (5 +36 +10 +1) *29 = 1508 clock cycle
; writeback: 1 +1 = 2 clock cycle
; totale: 10 +1508 +2 = 1520 clock cycle

; in WinMips si generano 145 RAW stalls in quanto il fetch degli operandi avviene nella decode invece che nella execute
; totale WinMips: 1665 clock cycle
; 1520 +145 = 1665 clock cycle

; attenzione ai clock cycle persi nelle iterazioni e all'ultima iterazione che non fa perdere clock cycle

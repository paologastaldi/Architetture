; Gastaldi Paolo
; s277393
; lab_02, program_3.s
; 22-10-19

; differenza di Hamming

.data
    X: .byte 1, 2, 3, 4, 5, 6, 7, 8
        .byte 1, 2, 3, 4, 5, 6, 7, 8
        .byte 1, 2, 3, 4, 5, 6, 7, 8
        .byte 1, 2, 3, 4, 5, 6 ; vettore di 30 elementi
    even_counter: .byte 0
    odd-counter: .byte 0
    
.text
    init:
        daddui r1, r0, 29 ; contatore loop
        dadd r2, r0, r0 ; indice vettore
        dadd r3, r0, r0 ; contatore pari
        dadd r4, r0, r0 ; contatore dispari
    
        lb r5, X(r2)
        daddui r2, r2, 1
        
    loop:
        lb r6, X(r2)
        daddi r2, r2, 1
        
        xor r7, r5, r6
        
        dadd r30, r0, r0 ; contatore numero bit a 1
        daddi r29, r0, 4 ; contatore loop interno (coppie di bit)
        
        bitLoop:
        	; r7: byte da shiftare
		    andi r8, r7, 1 ; mask 0b00000001
		    dadd r30, r30, r8
		    dsrl r9, r7, 1 ; shift right
		    
        	; r9: byte da shiftare
		    andi r10, r9, 1 ; mask 0b00000001
		    dadd r30, r30, r10
		    dsrl r7, r9, 1 ; shift right
		    
		    daddi r29, r29, -1
		    bnez r29, bitLoop
	    
	    and r28, r30, r31 ; verifico se il numero di bit a 1 e' dispari
	    daddi r27, r0, 1
	    dadd r26, r0, r0
	    daddi r25, r0, 1
	    movz r26, r27, r28; se e' dispari, r26 = 1, altrimenti = 0
	    movz r25, r0, r28; se e' dispari, r25 = 1, almenti = 0
	    dadd r3, r3, r25 ; incremento contatore pari
	    dadd r4, r4, r26 ; incremento contatore dispari
        
        dadd r5, r0, r6
        lb r6, X(r2)
        
        daddi r1, r1, -1
        bnez r1, loop
        
	writeback:
        sb r3, even_counter(r0)
        sb r4, odd-counter(r0)
    
    halt

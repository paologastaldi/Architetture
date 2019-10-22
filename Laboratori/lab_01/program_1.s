; Gastaldi Paolo
; s277393
; lab 01 - program_1.s

.data
	a: .byte 0, 1, 2, 3, 4, 5, 6, 7
		.byte 9, 8, 7, 6, 5, 4, 3, 2
		.byte 0, 1, 2, 3, 4, 5, 6, 7
		.byte 9, 8, 7, 6, 5, 4, 3, 2
		.byte -9, -8, -7, -6, -5, -4, -3, -2
		.byte 9, 8, 7, 6, 5, 4, 3, 2
		.byte 1, -1
	b: .byte 9, 8, 7, 6, 5, 4, 3, 2
		.byte 0, 1, 2, 3, 4, 5, 6, 7
		.byte 9, 8, 7, 6, 5, 4, 3, 2
		.byte 0, 1, 2, 3, 4, 5, 6, 7
		.byte 9, 8, 7, 6, 5, 4, 3, 2
		.byte 0, 1, 2, 3, 4, 5, 6, 7
		.byte 9, 8
	c: .space 50
	max: .space 1 ; max(c) = 10
	min: .space 1 ; min(c) = 0

.text	
	; r1: indice ciclo (unsigned)
	; r2: indice vettori a, b, c
	; r3: max
	; r4: min
	; r5: load valore a
	; r6: load valore b
	; r7: registro per il controllo del max, min

	; init
	daddui r1, r0, 49
	daddui r2, r0, 0
	
	lb r5, a(r2) ; load byte
	lb r6, b(r2) ; load byte
	dadd r5, r5, r6	
	sb r5, c(r2)
	daddui r2, r2, +1
	
	; caricamento in anticipo dei valori per l'inizializzazione dei registri usati per max, min
	dadd r3, r0, r5
	dadd r4, r0, r5
	
	loop:		
		lb r5, a(r2)
		lb r6, b(r2)
		
		dadd r5, r5, r6 ; somma delle celle corrispondenti
		sb r5, c(r2)
		
		; controllo se c[i] e' il max
		slt r7, r3, r5 ; r7 = (max<c[i]) ? 1:0
		beqz r7, noMax
		dadd r3, r0, r5 ; salva nuovo max
		
		noMax:
		
		; controllo se c[i] e' il min
		slt r7, r5, r4 ; r7 = (c[i]<min) ? 1:0
		beqz r7, noMin
		dadd r4, r0, r5 ; salva nuovo min
		
		noMin:
		
		daddui r2, r2, +1
		daddui r1, r1, -1
		
		bne r1, r0, loop ; branch greater or equal

	; salvataggio di max, min in memoria
	sb r3, max(r0)
	sb r4, min(r0)

	block: j block
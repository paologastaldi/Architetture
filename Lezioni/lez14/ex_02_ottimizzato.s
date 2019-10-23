; lez14
; 22-10-19
; example 2 con ottimizzazione statica

; forwarding attivo

.data
	.vetX: .double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8
		.double 2, 4, 6, 8		
	.vetZ: .double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
		.double 1, 2, 3, 4
	.vetY: .double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0
		.double 0, 0, 0, 0

.text
	main:
		daddui r1, r0, 100	; F D E M W: +5
		; 100 elementi nei vettori
		
		daddui r2, r0, vetX   ; F D E M W: +1
		daddui r3, r0, vetZ     ; F D E M W: +1
		daddui r4, r0, vetY       ; F D E M W: +1
	
	loop:
		l.d f1, 0(r2)               ; F D E M W: +1
		; altrimenti: ld f1, vetX(r2), e incremento r2 a ogni ciclo
		; no stallo, r2 viene modificato molto prima nel codice
		
		l.d f2, 0(r3)                 ; F D E M W: +1
		
		mul.d f3, f1, f1                ; F D E E E E M W: +4
		; uso f1 tranquillamente, forwarding attivato
		
		div.d f4, f1, f2                  ; F D E E E E M W: +1
		; div eseguita in parallelo alla mul
		; div FP: 4 colpi di clock
		
		daddi r2, r2, 8                  	; F D E M W: +0
		; istruzione spostata
		
		add.d f5, f3, f4                      ; F D s s E E M W: +2
		; dipendenze: si generano degli stalli
		; add FP: 2 colpi di clock
		; abbiamo ridotto lo stallo di 1 operazione
		
		s.d f5, 0(r4)                           ; F s s D E s M W: +1
		; la store attende i risultati della add
		; ATTENZIONE: si crea un hazard strutturale
		; lo stadio di memory M e' gia' occupato
		; genero quindi un nuovo stallo
		
		; daddi r2, r2, 8 ; istruzione anticipata
		daddi r3, r3, 8                               ; F D s M W: +1
		
		daddi r4, r4, 8                                 ; F s D M W: +1
		; lo stallo si propaga per le 2 istruzioni successive
		; la istruzione di somma su r4 non puo' essere anticipata, ci sono dipendenze di dato
		
		daddi r1, r1, -1
		bnez r1, loop

	halt
		
; calcolo colpi di clock: divido in 2 parti
; main: 8 colpi di clock

; --- utilizzando loop unrolling a gruppi di 4 istruzioni
; spostamento di daddi r4, r4, 32 dopo la bnez per evitare hazard

; loop: 12+12+12+15 = 51 colpi di clock
; 25 cicli
; totale: 8 + 51*25 = 1283 colpi di clock

; --- branch delay slot attivato

; loop: 12+12+12+15 = 44 colpi di clock
; 25 cicli
; totale: 8 + 44*25 = 1109 colpi di clock
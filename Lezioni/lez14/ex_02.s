; lez14
; 22-10-19
; example 2

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
		
		add.d f5, f3, f4                    ; F D s s s E E M W: +2
		; dipendenze: si generano degli stalli
		; add FP: 2 colpi di clock
		
		s.d f5, 0(r4)                         ; F D s s s s E M W: +1
		; la store attende i risultati della add
		
		daddi r2, r2, 8 ; indici di 8 byte in 8 byte
		daddi r3, r3, 8 ; indici di 8 byte in 8 byte
		daddi r4, r4, 8 ; indici di 8 byte in 8 byte
		daddi r1, r1, -1
		bnez r1, loop

	halt
		
; calcolo colpi di clock: divido in 2 parti
; main: 8 colpi di clock
; loop: 17 colpi di clock per 100 cicli
; totale: 8 + 17*100 = 1708 colpi di clock
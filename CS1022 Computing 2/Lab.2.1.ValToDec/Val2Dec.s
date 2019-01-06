	AREA	Val2Dec, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R4, =7888
	LDR	R5, =decstr

	MOV R0, R4
	MOV R1, R5
	BL val2dec

stop	B	stop

;divide
;divides value b from a
;parameters:
;			R0 = a
;			R1 = b
;return: 	R1 = answer
;			R0 = remainder

divide

	STMFD SP!, {R2,LR}
	MOV R2, #0
	CMP R0, #0
	BEQ endDiv

whileDivide			;while (b >= remainder)

	CMP R0, R1		;{
	BLT endDiv		;
	ADD R2, R2, #1	;Qout+=1;
	SUB R0, R0, R1	;a-=b;
	B whileDivide	;}
	
endDiv

	MOV R1, R2		
	LDMFD SP!, {R2,PC}

;val2dec
;stores a number in base 10
;parameters:	
;		R0 = Address where to store Number
;		R1 = Number to be stored
;return: No return
val2dec
	STMFD SP!, {LR}
	MOV R2, R0
	MOV R12, SP
loop						;while (remainder != 0)

	MOV	R0 , #10			;{
	BL divide				;Number/10
	STR R1, [SP , #-4]!		;StoreInStack(Number[+=4])
	MOV R1, R0				;Number = Remainder
	CMP R0, #0				;
	BEQ endLoop				;}
	B loop
	
endLoop	
	
storeLoop					;while (Stack[n] !=r12)

	CMP SP, R12				;{
	BEQ endStoreLoop		;
	LDR R1, [SP], #4		;Store[Stack[n]]
	STR R1, [R2], #4		;n+=4
	B storeLoop				;}
	
endStoreLoop

	LDMFD SP!, {PC}
	
	AREA	TestString, DATA, READWRITE

decstr	SPACE	16

	END	
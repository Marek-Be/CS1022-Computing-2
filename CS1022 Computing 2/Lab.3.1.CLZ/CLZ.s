	AREA	CLZ, CODE, READONLY
	IMPORT	main
	EXPORT	start

start

	; install the start address of your exception handler
	; in the exception vector lookup table

	LDR R0, = 1
	BL CLZFunction
	
	; write a program to test your exception handler

	
stop	B	stop

;CLZFunction - Count Leading Zeros
;Counts the amount of most significant zeroes in a register until the first one bit
;parameters:
;			R0 = Register to get CLZ
;return:	R0 = The amount of leading zeroes.

CLZFunction

	STMFD SP!, {LR}
	
	LDR R1, = 0x80000000
	LDR R3, = 0
	CMP R0, #0
	BNE notZero
	LDR R3, = 32
	B endCLZ
notZero
	ADD R3, #1
	LSL R0, #1
	AND R2, R1, R0
	CMP R2, #0
	BNE endCLZ
	
	B notZero

endCLZ
	MOV R0, R3
	
	LDMFD SP!, {PC}

	; write your exception handler


	END	
	
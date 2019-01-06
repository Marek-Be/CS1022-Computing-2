	AREA	MatMul, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R0, =matR
	LDR	R1, =matA
	LDR	R2, =matB
	LDR	R3, =N
	
	LDR R4, = 0				;i = 0
	
while1

	CMP R4, R3				;while (i < N)
	BGE	stop				;{
	
	LDR R5, = 0				;j = 0
	
while2

	CMP R5, R3				;while (j < N)
	BGE end2				;{
	
	LDR R6, = 0				;k = 0
	LDR R7, = 0				;r = 0
	
while3

	CMP R6, R3				;while (k < N)
	BGE end3				;{
	
	MUL	R8, R4,	R3			;ixN
	ADD	R8, R8, R6			;ixNxk
	LDR R8, [R1, R8, LSL #2];matA[ixNxkx4]
	
	MUL R9, R6, R3			;kxN
	ADD R9, R9, R5			;kxNxj
	LDR R9, [R2, R9, LSL #2];matB[kxNxjx4]
	
	MUL R8, R9, R8			;ans = matA[ixNxkx4] * matB[kxNxjx4]
	ADD R7, R7, R8			;r += ans
	ADD R6, R6, #1			;k+=1
	
	B while3				;}
	
end3

	MUL R8, R4, R3			;ixN
	ADD R8, R8, R5			;ixNxj
	STR R7, [R0, R8, LSL #2];matR[ixNxJ] = r
	ADD R5, R5, #1			;j+=1
	
	B while2				;}
	
end2						

	ADD R4, R4, #1			;i+=1
	
	B while1				;}
	
	
	
stop	B	stop

	AREA	TestArray, DATA, READWRITE

N	EQU	4

matA	DCD	5,4,3,2
	DCD	3,4,3,4
	DCD	2,3,4,5
	DCD	4,3,4,3

matB	DCD	5,4,3,2
	DCD 3,4,3,4
	DCD	2,3,4,5
	DCD	4,3,4,3

matR	SPACE	64

	END	
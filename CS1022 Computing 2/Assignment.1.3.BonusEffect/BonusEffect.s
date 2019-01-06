	AREA	BonusEffect, CODE, READONLY
	IMPORT	main
	IMPORT	getPicAddr
	IMPORT	putPic
	IMPORT	getPicWidth
	IMPORT	getPicHeight
	EXPORT	start
	PRESERVE8
	
start
	
	BL	getPicAddr	; load the start address of the image in R4
	MOV	R4, R0
	BL	getPicHeight	; load the height of the image (rows) in R5
	MOV	R6, R0
	BL	getPicWidth	; load the width of the image (columns) in R6
	MOV	R5, R0
	
	
	LDR R0, = Matrix
	MOV R1, R4
	MOV R2, R5
	MOV R3, R6		;Preparing values for the subroutine

	BL Kernel		;Kernel(MatAddress, ImgAddress, Width, Height)

	BL	putPic
	
	
stop	B	stop

;Kernel
;Applys a kernel matrix to the image provided
;parameters:
;			R0	= Matrix Address
;			R1	= Img Address
;			R2	= Width
;			R3	= Height
;return:	nothing

Kernel
	
	STMFD SP!, {LR}	
	
	LDR R4, = 1		;X
	LDR R5, = 1		;Y
	
	LDR R6, = 0
	
	SUB R2, R2, #1	;width-=1
	SUB R3, R3, #1	;height-=1
	
	
	B WhileYGet
	
WhileYGet			;while(Y != height)
	CMP R5, R3		;{
	BEQ endWhileSet
	
	ADD R5, R5, #1	;Y+=1

WhileXGet			;while(X != width)
	CMP R4, R2		;{
	BEQ WhileYGet
	
	ADD R7, R2, #1
	ADD R2, R2, #1
	MUL R7, R2, R7
	SUB R2, R2, #1
	ADD R7, R7, R3
	LSL R7, #2
	ADD R7, R7, R1	;ImgAddress[x,y]
	
	LDR R6, = 0
	
	LDR R10, = 0
	MOV R8, R0
	LDR R9, = 0
whileMatrixB		;while (CurrentIndex != 9)
	CMP R9, #9		;{
	BEQ endMatrixB
	
	CMP R9, #3		;if (CurrentIndex == 3)
	BNE Skip3B		;ImgAddress += (width -2)
	SUB R2, R2, #1	;
	LSL R2, #2		;
	ADD R7, R7, R2
	LSR R2, #2
	ADD R2, R2, #1
Skip3B
	CMP R9, #6		;if (CurrentIndex == 6)
	BNE Skip6B		;ImgAddress += (width -2)
	SUB R2, R2, #1
	LSL R2, #2
	ADD R7, R7, R2
	LSR R2, #2
	ADD R2, R2, #1
Skip6B
	LDR R12, = 2
	LDRB R11, [R7, R12]	;Loads the blue pixel
	LDR R12, [R8]		;Loads the value in the matrix
	MUL R11, R12, R11	;MatValue *= Pixel
	
	ADD R10, R10, R11	;AveragePixel += MatValue
	
	ADD R7, R7, #4		;ImgAdress += 4

	ADD R8, R8, #4		;Matrix += 4
	ADD R9, R9, #1		;CurrentIndex+=1
	B whileMatrixB		;}
endMatrixB
	
	CMP R10, #0			;if (AveragePixel < 0)
	BGE SkipSmallB		;AveragePixel = 0
	LDR R10, = 0
SkipSmallB

	CMP R10, #255		;if (AveragePixel > 255)
	BLS SkipBigB		;AveragePixel = 255
	LDR R10, = 255
SkipBigB
	
	ADD R6, R6, R10		;This same code is repeated for the green and blue pixels.
	LSL R6, #8
	
	
	
	
	ADD R7, R2, #1
	ADD R2, R2, #1
	MUL R7, R2, R7
	SUB R2, R2, #1
	ADD R7, R7, R3
	LSL R7, #2
	ADD R7, R7, R1
	
	LDR R10, = 0
	MOV R8, R0
	LDR R9, = 0
whileMatrixG
	CMP R9, #9
	BEQ endMatrixG
	
	CMP R9, #3
	BNE Skip3G
	SUB R2, R2, #1
	LSL R2, #2
	ADD R7, R7, R2
	LSR R2, #2
	ADD R2, R2, #1
Skip3G
	CMP R9, #6
	BNE Skip6G
	SUB R2, R2, #1
	LSL R2, #2
	ADD R7, R7, R2
	LSR R2, #2
	ADD R2, R2, #1
Skip6G
	LDR R12, = 1
	LDRB R11, [R7, R12]
	LDR R12, [R8]
	MUL R11, R12, R11
	
	ADD R10, R10, R11
	
	ADD R7, R7, #4

	ADD R8, R8, #4
	ADD R9, R9, #1
	B whileMatrixG
endMatrixG
	
	CMP R10, #0
	BGE SkipSmallG
	LDR R10, = 0
SkipSmallG

	CMP R10, #255
	BLS SkipBigG
	LDR R10, = 255
SkipBigG
	
	ADD R6, R6, R10
	LSL R6, #8
	
	
	
	ADD R7, R2, #1
	ADD R2, R2, #1
	MUL R7, R2, R7
	SUB R2, R2, #1
	ADD R7, R7, R3
	LSL R7, #2
	ADD R7, R7, R1
	
	LDR R10, = 0
	MOV R8, R0
	LDR R9, = 0
whileMatrixR
	CMP R9, #9
	BEQ endMatrixR
	
	CMP R9, #3
	BNE Skip3R
	SUB R2, R2, #1
	LSL R2, #2
	ADD R7, R7, R2
	LSR R2, #2
	ADD R2, R2, #1
Skip3R
	CMP R9, #6
	BNE Skip6R
	SUB R2, R2, #1
	LSL R2, #2
	ADD R7, R7, R2
	LSR R2, #2
	ADD R2, R2, #1
Skip6R
	LDR R12, [R8]
	LDRB R11, [R7]
	MUL R11, R12, R11
	
	ADD R10, R10, R11
	
	ADD R7, R7, #4

	ADD R8, R8, #4
	ADD R9, R9, #1
	B whileMatrixR
endMatrixR
	
	CMP R10, #0
	BGE SkipSmallR
	LDR R10, = 0
SkipSmallR

	CMP R10, #255
	BLS SkipBigR
	LDR R10, = 255
SkipBigR
	
	ADD R6, R6, R10
	
	STMFD SP!, {R6, LR}	;The pixel is stored in memory
	
	ADD R4, R4, #1		;X+=1
	B WhileXGet			;}
endWhileSet				;}


	MOV R4, R2			;X
	MOV R5, R3			;Y
	
	
	SUB R2, R2, #1
	SUB R5, R5, #1
	
	MUL R10, R2, R5
	MOV R9, R10
	LSL R9, #2
	ADD R9, R9, R1
	
	MOV R11, R5			;size = width*height

SetLoop					;while (size > 0)
	CMP R10, #0			;{
	BEQ endSet
	
	LDMFD SP!, {R6, LR}	;Takes the pixels from the stack
	STR R6, [R9]		;Changes the pixels
	
	CMP R11, #0			;if (counter == 0)
	BNE NormalNextPixel	;
	
	MOV R11, R5			;counter = width
	SUB R9, R9, #8		;size -= 8
	
NormalNextPixel
	
	SUB R11, R11, #1	;size-=1
	SUB R10, R10, #1	;counter -=1
	SUB R9, R9, #4		;ImgAdress -= 4
	B SetLoop			;}
endSet
	
	LDMFD SP!, {PC}	

	AREA	TestArray, DATA, READWRITE
		
Matrix	DCD	0,1,0
		DCD	1,-4,1
		DCD	0,1,0

	
	END	
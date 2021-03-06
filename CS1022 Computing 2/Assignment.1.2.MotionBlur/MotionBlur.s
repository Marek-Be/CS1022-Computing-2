	AREA	MotionBlur, CODE, READONLY
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
	
	
	MOV R10, R4
	
	MOV R3, R10
	MOV R11, R5	;maxX
	MOV R12, R6	;maxY
	LDR R7, = 1		;radius
	
	
	LDR R8, = 0	;x
	LDR R9, = -1;y
	
YLoop	
	ADD R9, R9, #1
	
	CMP R9, R12
	BGE EndYLoop	
	
	
	LDR R8, = 0
XLoop	
	CMP R8, R11
	BGE YLoop
	
	STMFD SP!, {R4-R12}
	BL GetAverages
	
	ADD R10, R10, #4
	ADD R8, #1
	
	B XLoop


EndYLoop
	
	BL	putPic
	
	
stop	B	stop

;SetPixel
;Sets the value of the pixel at a location and picks the type of pixel
;parameters:
;			R0 = location (From XYConvert)
;			R1 = PixelType (RED = 3, GREEN = 2, BLUE = 1);
;			R2 = Value
;return:	No return

SetPixel

	STMFD SP!, {LR}
	
	STRB R2, [R0, R1]
	
	LDMFD SP!, {PC}

;GetAverages
;Blurs the image using motion blur
;parameters:
;			R4 = ImgAdress
;			R5 = Width
;			R6 = Height
;			R7 = Radius
;			R8 = x
;			R9 = y
;			R10 = newImgAddress
;return:	R0 = AverageRed, R1 = AverageGreen, R2 = AverageBlue

GetAverages
	
	LDMFD SP!, {R4-R10}
	
	STMFD SP!, {R4-R12, LR}	
	
	
	STMFD SP!, {R10}

	MOV R10, R5
	ADD R10, R10, #1
	LSL R10, #2
	
	SUB R12, R8, R7
	SUB R11, R9, R7
	
	LDR R3, = 0
	
	
TooSmall
	
	CMP R12, #0
	BLT EitherSmall
	
	CMP R11, #0
	BGE SkipAddAverages

EitherSmall
	
	ADD R11, R11, #1
	ADD R12, R12, #1
	ADD R3, R3, #1
	
	B TooSmall

SkipAddAverages
	
	
	MOV R10, R5
	ADD R10, R10, #1
	LSL R10, #2
	
	SUB R3, R7, R3
	MUL R10, R3, R10
	SUB R4, R4, R10
	
	MOV R12, R8
	MOV R11, R9
	
TooBig

	CMP R12, R6
	BGT EitherBig
	
	CMP R11, R5
	BLE EndTooBig
	
EitherBig

	SUB R11, R11, #1
	SUB R12, R12, #1
	ADD R3, R3, #1
	
	B TooBig

EndTooBig

	ADD R3, R3, #1

SkipSubAverages
	
	LDR R10, = 0
	LDR R11, = 0
	LDR R12, = 0
	
	LSL R3, #2
	ADD R4, R4, R3
	MOV R6, R3
	
	
WhileGetAveragesSmall

	CMP R3, #0
	BLT EndAverages
	

	MOV R0, R4
	LDR R1, = 3
	BL GetPixel
	ADD R10, R0
	
	MOV R0, R4
	LDR R1, = 2
	BL GetPixel
	ADD R11, R0
	
	MOV R0, R4
	LDR R1, = 1
	BL GetPixel
	ADD R12, R0
	
	SUB R3, R3, #1
	
	ADD R4, R5, R4

	
	B WhileGetAveragesSmall
	
EndAverages

	MOV R0, R10
	MOV R1, R6
	BL Divide
	MOV R10, R1
	
	MOV R0, R11
	MOV R1, R6
	BL Divide
	MOV R11, R1
	
	MOV R0, R12
	MOV R1, R6
	BL Divide
	MOV R12, R1
	
	
	MOV R3, R10
	LDMFD SP!, {R10}

	MOV R2, R3
	LDR R1, = 3
	MOV R0, R10
	BL SetPixel
	
	MOV R2, R11
	LDR R1, = 2
	MOV R0, R10
	BL SetPixel
	
	MOV R2, R12
	LDR R1, = 1
	MOV R0, R10
	BL SetPixel
	
	
	LDMFD SP!, {R4-R12, PC}	

;GetPixel
;Gets the value of the pixel at a location and picks the type of pixel
;parameters:
;			R0 = location (From XYConvert)
;			R1 = PixelType (RED = 3, GREEN = 2, BLUE = 1);
;return:	R0 = Value Of pixel

GetPixel

	STMFD SP!, {LR}
	
	LDRB R0, [R0, R1]
	
	LDMFD SP!, {PC}


;divide
;divides value b from a
;parameters:
;			R0 = a
;			R1 = b
;return: 	R1 = answer
;			R0 = remainder

Divide

	STMFD SP!, {R2,LR}
	LDR R2, =0
	CMP R1, #0
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
	
	
	AREA	TestArray, DATA, READWRITE
		
	END	
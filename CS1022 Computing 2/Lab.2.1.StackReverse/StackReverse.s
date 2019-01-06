	AREA	StackReverse, CODE, READONLY
	IMPORT	main
	EXPORT	start

start

	LDR	R5, =string

	
	STMDB SP!, {R4-R8}
	BL SetPixel

	
stop	B	stop

;Adjust
;Adjusts the Contrast and brightness of the image
;parameters:
;			R4 = ImgAdress
;			R5 = Width
;			R6 = Height
;			R7 = Contrast
;			R8 = Brightness
;return:	No return

Adjust

	STMFD SP!, {LR}
	
	LDMIA SP!, {R4-R8}
	
	MOV R9, R5
	MUL R9, R6, R9
	
	ADD R9, R9, R4
	MOV R10, R4
whileAdjust
	CMP R10, R9
	BHI endWhileAdjust
	LDR R11, = 3
	
forEachPixelAdjust
	CMP R11, #0
	BEQ whileAdjust
	
	MOV R0, R10
	MOV R1, R11
	BL GetPixel
	
	MUL R0, R7, R0
	LDR R1, = 16
	BL Divide
	
	CMP R0, #8
	BLO DontRoundAdjust
	
	ADD R1, R1, #1
	
DontRoundAdjust
	
	ADD R1, R1, R8
	
	CMP R1, #255
	BLS IsWithInAdjust
	
	LDR R1, = 255

IsWithInAdjust
	
	MOV R2, R1
	MOV R1, R11
	MOV R0, R10
	BL SetPixel

	SUB R11, R11, #1
	B forEachPixelAdjust
	
	ADD R9, R9, #1
	B whileAdjust

endWhileAdjust

	LDMFD SP!, {PC}

	AREA	TestString, DATA, READWRITE

string	DCD 10252321, 15318235

	END	
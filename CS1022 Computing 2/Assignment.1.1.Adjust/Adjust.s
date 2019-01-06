	AREA	Adjust, CODE, READONLY
	IMPORT	main
	IMPORT	getPicAddr
	IMPORT	putPic
	IMPORT	getPicWidth
	IMPORT	getPicHeight
	EXPORT start
	PRESERVE8
	
start

	BL	getPicAddr	; load the start address of the image in R4
	MOV	R4, R0
	BL	getPicHeight; load the height of the image (rows) in R5
	MOV	R5, R0
	BL	getPicWidth	; load the width of the image (columns) in R6
	MOV	R6, R0
	
	LDR R7, = 16	;Contrast
	LDR R8, = -20	;Brightness
	

	STMFD SP!, {R4-R8}
	BL AdjustBC		;AdjustBC(ImgAdress, Width, Height, Contrast, Brightness)
	
	; your code goes here

	BL	putPic		; re-display the updated image

stop	B	stop

	
;Adjust
;Adjusts the Contrast and brightness of the image
;parameters:
;			R4 = ImgAddress
;			R5 = Width
;			R6 = Height
;			R7 = Contrast
;			R8 = Brightness
;return:	No return

AdjustBC
	
	LDMFD SP!, {R4-R8}	;Loads the input into registers
	
	STMFD SP!, {LR}
	
	
	CMP R7, #16
	BNE DoAdjust
	
	CMP R8, #0	
	BEQ SkipAdjust	;if (Brightness == 0 AND Contrast == 16)
					;It skips the function
DoAdjust
	CMP R7, #0		;
	BGE SkipChange	;if (Contrast < 0)
	LDR R7, = 0		;Contrast = 0
SkipChange
	
	
	MOV R9, R5, LSL #2	;Size = Width * 4
	MUL R9, R6, R9		;Size *= Height
	
	ADD R9, R9, R4		;Size += ImgAddress
	MOV R10, R4			;
whileAdjust				;while (ImgAddress < Size)
	CMP R10, R9			;{
	BHI endWhileAdjust
	LDR R11, = 2		;CurrentPixel = 2
	
forEachPixelAdjust		;while(CurrentPixel != -1)
	CMP R11, #-1		;{
	BEQ nextPixel		;
	
	LDRB R0, [R10, R11]	;Loads the pixel
	
	MUL R0, R7, R0		;pixel *= contrast
	
	LSR R0, #4			;pixel /= 16
	
	ADD R0, R0, R8		;pixel += brightness
	
	CMP R0, #255		;if (pixel > 255)
	BLE IsWithInAdjust	;pixel = 255
	
	LDR R0, = 255

IsWithInAdjust
	CMP R0, #0			;if (pixel < 0)
	BGE IsGreaterThanZero
	
	LDR R0, = 0			;pixel = 0
	
IsGreaterThanZero		
	
	STRB R0, [R10, R11]	;Stores the pixel

	SUB R11, R11, #1	;CurrentPixel -=1
	B forEachPixelAdjust

nextPixel
	ADD R10, R10, #1	;ImgAddress+=1
	B whileAdjust

endWhileAdjust
SkipAdjust

	LDMFD SP!, {PC}

	END
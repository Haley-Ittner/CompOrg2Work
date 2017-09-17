	AREA	Asign5,  CODE,  READONLY
	EXPORT main
	ENTRY

main	
	LDR R9, =B				;[R9]<-the address of a's MSD
	BL Hex2Bin				;if not, we continue and branch to find the values
	TST R2, #0x80000000		;is [R2]'s MSB 0?
	BNE DONE				;[R2]'s MSB is 1!
	MOV R5, R2				;[R5]<--B's 2's compliment number

	LDR R9, =A				;[R9]<-the address of b's MSD
	BL Hex2Bin				;if not, we continue and branch to find tha value
	TST R2, #0x80000000		;is [R2]'s MSB 0?
	BNE DONE				;[R2]'s MSB is 1!
	MVN R6, R2				;[R6]<-A's 1's complement
	ADD R6, R6, #1			;[R6]<-A's 2's complement

	ADD R7, R5, R6			;[R7]<- b + (-a)
	;TST R7, #0x80000000
	;BNE DONE	
	LDR R8, =result			;"loads" the address of the result into R8
	STR R7, [R8]			;store b + (-a) at result
	
DONE	
	MOV		r0, #0x18      ; angel_SWIreason_ReportException
	LDR		r1, =0x20026   ; ADP_Stopped_ApplicationExit
	SVC		#0x11		   ; previously SWI
	ALIGN

Hex2Bin		
	MOV R2, #0				;clear result register
	MOV R8, #0

LOOP_Hex2Bin
	LDRB R3, [R9], #1		;read one ascii of dec
	CBZ R3, DONE_Hex2Bin 	;break if it's a null terminator (0x0)

	SUB	R3, R3, #'0'		;convert ascii to digit
	CMP R3, #0				;is it lower then 0
	BLO InvalidHex			;not a valid digit
	CMP R3, #54
	BHI InvalidHex
	CMP R3, #23				;is it greater than 22
	BHI LowerCase			;not a valid hex #
	CMP R3, #9				;is it greater than 9
	BHI LetterHex			;If so we need to convert the letter to the right number

							;Next, [R2]<--[R2]*16+[R3]
StartOfLoop
	MOVS R4, R2, LSL #1		;[R4]<--original [R2] * 2
	BMI InvalidHex			;[R4]'s MSB is 1 ([R4] is negative)

	MOVS R4, R4, LSL #1		;[R4]<--original [R2] * 4
	BMI InvalidHex			;[R4]'s MSB is 1 ([R4] is negative)

	MOVS R4, R4, LSL #1		;[R4]<--original [R2] * 8
	BMI InvalidHex			;[R4]'s MSB is 1 ([R4] is negative)

	MOVS R2, R2, LSL #1		;[R2]<--original [R2] * 2
	BMI InvalidHex			;[R2]'s MSB is 1 ([R2] is negative)
	
	MOVS R2, R2, LSL #1		;[R2]<--original [R2] * 4
	BMI InvalidHex			;[R2]'s MSB is 1 ([R2] is negative)
	
	MOVS R2, R2, LSL #1		;[R2]<--original [R2] * 8
	BMI InvalidHex			;[R2]'s MSB is 1 ([R2] is negative)

	ADDS R2, R2, R4  		;[R2]<--original [R2]*16
	BMI InvalidHex			;[R2]'s MSB is 1 ([R2] is negative)

	ADDS R2, R2, R3			;[R2]<--original [R2]*16 + [R3]
	BMI InvalidHex			;[R2]'s MSB is 1 ([R2] is negative)

	ADD R8, R8, #1
	CMP R8, #8
	BHI InvalidHex
	
	B LOOP_Hex2Bin

LowerCase
	SUBS R3, R3, #39
	CMP R3, #16
	BLO StartOfLoop
	B	InvalidHex
	
LetterHex
	SUBS R3, R3, #7			;subtracts 7 from the ascii number for the letter
	CMP  R3, #9			;Compare that number with 15, to see if its a valid character
	BHI StartOfLoop   		;if its below 15, its valid, so branch back. 
							;If not we go straight to invalid hex
	
	
InvalidHex					;a digit beyond 0-15, or overflow
	MOV	R2, #0xFFFFFFFF		;0xFFFFFFFF is a valid Thumb modified
							;immdediate
DONE_Hex2Bin
	BX	LR					;return of Hex2Bin
	
				;Branch back to main once were done
				
	ALIGN			

	AREA	Holder, DATA, READWRITE
		
	EXPORT	adrA		;needed for displaying addr in command-window
	EXPORT	adrB		;needed ...
	EXPORT	adrResult	;needed ...

adrA	DCD		A		;needed for displaying addr in command-window
adrB	DCD		B		;needed ...
adrResult	DCD	result	;needed ...
	
A	DCB	"1", 0	; the number a
	ALIGN
 
B	DCB	"9", 0	; the number b
	ALIGN

result
	DCD	0	; the result of (-A) + B
	
	END
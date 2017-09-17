

MASK EQU 0x00000001
	AREA Assign6, CODE, READONLY
	EXPORT main
	ENTRY
	
main
	LDR R1, =HCode - 1
	MOV R2, #1
	MOV R7, #0
	
Reading
	LDRB R4, [R1, R2]
	CMP R4, #'0'
	BEQ IsZero
	CMP R4, #'1'
	BEQ IsOne
	
DoneErrDet
	CMP R7, #0
	BEQ DoneErrCor
	LDRB R4, [R1, R7]
	CMP R4, #'0'
	BNE ZeroFlip
	MOV R4, #'1'
	B DoneFlip
	
ZeroFlip
	MOV R4, #'0'
	
DoneFlip
	STRB R4, [R1, R7]
	
DoneErrCor
	MOV R2, #1
	LDR R3, =SrcWord - 1
	MOV R4, #1
	MOV R5, #1
	
Correcting
	LDRB R6, [R1, R2]
	CMP R6, #0
	BEQ Done
	CMP R2, R5
	BEQ CheckBit
	STRB R6, [R3, R4]
	ADD R4, #1
	B Indexing
	
CheckBit	
	LSL R5, #1

Indexing
	ADD R2, #1
	B Correcting
	
IsOne
	EOR R7, R7, R2
	
IsZero
	ADD R2, #1
	B Reading
	
Done
	STRB R6, [R4, R3]
	MOV	R0, #0x18      	;These three lines of code end all programs	
	LDR	R1, =0x20026   		
	SVC	#0x11
		
	ALIGN
	AREA DataAssign6, DATA, READWRITE

	EXPORT adrHCode
	EXPORT adrSrcWord
	EXPORT MAX_LEN

adrHCode 	DCD HCode
	
adrSrcWord 	DCD SrcWord

HCode		DCB "010011100101", 0x0

MAX_LEN 	EQU 100
	
SrcWord 	SPACE MAX_LEN
	
	END
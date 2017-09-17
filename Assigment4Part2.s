	AREA	Assign4P2,  CODE,  READONLY	
	EXPORT main
	ENTRY
	
main
	
	LDR R9, =StrOne			;Put the address of StrOne into R9
	LDR R7, =StrTwo			;Put the address of StrTwo into R7
	BL Mixer				;Go to the sub-routine Mixer
	
DONE
	MOV		r0, #0x18      ;angel_SWIreason_ReportException
	LDR		r1, =0x20026   ;ADP_Stopped_ApplicationExit
	SVC		#0x11	       ;previously SWI	
	
Mixer
	LDR R2, =MixStr
	MOV R3, #1
	MOV R4, #1
	
Load_One
	CMP R3, #0x00000000
	BEQ Done_Mixer
	LDRB R3, [R9], #1
	CBZ R3, Done_Mixer
	STRB R3, [R2], #1
	
Load_Two
	CMP R4, #0x00000000
	BEQ Done_Mixer
	LDRB R4, [R7], #1
	CBZ R4, Done_Mixer
	STRB R4, [R2], #1
	
Done_Mixer
	CMP R3, #0x00000000
	BNE Load_One
	CMP R4, #0x00000000
	BNE Load_Two
	BX LR
	
	ALIGN
	
	
	
	AREA	DataForAssign,	DATA, READWRITE
	
	EXPORT adStrOne
	EXPORT adStrTwo		
	EXPORT adMixStr

adStrOne	DCD StrOne		;The adress of our StrOne

adStrTwo	DCD StrTwo		;The address of our StrTwo

adMixStr	DCD MixStr 		;The address of our MixStr 
		
StrOne	DCB	"Goodbye All", 0	;A byte labeled StrOne, with the value "Goodbye"	
	
	ALIGN					;Aligning the memory so we can store another byte

StrTwo	DCB "Hello", 0		;A byte labeled StrTwo, with the value "Hello"

	ALIGN					;Aligning the memory so we can store more values
		
MAX_LEN	EQU 150				;A symbolic value with the value 150

MixStr	SPACE MAX_LEN + 1	;A block of memory MAX_LEN long of blank words.
	
	END						;End of program
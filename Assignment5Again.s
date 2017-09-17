;Trying again....	
	

MASK	EQU		0x80000000 ;This is the mask we use to test if a value is negative.
	AREA decToStr, CODE, READONLY
	EXPORT main			; Needed for a program by the compiler
	ENTRY				; Also needed

main					;Label for main
	LDR R1, =HexStr		;Load the address of HexStr into R1
	MOV R2, #0			;Mov 0 into R2	
	BL Loading_Hex		;Branch with link to Loading_Hex label
	
Done
	MOV	R0, #0x18      	;These three lines of code end all programs	
	LDR	R1, =0x20026   		
	SVC	#0x11
	
Loading_Hex	
	LDRB R3, [R1], #1	;Loads the first bit of HexStr into R3
	CMP R3, #'0'		;Compares R3 tio the ASCII value of '0'
	BLT Done_Read_Hex	;If its lower, were done reading
	CMP R3, #'9'		;If R3 is equal or higher then '0', we compare it to the ASCII value of '9'
	BLE Number			;If R3 is less than or equal to '9', we branch to out label Number
	CMP R3, #'A'		;If R3 is greather than the value of '9', we compare it to the ASCII value of 'A'
	BLT Done_Read_Hex	;If R3 is lower than 'A' we are done reading
	CMP R3, #'F'		;If R3 is greater or equal to 'A', we compare it to the ASCII value of 'F'
	BGT Lower_Case		;If R3 is greater than 'F', it is a lowercase letter, so we branch to that label
	SUB R3, #'A'		;If it is between the values of 'A' and 'F', we subtract the value of 'A' from R3
	ADD R3, #10			;Then we add 10 to R#, making it the correct value in hex
	B Done_Converting	;We then uncoditionally branch to Done_Converting
	
Number					
	SUB R3, #'0'		;If we got here, out first bit is a number. Thus, we subtract the value of '0' from R3
	B Done_Converting	;Then, we are done converting it to its correct hex value, so we branch to Done_Converting

Lower_Case				;If we got here, it was a lowercase letter.
	CMP R3, #'a'		;We then compare R3 to the value of 'a'
	BLT Done_Read_Hex	;If R3 less than, it is not a valid character, thus we are done reading.
	CMP R3, #'f'		;If R3 was greater than or equal to 'a', we compare it to the value of 'f'
	BGT Done_Read_Hex	;If R3 is greater than 'f', it is an invalid character, so we are done
	SUB R3, #'a'		;If R3 is in between the value of 'a' and the value of 'f', we subtract the value of 'a' from R3	
	ADD R3, #10			;Then, we add 10 to R3 to get the correct hex value
	
Done_Converting			;When we get here we are done converting the ASCII to hex.
	MOV R2, R2, LSL #4	;We then shift R2 by 4 bits(or 1 hex digit) and put it back into R2	
	ADD R2, R3			;Then, we add R3 and R2 and put it into R2. This is out holding register so we can store it later
	B Loading_Hex		;Then, we unconditional branch to the begining.
	
Done_Read_Hex			;If we got here we are done loading the bits from HexStr
	MOV R6, #15			;We then put 15 into R6
	LDR R3, =TwosComp	;We load the address of TwosComp inyo R3
	STR R2, [R3]		;We then store what is in R2 to TwosComp in memory
	LDR R9, =RvsDecStr	;We load the address of RvsDecStr to R9
	LDR R10, =DecStr	;We load the address of DecStr to R10
	TST R2, #MASK		;We then test R2 against out mask(at the top of the program)
	BEQ Divid			;If HexStr is a positive number, we branch to divid.
	MOV R3, #'-'		;If HexStr is a negative number we move '-' into R3	
	STRB R3, [R10], #1	;Then, we store '-' into DecStr in memory
	MVN R2, R2			;We then flip the bits in R2
	ADD R2, #1			;Then add one to complete the twos compliment
	MOV R4, #0			;We move 0 into R4
	CMP R2, #MASK		;Then we test to see if R2 is 0x80000000
	BEQ Special			;If it is, it is a special case so we branch to that subroutine.
	
	
Divid					;We now start dividing the number
	CMP R2, #10			;We compare R2(The remainder/starting number first time through) to 10	
	BLT DoneDiv			;It R2 is lower than 10 we are done dividing.

	SUB R2, R2, #10		;Otherwise, we subtract 10 from R2
	ADD R4, R4, #1		;Then, add one to the counter, also known as the quotient	
	B Divid				;Then we branch back to the top of divid.

DoneDiv					;Once we get here we are done dividing
	ADD R2, #'0'		;We then add the value of '0' to out remainder to get the ASCCI value of that hex digit
	STRB R2, [R9], #1	;Then we store that number(as a byte) into RvsDecStr in memory
	MOV R2, R4			;We then move R4(the quotient) into R4 to be divided again
	MOV R4, #0			;We reset the quotient to 0, so we can start the count again
	CMP R2, #0			;Then, we conpare R2 to 0, to make sure we need to divid again
	BNE Divid			;If R2 if not 0, we keep dividing.

DoneRvsDecStr			;If we get here we are done dividing and storing into RvsDecStr
	MOV R3, #0			;We move 0 into R3
	STRB R3, [R9]		;We then store what is in R3(which is 0) into the last byte of RcsDecStr.
	LDR R5, =RvsDecStr	;Then, we load the address of RvsDecStr into R5
	SUB R9, #1			;Then we subtract 1 from the address of the RvsDecStr we have been using
						;(So it is so many bytes away from the original, we will use this to compare)
	LDRB R3, [R9]		;We then load what is in RvsDecStr into R3
	CMP R6, #0			;We then compare R6 to 0
	BEQ Special_Number	;If R6 is 0, we had the case of our HexStr is equal to 0x80000000 so we branch
	
Store					;Otherwise, we start storing out number into DecStr
	STRB R3, [R10]		;We store the last byte of RvsDecStr(which if the MSB of out number) into DecStr
	ADD R10, #1			;We then add 1 to the address of DecStr
	SUB R6, #1			;Then we subtract 1 from R6
	CMP R9, R5			;We compare R5(The original address of RvsDecStr) to R9(modified address)
	BHI DoneRvsDecStr	;If R9 is higher than R5(meaning we are not back to the orginal address) we loop back up
	BX LR				;Otherwise we are done with the progra, and should loop back to main
	
Special_Number			;This is the second ubroutine for the special case of 0x80000000
	ADD R3, #1			;We add one to R3, to make the first number 8 instead of 7
	MOV R6, #0			;Then we set R6 to 0, to make sure we don't come back here
	B Store				;Then we unconditionally branch to Store
	
Special					;This is the first subroutine we use when we have the case of 0x80000000
	MOV R2, #0x7FFFFFFF	;We make R2 0x7FFFFFFF, so we can skip the twos compliment process
	MOV R6, #9			;We then put 9 into R6, so we can make sure we hit the second subroutine of the special case
	B Divid				;Then we unconditionally branch to divid. 
	
	
	ALIGN
	AREA dataDecToStr, DATA, READWRITE
	EXPORT adrHexStr
	EXPORT adrTwosComp
	EXPORT adrDecStr
	EXPORT adrRvsDecStr


adrHexStr		DCD HexStr
	
adrTwosComp 	DCD TwosComp

adrDecStr		DCD DecStr
	
adrRvsDecStr	DCD RvsDecStr	
				ALIGN

HexStr			DCB "00000093", 0
				ALIGN
				
TwosComp		DCD 0
				ALIGN
	
DecStr			SPACE 12	
	
RvsDecStr		SPACE 11
	
	END
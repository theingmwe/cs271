TITLE Assignment5   (p5_tmo.asm) ; (*** still incomplete ***)

; Author: Breanne Oo
; Last Modified: March 16 2021
; OSU email address: oot@oregonstate.edu
; Course number/section: CS 271 001 W21 
; Assignment Number: Assignment 5             Due Date: Feb 28 2021
; Description:
	;
	;
	;

INCLUDE Irvine32.inc

;insert constant definitions here

	MIN_ARRAY = 15
	MAX_ARRAY = 200
	MIN_NUMBERS = 100
	MAX_NUMBERS = 999
	;RANGE = 899 ; MAX_NUMBERS - MIN_NUMBERS = 999 - 100 = 899


.data
;insert variable definitions here

	welcomeMessage		BYTE	"Sorting Random Integers", 0 ;used
	authorName			BYTE	"Programmed by Breanne Oo", 0 ;used
	description1		BYTE	"This program generates random numbers in the range [100 .. 999],", 0 ;used
	description2		BYTE	"displays the original list, sorts the list, and calculates the", 0 ;used
	description3		BYTE	"median value. Finally, it displays the list sorted in descending order.", 0 ;used
	askForNumber		BYTE	"How many numbers should be generated? [15 .. 200]: ", 0 ;used
	errorMessage		BYTE	"Invalid input", 0 ;used
	request				DWORD	? ; how many numbers the user wants in the array
	array				DWORD	MAX_ARRAY	DUP(?)
	iAmHere				BYTE	"I am in display list now", 0
	unsortedMessage		BYTE	"The unsorted random numbers:", 0
	spaces				BYTE	"      ", 0
	medianMessage		BYTE	"The median is ", 0
	sortedMessage		BYTE	"The sorted list:", 0
	thankYou			BYTE	"Thank you for using my program!", 0


.code
main PROC
	; main - must consist mostly of procedure calls
	call	Randomize 

	call	introduction

	push	OFFSET request ; 8
	call	get_data

	push	OFFSET array ; 12
	push	request	; 8
	call	fill_array

	push	OFFSET array ; 20
	push	request ; 16
	push	OFFSET unsortedMessage ; 12
	push	OFFSET spaces ; 8
	call	display_list

	push	OFFSET array ; 12
	push	request ; 8
	call	sort_list

	push	OFFSET array ; 20
	push	request ; 16
	push	OFFSET sortedMessage ; 12
	push	OFFSET spaces ; 8
	call	display_list

	push	OFFSET thankYou ; 8
	call	goodbye

exit

main ENDP

; description: procedure to greet the user and explain what the program does
; receives: none
; returns: none
; preconditions: none
; registers changed: edx
introduction PROC

	; display program name
	mov		edx, OFFSET welcomeMessage
	call	WriteString
	call	Crlf
	; display author name
	mov		edx, OFFSET	authorName
	call	WriteString
	call	Crlf
	call	Crlf
	; explain what the program does
	mov		edx, OFFSET description1
	call	WriteString
	call	Crlf
	mov		edx, OFFSET description2
	call	WriteString
	call	Crlf
	mov		edx, OFFSET description3
	call	WriteString
	call	Crlf
	call	Crlf

	ret

introduction ENDP

; description: 
; receives: (a list of input parameters)
; returns: (a description of values returned by the procedure)
; preconditions: (list of requirements that must be met before the procedure is called)
; registers changed: (list of registers that may have different values now)
get_data PROC ; {parameters: request (reference)}

	; set up the stack frame
	push	ebp ; push onto stack
	mov		ebp, esp ; set up stack frame

	ifInvalid: ; displays error message and asks for user input again
		mov		edx, OFFSET errorMessage
		call	WriteString
		call	Crlf

	; get the address of where the user input is going to be stored
	mov		eax, [ebp + 8] ; used to be ebx
	mov		eax, 0
	; display prompt that asks user how many numbers they want in the array
	mov		edx, OFFSET askForNumber
	call	WriteString
	; take in user input
	call	ReadInt
	; store user input (eax) in ebx
	;mov		[ebx], eax		; move this to later!!!!

	; check if the user input is in range [15 .. 200]
	cmp		eax, MIN_ARRAY ; minimum length of the array is 15
	jl		ifInvalid ; if the user input is less than 15, jump to the 'ifInvalid' function
	cmp		eax, MAX_ARRAY ; maximum length of the array is 200
	jg		ifInvalid ; if the user input is greater than 200, jump to the 'ifInvalid' function
	
	; store user input (eax) in ebx
	mov		ebx, [ebp + 8]
	mov		[ebx], eax

	; restore old ebp
	pop		ebp
	; pop the parameter stored
	ret		4

get_data ENDP

; description
; receives: (a list of input parameters)
; returns: (a description of values returned by the procedure)
; preconditions: (list of requirements that must be met before the procedure is called)
; registers changed: (list of registers that may have different values now)
fill_array PROC ; {parameters: request (value), array (reference)}

	; set up the stack frame
	push	ebp ; push onto stack
	mov		ebp, esp ; set up stack frame
	; create an array 
	mov		ecx, [ebp + 8] ; store 'request' in ecx
	mov		edi, [ebp + 12] ; store address of the array in edi
	; clear the ebx register so that there is no data corruption
	mov		ebx, 0
	; fill the array
	fill_array_loop:
		mov		eax, MAX_NUMBERS
		SUB		eax, MIN_NUMBERS
		inc		eax
		call	RandomRange
		add		eax, MIN_NUMBERS
		mov		[edi], eax ; store the random number in the array
		add		edi, 4 ; add space for one more DWORD in the array
		loop	fill_array_loop

	call	Crlf

	pop		ebp
	ret		8 

	; display the array (10 numbers per line)
	;mov		edx, OFFSET unsortedMessage
	;call	WriteString
	;call	Crlf

fill_array ENDP

; description
; receives: (a list of input parameters)
; returns: (a description of values returned by the procedure)
; preconditions: (list of requirements that must be met before the procedure is called)
; registers changed: (list of registers that may have different values now)
sort_list PROC ; {parameters: array (reference), request (value)}
		; exchange elements (for most sorting algorithms): {parameters: array[i] (reference),
		; array[j] (reference), where i and j are the indexes of elements to be exchanged}

	; set up stack
	push	ebp
	mov		ebp, esp
	; set up registers
	mov		esi, [ebp + 12] ; store array in esi
	mov		ecx, [ebp + 8] ; store request in ecx
	dec		ecx ; -1 to ecx to access array accurately

	; nested loops
	outsideLoop:
		push	ecx
		inc		ecx
		mov		ebx, [esi] ; ebx = i, [esi] = k, meaning i = k
			insideLoop:
				mov		eax, [esi + 4] ; store next element from array in eax. eax = k + 1
				cmp		ebx, eax
				jg		ifGreater
				push	[esi] ; i // 12
				push	[esi + 4] ; j // 8
				call	swap_procedure
				pop		[esi]
				pop		[esi + 4]

				ifGreater:
					add		esi, 4
				
			loop	insideLoop ; redo the inside loop
		pop		ecx ; clean up stack
		loop	outsideLoop ; redo outside loop

	pop		ebp
	ret		8

sort_list ENDP

; description
; receives: (a list of input parameters)
; returns: (a description of values returned by the procedure)
; preconditions: (list of requirements that must be met before the procedure is called)
; registers changed: (list of registers that may have different values now)
swap_procedure PROC

	; set up stack
	push	ebp
	mov		ebp, esp
	; swap i and j
	mov		eax, [ebp + 8] ; store j in eax
	mov		ebx, [ebp + 12] ; store i in ebx
	mov		[ebp + 8], ebx ; move j to i
	mov		[ebp + 12], eax ; move i to j
	
	; clean stack and pop memory
	pop		ebp
	ret		8

swap_procedure ENDP

; description
; receives: (a list of input parameters)
; returns: (a description of values returned by the procedure)
; preconditions: (list of requirements that must be met before the procedure is called)
; registers changed: (list of registers that may have different values now)
display_median PROC ; {parameters: array (reference), request (value)}
	
	; set up stack
	push	ebp
	mov		ebp, esp
	; print the message saying it is now displaying the median
	mov		edx, [ebp + 8]
	call	WriteString
	call	Crlf
	; 

display_median ENDP

; description
; receives: (a list of input parameters)
; returns: (a description of values returned by the procedure)
; preconditions: (list of requirements that must be met before the procedure is called)
; registers changed: (list of registers that may have different values now)
display_list PROC ; {parameters: array (reference), request (value), title (reference)}

	; set up the stack
	push	ebp
	mov		ebp, esp
	; print the title of the array (unsorted or sorted)
	mov		edx, [ebp + 12]
	call	WriteString
	call	Crlf
	; set up registers 
	mov		ecx, [ebp + 16] ; number of elements in the array = number of loops
	mov		esi, [ebp + 20] ; store the number array in esi
	mov		ebx, 0 ; count for the number of elements per line
	mov		edx, [ebp + 8] ; space 
	; loop to display the list
	display_list_loop:
		; print number
		mov		eax, [esi] ; store number from array in eax
		call	WriteDec ; display the number
		; +1 to the count of numbers in one line
		inc		ebx
		; print spaces
		;mov		edx, [ebp + 8]
		call	WriteString ; printing what is stored in edx (spaces)
		; add space for one more number in the esi array
		add		esi, 4
		; check if there are already 10 numbers in the display line
		cmp		ebx, 10
		je		startNewLine
		; if there is not yet 10 numbers in the line, jump to the end of the procedure
		jmp		endOfProc

		startNewLine:
			call	Crlf ; start new line
			mov		ebx, 0 ; reset count for numbers in the line to 0

		endOfProc:
			loop display_list_loop ; redo the loop
	
	push	ebp
	ret		16

display_list ENDP

goodbye PROC

	;set up stack
	push	ebp
	mov		ebp, esp
	;display thank you
	mov		edx, [ebp + 8]
	call	WriteString
	call	Crlf

	;clean stack
	pop		ebp
	ret		4

	
goodbye ENDP

END main

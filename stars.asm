; #########################################################################
;
;   	Naomi Gutstein nyg316
;	stars.asm - Assembly file for EECS205 Assignment 1
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA
	movin DWORD 1
	;; If you need to, you can place global variables here

.CODE

DrawStarField proc s1:DWORD, s2:DWORD, s3:DWORD, s4:DWORD, s5:DWORD, s6:DWORD, s7:DWORD, s8:DWORD, s9:DWORD, s10:DWORD, s11:DWORD, s12:DWORD

	;; Place your code here
	invoke DrawStar, s1,50
	invoke DrawStar, s1,400
	invoke DrawStar, s2,150
	invoke DrawStar, s2,300
	invoke DrawStar, s3,50
	invoke DrawStar, s3,400
	invoke DrawStar, s4,150
	invoke DrawStar, s4,300
	invoke DrawStar, s5,50
	invoke DrawStar, s5,400
	invoke DrawStar, s6,150
	invoke DrawStar, s6,300
	invoke DrawStar, s7,50
	invoke DrawStar, s7,400
	invoke DrawStar, s8,150
	invoke DrawStar, s8,300
	invoke DrawStar, s9,50
	invoke DrawStar, s9,400
	invoke DrawStar, s10,150
	invoke DrawStar, s10,300
	invoke DrawStar, s11,50
	invoke DrawStar, s11,400
	invoke DrawStar, s12,150
	invoke DrawStar, s12,300

	ret  			; Careful! Don't remove this line
DrawStarField endp


AXP	proc a:FXPT, x:FXPT, p:FXPT

	;; Place your code here
	xor edx, edx 
	mov eax, a
	mov ebx, x
	imul ebx
	;;shifts the decimal to correct location which is 16 bits to the right
	shr eax, 16
	;;shifts the number to write location which is 16 bits to the left
	shl edx, 16
	;;or the number with the decimal to create the answer
	or eax, edx
	add eax, p

	;; Remember that the return value should be copied in to EAX
	
	ret  			; Careful! Don't remove this line	
AXP	endp

	

END

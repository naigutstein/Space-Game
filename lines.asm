; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;    Name: Naomi Gutstein
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA
;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  256 / PI   (use this to find the table entry for a given angle
	                        ;;              it is easier to use than divison would be)

	;; If you need to, you can place global variables here




.CODE
	

FixedSin PROC USES edx ebx ecx angle:FXPT

	mov eax, angle
r_test:

;;r1 if angle is from 0 to pi/2
r1:
	cmp eax, 0           ;;check angle is greater that or equal to zero
	je PeaceOut
	cmp eax, 0
	jl r6
	cmp eax, TWO_PI      ;;check angle is greater than 2pi
	jge r5
	cmp eax, PI_HALF     ;;check angle is less than pi/2
	jge r2 
	
	mov ebx, PI_INC_RECIP      
	imul ebx                 ;; index is stored in edx
	movzx eax, SINTAB[edx*2] ;;moves sin value at index i to eax
	jmp outofhere

;;r2 if angle is from pi/2 to pi
r2: 
	cmp eax, PI           ;;checks that eax is less than pi
	jge r3

	mov ecx, PI               ;; ecx = PI
	sub ecx, eax			  ;; ecx = PI- angle
	mov eax, ecx              ;; eax = PI - angle
	mov ebx, PI_INC_RECIP
	imul ebx                  ;; index stored in edx, index = (pi-angle) * 256/pi
	movzx eax, SINTAB[edx*2]  ;;finding index
	jmp outofhere

;;r3 if angle is from pi to 3pi/2
r3:
    mov ebx, PI_HALF
	add ebx, PI
	cmp eax, ebx          ;;check to see if eax is less than 3pi/2
	jge r4

	sub eax, PI           ;;subtract pi from angle before finding index
	mov ebx, PI_INC_RECIP
	imul ebx
	movzx eax, SINTAB[edx*2]     ;;finding index
	mov ecx, -1                  ;;uses identity sin (x + Pi) = - sin(x)
	imul ecx

	jmp outofhere
	

;;r4 if angle is from 3pi/2 to 2pi
r4:

	mov ebx, TWO_PI
	sub ebx, eax       ;; ebx = 2pi-angle 
	mov eax, ebx


	mov ecx, PI_INC_RECIP       
	imul ecx
	movzx eax, SINTAB[edx*2]
	mov ecx, -1               ;;using identiy sin (x + Pi) = - sin(x)
	imul ecx

	jmp outofhere


;;r5 if angle is greater than 2pi
r5:
	sub eax, TWO_PI            ;; uses identity sin (x + 2 Pi) = sin (x)
	jmp r1

;;r6 if less than 0
r6:
	add eax, TWO_PI            ;; if its less than 0 then add 2pi 
	jmp r1                     ;; uses identity sin (x + 2 Pi) = sin (x)

PeaceOut:
	xor eax, eax

outofhere:
	

	ret        	;;  Don't delete this line...you need it	
FixedSin ENDP 
	
FixedCos PROC angle:FXPT

    mov eax, angle
	add eax, PI_HALF
	invoke FixedSin, eax     ;; using identity cos (x) = sin (x + Pi/2)

	ret        	;;  Don't delete this line...you need it		
FixedCos ENDP	

PLOT PROC USES edi ebx ecx x:DWORD, y:DWORD, color:DWORD

	mov edi, ScreenBitsPtr


	mov ecx, x
	cmp ecx, 640        ;;check that ecx is on the screen
	jge peace
	cmp ecx, 0
	jle peace
	xor ecx, ecx
	mov ecx, y
	cmp ecx, 480
	jge peace
	cmp ecx, 0
	jle peace

	mov eax, 640
	mov ebx, y
	imul ebx             ;;640*y into eax
	xor ebx, ebx
	mov ebx, x
	add eax, ebx         ;; eax = 640*y + x
    xor edx, edx
    

	mov edx, color        ;; color into edx
	mov BYTE PTR [edi + eax], dl    ;;make last 8 bits of the index on screen switch to color

	peace:
	ret

PLOT ENDP



DrawLine PROC USES edi esi ebx ecx edx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	

	;;making ints into fixed point

;;if (ABS(y1 - y0) < ABS(x1 - x0))
	;;checking absolute values of y1-y0 and x1-x0
	xor eax, eax
	mov eax, y1
	sub eax, y0
	cmp eax, 0
	jge positivey  
	;;neg eax            
	xor eax, eax
	mov eax, y0
	sub eax, y1      ;;ABS(y1 - y0)
positivey:
	
	xor ebx, ebx
	mov ebx, x1
	sub ebx, x0
	cmp ebx, 0
	jge positivex
	;;neg ebx                
	xor ebx, ebx
	mov ebx, x0
    sub ebx, x1     ;; ABS(x1 - x0)
positivex:
   
	cmp eax, ebx
	jge els                ;;if (ABS(y1 - y0) < ABS(x1 - x0))

;;	fixed_inc = INT_TO_FIXED(y1 - y0) / INT_TO_FIXED(x1 - x0);
	xor eax, eax
	mov eax, y1
	sub eax, y0      ;;eax = y1-y0
	xor ebx, ebx
	mov ebx, x1
	sub ebx, x0      ;;ebx = x1-x0
	
	xor edx, edx
	mov edx, eax      ;; idiv takes {edx, eax} and divides by ebx
	xor eax, eax
	shl ebx, 16
	idiv ebx    
	       
	xor esi, esi
	mov esi, eax       ;; fixed_inc = INT_TO_FIXED(y1 - y0) / INT_TO_FIXED(x1 - x0)
	                   ;; esi is the fixed_inc
	

	xor eax, eax
	mov eax, x0        ;;eax = x0 and ebx = x1
	xor ebx, ebx
	mov ebx, x1
	cmp eax, ebx
	jle els2                 ;;if (x0 > x1)
	
	;;SWAP      
	mov ecx, eax                     ;;eax = x1, ebx = x0
	mov eax, ebx
	mov ebx, ecx
	

	xor edx, edx
	mov edx, y1              
	shl edx, 16
	xor edi, edi
	mov edi, edx         ;;fixed_j = INT_TO_FIXED(y1)
						;; edi is the fixed_j

	jmp loop1

els2:
                       ;;eax = x0 and ebx = x1
    xor edx, edx
	mov edx, y0               
	shl edx, 16
    xor edi, edi
	mov edi, edx         ;;fixed_j = INT_TO_FIXED(y0)


loop1:
	xor ecx, ecx
	mov ecx, eax           ;;ebx is x0/x1
	jmp loop1_test              ;; i= ecx = x0

loop1_body:
   
    xor edx, edx
	mov edx, edi
	shr edx, 16


    invoke PLOT, ecx, edx, color    ;;PLOT(i, FIXED_TO_INT(fixed_j), c);
	

	add edi, esi           ;;fixed_j += fixed_inc
	add ecx, 1


loop1_test:
	cmp ecx, ebx          ;;eax is x1/x0
	jle loop1_body        ;;i<x1
	jmp bye

els:
    xor eax, eax
	mov eax, y0
	cmp eax, y1               ;;(y1 != y0)
    je bye

	xor eax, eax
	mov eax, x1
	sub eax, x0             ;;eax = x1-x0
	xor ebx, ebx
	mov ebx, y1
	sub ebx, y0             ;;ebx = y1-y0
	
	xor edx, edx
	mov edx, eax
	xor eax, eax
	shl ebx, 16
	idiv ebx
	mov esi, eax       ;; fixed_inc = INT_TO_FIXED(x1 - x0) / INT_TO_FIXED(y1 - y0)
	
	xor eax, eax
	mov eax, y0            ;;eax is y0 and ebx is y1
	xor ebx, ebx
	mov ebx, y1
	cmp eax, ebx         ;;if (y0 > y1)
	jle els3

	;;SWAP 
	mov ecx, eax                     ;;eax = x1, ebx = x0
	mov eax, ebx
	mov ebx, ecx

	xor edx, edx
	mov edx, x1
	shl edx, 16              ;;fixed_j = INT_TO_FIXED(x1)
	mov edi, edx

	jmp loop2

els3:
    xor edx, edx
	mov edx, x0
	shl edx, 16
	mov edi, edx             ;;fixed_j = INT_TO_FIXED(x0)


loop2: 
    xor ecx, ecx
	mov ecx, eax                ;;eax is y0/1
	jmp loop2_test              ;; i = y0

loop2_body:
    xor edx, edx
	mov edx, edi
	shr edx, 16
    invoke PLOT, edx, ecx, color        ;;PLOT(FIXED_TO_INT(fixed_j), i, c);
	
	add edi, esi              ;;fixed_j += fixed_inc
	add ecx, 1


loop2_test:
	cmp ecx, ebx              ;;eax is y1/0
	jle loop2_body            ;;i<y1


bye:
	ret        	;;  Don't delete this line...you need it
DrawLine ENDP



END

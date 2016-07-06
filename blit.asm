; #########################################################################
;
;   
;   Naomi Gutstein
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include blit.inc

.DATA

	;; If you need to, you can place global variables here
	
	width_bound DWORD ?
	current_row DWORD ?
	color_count DWORD ?
	start_index DWORD ?
	d_height DWORD ?
	d_width DWORD ?
	cosa DWORD ?
	sina DWORD ?
	shiftx DWORD ?
	shifty DWORD ?
	dstWidth DWORD ?
	dstHeight DWORD ?
	dstx DWORD ?
	dsty DWORD ?
	srcx DWORD ?
	srcy DWORD ?
	r1 DWORD ?
	r2 DWORD ?
	l1 DWORD ?
	l2 DWORD ?
	b1 DWORD ?
	b2 DWORD ?
	t1 DWORD ?
	t2 DWORD ?

.CODE

BasicBlit PROC USES edi esi ebx edx ecx ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD
	
;;finding the height and width
	mov esi, [ptrBitmap]
	mov eax, (EECS205BITMAP PTR[esi]).dwHeight
	mov d_height, eax
	mov ebx, (EECS205BITMAP PTR[esi]).dwWidth
	mov d_width, ebx

	xor eax, eax
	xor edi, edi
	xor ebx, ebx
	
	mov eax, 1
	sal eax, 16
	mov cosa, eax                                       ;;cosa

	xor eax, eax 

	mov eax, d_width
	sal eax, 16
	imul cosa                                            ;; ----> {edx, eax}
	sar edx, 1
	mov ebx, edx                                         ;; ebx = f_width * cosa/2
	mov shiftx, ebx                                       ;; shiftX
	
	xor eax, eax
	xor edx, edx
	xor ebx, ebx
	xor ecx, ecx

	mov eax, d_height
	sal eax, 16
	imul cosa                                              ;;---->{edx, eax}
	sar edx, 1
	mov ebx, edx                                           ;;ebx = f_height * cosa/2
	mov shifty, ebx                                        ;;shiftY

	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	mov eax, d_width
	add eax, d_height                                      ;;eax= d_width+d_height
	mov dstWidth, eax                                      ;;dstWidth
	mov dstHeight, eax                                     ;;dstHeight


	mov dstx, eax
	neg dstx                                              ;;dstx = -dstWidth
	jmp condition_x
next_x:
	inc dstx                                              ;;dstx++
condition_x:
	mov eax, dstx
	cmp eax, dstWidth
	jge peace                                             ;;dstx<dstWidth
	
	mov eax, dstHeight
	mov dsty, eax
	neg dsty                                              ;;dsty =-dstHeight
	jmp condition_y
next_y:
	inc dsty                                              ;;dsty++
condition_y:
	xor eax, eax
	mov eax, dsty
	cmp eax, dstHeight
	jge next_x                                            ;;dsty<dstHeight
	 
monster_loop:
	mov eax, dstx
	sal eax, 16
	imul cosa                                             ;;edx = dstx *cosa    
	mov srcx, edx

	xor eax, eax
	xor ebx, ebx

	mov eax, dsty
	sal eax, 16
	imul cosa                                             ;;edx= dstY*cosa              
	mov srcy, edx

	xor eax, eax
	xor edx, edx

	mov eax, srcx
	cmp eax, 0
	jl next_y                                             ;;srcX >=0

	cmp eax, d_width
	jge next_y                                            ;;srcX < d_width

	xor eax, eax

	mov eax, srcy
	cmp eax, 0
	jl next_y                                              ;;srcY >=0

	cmp eax, d_height
	jge next_y                                             ;;srcY < d_height

	xor eax, eax

	mov ecx, xcenter
	add ecx, dstx
	sub ecx, shiftx
	cmp ecx, 0
	jl next_y                                               ;;(xcenter+dstX-shiftX)>=0

	cmp ecx, 639
	jge next_y                                              ;;(xcenter+dstX-shiftX)< 639

	mov eax, ycenter
	add eax, dsty
	sub eax, shifty
	cmp eax, 0
	jl next_y                                                ;;(ycenter+dstY-shiftY)>=0

	cmp eax, 479
	jge next_y                                               ;;(ycenter+dstY-shiftY)<479

	xor eax, eax

	mov eax, ycenter
	add eax, dsty
	sub eax, shifty                                          ;;eax= ycenter+dsty-shifty

	mov ebx, 640
	imul ebx                                                 ;;eax=(ycenter+dsty-shifty)*640
	add eax, ecx                                             
	mov ecx, eax                                             ;;ecx=(ycenter+dsty-shifty)*64+(xcenter+dstX-shiftX)
	mov esi, [ptrBitmap]


	mov eax, srcy
	mov ebx, d_width
	imul ebx                                             
	add eax, srcx                                            ;; eax = srcy* d_width + srcx


	mov edi, ScreenBitsPtr

	add eax, (EECS205BITMAP PTR[esi]).lpBytes
	mov bl, (BYTE PTR[eax])
	xor edx, edx
	mov dl, (EECS205BITMAP PTR[esi]).bTransparent
	cmp bl, dl                                              
	jz dont_draw                                             ;;if the color is transparent dont draw it!
	mov(BYTE PTR [edi + ecx]), bl                            ;;if color is not transparent draw it!

dont_draw:
	jmp next_y
	

peace:
	ret  	;;  Do not delete this line!


BasicBlit ENDP


RotateBlit PROC USES edi esi ebx ecx edx lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	
	;;finding the height and width
	mov esi, [lpBmp]
	mov eax, (EECS205BITMAP PTR[esi]).dwHeight
	mov d_height, eax
	mov ebx, (EECS205BITMAP PTR[esi]).dwWidth
	mov d_width, ebx

	xor eax, eax
	xor edi, edi
	xor ebx, ebx

	cmp angle, 0                                       ;;check if angle is not zero
	jne rotate_star
	
	INVOKE BasicBlit, lpBmp, xcenter, ycenter          ;;if it is zero draw as we had before
	jmp peace

rotate_star:
	
	mov ebx, angle
	INVOKE FixedCos, ebx
	mov cosa, eax                                       ;;cosa

	xor eax, eax
	INVOKE FixedSin, ebx
	mov sina, eax                                       ;;sina

	xor eax, eax
	xor ebx, ebx 

	mov eax, d_width
	sal eax, 16
	imul cosa                                            ;; ----> {edx, eax}
	sar edx, 1
	mov ebx, edx                                         ;; ebx = f_width * cosa/2
	
	xor eax, eax
	xor edx, edx

	mov eax, d_height
	sal eax, 16
	imul sina                                             ;; ----->{edx, eax}
	sar edx, 1
	mov ecx, edx                                          ;; ecx = f_height * sina/2

	xor eax, eax
	xor edx, edx 

	sub ebx, ecx                                           ;; ebx = d_width * cosa/2 - d_height * sina/2
	mov shiftx, ebx                                        ;; shiftX

	xor ebx, ebx
	xor ecx, ecx

	mov eax, d_height
	sal eax, 16
	imul cosa                                              ;;---->{edx, eax}
	sar edx, 1
	mov ebx, edx                                           ;;ebx = f_height * cosa/2

	xor eax, eax
	xor edx, edx

	mov eax, d_width
	sal eax, 16
	imul sina                                               ;;------> {edx, eax}
	sar edx, 1
	mov ecx, edx                                            ;; ecx = f_width * sina/2

	add ebx, ecx                                           ;;ebx = f_height * cosa/2 + f_width * sina/2
	mov shifty, ebx                                        ;;shiftY

	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	mov eax, d_width
	add eax, d_height                                      ;;eax= d_width+d_height
	mov dstWidth, eax                                      ;;dstWidth
	mov dstHeight, eax                                     ;;dstHeight


	mov dstx, eax
	neg dstx                                              ;;dstx = -dstWidth
	jmp condition_x
next_x:
	inc dstx                                              ;;dstx++
condition_x:
	mov eax, dstx
	cmp eax, dstWidth
	jge peace                                             ;;dstx<dstWidth
	
	mov eax, dstHeight
	mov dsty, eax
	neg dsty                                              ;;dsty =-dstHeight
	jmp condition_y
next_y:
	inc dsty                                              ;;dsty++
condition_y:
	xor eax, eax
	mov eax, dsty
	cmp eax, dstHeight
	jge next_x                                            ;;dsty<dstHeight
	 
monster_loop:
	mov eax, dstx
	sal eax, 16
	imul cosa                                             ;;edx = dstx *cosa    
	mov srcx, edx
	
	xor eax, eax
	xor edx, edx

	mov eax, dsty
	sal eax, 16
	imul sina                                             ;;edx = dstY*sina
	add srcx, edx                                         ;;srcX = dstx*cosa + dsty*sina

	xor eax, eax
	xor ebx, ebx

	mov eax, dsty
	sal eax, 16
	imul cosa                                             ;;edx= dstY*cosa              
	mov srcy, edx

	xor eax, eax
	xor edx, edx

	mov eax, dstx
	sal eax, 16
	imul sina                                             ;;edx= dstX*sina        
	sub srcy, edx                                         ;;srcY =dstY*cosa - dstX*sina

	xor eax, eax
	xor edx, edx

	mov eax, srcx
	cmp eax, 0
	jl next_y                                             ;;srcX >=0

	cmp eax, d_width
	jge next_y                                            ;;srcX < d_width

	xor eax, eax

	mov eax, srcy
	cmp eax, 0
	jl next_y                                              ;;srcY >=0

	cmp eax, d_height
	jge next_y                                             ;;srcY < d_height

	xor eax, eax

	mov ecx, xcenter
	add ecx, dstx
	sub ecx, shiftx
	cmp ecx, 0
	jl next_y                                               ;;(xcenter+dstX-shiftX)>=0

	cmp ecx, 639
	jge next_y                                              ;;(xcenter+dstX-shiftX)< 639

	mov eax, ycenter
	add eax, dsty
	sub eax, shifty
	cmp eax, 0
	jl next_y                                                ;;(ycenter+dstY-shiftY)>=0

	cmp eax, 479
	jge next_y                                               ;;(ycenter+dstY-shiftY)<479

	xor eax, eax

	mov eax, ycenter
	add eax, dsty
	sub eax, shifty                                          ;;eax= ycenter+dsty-shifty

	mov ebx, 640
	imul ebx                                                 ;;eax=(ycenter+dsty-shifty)*640
	add eax, ecx                                             
	mov ecx, eax                                             ;;ecx=(ycenter+dsty-shifty)*64+(xcenter+dstX-shiftX)
	mov esi, [lpBmp]


	mov eax, srcy
	mov ebx, d_width
	imul ebx                                             
	add eax, srcx                                            ;; eax = srcy* d_width + srcx


	mov edi, ScreenBitsPtr

	add eax, (EECS205BITMAP PTR[esi]).lpBytes
	mov bl, (BYTE PTR[eax])
	xor edx, edx
	mov dl, (EECS205BITMAP PTR[esi]).bTransparent
	cmp bl, dl                                              
	jz dont_draw                                             ;;if the color is transparent dont draw it!
	mov(BYTE PTR [edi + ecx]), bl                            ;;if color is not transparent draw it!

dont_draw:
	jmp next_y
	

peace:
	ret  	;;  Do not delete this line!
	
RotateBlit ENDP


CheckIntersectRect PROC USES ebx ecx edx one:PTR EECS205RECT, two:PTR EECS205RECT

	mov eax, [one]
	mov ebx, (EECS205RECT PTR[eax]).dwLeft
	mov l1, ebx                                               ;; rec one left--> l1

	xor ebx, ebx
	mov ebx, (EECS205RECT PTR[eax]).dwRight                     
	mov r1, ebx                                               ;; rec one right--> r1

	xor ebx, ebx
	mov ebx, (EECS205RECT PTR[eax]).dwTop
	mov t1, ebx                                               ;; rec one top --> t1

	xor ebx, ebx
	mov ebx, (EECS205RECT PTR[eax]).dwBottom
	mov b1, ebx                                               ;; rec one bottom --> b1

	xor eax, eax 
	xor ebx, ebx

	mov esi, [two]
	mov eax, (EECS205RECT PTR[esi]).dwLeft                    ;; rec one left--> eax
	mov ebx, (EECS205RECT PTR[esi]).dwRight                   ;; rec one right--> ebx
	mov ecx, (EECS205RECT PTR[esi]).dwTop                     ;; rec one top --> ecx
	mov edx, (EECS205RECT PTR[esi]).dwBottom                  ;; rec one bottom --> edx

;;if any case makes it through without jumping then the boxes are not overlapping

	cmp b1, ecx
	jl not_overlapping

	cmp t1, edx
	jg not_overlapping

	cmp r1, eax
	jl not_overlapping

	cmp l1, ebx
	jg not_overlapping

overlapping:
	ret 

not_overlapping:
	xor eax, eax                                              ;;remove color rectangles on the screen
	mov eax, 0
	ret  	;;  Do not delete this line!
	
CheckIntersectRect ENDP

END

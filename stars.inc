; #########################################################################
;
;   stars.inc - Includes for EECS205 Assignment 1
;
;
; #########################################################################

FXPT typedef SDWORD

DrawStar proto stdcall x:DWORD, y:DWORD

DrawStarField proto stdcall s1:DWORD, s2:DWORD, s3:DWORD, s4:DWORD, s5:DWORD, s6:DWORD, s7:DWORD, s8:DWORD, s9:DWORD, s10:DWORD, s11:DWORD, s12:DWORD
AXP proto stdcall a:FXPT, x:FXPT, p:FXPT

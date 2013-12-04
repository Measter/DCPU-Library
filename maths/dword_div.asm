; --------------------------------------------
; Title:   DWard Maths - Division Module
; Author:  Measter
; Date:    2013/10/29
; --------------------------------------------

; Revisions
; 1  :  Initial Release.
; 2  :  Added macro.

.macro dword_div ( fir1, fir2, sec, res1, res2 )
	set push, fir1
	set push, fir2
	set push, sec
		jsr dword_div_func
	set res2, pop 	; Clear stack without adding.
	set res2, pop
	set res1, pop
.endmacro

; Divide a 32-bit by a 16-bit number.
; Input
; SP+2 			: Left half of first value.
; SP+1  		: Right half of first value.
; SP+0 			: Second Value.

; Output
; SP+1 			: Right half of result.
; SP+2 			: Left half of result.
; EX 			: Non-Zero indicates a remainder.
:dword_div_func
	set push, z
	set z, sp
	add z, 2
	set push, a

		;Set A to left half of first value.
		;Divide by second value.
		set a, [z+2]
		div a, [z+0]
		;Save value in Z+2
		set [z+2], a


		;Set A to right half of first value.
		set a, [z+1]
		;Set Z+1 to EX from first division.
		set [z+1], ex

		;Divide A by second value.
		div a, [z+0]

		;Save EX for later.
		set push, ex
			
			;Store in Z+1
			add [z+1], a	
			;Add EX from addition to left half of result.
			add [z+2], ex

		;Restore EX
		set ex, pop

	set a, pop
	set z, pop
	set pc, pop
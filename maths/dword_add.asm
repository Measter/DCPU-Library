; --------------------------------------------
; Title:   DWard Maths - Addition Module
; Author:  Measter
; Date:    2013/10/29
; --------------------------------------------

; Revisions
; 1  :  Initial Release.
; 2  :  Added macro.

.macro dword_add ( fir1, fir2, sec1, sec2, res1, res2 )
	set push, fir1
	set push, fir2
	set push, sec1
	set push, sec2
		jsr dword_add_func
	add sp, 2
	set res2, pop
	set res1, pop
.endmacro

; Adds two 32-bit numbers. Big Endian.
; Input
; SP+3			: Left half of first value.
; SP+2			: Right half of first value.
; SP+1			: Left half of second value.
; SP+0			: Right half of second value.

; Output
; SP+2			: Right half of result.
; SP+3			: Left half of result.
; EX			: Same result as expected from ADD.
:dword_add_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, i

		;Set A to right half of first value.
		;Then add right half of second value.
		set a, [z+2]
		add a, [z+0]
		;Store A back in [Z+2]
		set [z+2], a

		;Set A to value of I. Add left side of first value.
		set a, ex
		add a, [z+3]
		;Store overflow in I
		set i, ex
		;Add left side of second value.
		add a, [z+1]
		;Store A back in [Z+3]
		set [z+3], a

		;Check overflows, and set EX accordingly.
		ife i, 1
			set pc, dword_add_i_overflow
		set pc, dword_add_exit

		:dword_add_i_overflow
			set ex, 1
			set pc, dword_add_exit

	:dword_add_exit
	set i, pop
	set a, pop
	set z, pop
	set pc, pop

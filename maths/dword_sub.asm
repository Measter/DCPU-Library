; --------------------------------------------
; Title:   DWard Maths - Subtraction Module
; Author:  Measter
; Date:    02/11/2012
; Version: 1.0a
; --------------------------------------------

; Subtracts two 32-bit numbers. Big Endian.
; Input
; SP+3			: Left half of first value.
; SP+2			: Right half of first value.
; SP+1			: Left half of second value.
; SP+0			: Right half of second value.

; Output
; SP+2			: Right half of result.
; SP+3			: Left half of result.
; EX			: Same result as expected from SUB.
:dword_sub
	set push, z
	set z, sp
	add z, 2
	set push, a

		;Set A to right half of first value.
		;Subtract right half of second value.
		set a, [z+2]
		sub a, [z+0]
		;Store A back in [Z+2].
		set [z+2], a

		;Set A to value of I, then add left half of first value.
		;This will account for the underflow of right side calc.
		set a, ex
		add a, [z+3]
		sub a, [z+1]
		;Store A back in [Z+3]
		set [z+3], a

	set a, pop
	set z, pop
	set pc, pop
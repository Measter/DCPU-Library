; --------------------------------------------
; Title:   DWard Maths - Multiplication Module
; Author:  Measter
; Date:    2013/10/29
; --------------------------------------------

; Revisions
; 1  :  Initial Release.
; 2  :  Added macro.

.macro dword_mul ( fir1, fir2, sec1, sec2, res1, res2 )
	set push, fir1
	set push, fir2
	set push, sec1
	set push, sec2
		jsr dword_mul_func
	set res2, pop 	; Clear stack without adding.
	set res2, pop   ; Clear stack without adding.
	set res2, pop
	set res1, pop
.endmacro

; Multiplies two 32-bit numbers. Big Endian.
; Input
; SP+3			: Left half of first value.
; SP+2			: Right half of first value.
; SP+1			: Left half of second value.
; SP+0			: Right half of second value.

; Output
; SP+2			: Right half of result.
; SP+3			: Left half of result.
; EX			: Same result as expected from MUL.
:dword_mul_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, i
	set push, j

		;Set A to the right half of the first value.
		;Multiply by the left half of the second value.
		set a, [z+2]
		mul a, [z+1]
		;Push result and EX to stack for later.
		set push, a
		set push, ex

			;Set A to the right half of the first value.
			;Multiply by right half of second value.
			set a, [z+2]
			mul a, [z+0]

			;Store A back in [Z+2]
			set [Z+2], a
			;Store left side of result in I.
			set i, ex
		
			;Set A to left side of first value.
			;Multiply by right side of second value.
			;Store overflow in J.
			set a, [z+3]
			mul a, [z+0]
			add j, ex
			
		;Add to J the overflow from first calc.
		add j, pop
		;Add to A the result from earlier.
		add a, pop

		;Store A for later.
		set push, a

			;Set A to left side of first value.
			;Multiply by left side of second value.
			;Add overflow to J
			set a, [z+3]
			mul a, [z+1]
			add j, a
			;Set A to I.
			;If overflowed, add 1 to J.
			set a, i

		;Add pushed value to A.
		;If overflowed, add 1 to J
		add a, pop
		ifn ex, 0
			add j, 1

		;Store A in [Z+3].
		set [z+3], a

		set ex, j

	set j, pop
	set i, pop
	set a, pop
	set z, pop
	set pc, pop

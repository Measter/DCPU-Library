; --------------------------------------------
; Title:   MemFunctions
; Author:  Measter
; Date:    02/11/2012
; Version: 1.0a
; --------------------------------------------

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
:dword_add
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

; Divide a 32-bit by a 16-bit number.
; Input
; SP+2 			: Left half of first value.
; SP+1  		: Right half of first value.
; SP+0 			: Second Value.

; Output
; SP+1 			: Right half of result.
; SP+2 			: Left half of result.
; EX 			: Non-Zero indicates a remainder.
:dword_div
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
:dword_mul
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



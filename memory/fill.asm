; -----------------------
; Title: 	Memory Fill
; Author: 	Measter
; Date:		2013/10/29
; -----------------------

; Revisions
; 1  :  Initial Release.
; 2  :  Added macro.

.macro mem_fill ( start, val, len)
	set push, start
	set push, val
	set push, len
		jsr mem_fill_func
	add sp, 3
.endmacro

; Fills a section of memory with a given value.
; Input
; SP+2 		: Start location.
; SP+1 		: Value to fill.
; SP+0 		: Length of memory to copy.
:mem_fill_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, i
	set push, j

	set a, [z+0]
	set i, [z+1]
	set j, [z+2]
	; A = Length of memory.
	; I = Value.
	; J = Start location.

	ife a, 0
		set pc, .exit

	:.fill_loop_start
		set [j], i
	
		add j, 1
		sub a, 1
		ifg a, 0
			set pc, .fill_loop_start
	
	:.exit
	set j, pop
	set i, pop
	set a, pop
	set z, pop
	set pc, pop

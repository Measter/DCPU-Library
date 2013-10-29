; -----------------------
; Title: 	Memory Copy
; Author: 	Measter
; Date:		2013/10/29
; -----------------------

; Revisions
; 1  :  Initial Release.
; 2  :  Added macro.

.macro mem_copy ( source, dest, len )
	set push, source
	set push, dest
	set push, len
		jsr mem_copy_func
	add sp, 3
.endmacro

; Copies one section of memory to another.
; Takes no account of overlap.
; Input
; SP+2 		: Source location.
; SP+1 		: Destination.
; SP+0 		: Length of memory to copy.
:mem_copy_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, i
	set push, j

	set a, [z+0]
	set i, [z+1]
	set j, [z+2]
	; A = length of memory.
	; I = Destination.
	; J = Source.

	ife a, 0
		set pc, .exit

	:.copy_loop_start
		sti [i], [j]
	
		sub a, 1
		ifg a, 0
			set pc, .copy_loop_start
	
	:.exit
	set j, pop
	set i, pop
	set a, pop
	set z, pop
	set pc, pop

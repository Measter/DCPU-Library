; -----------------------
; Title: 	Random Number Generator.
; Author: 	Measter
; Date:		2013/12/05
; -----------------------

; Revisions
; 1  -  Initial release.
; 2  -  Only include dword_mul instead of entire maths library.
; 3  -  Added macros.
; 4  -  rand_range macro no longer uses the A register.

.include <maths/dword_mul.asm>

.macro set_seed(seed)
	set [rand_seed], seed
.endmacro
.macro rand(dest)
	jsr rand_func
	set dest, [rand_seed]
.endmacro
.macro rand_range(min, max, dest)
	sub sp, 1
		set [sp], max
		sub [sp], min
		rand(dest)
		mod dest, [sp]
		add dest, min
	add sp, 1
.endmacro

; Seed for the generator.
:rand_seed
	dat 0x1

; Generates a 16-bit random number.
; Input
;	[rand_seed] : Seed.
; Output
;	[rand_seed] : Result.
:rand_func
	set push, a
	set push, b

	dword_mul(0x015A, 0x4E35, 0x0000, [rand_seed], a, b)

	add b, 1
	ife ex, 0x1
		add a, 1

	and a, 0x7FFF
	set [rand_seed], a
	
	set b, pop
	set a, pop
	set pc, pop
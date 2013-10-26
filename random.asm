; -----------------------
; Title: 	Random Number Generator.
; Author: 	Measter
; Date:		14/09/13
; -----------------------

.include <dword_maths.asm>

; Seed for the generator.
:rand_seed
	dat 0x1

; Generates a 16-bit random number.
; Input
;	[rand_seed] : Seed.
; Output
;	[rand_seed] : Result.
:rand
	set push, a
	set push, b

	set push, 0x015A
	set push, 0x4E35
	set push, 0x0000
	set push, [rand_seed]
		jsr dword_mul
	add sp, 2
	set b, pop
	set a, pop

	add b, 1
	ife ex, 0x1
		add a, 1

	and a, 0x7FFF
	set [rand_seed], a
	
	set b, pop
	set a, pop
	set pc, pop
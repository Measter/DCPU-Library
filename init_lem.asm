; -----------------------
; Title: 	InitLem
; Author: 	Measter
; Date:		2013/10/25
; -----------------------

; Initialises the LEM1802 at the given port.
; Input
; SP+3 : Memory address of the font buffer. Set to 0x0 for default.
; SP+2 : Memory address of the palette buffer. Set to 0x0 for default.
; SP+1 : Memory address of the display buffer.
; SP+0 : Port number of the LEM.
:init_lem
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b

	set a, 0
	set b, [z+1]
	hwi [z]

	ife [z+2], 0x0
		set pc, .skip_palette

	set a, 2
	set b, [z+2]
	hwi [z]

	:.skip_palette

	ife [z+3], 0x0
		set pc, .end

	set a, 1
	set b, [z+3]
	hwi [z]

	:.end
	set b, pop
	set a, pop
	set z, pop
	set pc, pop
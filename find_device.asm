; --------------------------------------------
; Title:   Find Device
; Author:  Measter
; Date:    04/11/2012
; Version: 1.0
; --------------------------------------------

; Queries the hardware for the given ID
; Input
; SP+1		: ID Second Byte
; SP+0		: ID First Byte
; Output
; SP+0		: If found, returns address.
;			: If not found, returns 0xFFFF.
:find_device
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b
	set push, c
	set push, x
	set push, y
	set push, i
	
	hwn i
	
	:.find_loop
		sub i, 1
		hwq i
		ife a, [z]
			ife b, [z+1]
				set pc, .found_device
		
		ifn i, 0
			set pc, .find_loop
	
	set [z], 0xffff
	set pc, .exit
	
	:.found_device
	set [z], i	
	
	:.exit
	set i, pop
	set y, pop
	set x, pop
	set c, pop
	set b, pop
	set a, pop
	set z, pop
	set pc, pop
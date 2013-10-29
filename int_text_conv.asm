; -----------------------
; Title: 	Integer > Text Converter
; Author: 	Measter
; Date:	   2013/10/29
; -----------------------

; Revisions
; 1  :  Initial Release.
; 2  :  Generalised function.
; 3  :  Added macro.

.macro int_text_conv (buffer, value, base)
	set push, buffer
	set push, value
	set push, base
		jsr int_text_conv_func
	add sp, 3
.endmacro

; Converts a value to ASCII output.
; Maximum output is 5 digits.
; Output is 0-terminated.
; Input
; 	SP+2 : Buffer address to store output.
;	SP+1 : Value to convert.
; 	SP+0 : Base to convert to. Must be between 2 and 36.
:int_text_conv_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b
	set push, c
	set push, i

	ifl [z+0], 2
		set pc, .exit
	ifg [z+0], 36
		set pc, .exit
	
	set c, [z+0]
	set a, [z+1]
	set z, [z+2]
	; C = Base of output.
	; A = Value to convert.
	; Z = Buffer address.

	set i, 0
	; I = Number of digits.
	:.conv_loop_start
		set b, a
		mod b, c 	; Get right-most digit.
		div a, c 	; Remove right-most digit.

		; Output ASCII value.
		ifg b, 9
			set pc, .ten_plus

		:.ten_sub
		set [z], 0x30 	; Digit 0
		add [z], b
		set pc, .continue

		:.ten_plus
		set [z], 0x41 	; Capital A.
		sub b, 10
		add [z], b

		:.continue
		add i, 1
		add z, 1	
		ifg a, 0
			set pc, .conv_loop_start

	set [z], 0
	sub z, i 	; Back to start.
	add i, z 
	sub i, 1 	; I = End of string.

	:.invert_loop_start
		ifg z, i
			set pc, .exit
		ife z, i
			set pc, .exit
		set a, [z]
		set [z], [i]
		set [i], a

		add z, 1
		sub i, 1
		set pc, .invert_loop_start
	
	:.exit
	set i, pop
	set c, pop
	set b, pop
	set a, pop
	set z, pop
	set pc, pop

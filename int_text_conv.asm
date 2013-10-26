; -----------------------
; Title: 	Integer > Text Converter
; Author: 	Measter
; Date:		04/09/13
; -----------------------

; Converts a value to decimal ASCII output.
; Maximum output is 5 digits.
; Output is 0-terminated.
; Input
; 	SP+1 : Buffer address to store output.
;	SP+0 : Value to convert.
:int_dec_conv
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b
	set push, i
	
	set a, [z]
	set z, [z+1]
	; A = Value to convert.
	; Z = Buffer address.

	set i, 1
	; I = Number of digits.
	ifg a, 9
		set i, 2
	ifg a, 99
		set i, 3
	ifg a, 999
		set i, 4
	ifg a, 9999
		set i, 5
	add z, i
	; Z = Right most digit address.
	; Zero-terminate string.
	set [z], 0

	:.conv_loop_start
		sub i, 1
		sub z, 1

		set b, a
		mod b, 10

		; Output ASCII value.
		set [z], 0x30
		add [z], b
	
		div a, 10
		ifg i, 0
			set pc, .conv_loop_start
		:.conv_loop_exit

	set i, pop
	set b, pop
	set a, pop
	set z, pop
	set pc, pop

; Converts a value to Hex ASCII output.
; Output is 4 digits.
; Output is 0-terminated.
; Input
; 	SP+1 : Buffer address to store output.
;	SP+0 : Value to convert.
:int_hex_conv
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b
	set push, i
	
	set a, [z]
	set z, [z+1]
	; A = Value to convert.
	; Z = Buffer address.

	set i, 4
	add z, i
	; Z = Right most digit address.
	; Zero-terminate string.
	set [z], 0

	:.conv_loop_start
		sub i, 1
		sub z, 1

		set b, a
		and b, 0xF

		; Output ASCII value.
		ifl b, 0xA
			set pc, .no_hex

		:.hex
		set [z], 0x41
		mod b, 10
		set pc, .add_value

		:.no_hex
		set [z], 0x30

		:.add_value
		add [z], b

		shr a, 4
		ifg i, 0
			set pc, .conv_loop_start
		:.conv_loop_exit

	set i, pop
	set b, pop
	set a, pop
	set z, pop
	set pc, pop

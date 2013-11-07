; -----------------------
; Title: 	Console
; Author: 	Measter
; Date:		2013/10/29
; -----------------------

; Revisions
; 1  :  Initial Release.
; 2  :  Added support for arbitrary sizes.
; 3  :  Added macro.

.macro console_scroll_buffer ( pointer )
	set push, pointer
		jsr console_scroll_buffer_func
	add sp, 1
.endmacro
.macro console_write_line ( msg_ptr, cnsl_ptr)
	console_scroll_buffer(cnsl_ptr)
	set push, msg_ptr
	set push, cnsl_ptr
		jsr console_write_func
	add sp, 2
.endmacro
.macro console_write (msg_ptr, cnsl_ptr)
	set push, msg_ptr
	set push, cnsl_ptr
		jsr console_write_func
	add sp, 2
.endmacro

;LEM1802 Console data structure.
; +0 		: Port ID.
; +1 		: Display Buffer Address.
; +2 		: Foreground Colour.
; +3 		: Background Colour.
; +4 		: Blink.
; +5 		: Start line.
; +6 		: End line. Both this and the above are 0-indexed.
; +7 		: Line length.
; +8		: Column offset.

; Scrolls the lines of the buffer up by 1
; Input
; SP+0 			: Address to the console data struct.
:console_scroll_buffer_func
	set push, z
	set z, sp
	add z, 2
	set push, i
	set push, j
	set push, x
	set push, y

		set z, [z]

		set x, 0
		set y, [z+5]	; Y = Start line.
		set i, y
		mul i, 32 		; I = Offset of start line.
		add i, [z+1]	; Add buffer address.
		add i, [z+8] 	; Add column offset. I = Start of console.
		set j, i
		add j, 32
		; I = current line, J = next line.
		:.line_loop_start
			sti [i], [j]

			add x, 1
			;If not at end of line, restart loop.
			ifl x, [z+7]	; Line length check.
				set pc, .line_loop_start
			
			; Go to next line offsets.
			add y, 1
			ife y, [z+6]
				set pc, .line_loop_end

			set i, y
			mul i, 32
			add i, [z+1]	; Add buffer address.
			add i, [z+8]	; Add column offset. I = Offset of first line.
			set j, i
			add j, 32		; J = Offset of next line.
			set x, 0
			set pc, .line_loop_start
			:.line_loop_end

	set y, pop
	set x, pop
	set j, pop
	set i, pop
	set z, pop
	set pc, pop

; Writes the next line to the LEM buffer.
; Input
; SP+1 			: Address to the ASCII values of the next line.
;				: 0-terminated string.
; SP+0 			: Address to the console data struct.
:console_write_func
	set push, z
	set z, sp
	add z, 2
	set push, b
	set push, i
	set push, j
	set push, x
	set push, a

		set a, [z]
		; A = Console data struct address.

		; B = colour information.
		set b, [a+2]		; Foreground.
		shl b, 4
		bor b, [a+3]		; Background.
		shl b, 1
		bor b, [a+4]		; Blink
		shl b, 7

		set x, 0
		set i, 32
		mul i, [a+6]		; Find end line offset.
		add i, [a+1]		; Add buffer address.
		add i, [a+8]		; Add column offset. I = Start of end line.
		set j, [z+1]		; Output string address.
		:.char_loop_start
			ife [j], 0
				set pc, .char_loop_end

			sti [i], [j]
			bor [i-1], b

			add x, 1
			ifl x, [a+7] 	; End of line check.
				set pc, .char_loop_start
			:.char_loop_end

		ife x, [a+7]		; End of line check.
			set pc, .end

		:.clear_loop_start
			set [i], 32 	; Set character to Space.

			add i, 1
			add x, 1
			ifl x, [a+7]	; End of line check.
				set pc, .clear_loop_start
			:.clear_loop_exit

	:.end
	set a, pop
	set x, pop
	set j, pop
	set i, pop
	set b, pop
	set z, pop
	set pc, pop

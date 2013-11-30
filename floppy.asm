; -----------------------
; Title:	M35FD Driver.
; Author:	Measter
; Date:		2013-11-30
; -----------------------

; Revisions
; 1  :  Implemented reading from disk.

.include <maths/dword_div.asm>
.include <maths/dword_mul.asm>
.include <maths/dword_sub.asm>

.define DISK_ERROR_NONE 		0x0000
.define DISK_ERROR_BUSY			0x0001
.define DISK_ERROR_NO_MEDIA 	0x0002
.define DISK_ERROR_PROTECTED 	0x0003
.define DISK_ERROR_EJECT 		0x0004
.define DISK_ERROR_BAD_SECTOR 	0x0005
.define DISK_ERROR_BROKEN 		0xFFFF

.define DISK_STATE_NO_MEDIA 	0x0000
.define DISK_STATE_READY 		0x0001
.define DISK_STATE_READY_WP		0x0002
.define DISK_STATE_BUSY 		0x0003

.define 

.macro disk_read_data(port, f_ptr, s_ptr, dest_ptr, len, err)
	set push, port
	set push, f_ptr
	set push, s_ptr
	set push, dest_ptr
	set push, len
		jsr disk_read_data_func
	set err, pop
	add sp, 4
.endmacro

;Input
; +4 	: M35FD port.
; +3 	: First sector address word.
; +2 	: Second sector address word.
; +1 	: Memory pointer to read to.
; +0	: Length of data to read.
; Output
; +0 	: 0xFFFF if error, else 0.
:disk_read_data_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b
	set push, c
	set push, i
	set push, j
	set push, x
	set push, y

	; Poll state.
	set a, 0
	hwi [z+4]
	ifn c, DISK_ERROR_NONE
		set pc, .exit_error
	ife b, DISK_STATE_NO_MEDIA
		set pc, .exit_error

	:.busy_wait_one
		hwi [z+4]
		ife b, DISK_STATE_NO_MEDIA
			set pc, .exit_error
		ife b, DISK_STATE_BUSY
			set pc, .busy_wait_one

	; Find sector.
	dword_div([z+3], [z+2], 512, b, x)
	; X = Sector.

	; Find Offset.
	dword_mul(0x0, a, 0x0, 512, i, j)
	dword_sub([z+3], [z+2], i, j, j, i)
	; I = Offset from sector.

	; Read disk.
	set y, disk_buffer
	set a, 2
	hwi [z+4]

	ifn b, 1
		set pc, .exit_error 	; Isn't reading for some reason.

	:.busy_wait_two
		hwi [z+4]
		ife b, DISK_STATE_BUSY
			set pc, .busy_wait_two

	; Copy data from buffer to destination.
	set b, 0
	; B = Current copy amount.
	:.read_loop_start
		ife b, [z+0]
			set pc, .read_loop_exit
		
		set a, 512
		sub a, i
		; A = Difference between end of sector and current place.
		ifg a, 0
			set pc, .skip_read

		add x, 1
		; X = Sector.
		set push, b
			set a, 2
			hwi [z+4]
			ifn b, 1
				set pc, .exit_error 	; Error reading.

			:.busy_wait_three
				hwi [z+4]
				ife b, DISK_STATE_BUSY
					set pc, .busy_wait_three
		set b, pop
		set i, 0

		:.skip_read
		set a, i
		add a, disk_buffer
		; A = Read address in buffer.
		set j, [z+1]
		add j, b
		; J = Destination address.
		set [j], [a]

		add i, 1
		add b, 1	
		set pc, .read_loop_start
	:.read_loop_exit

	set b, 0
	set pc, .exit

	:.exit_error
	set [z+0], 0xFFFF

	:.exit
	set pop, y
	set pop, x
	set pop, j
	set pop, i
	set pop, c
	set pop, b
	set pop, a
	set z, pop
	set pc, pop

:disk_buffer
	.pad 512, 0
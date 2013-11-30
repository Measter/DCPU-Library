; -----------------------
; Title:	M35FD Driver.
; Author:	Measter
; Date:		2013-11-30
; -----------------------

; Revisions
; 1  :  Implemented reading from disk.
; 2  :  Moved calculation from disk_read_data_func to seperate
; 		function. disk_read_data_func now uses sector/offset.
; 3  :  Fixed error caused by forgetting to set A when polling.
; 4  :  Added error check during polling.
; 5  :  Added write function.

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

.macro disk_read_data(port, sector, offset, dest_ptr, len, err)
	set push, port
	set push, sector
	set push, offset
	set push, dest_ptr
	set push, len
		jsr disk_read_data_func
	set err, pop
	add sp, 4
.endmacro

.macro disk_write_data(port, sector, offset, read_ptr, len, err)
	set push, port
	set push, sector
	set push, offset
	set push, read_ptr
	set push, len
		jsr disk_write_data_func
	set err, pop
	add sp, 4
.endmacro

.macro disk_conv_ptr_sctr(addr1, addr2, sector, offset)
	set push, addr1
	set push, addr2
		jsr disk_conv_ptr_sctr_func
	set offset, pop
	set sector, pop
.endmacro

;Input
; +4 	: M35FD port.
; +3 	: Sector.
; +2 	: Sector offset.
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
	:.busy_wait_one
		hwi [z+4]
		ifn c, DISK_ERROR_NONE
			set pc, .exit_error
		ife b, DISK_STATE_NO_MEDIA
			set pc, .exit_error
		ife b, DISK_STATE_READY_WP
			set pc, .exit_error
		ife b, DISK_STATE_BUSY
			set pc, .busy_wait_one

	set x, [z+3]
	set i, [z+2]
	; X = Sector.
	; I = Offset from sector.

	; Read disk.
	set y, disk_buffer
	set a, 2
	hwi [z+4]

	ifn b, 1
		set pc, .exit_error 	; Isn't reading for some reason.

	set a, 0
	:.busy_wait_two
		hwi [z+4]
		ifn c, DISK_ERROR_NONE
			set pc, .exit_error
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
				set pc, .exit_error_rest_b 	; Error reading.

			set a, 0
			:.busy_wait_three
				hwi [z+4]
				ifn c, DISK_ERROR_NONE
					set pc, .exit_error_rest_b
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

	set [z+0], 0
	set pc, .exit

	:.exit_error_rest_b
	set b, pop
	:.exit_error
	set [z+0], 0xFFFF

	:.exit
	set y, pop
	set x, pop
	set j, pop
	set i, pop
	set c, pop
	set b, pop
	set a, pop
	set z, pop
	set pc, pop

;Input
; +4 	: M35FD port.
; +3 	: Sector.
; +2 	: Sector offset.
; +1 	: Memory pointer to read from.
; +0	: Length of data to read.
; Output
; +0 	: 0xFFFF if error, else 0.
:disk_write_data_func
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
	:.busy_wait_one
		hwi [z+4]
		ifn c, DISK_ERROR_NONE
			set pc, .exit_error
		ife b, DISK_STATE_NO_MEDIA
			set pc, .exit_error
		ife b, DISK_STATE_READY_WP
			set pc, .exit_error
		ife b, DISK_STATE_BUSY
			set pc, .busy_wait_one


	set x, [z+3]
	set i, [z+2]
	; X = Sector.
	; I = Offset from sector.

	; Read disk.
	set y, disk_buffer
	set a, 2
	hwi [z+4]

	ifn b, 1
		set pc, .exit_error 	; Isn't reading for some reason.

	set a, 0
	:.busy_wait_two
		hwi [z+4]
		ifn c, DISK_ERROR_NONE
			set pc, .exit_error
		ife b, DISK_STATE_BUSY
			set pc, .busy_wait_two

	; Copy data from buffer to destination.
	set b, 0
	; B = Current copy amount.
	:.write_loop_start
		ife b, [z+0]
			set pc, .write_loop_exit
		
		set a, 512
		sub a, i
		; A = Difference between end of sector and current place.
		ifg a, 0
			set pc, .skip_read


		set push, b
			; Write current sector.
			set a, 3
			hwi [z+4]

			set a, 0
			:.busy_wait_four
				hwi [z+4]
				ifn c, DISK_ERROR_NONE
					set pc, .exit_error_rest_b
				ife b, DISK_STATE_BUSY
					set pc, .busy_wait_four

			; Read next sector.
			add x, 1
			; X = Sector.
			set a, 2
			hwi [z+4]
			ifn b, 1
				set pc, .exit_error_rest_b 	; Error reading.

			set a, 0
			:.busy_wait_three
				hwi [z+4]
				ifn c, DISK_ERROR_NONE
					set pc, .exit_error_rest_b
				ife b, DISK_STATE_BUSY
					set pc, .busy_wait_three
		set b, pop
		set i, 0

		:.skip_read
		set a, i
		add a, disk_buffer
		; A = Write address in buffer.
		set j, [z+1]
		add j, b
		; J = Source address.
		set [a], [j]

		add i, 1
		add b, 1	
		set pc, .write_loop_start
	:.write_loop_exit

	set a, 3
	hwi [z+4]

	set a, 0
	:.busy_wait_five
		hwi [z+4]
		ifn c, DISK_ERROR_NONE
			set pc, .exit_error
		ife b, DISK_STATE_BUSY
			set pc, .busy_wait_five

	set [z+0], 0
	set pc, .exit

	:.exit_error_rest_b
	set b, pop
	:.exit_error
	set [z+0], 0xFFFF

	:.exit
	set y, pop
	set x, pop
	set j, pop
	set i, pop
	set c, pop
	set b, pop
	set a, pop
	set z, pop
	set pc, pop

;Input
; +1 	: Left side of address pointer.
; +0 	: Right side of address pointer.
;Output
; +1 	: Sector.
; +0 	: Sector offset.
:disk_conv_ptr_sctr_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b
	set push, c

	; Find sector.
	dword_div([z+1], [z+0], 512, a, b)
	; B = Sector.

	; Find offset.
	dword_mul(0x0, b, 0x0, 512, a, c)
	dword_sub([z+1], [z+0], a, c, c, a)
	; A = Offset.

	set [z+1], b
	set [z+0], a

	set c, pop
	set b, pop
	set a, pop
	set z, pop
	set pc, pop

:disk_buffer
	.pad 512, 0

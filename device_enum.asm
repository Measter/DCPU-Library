; --------------------------------------------
; Title:   Device Enumerator
; Author:  Measter
; Date:    04/11/2012
; Version: 1.0
; --------------------------------------------

.include <memory/alloc.asm>

; Device structure definition.
; +0+	: Type ID.
; +1~ 	: Port numbers.

; Type IDs
; 0: Clock 				: 0x12d0, 0xb402
; 1: M35FD Disk Drive 	: 0x4fd5, 0x24c5
; 2: Keyboard 			: 0x30cf, 0x7406
; 3: LEM1802 			: 0x7349, 0xf615
; 4: SPED-3 			: 0x42ba, 0xbf3c
; -1: Unknown

; Goes through the connected hardware, and provides
; a list of device types, with ports.
; Input
; 	SP+1 : Second ID byte.
;	SP+0 : First ID byte.
; Output
;	SP+0 : Address of the list. 0xFFFF if error.
:enum_devices
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b
	set push, c
	set push, i
	set push, j
	set push, y
	set push, x
		
		; Get number of connected devices.
		hwn i
		ife i, 0
			set pc, .error

		set j, 0

		:.find_loop
			sub i, 1
			hwq i
			ifn b, [z]
				set pc, .next_device
			ifn a, [z+1]
				set pc, .next_device

			; Device found.
			set push, i
			add j, 1

			:.next_device
			ifn i, 0
				set pc, .find_loop

		ife j, 0
			set pc, .error
		; Allocate list.
		set a, j
		add a, 2
		; A = Space needed.
		set push, a
			jsr mem_alloc
		set a, pop

		; Set Type ID. See above table.
		:.type_id_table
			set [a], 0xFFFF			; Unknown
			ife [z], 0x12d0
				ife [z+1], 0xb402
					set [a], 0 		; Clock
			ife [z], 0x4fd5
				ife [z+1], 0x24c5
					set [a], 1 		; M35FD
			ife [z], 0x30cf
				ife [z+1], 0x7406
					set [a], 2 		; Keyboard
			ife [z], 0x7349
				ife [z+1], 0xf615
					set [a], 3 		; LEM1802
			ife [z], 0x42ba
				ife [z+1], 0xbf3c
					set [a], 4 		; SPED-3
		
		; Number of devices.
		set [a+1], j

		set i, 0
		set b, a
		add b, 2
		:.make_list_loop_start
			set [b], pop
		
			add i, 1
			add b, 1
			ifl i, j
				set pc, .make_list_loop_start
			:.make_list_loop_exit

		set [z], a
		set pc, .end
		:.error
			set [z], 0xFFFF
			set pc, .end

	:.end
	set x, pop
	set y, pop
	set j, pop
	set i, pop
	set c, pop
	set b, pop
	set a, pop
	set z, pop
	set pc, pop

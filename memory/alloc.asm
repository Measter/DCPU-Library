; --------------------------------------------
; Title:   Memory Alloc
; Author:  Measter
; Date:    2013/10/29
; --------------------------------------------

; Revisions
; 1  :  Initial Release.
; 2  :  Removed use of memory_end.asm
; 3  :  Added macros.

.macro set_heap(ptr)
	set [mem_start], ptr
.endmacro
.macro mem_alloc ( size, dest )
	set push, size
		jsr mem_alloc_func
	set dest, pop
.endmacro
.macro mem_free ( ptr )
	set push, ptr
		jsr mem_free_func
	set ptr, pop
.endmacro

;Allocated memory header definition.
; +0 		:  Magic number. (0x6D61)
; +1 		:  Previous cluster memory address. Values is 0xFFFF for first cluster.
; +2 		:  Next cluster memory address. Value is 0xFFFF for last cluster.
; +3 		:  Size of cluster in words.
; +4-Length :  Area to be used by the program.

;Area of memory reserved for stack.
:mem_stack_reserve
	dat 0x1000
;First cluster address.
:mem_first_alloc
	dat 0xFFFF
;The start of the available memory.
:mem_start
	dat 0

;Allocate an area of memory.
;Input
; SP+0 : Size of memory to allocate.
;Output
; SP+0 : Memory address. 0xFFFF if out of memory.
:mem_alloc_func
	set push, z
	set z, sp
	add z, 2
	set push, i
	set push, j
	set push, a
	set push, b
	set push, y
		
		set y, [mem_start]
		set i, [z]
		add i, 4
		; I = Total size of space needed.

		; J = Address of first list entry.
		set j, [mem_first_alloc]

		; If mem_first_alloc is 0, then it's the first allocation. 
		ife j, 0xFFFF
			set pc, .alloc_at_start
		ife j, y
			set pc, .search_tree

		;Check if space at beginning of memory is enough.
		set a, j
		sub a, y
		ifg i, a
			set pc, .search_tree

		:.alloc_at_start
			; Allocate at beginning of heap.
			set [mem_first_alloc], y
			set [y], 0x6D61 	; Magic number.
			set [y+1], 0xFFFF	; Now first in list, so no prev.
			set [y+2], j 		; Address of next in list.
			set [y+3], [z]		; Size of cluster.

			ifn j, 0xFFFF
				set [j+1], y	; "Previous" link of the now second entry.
			set [z], y
			add [z], 4
			set pc, .exit

		:.alloc_at_end
			set a, j
			add a, 4
			add a, [j+3]
			; A = End of J.
			set b, 0xFFFF
			sub b, [mem_stack_reserve]
			sub b, a
			; B = Total remaining space between J and stack reserve.
			ifg b, i
				set pc, .skip_error
			set [z], 0xFFFF
			set pc, .exit

			:.skip_error
				set [a], 0x6D61			; Magic number.
				set [a+1], j 			; Previous list item.
				set [a+2], 0xFFFF		; Last in list, so 0xFFFF
				set [a+3], [z]			; Size of cluster.

				set [j+2], a 			; List item's "Next" pointer.

				add a, 4
				set [z], a
				set pc, .exit

		:.insert
			set a, [j+2]
			; J = Current list item header address.
			; A = Next list item header address.
			set b, j
			add b, 4
			add b, [j+3]
			; B = End of J.
			set [b], 0x6D61				; Magin number.
			set [b+1], j 				; Previous list item.
			set [b+2], a 				; Next list item.
			set [b+3], [z]				; Size of cluster.

			set [a+1], b 				; Next item's "Previous" pointer.

			add b, 4
			set [z], b
			set pc, .exit

		:.search_tree
			set a, [j+2]
			; J = Current list item header address.
			; A = Next list item header address.
			ife a, 0xFFFF
				set pc, .alloc_at_end	; Last item in list.

			set b, j
			add b, 4
			add b, [j+3]		; B = End of J
			sub a, b 			; A = Space between end of J and start of next item.
			
			ifg a, i
				set pc, .insert

			set j, [j+2]
			set pc, .search_tree
		:.search_loop_exit


	:.exit
	set y, pop
	set b, pop
	set a, pop
	set j, pop
	set i, pop
	set z, pop
	set pc, pop

;De-allocate an area of memory.
;Input
; SP+0 : Address of memory to free.
;Output
; SP+0 : 0x0000 if all went well, 0xFFFF if error.
:mem_free_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b

	set a, [z]
	sub a, 4		; A = Beginning of cluster.
	
	ifn [a], 0x6D61
		set pc, .error

	ife [a+1], 0xFFFF
		ife [a+2], 0xFFFF
			set pc, .start_end_case
	ife [a+1], 0xFFFF
		set pc, .start_case
	ife [a+2], 0xFFFF
		set pc, .end_case

	:.middle_case
		set [a], 0x6672
		set b, [a+2]	; B = Next cluster address.
		set a, [a+1]	; A = Previous cluster address.
		set [a+2], b
		set [b+1], a

		set pc, .no_error

	:.start_end_case
		set [a], 0x6672
		set [mem_first_alloc], 0xFFFF
		set pc, .no_error

	:.start_case
		set [a], 0x6672
		set b, [a+2]	; B = Next cluster address.
		set [mem_first_alloc], b
		set [b+1], 0xFFFF
		set pc, .no_error

	:.end_case
		set [a], 0x6672
		set b, [a+1]	;B = Previous cluster address.
		set [b+2], 0xFFFF
		set pc, .no_error

	:.no_error
		set [z], 0x0000
		set pc, .exit
	:.error
		set [z], 0xFFFF
	:.exit
	set b, pop
	set a, pop
	set z, pop
	set pc, pop

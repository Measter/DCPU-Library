; -----------------------
; Title: 	Queue
; Author: 	Measter
; Date:	    2013/10/29
; -----------------------

; Revisions
; 1  :  Initial Release.
; 2  :  Added macro.

.include <memory/alloc.asm>

.macro create_queue(dest)
	set push, 0
		jsr create_queue_func
	set dest, pop
.endmacro
.macro delete_queue (ptr)
	set push, ptr
		jsr delete_queue_func
	set ptr, pop
.endmacro
.macro pop_queue (queue_ptr, data)
	set push, queue_ptr
		jsr pop_queue_func
	set data, pop
.endmacro
.macro push_queue (queue_ptr, data, err)
	set push, queue_ptr
	set push, data
		jsr push_queue_func
	set err, pop
.endmacro

; Queue Header Structure.
; +0		: Number of items in queue.
; +1 		: First item in queue. Null address is 0xFFFF.
; +2 		: Last item in queue. Null address is 0xFFFF.

; Queue Item Structure.
; +0 		: Next item in queue.
; +1 		: Data.

; Creates a new Queue, and returns the header address.
; Input
; SP+0 		: None.
; Output
; SP+0 		: Address of queue header. Will return 0xFFFF on error.
:create_queue_func
	set push, z
	set z, sp
	add z, 2
	
	; Memory for header.
	mem_alloc(0x3, [z])
	set z, [z]	; Z = address of queue header.

	; Unable to allocate.
	ife z, 0xFFFF
		set pc, .exit

	set [z], 0
	set [z+1], 0xFFFF
	set [z+2], 0xFFFF

	:.exit
	set z, pop
	set pc, pop

; Deletes a queue.
; Input
; SP+0 		: Address of header.
; Output
; SP+0 		: 0xFFFF if error, else 0x0.
:delete_queue_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b

	set a, [z]
	ife [a+0], 0
		set pc, .delete_header

	; Delete contents.
	:.empty_loop_start
		pop_queue (a, b)
		ifg [a+0], 0
			set pc, .empty_loop_start
		:.empty_loop_exit

	:.delete_header
	mem_free (a)
	set [z], a

	set b, pop
	set a, pop
	set z, pop
	set pc, pop

; Dequeues an item.
; Input
; SP+0 		: Queue header.
; Output
; SP+0 		: Data.
:pop_queue_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b

	set a, [z] 	; A = queue header.
	ife [a+0], 0
		set pc, .exit 	; Empty queue.

	set b, [a+1];		; B = next item.
	set [z], [b+1] 		; Return data.

	; Deallocate.
	set [a+1], [b+0]	; Set next link.
	sub [a+0], 1 		; Decrement count.

	ife [a+2], b
		set [a+2], 0xFFFF	; If last item, null last link.

	mem_free (b)

	:.exit
	set b, pop
	set a, pop
	set z, pop
	set pc, pop

; Enqueue an item.
; Input
; SP+1 		: Queue Header.
; SP+0 		: Data to queue.
; Output
; SP+0 		: 0xFFFF if error, else 0x0.
:push_queue_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, i
	set push, x

	set i, [z+1] 		; I = queue header.
	
	mem_alloc(2, a) ; A = new item.

	ifn a, 0xFFFF
		set pc, .no_error
	set [z], 0xFFFF
	set pc, .exit

	:.no_error
	set [a+0], 0xFFFF ; Null last link.
	set [a+1], [z]	; Set data.
	
	ifn [i+0], 0 	; Count
		set pc, .last_item

	; First item.
	set [i+1], a
	set [i+2], a
	set pc, .exit_no_error

	:.last_item
	set x, [i+2]	; Last item.
	set [x+0], a 	; Next link.
	set [i+2], a 	; Last link.

	:.exit_no_error
	add [i+0], 1 	; Increment count.
	set [z], 0x0
	:.exit
	set x, pop
	set i, pop
	set a, pop
	set z, pop
	set pc, pop

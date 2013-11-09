; -----------------------
; Title: 	Date Functions.
; Author: 	Measter
; Date:		2013/11/09
; -----------------------

; Revisions
; 1  :  Initial Release.

.macro date_from_ordinal (day_num, is_leap, d_dest, m_dest)
	set push, day_num
	set push, is_leap
		jsr date_from_ordinal_func
	set d_dest, pop
	set m_dest, pop
.endmacro
.macro date_to_ordinal (day, month, is_leap, dest)
	set push, day
	set push, month
	set push, is_leap
		jsr date_to_ordinal_func
	set dest, pop
	add sp, 2
.endmacro
.macro date_is_leap_year(year_val, dest)
	set push, year_val
		jsr date_is_leap_year_func
	set dest, pop
.endmacro

.macro get_month_string (id)
	mul id, 10
	add id, date_month_strings
.endmacro
.macro get_short_month_string (id)
	mul id, 4
	add id, date_short_month_strings
.endmacro

; Input
; +1 	: Ordinal Day.
; +0 	: Is leap year.
; Output
; +1 	: Month ID.
; +0 	: Day of month.
:date_from_ordinal_func
	set push, z
	set z, sp
	add z, 2
	set push, b
	set push, a
	set push, i

	set b, [z+1]
	; B = Day of year.
	set a, date_month_amounts
	ifg [z], 0
		set a, date_month_leap_amounts

	set i, 0
	:.find_loop_start
		ifg [a], b
			set pc, .find_loop_exit
		ife [a], b
			set pc, .find_loop_exit
		add a, 1
		add i, 1
		set pc, .find_loop_start
	:.find_loop_exit

	sub a, 1 	; Correct fencepost error.
	sub i, 1
	sub b, [a]

	set [z], b
	set [z+1], i

	set i, pop
	set a, pop
	set b, pop
	set z, pop
	set pc, pop

; Input
; +2 	: Day.
; +1 	: Month ID.
; +0 	: Is leap year.
; Output
; +0 	: Ordinal Day.
:date_to_ordinal_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b

	set a, date_month_amounts
	ifg [z], 0
		set a, date_month_leap_amounts

	add a, [z+1]
	set b, [z+2]
	add b, [a]

	set [z], b

	set b, pop
	set a, pop
	set z, pop
	set pc, pop

; Input
; +0 	: Year.
; Output
; +0 	: 1 if leap year, else 0.
:date_is_leap_year_func
	set push, z
	set z, sp
	add z, 2
	set push, a

	set a, [z]
	mod a, 400
	ife a, 0
		set pc, .is_leap

	set a, [z]
	mod a, 100
	ife a, 0
		set pc, .not_leap

	set a, [z]
	mod a, 4
	ife a, 0
		set pc, .is_leap

	:.not_leap
	set [z], 0
	set pc, .end

	:.is_leap
	set [z], 1

	:.end
	set a, pop
	set z, pop
	set pc, pop

:date_month_amounts
	dat 0,31,59,90,120,151,181,212,243,273,304,334
:date_month_leap_amounts
	dat 0,31,60,91,121,152,182,213,244,274,305,335

:date_month_strings
	.asciiz "January"
	.pad 2, 0
	.asciiz "February"
	.pad 1, 0
	.asciiz "March"
	.pad 4, 0
	.asciiz "April"
	.pad 4, 0
	.asciiz "May"
	.pad 6, 0
	.asciiz "June"
	.pad 5, 0
	.asciiz "July"
	.pad 5, 0
	.asciiz "August"
	.pad 3, 0
	.asciiz "September"
	.asciiz "October"
	.pad 2, 0
	.asciiz "November"
	.pad 1, 0
	.asciiz "December"
	.pad 1, 0

:date_short_month_strings
	.asciiz "JAN"
	.asciiz "FEB"
	.asciiz "MAR"
	.asciiz "APR"
	.asciiz "MAY"
	.asciiz "JUN"
	.asciiz "JUL"
	.asciiz "AUG"
	.asciiz "SEP"
	.asciiz "OCT"
	.asciiz "NOV"
	.asciiz "DEC"

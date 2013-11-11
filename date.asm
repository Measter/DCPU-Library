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
.macro date_get_day( year_val, day_val, is_leap, dest)
	set push, year_val
	set push, day_val
	set push, is_leap
		jsr date_get_day_func
	set dest, pop
	add sp, 2
.endmacro
.macro date_get_ordinal_suffix (day, dest)
	set push, day
		jsr date_get_ordinal_suffix_func
	set dest, pop
.endmacro

.macro get_month_string (id)
	sub id, 1
	mul id, 10
	add id, date_month_strings
.endmacro
.macro get_short_month_string (id)
	sub id, 1
	mul id, 4
	add id, date_short_month_strings
.endmacro
.macro get_day_string (id)
	mul id, 10
	add id, date_day_strings
.endmacro

; Input
; +1 	: Ordinal Day.
; +0 	: Is leap year.
; Output
; +1 	: Month.
; +0 	: Day of month.
:date_from_ordinal_func
	set push, z
	set z, sp
	add z, 2
	set push, b
	set push, a
	set push, i

	set b, [z+1]
	ife [z], 0
		ifg b, 365
			set b, 365
	ifg [z], 0
		ifg b, 366
			set b, 366

	; B = Day of year.
	set a, date_month_amounts
	ifg [z], 0
		set a, date_month_leap_amounts

	set i, 0
	:.find_loop_start
		ife i, 12 	; December.
			set pc, .find_loop_exit
		ifg [a], b
			set pc, .find_loop_exit
		ife [a], b
			set pc, .find_loop_exit
		add a, 1
		add i, 1
		set pc, .find_loop_start
	:.find_loop_exit

	sub a, 1 	; Correct fencepost error.
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
; +1 	: Month.
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

	set b, [z+1]
	sub b, 1
	add a, b
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

; Input
; +2 	: Year.
; +1 	: Ordinal Day.
; +0 	: Is leap year.
; Output
; +0 	: Day ID.
:date_get_day_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, b
	set push, c
	
	; Find anchor day.
	set b, [z+2]
	div b, 100
	mod b, 4
	mul b, 5
	mod b, 7
	add b, 2
	; B = Anchor day.

	; Find doomsday. Uses Odd+11 method.
	set a, [z+2]
	mod a, 100
	set c, a
	mod c, 2
	ife c, 1
		add a, 11
	div a, 2
	set c, a
	ife c, 1
		add a, 11
	mod a, 7
	set c, 7
	sub c, a
	set a, b
	add a, c
	mod a, 7
	; A = Doomsday.

	set c, 59
	ife [z+0], 1
		set c, 60
	; C = Last day of February.

	set b, [z+1]
	ifl b, c
		set pc, .less

	ifg b, c
		sub b, c
	ife b, c
		sub b, c

	set pc, .calc_day

	:.less
		sub c, b
		set b, c

	:.calc_day
	add b, a
	mod b, 7

	set [z], b

	set c, pop
	set b, pop
	set a, pop
	set z, pop
	set pc, pop

; Input
; +0 	: Day.
; Output
; +0 	: Suffix Pointer.
:date_get_ordinal_suffix_func
	set push, z
	set z, sp
	add z, 2
	set push, a

	set a, [z]

	ife a, 11
		set pc, .first
	ife a, 12
		set pc, .first
	ife a, 13
		set pc, .first

	mod a, 10

	set [z], 0
	ife a, 1
		set [z], 1
	ife a, 2
		set [z], 2
	ife a, 3
		set [z], 3

	set pc, .after

	:.first
	set [z], 0

	:.after
	mul [z], 3
	add [z], date_ordinal_suffix
	
	set a, pop
	set z, pop
	set pc, pop

:date_month_amounts
	dat 0,31,59,90,120,151,181,212,243,273,304,334
:date_month_leap_amounts
	dat 0,31,60,91,121,152,182,213,244,274,305,335

:date_ordinal_suffix
	.asciiz "th"
	.asciiz "st"
	.asciiz "nd"
	.asciiz "rd"

:date_day_strings
	.asciiz "Sunday"
	.pad 3, 0
	.asciiz "Monday"
	.pad 3, 0
	.asciiz "Tuesday"
	.pad 2, 0
	.asciiz "Wednesday"
	.asciiz "Thursday"
	.pad 1, 0
	.asciiz "Friday"
	.pad 3, 0
	.asciiz "Saturday"
	.pad 1, 0

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

; -----------------------
; Title: 	Date Functions.
; Author: 	Measter
; Date:		2013/11/09
; -----------------------

; Revisions
; 1  :  Initial Release.
; 2  :  Added date_get_day, date_get_ordinal_suffix.
; 3  :  moved date_get_ordinal_suffix to int_text_conv.asm
; 4  :  Added calendar drawing.
; 5  :  Fixed error in month length selection.

.include <int_text_conv.asm>

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
.macro date_draw_calendar( x_val, y_val, buffer_ptr, year_val, month_val )
	set push, x_val
	set push, y_val
	set push, buffer_ptr
	set push, year_val
	set push, month_val
		jsr date_draw_calendar_func
	add sp, 5
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
; +4 	: X Coordinate.
; +3 	: Y Coordinate.
; +2 	: Buffer Address.
; +1 	: Year.
; +0 	: Month.
:date_draw_calendar_func
	set push, z
	set z, sp
	add z, 2
	set push, a
	set push, x
	set push, y
	set push, c
	set push, i
	set push, j
	set push, b

	set a, [z+2]
	set x, [z+4]
	set y, [z+3]
	; A = Buffer address.
	; X = X Coordinate.
	; Y = Y Coordinate.

	; Clear area.
	set i, 0
	:.x_clear_loop_start
		set j, 0
		:.y_clear_loop_start
			set c, j
			add c, y
			; C = Y Coordinate.
			mul c, 32
			; C = Offset of column.
			add c, i
			add c, x
			; C = Offset of first character.

			add c, a
			set [c], 0x0000
		
			add j, 1
			ifl j, 9
				set pc, .y_clear_loop_start
	
		add i, 1
		ifl i, 20
			set pc, .x_clear_loop_start

	sub sp, 6
		; Draw year.
		int_text_conv(sp, [z+1], 10)


		set c, y
		mul c, 32
		add c, x
		add c, a
		add c, 8  ; Middle of area.
		set i, sp
		:.year_loop_start
			ife [i], 0
				set pc, .year_loop_exit
			
			set [c], [i]
			bor [c], 0xF000
		
			add i, 1
			add c, 1
			set pc, .year_loop_start
		:.year_loop_exit
	add sp, 6

	; Draw month.
	set j, [z]
	sub j, 1
	add j, date_month_name_lengths
	set j, [j]
	; J = Month name length
	set i, j
	shr i, 1
	; I = Half of name length.

	set c, y
	add c, 1
	mul c, 32
	add c, x
	add c, a
	add c, 10
	sub c, i
	; C = Start of name location.
	add j, c
	; J = End of name location.
	set b, [z]
	get_month_string(b)
	; B = Start of month name string.
	:.month_draw_loop_start
		ife c, j
			set pc, .month_draw_loop_exit
		
		set [c], [b]
		bor [c], 0xF000
	
		add c, 1
		add b, 1
		set pc, .month_draw_loop_start
	:.month_draw_loop_exit

	; Draw day labels.
	set c, y
	add c, 2
	mul c, 32
	add c, x
	add c, a
	; C = Start of day label location.
	set j, date_calendar_days
	; J = Label strings.
	set i, 0
	:.day_labels_draw_loop_start
		ife [j], 0
			set pc, .day_labels_draw_loop_exit
		
		set [c], [j]
		bor [c], 0xF000
	
		add j, 1
		add c, 1
		set pc, .day_labels_draw_loop_start
	:.day_labels_draw_loop_exit

	; Day numbers.
	date_is_leap_year([z+1], b)
	date_to_ordinal(1, [z+0], b, i)
	date_get_day([z+1], i, b, i)
	; I = Day ID.
	set c, [z]
	sub c, 1
	add c, date_month_lengths
	set c, [c]
	ife [z], 2
		ife b, 1 	; If leap year and February.
			add c, 1

	; C = Length of month.
	add y, 3
	mul y, 32
	add y, a
	; Y = Line to write to.
	set j, 0
	; J = Current day.
	:.days_loop_start
		set b, i
		mul b, 3
		; B = Column offset of day.

		set a, y
		add a, x
		add a, b
		; A = Write offset.

		; Write right digit.
		set b, j
		add b, 1
		mod b, 10
		; B = Right digit.
		add b, '0'
		bor b, 0xF000
		set [a+1], b

		; Write left digit.
		set b, j
		add b, 1
		div b, 10

		ife b, 0
			set pc, .skip_right
		add b, '0'
		bor b, 0xF000
		set [a], b

		.skip_right:
	
		add j, 1
		
		add i, 1
		ifl i, 7
			set pc, .next
		mod i, 7
		add y, 32 	; Next row.

		.next:
		ifl j, c
			set pc, .days_loop_start

	set b, pop
	set j, pop
	set i, pop
	set c, pop
	set y, pop
	set x, pop
	set a, pop
	set z, pop
	set pc, pop

:date_month_amounts
	dat 0,31,59,90,120,151,181,212,243,273,304,334
:date_month_leap_amounts
	dat 0,31,60,91,121,152,182,213,244,274,305,335

:date_calendar_days
	.asciiz "Su Mo Tu We Th Fr Sa"
:date_month_name_lengths
	.dat 7, 8, 5, 5, 3, 4, 4, 6, 9, 7, 8, 8
:date_month_lengths
	.dat 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31

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

;GoldOS 4.0 Interrupts
;
;Roy Procell
;7/21/2015
;
;This is where we have the interrupts for user programs.
;Input for specifying functions will most likely be DI.
;
;

;Text mode graphics
intF1h_enter:
	cmp di, 00h
	je .00
	cmp di, 01h
	je .01
	cmp di, 02h
	je .02
	cmp di, 03h
	je .03
	cmp di, 04h
	je .04
	cmp di, 05h
	je .05
	cmp di, 06h
	je .06
	cmp di, 07h
	je .07
	cmp di, 08h
	je .08
	cmp di, 09h
	je .09
	cmp di, 0Ah
	je .0A
	cmp di, 0Bh
	je .0B
	cmp di, 0Ch
	je .0C
	cmp di, 0Dh
	je .0D
	cmp di, 0Eh
	je .0E
	stc
	iret
.00:
	call os_set_video_mode
	iret
.01:
	call os_get_video_mode
	iret
.02:
	call os_move_cursor
	iret
.03:
	call os_get_cursor
	iret
.04:
	call os_set_cursor_visible
	iret
.05:
	call os_set_cursor_invisible
	iret
.06:
	call os_set_cursor_full
	iret
.07:
	call os_set_cursor_bar
	iret
.08:
	call os_disable_blinking
	iret
.09:
	call os_enable_blinking
	iret
.0A:
	call os_clear_screen
	iret
.0B:
	call os_set_background
	iret
.0C:
	call os_draw_border
	iret
.0D:
	call os_draw_bar
	iret
.0E:
	call os_draw_box
	iret

;Graphics mode primitives
intF2h_enter:
	cmp di, 00h
	je .00
	cmp di, 01h
	je .01
	cmp di, 02h
	je .02
	cmp di, 03h
	je .03
	cmp di, 04h
	je .04
	cmp di, 05h
	je .05
	cmp di, 06h
	je .06
	cmp di, 07h
	je .07
	stc
	iret
.00:
	call os_draw_pixel
	iret
.01:
	call os_get_pixel
	iret
.02:
	call os_clear_screen_gfx
	iret
.03:
	call os_draw_line_gfx
	iret
.04:
	call os_draw_triangle_gfx
	iret
.05:
	call os_draw_box_gfx
	iret
.06:
	call os_draw_rect_gfx
	iret
.07:
	call os_draw_icon
	iret

;Keyboard services
intF3h_enter:
	cmp di, 00h
	je .00
	cmp di, 01h
	je .01
	stc
	iret
.00:
	call os_wait_for_key
	iret
.01:
	call os_check_for_key
	iret
	
;String services
intF4h_enter:
	cmp di, 00h
	je .00
	cmp di, 01h
	je .01
	cmp di, 02h
	je .02
	cmp di, 03h
	je .03
	cmp di, 04h
	je .04
	cmp di, 05h
	je .05
	cmp di, 06h
	je .06
	cmp di, 07h
	je .07
	cmp di, 08h
	je .08
	cmp di, 09h
	je .09
	cmp di, 0Ah
	je .0A
	cmp di, 0Bh
	je .0B
	cmp di, 0Ch
	je .0C
	cmp di, 0Dh
	je .0D
	cmp di, 0Eh
	je .0E
	cmp di, 0Fh
	je .0F
	cmp di, 10h
	je .10
	cmp di, 11h
	je .11
	cmp di, 12h
	je .12
	stc
	iret
.00:
	call os_print_string
	iret
.01:
	call os_print_char
	iret
.02:
	call os_print_new_line
	iret
.03:
	call os_convert_string_upper
	iret
.04:
	call os_convert_string_lower
	iret
.05:
	call os_string_to_int
	iret
.06:
	call os_int_to_string
	iret
.07:
	call os_hex_to_int
	iret
.08:
	call os_int_to_hex
	iret
.09:
	call os_string_length
	iret
.0A:
	call os_string_truncate
	iret
.0B:
	call os_string_copy
	iret
.0C:
	call os_string_copy_num
	iret
.0D:
	call os_strcat
	iret
.0E:
	call os_strchr
	iret
.0F:
	call os_strcmp
	iret
.10:
	call os_print_registers
	iret
.11:
	call os_print_time
	iret
.12:
	call os_print_date
	iret

;Disk services
intF5h_enter:
	cmp di, 00h
	je .00
	cmp di, 01h
	je .01
	cmp di, 02h
	je .02
	cmp di, 03h
	je .03
	cmp di, 04h
	je .04
	cmp di, 05h
	je .05
	cmp di, 06h
	je .06
	cmp di, 07h
	je .07
	cmp di, 08h
	je .08
	cmp di, 09h
	je .09
	stc
	iret
.00:
	;reserved
	iret
.01:
	call fat_file_exist
	iret
.02:
	call fat_file_list
	iret
.03:
	call fat_file_read
	iret
.04:
	call fat_file_write
	iret
.05:
	call fat_file_delete
	iret
.06:
	;mov word [.ax], ax
	;mov word [.bx], bx
	;mov word [.cx], cx
	;mov word [.dx], dx
	;mov ax, cx
	;mov bx, dx
	;call fat_file_convert
	;jc .06_error
	;mov dx, bx
	;mov ax, word [.ax]
	;mov bx, word [.bx]
	;mov cx, word [.cx]
	call fat_file_rename
	iret
;.ax dw 0
;.bx dw 0
;.cx dw 0
;.dx dw 0
;.06_error:
;	iret
.07:
	call fat_file_create
	iret
.08:
	call fat_file_convert
	iret
.09:
	call fat_file_attrib
	iret
	
;Math services
intF6h_enter:
	cmp di, 00h	;reserved [add]
	je .00
	cmp di, 01h	;reserved [sub]
	je .01
	cmp di, 02h	;reserved [mul]
	je .02
	cmp di, 03h	;reserved [div]
	je .03
	cmp di, 04h	;reserved [exp]
	je .04
	cmp di, 05h	;reserved [factorial]
	je .05
	cmp di, 06h	;reserved []
	je .06
	cmp di, 07h	;reserved []
	je .07
	cmp di, 08h	;reserved []
	je .08
	cmp di, 09h	;reserved []
	je .09
	cmp di, 0Ah	;initialize x87 fpu
	je .0A
	cmp di, 0Bh	;push to x87 fpu
	je .0B
	cmp di, 0Ch	;pop from x87 fpu
	je .0C
	cmp di, 0Dh	;x87 fpu convert float to int
	je .0D
	cmp di, 0Eh	;x87 fpu sin
	je .0E
	cmp di, 0Fh	;x87 fpu cos
	je .0F
	
	
.00:
.01:
.02:
.03:
.04:
.05:
.06:
.07:
.08:
.09:
.0A:
.0B:
.0C:
.0D:
.0E:
.0F:
	;log
	;ln
	;sqrt
	;
	;asin
	;acos
	;tan
	;atan
	;return pi
	;return e
	
	iret
	
;Extra interrupt 1
intF7h_enter:
	iret
	
;Miscellaneous services
intF8h_enter:
	cmp di, 00h
	je .00
	cmp di, 01h
	je .01
	cmp di, 02h
	je .02
	cmp di, 03h
	je .03
	cmp di, 04h
	je .04
	cmp di, 05h
	je .05
	stc
	iret
.00:
	iret
.01:
	call os_list_selector
	iret
.02:
	call os_input_dialogue
	iret
.03:
	call os_input_dialogue_equation
	iret
.04:
	call os_input_dialogue_numbers
	iret
.05:
	call os_wait
	iret
.06:
	;call os_random
	iret
	
;System services
;Not to be called often!
intF9h_enter:
	cmp di, 00h
	je .00
	cmp di, 01h
	je .01
	cmp di, 02h
	je .02
	cmp di, 03h
	je .03
	stc
	iret
	
;gives the locations of several important GoldOS variables.
;AX=os_gfx_var, DX=os_disk_num
.00:
	mov ax, os_gfx_var
	mov dx, os_disk_num
	iret	
.01:
	call os_print_cpuid
	iret
.02:
	call os_print_conventional_memory
	iret
.03:
	call os_print_total_memory
	iret

;Unprogrammed extra interrupt 1
intFAh_enter:
	iret

;Unprogrammed extra interrupt 2
intFBh_enter:
	iret
	
;Unprogrammed extra interrupt 3
intFCh_enter:
	iret
	
;Unprogrammed extra interrupt 4
intFDh_enter:
	iret
	
;System Reset Interrupt
;Called by int 09h when Ctrl-Break has been pressed.
;Good for escaping infinite loops and other errors
;Does not work in VirtualBox!
int1Bh_enter:
	int 19h
	
;Memory Dump Interrupt
;Called by int 09h when PrtSc is pressed.
;Good for debugging
;Does not work in VirtualBox!
int05h_enter:
	mov ax, 2000h
	mov bx, .filename1
	call fat_file_delete
	
	clc
	
	mov ax, 2000h
	mov bx, .filename2
	call fat_file_delete
	
	clc
	
	mov ax, 2000h
	mov bx, .filename1
	mov cx, 2000h
	mov dx, 0
	mov si, 0xFFFF
	call fat_file_write
	
	clc
	
	mov ax, 2000h
	mov bx, .filename2
	mov cx, 3000h
	mov dx, 0
	mov si, 0xFFFF
	call fat_file_write
	
	clc
	
	int 19h
	
.filename1 db '2000    DMP', 0
.filename2 db '3000    DMP', 0
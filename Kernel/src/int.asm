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
	call os_draw_box_gfx
	iret
.04:
.05:
.06:
.07:
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
.06:
.07:
.08:
.09:
.0A:
.0B:
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
	stc
	iret
.00:
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
	iret
.07:
	call fat_file_create
	iret
	
;Math services
intF6h_enter:
	iret
	
;
intF7h_enter:
	iret
	
;
intF8h_enter:
	iret
	
;
intF9h_enter:
	iret

;
intFAh_enter:
	iret

;
intFBh_enter:
	iret
	
;Miscellaneous services
intFCh_enter:
	cmp di, 00h
	je .00
	cmp di, 01h
	je .01
	stc
	ret
	
.00:
	iret
.01:
	call os_list_selector
	iret
	
;System services
;Not to be called often!
intFDh_enter:
	iret
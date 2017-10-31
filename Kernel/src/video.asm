;==============================
;GoldElfOS: Mk II
;
;Roy Procell
;21 April 2015
;
;Updated 7/14/2015 for GoldOS Mk IV
;
;Video System Calls
;Video.asm
;
;Features:
;Video:
;os_set_video_mode (done!)
;os_move_cursor (done!)
;os_get_cursor (done!)
;os_set_cursor_visible (done!)
;os_set_cursor_invisible (done!)
;os_clear_screen (done!)
;os_set_background (done!)
;os_print_string (done!)
;os_print_char (done!)
;os_print_new_line (done!)
;os_draw_pixel (done!)
;os_get_pixel (done!)
;os_draw_border (done!)
;os_draw_bar (done!)
;os_get_video_mode (done!)
;os_draw_box (done!)
;os_set_cursor_full (done!)
;os_set_cursor_bar (done!)
;
;os_disable_blinking (done!)
;os_enable_blinking (done!)
;
;os_set_vga_font
;os_draw_icon (done!)
;
;os_draw_box_gfx (done!)
;os_clear_screen_gfx (done!)
;
;os_draw_rect_gfx (done!)
;os_draw_triangle_gfx (done!)
;os_draw_line_gfx (done!)
;==============================

;==================
;os_set_video_mode
;Sets the current video mode
;IN:	AL=video mode
;OUT:	Nothing
;==================
os_set_video_mode:
	pusha
	mov ah, 0
	int 10h
	popa
	ret

;==================
;os_move_cursor
;Sets the location of the cursor
;IN:	DH: row, DL: column
;OUT:	Nothing
;==================
os_move_cursor:
	pusha
	mov ah, 02h
	mov bh, 0
	int 10h
	popa
	ret
	
;==================
;os_get_cursor
;Gets the cursor position
;IN:	Nothing
;OUT:	DH: row, DL: column
;==================
os_get_cursor:
	pusha
	mov ah, 03h
	mov bh, 0
	int 10h
	popa
	ret

;==================
;os_set_cursor_visible
;Sets the cursor type to visible
;IN:	Nothing
;OUT:	Nothing
;==================
os_set_cursor_visible:
	pusha
	mov ch, 6
	mov cl, 7
	mov ah, 1
	mov al, 3
	int 10h
	popa
	ret

;==================
;os_set_cursor_invisible
;Sets the cursor type to invisible
;IN:	Nothing
;OUT:	Nothing
;==================
os_set_cursor_invisible:
	pusha
	mov ch, 32
	mov ah, 1
	mov al, 3
	int 10h
	popa
	ret

;==================
;os_clear_screen
;Clears the screen of text
;IN:	BL: color IGNORE:(BH: background color)
;OUT:	Nothing
;==================
os_clear_screen:
	pusha
	
	;checks to see if the system can support 16 colors, or only 8 colors and blinking.
	;if the system can only support 8 colors and blinking, os_gfx_var will be set to 1
	;and colors will be reduced so that no unintentional blinking occurs.
	cmp byte [os_gfx_var], 1
	je .color_filter
	jmp .interrupt
	
.color_filter:
	call os_clear_blinking_bit_bl;h
	
.interrupt:
	mov dh, 0
	mov cx, 25
	
.loop:
	call os_draw_border
	inc dh
	loop .loop

	;mov ah, 06h
	;mov ch, 0
	;mov cl, 0
	;mov dh, 24
	;mov dl, 79
	;int 10h
	popa
	ret

;==================
;os_set_background
;Sets the background color
;IN:	BL: background color
;OUT:	Nothing
;==================
os_set_background:
	pusha
	
	;checks to see if the system can support 16 colors, or only 8 colors and blinking.
	;if the system can only support 8 colors and blinking, os_gfx_var will be set to 1
	;and colors will be reduced so that no unintentional blinking occurs.
	cmp byte [os_gfx_var], 1
	je .color_filter
	jmp .interrupt
	
.color_filter:
	call os_clear_blinking_bit_bl
	
.interrupt:
	mov ah, 0Bh
	mov bh, 0
	int 10h
	popa
	ret

;==================
;os_print_string
;Prints strings
;IN:	SI: string address, DS: string segment
;OUT:	Nothing. Resets DS to 2000h.
;==================
os_print_string:
	pusha
	;mov ds, ax
	mov ah, 0Eh

.repeat:
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp .repeat

.done:
	mov ax, 2000h
	mov ds, ax
	popa
	ret

;==================
;os_print_char
;Prints a single char
;IN:	AL: desired char
;OUT:	Nothing
;==================
os_print_char:
	pusha
	mov ah, 0Eh
	mov bh, 0
	int 10h
	popa
	ret

;==================
;os_print_new_line
;Prints a new line char and moves the cursor down.
;IN:	Nothing
;OUT:	Nothing
;==================
os_print_new_line:
	pusha
	mov ah, 0Eh
	mov al, 13
	int 10h
	mov al, 10
	int 10h
	popa
	ret

;==================
;os_draw_pixel
;For use in graphics modes only!
;IN:	AX: pixel row, BX: pixel column, CL: pixel color
;OUT:	Nothing
;==================
os_draw_pixel:
	pusha
	mov dx, 0xA000
	mov es, dx
	mov di, 0
	xchg ax, bx
	mov dx, 320
	mul dx
	add di, ax
	add di, bx
	mov byte [es:di], cl
	mov ax, 2000h
	mov es, ax
	popa
	ret
	
;==================
;os_get_pixel
;Gets pixel data at a certain x and y. For use in graphics modes only!
;IN:	AX: pixel row, BX: pixel column
;OUT:	CL: pixel color
;==================
os_get_pixel:
	pusha
	mov dx, 0xA000
	mov es, dx
	mov di, 0
	xchg ax, bx
	mov dx, 320
	mul dx
	add di, ax
	add di, bx
	mov cl, byte [es:di]
	mov byte [.tmp], cl
	mov ax, 2000h
	mov es, ax
	popa
	mov cl, byte [.tmp]
	ret
	
.tmp db 0

;==================
;os_draw_border
;Draws a border at the cursor's row
;IN:	BL: color, DH: cursor's row
;OUT:	Nothing
;==================
os_draw_border:
	pusha
	mov dl, 0
	call os_move_cursor
	
	;checks to see if the system can support 16 colors, or only 8 colors and blinking.
	;if the system can only support 8 colors and blinking, os_gfx_var will be set to 1
	;and colors will be reduced so that no unintentional blinking occurs.
	cmp byte [os_gfx_var], 1
	je .color_filter
	jmp .interrupt
	
.color_filter:
	call os_clear_blinking_bit_bl
	
.interrupt:
	mov ah, 09h
	mov al, ' '
	mov bh, 0
	mov cx, 80
	int 10h
	popa
	ret

;==================
;os_draw_bar
;Draws a bar at the cursor's row and column
;IN:	BL: color, DH: cursor's row, DL: cursor's column, CX: number of columns
;OUT:	Nothing
;==================
os_draw_bar:
	pusha
	mov word [.tmp], cx
	call os_move_cursor
	mov cx, word [.tmp]
	
	;checks to see if the system can support 16 colors, or only 8 colors and blinking.
	;if the system can only support 8 colors and blinking, os_gfx_var will be set to 1
	;and colors will be reduced so that no unintentional blinking occurs.
	cmp byte [os_gfx_var], 1
	je .color_filter
	jmp .interrupt
	
.color_filter:
	call os_clear_blinking_bit_bl
	
.interrupt:
	mov ah, 09h
	mov al, ' '
	mov bh, 0
	int 10h
	popa
	ret
	
.tmp dw 0

;==================
;os_get_video_mode
;Gets the current video mode.
;IN:	Nothing
;OUT:	AL: video mode, AH: character columns, BH: active page
;==================
os_get_video_mode:
	mov ah, 0Fh
	int 10h
	ret

;==================
;os_draw_box
;Draws a box
;IN:	BL: color, DH: cursor's row, DL: cursor's column, CX: number of columns, AX: number of rows
;OUT:	Nothing
;==================
os_draw_box:
	mov word [.tmp], ax
	sub dh, 1

.loop:
	cmp word [.tmp], 0
	je .done
	inc dh
	call os_draw_bar
	dec word [.tmp]
	jmp .loop
	
.done:
	ret
	
.tmp dw 0

;==================
;os_set_cursor_full
;Sets the cursor to a full box
;IN:	Nothing
;OUT:	Nothing
;==================
os_set_cursor_full:
	pusha
	mov cx, 0007h
	call os_get_video_mode
	mov ah, 1
	int 10h
	popa
	ret

;==================
;os_set_cursor_bar
;Sets the cursor to the default bar
;IN:	Nothing
;OUT:	Nothing
;==================
os_set_cursor_bar:
	pusha
	mov cx, 0607h
	call os_get_video_mode
	mov ah, 1
	int 10h
	popa
	ret
	
;==================
;os_draw_box_gfx
;Draws a box in graphics mode.
;IN: BX: starting column, CX: starting row, DX: number of columns, SI: number of rows, AL: color
;OUT: Nothing
;==================
os_draw_box_gfx:
	pusha
	mov byte [.color], al
	mov word [.x_coord], bx
	mov word [.y_coord], cx
	mov word [.dx_coord], dx
	mov word [.dy_coord], si
	mov ax, 0xA000
	mov es, ax
	mov ax, word [.y_coord]
	mov bx, 320
	mul bx
	add ax, word [.x_coord]
	mov word [.first_pixel], ax
	mov di, ax
	mov cx, word [.dx_coord]
	mov al, byte [.color]
	
.x_loop:
	cmp cx, 0
	je .post_x_loop
	;cmp di, 0x7FFF
	;jge .done
	mov byte [es:di], al
	inc di
	dec cx
	jmp .x_loop
	
.post_x_loop:
	dec word [.dy_coord]
	cmp word [.dy_coord], 0
	je .done
	add word [.first_pixel], 320
	mov di, word [.first_pixel]
	mov cx, word [.dx_coord]
	jmp .x_loop
	
.done:
	mov ax, 2000h
	mov es, ax
	popa
	ret
	
.color db 0
.x_coord dw 0
.y_coord dw 0
.dx_coord dw 0
.dy_coord dw 0
.first_pixel dw 0
	
;==================
;os_clear_screen_gfx
;Clears the screen in graphics mode 13h.
;IN: BL: color
;OUT: Nothing
;==================
os_clear_screen_gfx:
	pusha
	mov cx, 64000
	mov ax, 0xA000
	mov es, ax
	mov di, 0
	
.loop:
	cmp cx, 0
	je .done
	mov byte [es:di], bl
	inc di
	dec cx
	jmp .loop
	
.done:
	mov ax, 2000h
	mov ds, ax
	popa
	ret
	
;==================
;os_draw_icon
;Draws an icon at the specified coordinates
;IN: AX: x, BX: y, GS: icon segment, SI: icon address
;OUT: Nothing
;==================
os_draw_icon:
	mov word [.ax], ax
	mov al, byte [gs:si]
	mov byte [.counter], al
	mov byte [.counter_backup], al
	inc si
	mov al, byte [gs:si]
	dec al
	mov byte [.post_counter], al
	inc si
	mov ax, word [.ax]
	dec ax
.loop:
	cmp byte [.counter], 0
	je .post_loop
	mov cl, byte [gs:si]
	inc ax
	call os_draw_pixel
	inc si
	dec byte [.counter]
	jmp .loop

.post_loop:
	cmp byte [.post_counter], 0
	je .done
	inc bx
	dec byte [.post_counter]
	mov al, byte [.counter_backup]
	mov byte [.counter], al
	mov ax, word [.ax]
	dec ax
	jmp .loop
	
.done:
	ret
	
.counter db 0
.counter_backup db 0
.post_counter db 0
.ax dw 0

;==================
;os_disable_blinking
;Disables blinking text.
;IN: Nothing
;OUT: Nothing
;==================
os_disable_blinking:
	pusha
	mov ax, 1003h
	mov bx, 0
	int 10h
	popa
	ret
	
;==================
;os_enable_blinking
;Enables blinking text.
;IN: Nothing
;OUT: Nothing
;==================
os_enable_blinking:
	pusha
	mov ax, 1003h
	mov bl, 1
	mov bh, 0
	int 10h
	popa
	ret
	
;==================
;os_draw_line_gfx
;Draws a line in graphics mode.
;IN: AX: x1, BX: y1, SI: x2, DX: y2, CL: color
;OUT: Nothing
;==================
os_draw_line_gfx:
	mov word [.x1], ax
	mov word [.y1], bx
	mov word [.x2], si
	mov word [.y2], dx
	
	mov byte [.color], cl
	
	;calculate dx and dy
	sub si, ax
	mov word [.dx], si
	sub dx, bx
	mov word [.dy], dx
	
	;calculate b
	mov ax, word [.dy]
	mov bx, [.x1]
	imul bx
	mov bx, word [.dx]
	;before we div by bx, make sure it isn't zero!
	cmp bx, 0
	je .zero_draw_loop
	idiv bx
	mov word [.m1], ax
	mov ax, word [.y1]
	mov bx, word [.m1]
	sub ax, bx
	mov word [.b], ax
	
	;if dy is bigger than dx,
	;it is better to draw with (y-b)/m = x
	mov dx, word [.dy]
	mov si, word [.dx]
	cmp dx, 0
	jl .dx_neg
	cmp si, 0
	jl .si_neg
	jmp .neg_cont
	
.dx_neg:
	neg dx
	cmp si, 0
	jl .si_neg
	jmp .neg_cont
	
.si_neg:
	neg si
	jmp .neg_cont

.neg_cont:
	cmp dx, si
	jge .x_calc_choose
	
	mov cx, word [.dx]
	cmp word [.dx], 0
	jl .backward_draw_loop
	
.forward_draw_loop:
	mov ax, word [.x1]
	mov bx, word [.y1]
	mov word [.cx_tmp], cx
	mov cl, byte [.color]
	call os_draw_pixel
	mov cx, word [.cx_tmp]
	
	inc word [.x1]
	call .calc_y
	loop .forward_draw_loop
	jmp .done

.backward_draw_loop:
	neg cx

.backward_draw_loop_run:
	mov ax, word [.x1]
	mov bx, word [.y1]
	mov word [.cx_tmp], cx
	mov cl, byte [.color]
	call os_draw_pixel
	mov cx, word [.cx_tmp]
	
	dec word [.x1]
	call .calc_y
	loop .backward_draw_loop_run
	jmp .done
	
.zero_draw_loop:
	mov cx, word [.dy]
	mov ax, word [.x1]
	cmp word [.dy], 0
	jl .zero_draw_loop_run_neg_pre
	
.zero_draw_loop_run_pos:
	mov bx, word [.y1]
	mov word [.cx_tmp], cx
	mov cl, byte [.color]
	call os_draw_pixel
	mov cx, word [.cx_tmp]
	inc word [.y1]
	loop .zero_draw_loop_run_pos
	jmp .done
	
.zero_draw_loop_run_neg_pre:
	neg cx
	
.zero_draw_loop_run_neg:
	mov bx, word [.y1]
	mov word [.cx_tmp], cx
	mov cl, byte [.color]
	call os_draw_pixel
	mov cx, word [.cx_tmp]
	dec word [.y1]
	loop .zero_draw_loop_run_neg
	jmp .done
	
.done:
	ret
	
.x_calc_choose:
	mov bx, word [.dy]
	;before we div by bx, make sure it isn't zero!
	cmp bx, 0
	je .zero_draw_loop_x

	mov cx, word [.dy]
	cmp word [.dy], 0
	jl .backward_draw_loop_x
	
.forward_draw_loop_x:
	mov ax, word [.x1]
	mov bx, word [.y1]
	mov word [.cx_tmp], cx
	mov cl, byte [.color]
	call os_draw_pixel
	mov cx, word [.cx_tmp]
	
	inc word [.y1]
	call .calc_x
	loop .forward_draw_loop_x
	jmp .done
	
.zero_draw_loop_x:
	mov cx, word [.dx]
	mov bx, word [.y1]
	cmp word [.dx], 0
	jl .zero_draw_loop_run_neg_x_pre
	
.zero_draw_loop_run_pos_x:
	mov bx, word [.y1]
	mov word [.cx_tmp], cx
	mov cl, byte [.color]
	call os_draw_pixel
	mov cx, word [.cx_tmp]
	inc word [.y1]
	loop .zero_draw_loop_run_pos_x
	jmp .done
	
.zero_draw_loop_run_neg_x_pre:
	neg cx
	
.zero_draw_loop_run_neg_x:
	mov bx, word [.y1]
	mov word [.cx_tmp], cx
	mov cl, byte [.color]
	call os_draw_pixel
	mov cx, word [.cx_tmp]
	dec word [.y1]
	loop .zero_draw_loop_run_neg_x
	jmp .done

.backward_draw_loop_x:
	neg cx

.backward_draw_loop_run_x:
	mov ax, word [.x1]
	mov bx, word [.y1]
	mov word [.cx_tmp], cx
	mov cl, byte [.color]
	call os_draw_pixel
	mov cx, word [.cx_tmp]
	
	dec word [.y1]
	call .calc_x
	loop .backward_draw_loop_run_x
	jmp .done
	
.calc_y:
	mov ax, word [.dy]
	mov bx, [.x1]
	imul bx
	mov bx, word [.dx]
	idiv bx
	add ax, word [.b]
	mov word [.y1], ax
	ret
	
.calc_x:
	mov ax, word [.y1]
	sub ax, word [.b]
	mov bx, word [.dx]
	imul bx
	mov bx, word [.dy]
	idiv bx
	mov word [.x1], ax
	ret

.cx_tmp dw 0
.m1 dw 0
.b dw 0
.d dw 0
.dx dw 0
.dy dw 0
.x1 dw 0
.y1 dw 0
.x2 dw 0
.y2 dw 0
.color db 0

;==================
;os_draw_triangle_gfx
;Draws a triangle in graphics mode.
;Data format:
;2 bytes: x1
;2 bytes: y1
;2 bytes: x2
;2 bytes: y2
;2 bytes: x3
;2 bytes: y3
;TOTAL: 12 byte packet
;IN: AX: segment to point data, BX: location of point data, CL: color
;OUT: Nothing
;==================
os_draw_triangle_gfx:
	pusha
	mov es, ax
	mov si, bx
	
	mov byte [.cl], cl
	
	mov ax, word [es:si]
	mov word [.x1], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.y1], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.x2], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.y2], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.x3], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.y3], ax
	
	mov ax, word [.x1]
	mov bx, word [.y1]
	mov si, word [.x2]
	mov dx, word [.y2]
	mov cl, byte [.cl]
	call os_draw_line_gfx
	

	mov ax, word [.x2]
	mov bx, word [.y2]
	mov si, word [.x3]
	mov dx, word [.y3]
	mov cl, byte [.cl]
	call os_draw_line_gfx
	
	mov ax, word [.x3]
	mov bx, word [.y3]
	mov si, word [.x1]
	mov dx, word [.y1]
	mov cl, byte [.cl]
	call os_draw_line_gfx
	mov ax, 2000h
	mov es, ax
	popa
	ret
	
.cl db 0
.x1 dw 0
.y1 dw 0
.x2 dw 0
.y2 dw 0
.x3 dw 0
.y3 dw 0

;==================
;os_draw_rect_gfx
;Draws a rectangle in graphics mode.
;Data format:
;2 bytes: x1
;2 bytes: y1
;2 bytes: x2
;2 bytes: y2
;2 bytes: x3
;2 bytes: y3
;2 bytes: x4
;2 bytes: y4
;TOTAL: 16 byte packet
;IN: AX: segment to point data, BX: location of point data, CL: color
;OUT: Nothing
;==================
os_draw_rect_gfx:
	pusha
	mov es, ax
	mov si, bx
	
	mov byte [.cl], cl
	
	mov ax, word [es:si]
	mov word [.x1], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.y1], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.x2], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.y2], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.x3], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.y3], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.x4], ax
	inc si
	inc si
	
	mov ax, word [es:si]
	mov word [.y4], ax

	
	mov ax, word [.x1]
	mov bx, word [.y1]
	mov si, word [.x2]
	mov dx, word [.y2]
	mov cl, byte [.cl]
	call os_draw_line_gfx
	

	mov ax, word [.x2]
	mov bx, word [.y2]
	mov si, word [.x3]
	mov dx, word [.y3]
	mov cl, byte [.cl]
	call os_draw_line_gfx
	
	mov ax, word [.x3]
	mov bx, word [.y3]
	mov si, word [.x1]
	mov dx, word [.y1]
	mov cl, byte [.cl]
	call os_draw_line_gfx
	mov ax, 2000h
	mov es, ax
	popa
	ret
	
.cl db 0
.x1 dw 0
.y1 dw 0
.x2 dw 0
.y2 dw 0
.x3 dw 0
.y3 dw 0
.x4 dw 0
.y4 dw 0
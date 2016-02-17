;GoldOS 4.0 Miscellaneous Functions
;
;Roy Procell
;7/23/2015
;
;Functions:
;os_random
;os_wait (done!)

;==================
;os_wait
;Stops execution for a certain number of microseconds
;IN: CX:DX: microseconds to wait (CX is high word, DX is lower word)
;OUT: Nothing
;==================
os_wait:
	pusha
	mov ah, 86h
	int 15h
	popa
	ret

;==================
;os_clear_blinking_bit_bl
;Makes sure text isn't blinking on older computers
;IN: Nothing
;OUT: Nothing
;==================
os_clear_blinking_bit_bl:
	btr ebx, 7
	ret
	
;==================
;os_clear_blinking_bit_bh
;Makes sure text isn't blinking on older computers
;IN: Nothing
;OUT: Nothing
;==================
os_clear_blinking_bit_bh:
	btr ebx, 13
	ret
	
;==================
;os_list_selector
;Provides a menu to select objects from. Warning: lists can only hold 256 items.
;IN: AX: segment of list location, BX: offset of list location, CX: title of menu, DH: selection option 1, DL: selection option 2, SI: selection option 3
;OUT: AL: number of selected item in list, AH: number of selected option (0 for enter, 1 for option 1, 2 for option 2, 3 for option 3)
;==================
os_list_selector:
	mov word [.segment], ax
	mov word [.address], bx
	mov word [.title], cx
	mov byte [.skip_entries], 0
	mov byte [.entries], 0
	
	; Count the number of entries in the list
	mov cl, 0
	mov ds, ax
	mov si, bx
.count_loop:
	lodsb
	cmp al, 0
	je .done_count
	cmp al, ','
	jne .count_loop
	inc cl
	jmp .count_loop

.done_count:
	inc cl
	mov byte [.entries], cl
	
	mov dh, 0
	mov dl, 0
	call os_move_cursor
	mov ax, word [.segment]
	mov ds, ax
	mov si, word [.title]
	call os_print_string
	mov dh, 1
	mov dl, 0
	call os_move_cursor
	mov ax, 2000h
	mov ds, ax
	mov si, .subtitle
	call os_print_string
	
.pre_outer_loop:
	mov byte [.tmp], 21
	mov dh, 2
	
.outer_bar_loop:
	cmp byte [.tmp], 0
	je .done_outer_loop
	mov bl, 0x83
	inc dh
	mov dl, 2;22
	mov cx, 76;35
	call os_draw_bar
	dec byte [.tmp]
	jmp .outer_bar_loop
	
.done_outer_loop:
	mov dh, 4
	mov dl, 4;2;24
	mov word [.dx_tmp], dx
	mov dx, 0
	
	mov dh, 3
	mov dl, 2
	mov di, 02h
	int 0F1h
	mov si, .header
	mov di, 0
	int 0F4h
	
.pre_loop:
	pusha
	mov byte [.tmp], 19
	mov dh, 3
	
;draws the file selection menu
.bar_loop:
	cmp byte [.tmp], 0
	je .done_loop
	mov bl, 0xF0;0x70
	inc dh
	mov dl, 3;23
	mov cx, 74;33
	call os_draw_bar
	dec byte [.tmp]
	jmp .bar_loop
	
;sets the starting position of the cursor
;and changes it to a full block
.done_loop:
	mov dh, 4
	mov dl, 4;5;24
	call os_move_cursor
	call os_set_cursor_full
	;mov ah, 1
	
;draws the list of options
.draw_list:
	mov ax, word [.segment]
	mov si, word [.address]
	
	mov dh, 4
	mov dl, 6;26
	call os_move_cursor
	
	mov cx, 0
	mov cl, byte [.skip_entries]
	
.skip_loop:
	cmp cx, 0
	je .skip_finished
	
.lodsb:
	lodsb
	cmp al, ','
	jne .lodsb
	dec cx
	jmp .skip_loop
	
.skip_finished:
	mov bx, 0
	
.more:
	lodsb
	cmp al, 0
	je .done_list
	cmp al, ','
	je .newline
	
	call os_print_char
	jmp .more
	
.newline:
	mov dl, 6;26
	inc dh
	call os_move_cursor
	
	inc bx
	cmp bx, 19
	jl .more
	
.done_list:
	popa
	mov dx, word [.dx_tmp]
	call os_move_cursor
	
.get_input:
	call os_wait_for_key
	cmp ah, 48h
	je .scroll_up
	cmp ah, 50h
	je .scroll_down
	cmp al, 13
	je .option_selected
	cmp al, byte [.option_1]
	je .option_1_selected
	cmp al, byte [.option_2]
	je .option_2_selected
	cmp al, byte [.option_3]
	je .option_3_selected
	cmp al, 27
	je .escape_pressed
	
	jmp .get_input
	
.scroll_up:
	call os_get_cursor
	cmp dh, 4
	je .hit_top
	dec dh
	call os_move_cursor
	jmp .get_input
	
.scroll_down:
	call os_get_cursor
	cmp dh, 22
	je .hit_bottom
	mov bl, byte [.entries]
	add bl, 3
	cmp dh, bl
	je .get_input
	inc dh
	call os_move_cursor
	jmp .get_input
	
.hit_top:
	cmp byte [.skip_entries], 0
	je .get_input
	dec byte [.skip_entries]
	mov word [.dx_tmp], dx
	jmp .pre_loop
	
.hit_bottom:
	mov al, byte [.skip_entries]
	add al, dh
	sub al, 3
	cmp byte [.entries], al
	je .get_input
	inc byte [.skip_entries]
	mov word [.dx_tmp], dx
	jmp .pre_loop
	
.escape_pressed:
	stc
	ret
	
.option_selected:
	call os_get_cursor
	mov al, dh
	add al, byte [.skip_entries]
	sub al, 3
	mov ah, 0
	clc
	ret
	
.option_1_selected:
	call os_get_cursor
	mov al, dh
	add al, byte [.skip_entries]
	sub al, 3
	mov ah, 1
	clc
	ret
	
.option_2_selected:
	call os_get_cursor
	mov al, dh
	add al, byte [.skip_entries]
	sub al, 3
	mov ah, 2
	clc
	ret
	
.option_3_selected:
	call os_get_cursor
	mov al, dh
	add al, byte [.skip_entries]
	sub al, 3
	mov ah, 3
	clc
	ret
	
.segment dw 0
.address dw 0
.entries db 0
.skip_entries db 0
.tmp db 0
.dx_tmp dw 0
.header db 'Menu', 0
.subtitle db 'Use the UP and DOWN arrow keys to select an option, then press desired key option', 0
.title dw 0
.option_1 db 0
.option_2 db 0
.option_3 db 0
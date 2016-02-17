;GoldOS 4.0 Kernel Main File
;
;Roy Procell
;7/21/2015
;
;This file was added to reduce clutter within the main kernel file.
;
;
draw_icons:
	mov al, 13h
	call os_set_video_mode
	
	call os_disable_blinking
	
	mov dx, 0
	call os_move_cursor
	
	mov ax, 2000h
	mov ds, ax
	mov si, os_welcome
	mov bl, 43
	call os_print_string
	
	inc dh
	call os_move_cursor
	mov ax, 2000h
	mov ds, ax
	mov si, os_help
	mov bl, 43
	call os_print_string
	inc dh
	call os_move_cursor
	mov si, os_help_2
	mov bl, 43
	call os_print_string
	inc dh
	call os_move_cursor
	mov si, os_help_3
	mov bl, 43
	call os_print_string
	
	mov dh, 0
	mov dl, 24
	call os_move_cursor
	mov ax, 2000h
	mov ds, ax
	mov si, os_desc
	call os_print_string
	inc dh
	call os_move_cursor
	mov si, os_desc_2
	call os_print_string
	
	mov bx, 176
	mov cx, 0
	mov dx, 8
	mov si, 200
	mov al, 21h
	call os_draw_box_gfx
	
	mov bx, 0
	mov cx, 128
	mov dx, 184
	mov si, 8
	mov al, 21h
	call os_draw_box_gfx
	
	mov bx, 0
	mov cx, 128
	mov dx, 184
	mov si, 8
	mov al, 21h
	call os_draw_box_gfx
	
	mov ax, 2000h
	mov gs, ax
	mov ax, 16-1
	mov bx, 48-1
	mov si, os_file_icon
	call os_draw_icon_kernel
	
	mov ax, 2000h
	mov gs, ax
	mov ax, 48-1
	mov bx, 48-1
	mov si, os_text_icon
	call os_draw_icon_kernel
	
	mov ax, 2000h
	mov gs, ax
	mov ax, 80-1
	mov bx, 48-1
	mov si, os_imge_icon
	call os_draw_icon_kernel
	
	mov ax, 2000h
	mov gs, ax
	mov ax, 112-1
	mov bx, 48-1
	mov si, os_calc_icon
	call os_draw_icon_kernel
	
	mov ax, 2000h
	mov gs, ax
	mov ax, 16-1
	mov bx, 88-1
	mov si, os_demo_icon
	call os_draw_icon_kernel
	
	mov ax, 2000h
	mov gs, ax
	mov ax, 48-1
	mov bx, 88-1
	mov si, os_info_icon
	call os_draw_icon_kernel
	
	mov ax, 2000h
	mov gs, ax
	mov ax, 80-1
	mov bx, 88-1
	mov si, os_cnfg_icon
	call os_draw_icon_kernel
	
	mov ax, 2000h
	mov gs, ax
	mov ax, 112-1
	mov bx, 88-1
	mov si, os_loff_icon
	call os_draw_icon_kernel
	
	;mov ax, 2000h
	;mov bx, os_test_file
	;mov cx, 2000h
	;mov dx, 0
	;mov si, 1051
	;call fat_file_write
	
choose_option:
	mov bl, 2Bh
	mov dh, 9
	mov dl, 0
	mov cx, 22
	call os_draw_bar
	mov bl, 2Bh
	mov dh, 14
	mov dl, 0
	mov cx, 22
	call os_draw_bar
	cmp byte [os_option_counter], 0
	je .file
	cmp byte [os_option_counter], 1
	je .edit
	cmp byte [os_option_counter], 2
	je .imge
	cmp byte [os_option_counter], 3
	je .calc
	cmp byte [os_option_counter], 4
	je .demo
	cmp byte [os_option_counter], 5
	je .info
	cmp byte [os_option_counter], 6
	je .cnfg
	cmp byte [os_option_counter], 7
	je .loff
	
.file:	
	mov dl, 2
	mov dh, 9
	call os_move_cursor
	mov al, '^'
	call os_print_char
	call os_print_char
	mov si, os_file_desc
	jmp .begin_print
.edit:
	mov dl, 6
	mov dh, 9
	call os_move_cursor
	mov al, '^'
	call os_print_char
	call os_print_char
	mov si, os_text_desc
	jmp .begin_print
.imge:
	mov dl, 10
	mov dh, 9
	call os_move_cursor
	mov al, '^'
	call os_print_char
	call os_print_char
	mov si, os_imge_desc
	jmp .begin_print
.calc:
	mov dl, 14
	mov dh, 9
	call os_move_cursor
	mov al, '^'
	call os_print_char
	call os_print_char
	mov si, os_calc_desc
	jmp .begin_print
.demo:
	mov dl, 2
	mov dh, 14
	call os_move_cursor
	mov al, '^'
	call os_print_char
	call os_print_char
	mov si, os_demo_desc
	jmp .begin_print
.info:
	mov dl, 6
	mov dh, 14
	call os_move_cursor
	mov al, '^'
	call os_print_char
	call os_print_char
	mov si, os_info_desc
	jmp .begin_print
.cnfg:
	mov dl, 10
	mov dh, 14
	call os_move_cursor
	mov al, '^'
	call os_print_char
	call os_print_char
	mov si, os_cnfg_desc
	jmp .begin_print
.loff:
	mov dl, 14
	mov dh, 14
	call os_move_cursor
	mov al, '^'
	call os_print_char
	call os_print_char
	mov si, os_loff_desc

.begin_print:
	mov dl, 24
	mov dh, 3
	call os_move_cursor
	mov byte [.counter], 21
	mov ax, 2000h
	mov ds, ax

.print_loop:
	cmp byte [.counter], 0
	je .choose_loop
	call os_print_string
	add si, 16
	call os_get_cursor
	inc dh
	mov dl, 24
	call os_move_cursor
	dec byte [.counter]
	jmp .print_loop
	
.choose_loop:
	call os_wait_for_key
	cmp ah, 4Dh
	je .right
	cmp ah, 48h
	je .up
	cmp ah, 50h
	je .down
	cmp ah, 4Bh
	je .left
	cmp al, 0Dh
	je load_file
	cmp al, 27
	je shutdown
	jmp .choose_loop
	
.right:
	cmp byte [os_option_counter], 7
	je .right_far
	inc byte [os_option_counter]
	jmp choose_option
	
;moves the cursor to the top left option if right button is pressed at bottom right option
.right_far:
	mov byte [os_option_counter], 0
	jmp choose_option
	
.up:
	cmp byte [os_option_counter], 3
	jle .choose_loop
	sub byte [os_option_counter], 4
	jmp choose_option
	
.down:
	cmp byte [os_option_counter], 4
	jae .choose_loop
	add byte [os_option_counter], 4
	jmp choose_option
	
.left:
	cmp byte [os_option_counter], 0
	je .left_far
	dec byte [os_option_counter]
	jmp choose_option

;moves the cursor to the bottom right option if the left button is pressed at the top left option
.left_far:
	mov byte [os_option_counter], 7
	jmp choose_option
	
.counter db 0
	
load_file:
	cmp byte [os_option_counter], 0
	je .file
	cmp byte [os_option_counter], 1
	je .edit
	cmp byte [os_option_counter], 2
	je .imge
	cmp byte [os_option_counter], 3
	je .calc
	cmp byte [os_option_counter], 4
	je .demo
	cmp byte [os_option_counter], 5
	je .info
	cmp byte [os_option_counter], 6
	je .cnfg
	cmp byte [os_option_counter], 7
	je .loff
	
.file:
	;mov ax, 2000h
	;mov bx, os_file_file
	;call fat_file_exec
	;mov cx, 2000h
	;mov dx, 9000h;49152
	;call fat_file_read
	;jc file_not_found
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov al, 3
	call os_set_video_mode
	
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0
	
	call 2000h:9000h
	
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0
	
	jmp main
.edit:
	mov ax, 2000h
	mov bx, os_text_file
	call fat_file_exec
	jc file_not_found
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	jmp main
.imge:
	mov ax, 2000h
	mov bx, os_imge_file
	call fat_file_exec
	jc file_not_found
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	jmp main
.calc:
	mov ax, 2000h
	mov bx, os_calc_file
	call fat_file_exec
	jc file_not_found
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	jmp main
.demo:
	mov ax, 2000h
	mov bx, os_demo_file
	call fat_file_exec
	jc file_not_found
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	jmp main
.info:
	mov ax, 2000h
	mov bx, os_info_file
	call fat_file_exec
	jc file_not_found
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	jmp main
.cnfg:
	mov ax, 2000h
	mov bx, os_cnfg_file
	call fat_file_exec
	jc file_not_found
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	jmp main
.loff:
	jmp shutdown
	
file_not_found:
	mov dh, 17
	mov dl, 0
	call os_move_cursor
	mov bl, 28h
	mov ax, 2000h
	mov ds, ax
	mov si, os_error
	call os_print_string
	mov bl, 43
	mov dh, 18
	mov dl, 0
	call os_move_cursor
	mov si, os_file_not_found
	call os_print_string
	mov dh, 19
	mov dl, 0
	call os_move_cursor
	mov si, os_file_not_found_2
	call os_print_string
	call os_wait_for_key
	jmp main

;==================
;internal routine to shut down the computer.
;warning: may not work on all systems.
;tested hardware seems to either restart the computer or hang.
;==================
shutdown:
	mov dh, 17
	mov dl, 0
	call os_move_cursor
	mov bl, 28h
	mov ax, 2000h
	mov ds, ax
	mov si, os_notice
	call os_print_string
	mov bl, 43
	mov dh, 18
	mov dl, 0
	call os_move_cursor
	mov si, os_shutdown
	call os_print_string
	mov dh, 19
	mov dl, 0
	call os_move_cursor
	mov si, os_shutdown_2
	call os_print_string
	mov dh, 20
	mov dl, 0
	call os_move_cursor
	mov si, os_shutdown_3
	call os_print_string
	
	mov dh, 22
	mov dl, 0
	call os_move_cursor
	mov bl, 2
	mov al, 'Y'
	call os_print_char
	mov bl, 43
	mov al, '/'
	call os_print_char
	mov bl, 28h
	mov al, 'N'
	call os_print_char
	
	call os_wait_for_key
	cmp al, 79h
	je .shutdown
	cmp al, 59h
	je .shutdown
	jmp main
	
.shutdown:
	mov ax, 5301h
	xor bx, bx
	int 15h

	mov ax, 530Eh
	xor bx, bx
	mov cx, 0102
	int 15h

	mov ax, 5307h
	mov bx, 0001h
	mov cx, 0003h
	int 15h

	ret
	
;==================
;internal routine to draw icons for the homepage stored in the kernel.
;==================
os_draw_icon_kernel:
	mov byte [.counter], 16
	mov byte [.post_counter], 15
	mov word [.ax], ax
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
	mov byte [.counter], 16
	mov ax, word [.ax]
	dec ax
	jmp .loop
	
.done:
	ret
	
.counter db 0
.post_counter db 0
.ax dw 0

;==================
;internal routine to detect if something can't load at startup.
;==================
fatal_error:
	mov al, 3
	call os_set_video_mode
	
	mov bh, 0
	call os_clear_screen
	
	mov ax, 2000h
	mov ds, ax
	mov si, .message
	call os_print_string
	jmp end_main
	
.message db 'GoldOS encountered an error and cannot run.', 0
	
end_main:
	jmp $
;GoldOS Mk IV
;
;Roy Procell
;8/8/2015
;
;filemngr.bin
;
;GoldOS File Manager 3.0
;The file manager will reside in the kernel segment to avoid problems with loading other programs.
;
org 49152

main:
	mov di, 0
	mov al, 3
	int 0F1h
	
	;clears the screen with the color 0x70 (aka light grey background with black text)
	;we have to do it by drawing borders because the bios is glitchy for some reason
	mov bl, 0x70
	mov dh, 2
	mov di, 0Ch
	int 0F1h
	mov dh, 3
	int 0F1h
	mov dh, 4
	int 0F1h
	mov dh, 5
	int 0F1h
	mov dh, 6
	int 0F1h
	mov dh, 7
	int 0F1h
	mov dh, 8
	int 0F1h
	mov dh, 9
	int 0F1h
	mov dh, 10
	int 0F1h
	mov dh, 11
	int 0F1h
	mov dh, 12
	int 0F1h
	mov dh, 13
	int 0F1h
	mov dh, 14
	int 0F1h
	mov dh, 15
	int 0F1h
	mov dh, 16
	int 0F1h
	mov dh, 17
	int 0F1h
	mov dh, 18
	int 0F1h
	mov dh, 19
	int 0F1h
	mov dh, 20
	int 0F1h
	mov dh, 21
	int 0F1h
	mov dh, 22
	int 0F1h
	mov dh, 23
	int 0F1h
	mov dh, 24
	int 0F1h
	
	;draws a bar at the top two rows of the screen with the color 0x83 (aka dark grey background with cyan text)
	mov bl, 0x83
	mov dh, 0
	mov di, 0Ch
	int 0F1h
	mov dh, 1
	int 0F1h
	
	;moves the cursor to 0,0 and writes the welcome and instruction strings
	mov dx, 0
	mov di, 02h
	int 0F1h
	mov ax, 2000h
	mov ds, ax
	mov si, welcome
	mov di, 0
	int 0F4h
	;mov dh, 1
	;mov dl, 0
	;mov di, 02h
	;int 0F1h
	;mov si, instructions
	;mov di, 0
	;int 0F4h
	
	;draws the header
	;mov bl, 0x83
	;mov dh, 3
	;mov dl, 2
	;mov cx, 76
	;mov di, 0Dh
	;int 0F1h
	;mov dh, 3
	;mov dl, 2
	;mov di, 02h
	;int 0F1h
	;mov si, header
	;mov di, 0
	;int 0F4h
	
	;get list from kernel
	mov di, 02h
	int 0F5h
	
	mov ax, 2000h
	mov cx, welcome
	
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
	mov di, 2
	int 0F1h
	;call os_set_cursor
	mov ax, word [.segment]
	mov ds, ax
	mov si, word [.title]
	mov di, 0
	int 0F4h
	;call os_print_string
	mov dh, 1
	mov dl, 0
	mov di, 2
	int 0F1h
	;call os_set_cursor
	mov ax, 2000h
	mov ds, ax
	mov si, instructions;.subtitle
	mov di, 0
	int 0F4h
	;call os_print_string
	
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
	mov di, 0Dh
	int 0F1h
	;call os_draw_bar
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
	mov si, header
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
	mov di, 0Dh
	int 0F1h
	;call os_draw_bar
	dec byte [.tmp]
	jmp .bar_loop
	
;sets the starting position of the cursor
;and changes it to a full block
.done_loop:
	mov dh, 4
	mov dl, 4;5;24
	mov di, 2
	int 0F1h
	;call os_set_cursor
	;makes the cursor appear as a full block
	mov ah, 1
	mov cx, 0007h
	int 10h
	
;draws the list of options
.draw_list:
	mov ax, word [.segment]
	mov si, word [.address]
	
	mov dh, 4
	mov dl, 6;26
	mov di, 02
	int 0F1h
	;call os_set_cursor
	
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
	
	mov di, 1
	int 0F4h
	;call os_print_char
	jmp .more
	
.newline:
	mov dl, 6;26
	inc dh
	mov di, 2
	int 0F1h
	;call os_set_cursor
	
	inc bx
	cmp bx, 19
	jl .more
	
.done_list:
	popa
	mov dx, word [.dx_tmp]
	mov di, 2
	int 0F1h
	;call os_set_cursor
	
.get_input:
	mov di, 0
	int 0F3h
	;call os_wait_for_key
	cmp ah, 48h
	je .scroll_up
	cmp ah, 50h
	je .scroll_down
	cmp al, 13
	je .option_selected
	cmp al, 27
	je .escape_pressed
	jmp .get_input
	
.scroll_up:
	mov di, 3
	int 0F1h
	;call os_get_cursor
	cmp dh, 4
	je .hit_top
	dec dh
	mov di, 2
	int 0F1h
	;call os_set_cursor
	jmp .get_input
	
.scroll_down:
	mov di, 3
	int 0F1h
	;call os_get_cursor
	cmp dh, 22
	je .hit_bottom
	mov bl, byte [.entries]
	add bl, 3
	cmp dh, bl
	je .get_input
	inc dh
	mov di, 2
	int 0F1h
	;call os_set_cursor
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
	mov di, 3
	int 0F1h
	;call os_get_cursor
	mov al, dh
	add al, byte [.skip_entries]
	sub al, 3
	clc
	ret
	
.segment dw 0
.address dw 0
.entries db 0
.skip_entries db 0
.tmp db 0
.dx_tmp dw 0
.subtitle db 'Use the UP and DOWN arrow keys to select an option, then press ENTER', 0
.title dw 0

open:
delete:
rename:

refresh_list:
	;draws a box where the list will go
	mov bl, 0xF0
	mov dh, 4
	mov dl, 2
	mov cx, 76
	mov ax, 20
	mov di, 0Eh
	int 0F1h
	
	;moves the cursor to the appropriate position to start drawing the list
	mov dh, 4
	mov dl, 4
	mov di, 02h
	int 0F1h
	
	;gets the list from the kernel
	mov di, 02h
	int 0F5h
	
	;saves the location of the list in segment 2000h
	mov word [list_loc], bx
	
	mov si, bx
	mov ax, 2000h
	mov es, ax
	mov ax, 0
	mov bx, 0
	
	mov di, 0
	int 0F3h
	
	retf

;counts the number of strings in the list	
count_loop:
	mov al, byte [es:si]
	cmp al, 0
	je .done
	cmp al, ','
	jne count_loop
	inc bx
	jmp count_loop
	
.done:
	mov word [list_size], bx
	
draw_list:
	mov si, word [list_loc]
	mov ax, 12
	mul word [skip]
	add si, ax
	mov cx, 0
	
.loop:
	mov al, [es:si]
	cmp al, 0
	je .done
	cmp al, ' '
	je .space
	mov di, 1
	int 0F4h
	inc cx
	inc si
	cmp cx, 8
	je .dot
	cmp cx, 11
	je .next
	jmp .loop
	
.space:
	inc si
	inc cx
	cmp cx, 8
	je .dot
	jmp .loop
	
.dot:
	mov al, '.'
	mov di, 1
	int 0F4h
	jmp .loop
	
.next:
	mov di, 3
	int 0F1h
	cmp dh, 23
	je .done
	cmp al, 0
	je .done
	inc si
	inc dh
	mov di, 2
	int 0F1h
	
.done:
	
	mov di, 0
	int 0F3h
	
return:
	retf
	
prgm_vars:
skip dw 0
current_entry dw 0
list_loc dw 0
list_size dw 0
	
prgm_strings:
welcome db 'GoldOS File Manager 3.0', 0
instructions db 'Use UP and DOWN to select, ENTER to open, D to delete, and R to rename.', 0
header db '    File name       Size      Size on disk', 0
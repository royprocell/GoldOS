;Roy Procell
;2/19/2016
;GoldOS text editor

org 40960

main:
	mov di, 0
	mov al, 3
	int 0F1h
	
	mov bl, 0x70
	mov di, 0xA
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
	mov si, welcome_msg
	mov di, 0
	int 0F4h

	;int to draw and use menu
	mov di, 1
	mov ax, 2000h
	mov bx, list
	mov cx, welcome_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	;0xFF is the option in the menu to exit
	cmp ah, 0xFF
	je exit
	
	cmp al, 1
	je edit_existing_file
	cmp al, 2
	je create_new_file
	jmp main
	
edit_existing_file:
	mov bl, 0x70
	mov di, 0xA
	int 0F1h
	
	;draws a bar at the top two rows of the screen with the color 0x83 (aka dark grey background with cyan text)
	mov bl, 0x83
	mov dh, 0
	mov di, 0Ch
	int 0F1h
	mov dh, 1
	int 0F1h
	
	;get list from kernel
	mov di, 02h
	int 0F5h

	;save the list location
	mov [list_loc], bx

	;int to draw and use menu
	mov di, 1
	mov ax, 2000h
	mov cx, welcome_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	cmp ah, 0xFF
	je main
	
	;find the file in the list
	mov si, word [list_loc]

	mov ah, 0
	
calculate_location:
	mov cl, 12
	dec al
	mul cl

	add si, ax
	
found_file:
	mov di, filename
	lodsw
	stosw
	lodsw
	stosw
	lodsw
	stosw
	lodsw
	stosw
	lodsw
	stosw
	lodsb
	stosb
	
	;checks to make sure the extension of the selected file is good
	mov cx, 3
	mov si, filename
	add si, 8
	mov di, txt_ext
	rep cmpsb
	je ext_good
	
	mov cx, 3
	mov si, filename
	add si, 8
	mov di, asm_ext
	rep cmpsb
	je ext_good
	
	mov cx, 3
	mov si, filename
	add si, 8
	mov di, py_ext
	rep cmpsb
	je ext_good
	
	mov cx, 3
	mov si, filename
	add si, 8
	mov di, c_ext
	rep cmpsb
	je ext_good
	
	mov cx, 3
	mov si, filename
	add si, 8
	mov di, cpp_ext
	rep cmpsb
	je ext_good
	
	jmp error_not_txt
	
ext_good:
	;reads the file to segment 3000h, offset 0000h
	mov ax, 2000h
	mov bx, filename
	mov cx, 3000h
	mov dx, 0000h
	mov di, 3
	int 0F5h
	
	jc error_io
	
	mov al, 10
	mov di, 1
	int 0F4h
	;jmp $

screen_setup:
	mov bl, 0xF0
	mov di, 0xA
	int 0F1h
	
	;draws a bar at the top two rows of the screen with the color 0x83 (aka dark grey background with cyan text)
	mov bl, 0x83
	mov dh, 0
	mov di, 0Ch
	int 0F1h
	mov dh, 1
	int 0F1h
	mov dh, 24
	int 0F1h
	
	mov dx, 0
	mov di, 02h
	int 0F1h
	mov ax, 2000h
	mov ds, ax
	mov si, welcome_msg
	mov di, 0
	int 0F4h
	mov dh, 1
	mov dl, 0
	mov di, 2
	int 0F1h
	mov si, instructions_msg
	mov di, 0
	int 0F4h
	
	mov dh, 2
	mov dl, 0
	mov di, 2
	int 0F1h
	
	mov di, 4
	int 0F1h
	mov di, 7
	int 0F1h
	
	mov ax, 3000h
	mov gs, ax
	
render_file:
	mov cx, word [skipped_lines]
	mov byte [chars_before_newline], 0
	mov cx, 5
	mov si, 0
	
;makes sure to not render skipped lines
.skip_skipped_lines:
	cmp cx, 0
	je .start_rendering
	cmp byte [gs:si], 10
	je .found_skipped_line
	inc si
	jmp .skip_skipped_lines
	
.found_skipped_line:
	inc si
	dec cx
	jmp .skip_skipped_lines
	
.start_rendering:
	cmp byte [chars_before_newline], 80
	je error_too_large
	mov di, 3
	int 0F1h
	cmp dh, 24
	je .finished_rendering
	cmp byte [gs:si], 10
	je .next_line
	cmp byte [gs:si], 0
	je .finished_rendering
	mov al, byte [gs:si]
	mov di, 1
	int 0F4h
	inc si
	inc byte [chars_before_newline]
	jmp .start_rendering
	
.next_line:
	mov di, 3
	int 0F1h
	inc dh
	mov dl, 0
	mov di, 2
	int 0F1h
	inc si
	jmp .start_rendering
	
.finished_rendering:
	mov di, 0
	int 0F3h
	jmp main
	
input:
	mov di, 0
	int 0F3h
	cmp al, 13
	je .newline
	cmp al, 27
	je .cancel
	cmp al, 8
	je .backspace
	cmp al, 31
	jbe input
	cmp al, 127
	jae input
	jmp .typing

;====================
;UNFINISHED CODE HERE
;====================

.typing:
	
.newline:

.backspace:

.cancel:

move_text_forward:
	mov si, word [loc_in_file]
	mov di, word [loc_in_file]
	
.loop:
	mov al, byte [gs:si]
	mov byte [gs:si+1], al
	dec si
	cmp si, di
	jl .done
	jmp .loop
	
.done:
	inc word [filesize]
	ret

move_text_backward:
	mov si, word [loc_in_file]
	mov di, word [loc_in_file]
	
.loop:
	mov al, byte [gs:si+1]
	mov byte [gs:si], al
	inc si
	cmp si, word [filesize]
	jne .loop
	
.done:
	dec word [filesize]
	ret

create_new_file:
	mov di, 2
	mov ax, welcome_msg
	mov bl, 8
	int 0F8h
	
	cmp ah, 0xFF
	je main
	
	;write spaces to filename_rename
	mov al, ' '
	mov di, filename
	stosb
	stosb
	stosb
	stosb
	stosb
	stosb
	stosb
	stosb
	stosb
	stosb
	stosb
	
	;copy filename
	mov si, bx
	mov di, filename
	lodsw
	stosw
	lodsw
	stosw
	lodsw
	stosw
	lodsw
	stosw
	
	;clear the screen from input dialogue
	mov bl, 0x70
	mov di, 0xA
	int 0F1h
	mov bl, 0x83
	mov dh, 0
	mov di, 0Ch
	int 0F1h
	mov dh, 1
	int 0F1h
	
	;ask user for extension
	mov di, 1
	mov ax, 2000h
	mov bx, ext_list
	mov cx, welcome_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	cmp al, 1
	je .txt
	cmp al, 2
	je .asm
	cmp al, 3
	je .py
	cmp al, 4
	je .c
	cmp al, 5
	je .cpp
	cmp ah, 0xFF
	je main
	
.txt:
	mov si, txt_ext
	mov di, filename
	add di, 8
	lodsb
	stosb
	lodsb
	stosb
	lodsb
	stosb
	jmp .replace_zeroes_setup
	
.asm:
	mov si, asm_ext
	mov di, filename
	add di, 8
	lodsb
	stosb
	lodsb
	stosb
	lodsb
	stosb
	jmp .replace_zeroes_setup

.py:
	mov si, py_ext
	mov di, filename
	add di, 8
	lodsb
	stosb
	lodsb
	stosb
	jmp .replace_zeroes_setup

.c:
	mov si, c_ext
	mov di, filename
	add di, 8
	lodsb
	stosb
	jmp .replace_zeroes_setup

.cpp:
	mov si, cpp_ext
	mov di, filename
	add di, 8
	lodsb
	stosb
	lodsb
	stosb
	lodsb
	stosb
	jmp .replace_zeroes_setup

.replace_zeroes_setup:
	mov si, filename
	mov cx, 11
	
.replace_zeroes_loop:
	cmp cx, 0
	je .zeroes_replaced
	cmp byte [ds:si], 0
	je .zero_found
	inc si
	dec cx
	jmp .replace_zeroes_loop
	
.zero_found:
	mov al, ' '
	mov byte [ds:si], al
	inc si
	dec cx
	jmp .replace_zeroes_loop
	
.zeroes_replaced:
	;convert to uppercase
	mov di, 3
	mov ax, 2000h
	mov si, filename
	mov di, 3
	int 0F4h

	mov ax, 2000h
	mov bx, filename
	mov di, 7
	int 0F5h
	
	jc error_io
	
	jmp main
	
error_not_txt:
	mov di, 1
	mov ax, 2000h
	mov bx, error_not_txt_msg
	mov cx, welcome_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	jmp edit_existing_file

error_io:
	mov di, 1
	mov ax, 2000h
	mov bx, error_io_msg
	mov cx, welcome_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	jmp main
	
error_too_large:
	mov bl, 0x70
	mov di, 0xA
	int 0F1h
	
	;draws a bar at the top two rows of the screen with the color 0x83 (aka dark grey background with cyan text)
	mov bl, 0x83
	mov dh, 0
	mov di, 0Ch
	int 0F1h
	mov dh, 1
	int 0F1h

	mov di, 1
	mov ax, 2000h
	mov bx, error_too_large_msg
	mov cx, welcome_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	jmp main
	
exit:
	retf
	
vars:
welcome_msg db 'GoldOS Text Editor 1.0', 0
instructions_msg db 'Use F1 to save, F2 to quit without saving, and arrow keys to move', 0
list db 'Edit existing file,Create new file', 0
list_loc dw 0
filename times 13 db 0
txt_ext db 'TXT', 0
asm_ext db 'ASM', 0
py_ext db 'PY ', 0
c_ext db 'C  ', 0
cpp_ext db 'CPP', 0
ext_list db 'TXT,ASM,PY,C,CPP', 0
error_io_msg db 'A disk error occured. Unable to handle request.', 0
error_not_txt_msg db 'Unable to open non-text file.', 0
error_too_large_msg db 'File too large or lines are too long.', 0

skipped_lines dw 0
chars_before_newline db 0
cursor_x dw 0
cursor_y dw 0
loc_in_file dw 0
filesize dw 0
;Roy Procell
;2/19/2016
;GoldOS text editor

org 40960

main:
	;we will use the gs segment to perform changes on our file
	mov ax, 3000h
	mov gs, ax

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
	;clears the segment 3000h before the file is loaded
	call clear_segment

	;reads the file to segment 3000h, offset 0000h
	mov ax, 2000h
	mov bx, filename
	mov cx, 3000h
	mov dx, 0000h
	mov di, 3
	int 0F5h
	
	jc error_io
	
	mov di, 9
	mov ax, 2000h
	mov bx, filename
	int 0F5h
	
	mov word [filesize], bx
	
	mov al, 10
	mov di, 1
	int 0F4h
	
	mov byte [cursor_y], 2
	mov byte [cursor_x], 0
	mov word [location], 0

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
	
calc_skip:
	mov cx, word [skip]
	mov si, 0
	
.skip:
	cmp cx, 0
	je render
	cmp byte [gs:si], 10
	je .found_a_skip
	inc si
	jmp .skip
	
.found_a_skip:
	dec cx
	inc si
	jmp .skip
	
render:
	mov di, 0
	int 0F3h
	;find out what row we are on
	mov di, 3
	int 0F1h
	;if we are on the last row, we're done rendering
	cmp dh, 24
	je .done
	;if we encounter a new line character, move to next row
	cmp byte [gs:si], 10
	je .next_line
	;if we encounter a carriage return character, ignore it and increment si
	cmp byte [gs:si], 13
	je .cr
	;if we reach the end of our file, we're done rendering
	cmp si, word [filesize]
	je .done
	;if we reach a zero, which could be the end of our file, we're done rendering
	cmp byte [gs:si], 0
	je .done
	;prepare the interrupt to print a character
	mov al, byte [gs:si]
	mov di, 1
	int 0F4h
	;go to the next char
	inc si
	;jump back to the render loop
	jmp render
	
.next_line:
	;find out what row we are on
	mov di, 3
	int 0F1h
	;increment the row
	inc dh
	;clear the line
	mov bl, 0xF0
	mov di, 0Ch
	int 0F1h
	;set the cursor
	mov dl, 0
	mov di, 2
	int 0F1h
	;go to the next char and jump back to the render loop
	inc si
	jmp render
	
.cr:
	inc si
	jmp render
	
.done:
	;set the cursor to the appropriate location
	mov dl, byte [cursor_x]
	mov dh, byte [cursor_y]
	mov di, 2
	int 0F1h
	
	;set si to the correct location in the file
	mov si, word [location]
	
input:
	;ask for keyboard input
	mov di, 0
	int 0F3h
	;if f1 is pressed, save the file
	cmp ax, 3B00h
	je save
	;if enter is entered, attempt to go to the next line
	cmp al, 13
	je newline
	;if escape is entered, exit the program without saving
	cmp al, 27
	je edit_existing_file
	;if backspace is entered, shift all characters backward and render
	cmp al, 8
	je backspace
	;if delete is entered, shift all character backward and render
	cmp ah, 53h
	je delete
	;if up is entered, attempt to move up a line
	cmp ah, 72
	je up
	;if down is entered, attempt to move down a line
	cmp ah, 80
	je down
	;if left is entered, attempt to decrement si
	cmp ah, 75
	je left
	;if right is entered, attempt to increment si
	cmp ah, 77
	je right
	;ignore if an inappropriate key is pressed
	cmp al, 31
	jbe input
	cmp al, 127
	jae input
	;if any other key is pressed, it must be good to print.
	jmp typing

typing:
	;are we at the rightmost column?
	mov di, 3
	int 0F1h
	;if so, ignore character typed
	cmp dl, 79
	je input
	
	call move_text_forward
	mov byte [gs:si], al
	mov di, 3
	int 0F1h
	inc dl
	mov di, 2
	int 0F1h
	mov byte [cursor_x], dl
	mov byte [cursor_y], dh
	mov word [location], si
	inc word [location]
	jmp screen_setup
	
move_text_backward:
	pusha
	mov di, si
	
.loop:
	mov al, byte [gs:di+1]
	mov byte [gs:di], al
	inc di
	cmp di, word [filesize]
	jne .loop
	
.done:
	dec word [filesize]
	popa
	ret

move_text_forward:
	pusha
	mov di, word [filesize]
	
.loop:
	mov al, byte [gs:di]
	mov byte [gs:di+1], al
	dec di
	cmp di, 0
	je .at_zero
	cmp di, si
	jb .done
	jmp .loop
	
.done:
	inc word [filesize]
	popa
	ret
	
.at_zero:
	mov al, byte [gs:di]
	mov byte [gs:di+1], al
	inc word [filesize]
	popa
	ret

newline:
	call move_text_forward
	mov byte [gs:si], 13
	inc si
	call move_text_forward
	mov byte [gs:si], 10
	inc si
	mov di, 3
	int 0F1h
	mov dl, 0
	inc dh
	mov byte [cursor_x], dl
	mov byte [cursor_y], dh
	mov word [location], si
	jmp screen_setup

backspace:
	;if the cursor is at the leftmost column, do nothing.
	mov di, 3
	int 0F1h
	cmp dl, 0
	je input
	
	;since we aren't at the leftmost column, we must delete the character in front of the current one.
	dec si
	call move_text_backward
	mov di, 3
	int 0F1h
	dec dl
	mov byte [cursor_x], dl
	mov byte [cursor_y], dh
	mov word [location], si
	jmp screen_setup
	
delete:
	;if the cursor is at the leftmost column, do nothing.
	mov di, 3
	int 0F1h
	cmp dl, 0
	je input
	;if we encounter a carriage return, there will most likely be a return character following it.
	;so we need to delete two characters instead of one!
	cmp byte [gs:si], 13
	je .cr_found
	;if any other character is found, just delete one character.
	call move_text_backward
	;if we delete the last character in the file, we need to move the cursor back!
	cmp byte [gs:si], 0
	je .deleted_eof
	mov di, 3
	int 0F1h
	mov byte [cursor_x], dl
	mov byte [cursor_y], dh
	mov word [location], si
	jmp screen_setup
	
.cr_found:
	call move_text_backward
	call move_text_backward
	mov di, 3
	int 0F1h
	mov byte [cursor_x], dl
	mov byte [cursor_y], dh
	mov word [location], si
	jmp screen_setup
	
.deleted_eof:
	mov di, 3
	int 0F1h
	dec dl
	dec si
	mov byte [cursor_x], dl
	mov byte [cursor_y], dh
	mov word [location], si
	jmp screen_setup

up:
	;if up is entered and it's the top of the screen, check if its the top of the file
	mov di, 3
	int 0F1h
	cmp dh, 2
	je .is_top
	
	;if it isn't the top of the screen, it can't be the top of the file (hopefully!).
	;therefore, we can find the second previous newline and mov si to that location.
	
	;if we are already on a newline, make sure to go back 3 newlines instead of just two, otherwise we will have the wrong location!
	cmp byte [gs:si], 10
	je .go_up_three
	mov byte [decs_left], 2
	jmp .go_up_two
	
.is_top:
	;save the location in file
	mov word [location], si
	jmp .previous_newlines
	
	;if we hit si = 0 before encountering a newline character, we are on the first line of the file
.previous_newlines_dont_exist:
	mov di, 3
	int 0F1h
	mov dh, 2
	mov dl, 0
	mov di, 2
	int 0F1h
	jmp input
	
.previous_newlines:
	cmp si, 0
	je .previous_newlines_dont_exist
	cmp byte [gs:si], 10
	je .previous_newlines_exist
	dec si
	jmp .previous_newlines
	
.previous_newlines_exist:
	mov si, word [location]
	;so it isn't the top of the file.
	;but it is the top of the screen!
	;therefore we need to decrement the skip lines and render again after finding our new location!
	
	dec word [skip]
	
	;if it isn't the top of the file, find the second previous newline and move si to that location, decrement skip lines, and render again
	
	;if we are already on a newline, make sure to go back 3 newlines instead of just two, otherwise we will have the wrong location!
	cmp byte [gs:si], 10
	je .go_up_three_top
	mov byte [decs_left], 2
	jmp .go_up_two_top
	
.go_up_two:
	;if si is zero, we can't decrement it or else it'll get messed up!
	cmp si, 0
	je .si_is_zero
	;have we passed two (or three) newlines?
	cmp byte [decs_left], 0
	;if so, we can now move the cursor
	je .dec_complete
	;if not, are we sitting on a newline char?
	cmp byte [gs:si], 10
	;if so, decrement si and decrement the number of newlines we have to find
	je .dec_up
	;if not, decrement si and repeat the loop
	dec si
	jmp .go_up_two
	
.dec_up:
	dec byte [decs_left]
	dec si
	jmp .go_up_two
	
.go_up_three:
	mov byte [decs_left], 3
	jmp .go_up_two
	
.dec_complete:
	;once we have found the second (or third) previous newline, increment si twice to move it to the right location
	inc si
	inc si
	;now, move the cursor up one row
	mov di, 3
	int 0F1h
	dec dh
	mov dl, 0
	mov di, 2
	int 0F1h
	;remember to save the new location!
	mov word [location], si
	;now, we have successfully gone up one line!
	;jump back so we can find more input.
	jmp input
	
.si_is_zero:
	mov di, 3
	int 0F1h
	dec dh
	mov dl, 0
	mov di, 2
	int 0F1h
	jmp input
	
.go_up_two_top:
	cmp si, 0
	je .si_is_zero_top
	;have we passed two (or three) newlines?
	cmp byte [decs_left], 0
	;if so, we can now move the cursor
	je .dec_complete_top
	;if not, are we sitting on a newline char?
	cmp byte [gs:si], 10
	;if so, decrement si and decrement the number of newlines we have to find
	je .dec_up_top
	;if not, decrement si and repeat the loop
	dec si
	jmp .go_up_two_top
	
.dec_up_top:
	dec byte [decs_left]
	dec si
	jmp .go_up_two_top
	
.go_up_three_top:
	mov byte [decs_left], 3
	jmp .go_up_two_top
	
.dec_complete_top:
	;once we have found the second (or third) previous newline, increment si twice to move it to the right location
	inc si
	inc si
	;now, save si
	mov word [location], si
	;save cursor position
	mov byte [cursor_x], 0
	mov byte [cursor_y], 2
	;jump back to render and we will have successfully gone up one line!
	jmp screen_setup
	
.si_is_zero_top:
	mov word [location], si
	mov byte [cursor_x], 0
	mov byte [cursor_y], 2
	jmp screen_setup
	
down:
	;if down is entered and it's the bottom of the screen, check if it's the end of the file.
	mov di, 3
	int 0F1h
	cmp dh, 23
	je .is_bottom
	
	;even if it isn't the bottom of the screen, we must still test for the end of a file.
.is_eof:
	mov word [location], si
	
.is_eof_loop:
	cmp byte [gs:si], 10
	je .not_eof
	cmp  byte [gs:si], 0
	je .is_eof_true
	inc si
	jmp .is_eof_loop
	
.not_eof:
	inc si
	mov word [location], si
	mov di, 3
	int 0F1h
	inc dh
	mov dl, 0
	mov di, 2
	int 0F1h
	jmp input
	
.is_eof_true:
	mov si, word [location]
	jmp input
	
.is_bottom:
	mov word [location], si
	;if it is the end of the file, do nothing.
	;to find out if it is the last line or not, we must test all characters after si.
	;if we find a newline character, it's all good.
	;if we find a zero, or if si becomes larger than the filesize, then we know we're at the end of the file and we can just do nothing.
.is_bottom_loop:
	;is we find a newline, then it's not the end of the file
	cmp byte [gs:si], 10
	je .not_end
	;if we find a zero, then it's the end of the file
	cmp byte [gs:si], 0
	je .is_end
	;if its some other typed character, ignore and increment si
	inc si
	jmp .is_bottom_loop
	
.not_end:
	;increment si and save the correct location
	inc si
	mov word [location], si
	;increment number of lines to skip
	inc word [skip]
	;make sure to save the cursor position
	mov byte [cursor_x], 0
	mov byte [cursor_y], 23
	jmp screen_setup
	
.is_end:
	;it's the end of the file. return to the original location, and do nothing.
	mov si, word [location]
	jmp input
	
left:
	;are we at the beginning of the file? if so, do nothing.
	cmp si, 0
	je input
	;find out what column we're at
	mov di, 3
	int 0F1h
	;are we at the leftmost column? if so, do nothing.
	cmp dl, 0
	je input
	;if not, decrement si, update the cursor, and jump back to input.
	dec dl
	mov di, 2
	int 0F1h
	dec si
	jmp input

right:
	;are we at the end of the file? if so, do nothing.
	cmp si, word [filesize]
	;cmp byte [gs:si+1], 0
	je input
	;are we at the end of a line? if so, do nothing.
	cmp byte [gs:si+1], 10
	je input
	;find out what column we're at
	mov di, 3
	int 0F1h
	;are we at the rightmost column? if so, do nothing.
	cmp dl, 79
	je input
	;if not, increment si, update the cursor, and jump back to input.
	inc dl
	mov di, 2
	int 0F1h
	inc si
	jmp input

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
	
	;jump straight into editing new file instead of main
	jmp ext_good
	
save:
	pusha
	;first we need to delete the original file
	mov ax, 2000h
	mov bx, filename
	mov di, 5
	int 0F5h
	
	;now we can save the file again
	mov ax, 2000h
	mov bx, filename
	mov cx, 3000h
	mov dx, 0
	mov si, word [filesize]
	mov di, 4
	int 0F5h
	jc error_io
	popa
	
	jmp input
	
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
	
exit:
	retf
	
;clears the segment for the next file to use.
clear_segment:
	pusha
	mov si, 0
	mov cx, 32768

.loop:
	cmp cx, 0
	je .done
	mov word [gs:si], 0
	inc si
	inc si
	dec cx
	jmp .loop
	
.done:
	popa
	ret
	
vars:
welcome_msg db 'GoldOS Text Editor 1.0', 0
instructions_msg db 'Use ESC to quit without saving, F1 to save, and arrow keys to move', 0
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

cursor_x db 0
cursor_y db 0
filesize dw 0
skip dw 0
location dw 0
decs_left db 0
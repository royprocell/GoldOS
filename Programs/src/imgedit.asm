;Roy Procell
;2/27/2016
;GoldOS image editor

org 40960

main:
	;set the correct segment for gs
	mov ax, 3000h
	mov gs, ax
	
	;set the video mode
	mov di, 0
	mov al, 3
	int 0F1h
	
	;clear the screen
	mov bl, 0x70
	mov di, 0xA
	int 0F1h
	
	;load vga.13h
	mov ax, 2000h
	mov bx, palette_file
	mov cx, 4000h
	mov dx, 0
	mov di, 3
	int 0F5h
	
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
	cmp al, 3
	je help
	jmp main
	
edit_existing_file:
	;set the video mode
	mov di, 0
	mov al, 3
	int 0F1h
	
	;clear existing variables
	mov ax, 0
	mov word [pixel_x], ax
	mov word [pixel_y], ax
	mov word [img_width], ax
	mov word [img_height], ax
	mov byte [pixel_color], al
	mov byte [brush_toggle], al
	
	;clear last image from segment 3000h
	call clear_segment

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
	mov di, ext_13h
	rep cmpsb
	je read_13h
	
	jmp error_not_img
	
error_not_img:
	mov di, 1
	mov ax, 2000h
	mov bx, error_not_img_msg
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
	mov di, 1
	mov ax, 2000h
	mov bx, error_too_large_msg
	mov cx, welcome_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	jmp main
	
read_13h:
	mov di, 0
	mov al, 13h
	int 0F1h

	;reads the file to segment 3000h, offset 0000h
	mov ax, 2000h
	mov bx, filename
	mov cx, 3000h
	mov dx, 0000h
	mov di, 3
	int 0F5h
	
	jc error_io
	
	;saves the width and height of the image
	mov si, 0

	mov al, byte [gs:si]
	mov byte [img_width], al
	inc si

	mov al, byte [gs:si]
	mov byte [img_height], al
	
	;saves the size of the file for when we save it back to disk
	mov di, 9
	mov ax, 2000h
	mov bx, filename
	int 0F5h
	
	mov word [filesize], bx
	
render:
	;clear the screen
	mov di, 2
	mov bl, 0
	int 0F2h

	cmp byte [brush_toggle], 1
	je .update
	jmp .draw
	
.update:	;if the brush is on, make sure to apply the new color where the cursor is!
	mov ax, word [pixel_x]
	mov bx, word [pixel_y]
	call plot_pixel

.draw:
	;draw the image into video memory
	mov ax, 0
	mov bx, 0
	mov si, 0
	mov di, 7
	int 0F2h
	
.add_cursor:	;displays a pixel where the cursor is, which is the logical not of the pixel color
				;note: the cursor is only visual, and does not get saved.
				;due to the weirdness of the vga palette, sometimes the cursor will not be visible.
	mov cl, byte [pixel_color]
	not cl
	
	mov di, 0
	mov ax, word [pixel_x]
	mov bx, word [pixel_y]
	int 0F2h
	
input:
	;wait for input
	mov di, 0
	int 0F3h
	;if space is pressed, toggle the brush
	cmp al, ' '
	je brush
	;if c is pressed, change the color
	cmp al, 'c'
	je color
	;if s is pressed, save the image
	cmp al, 's'
	je save
	;if escape is pressed, quit without saving
	cmp al, 27
	je edit_existing_file
	;if the arrow keys are pressed, move the pixel.
	;additionally, if the brush_toggle byte is on, change the pixel color for the current pixel and the pixel we move to.
	;update it in the file, then render again.
	cmp ah, 72
	je up
	cmp ah, 80
	je down
	cmp ah, 75
	je left
	cmp ah, 77
	je right
	;if b is pressed, bucket fill the color
	cmp al, 'b'
	je bucket_fill
	;if an inappropriate key is pressed, jump back to input
	jmp input
	
brush:
	cmp byte [brush_toggle], 1
	je .is_one
	
.is_zero:
	mov byte [brush_toggle], 1
	jmp input
	
.is_one:
	mov byte [brush_toggle], 0
	jmp input

color:
	;clear the screen
	mov di, 2
	mov bl, 0
	int 0F2h
	mov dx, 0
	;move the cursor to top left
	mov di, 2
	int 0F1h
	;write the instructions to the screen
	mov si, color_msg
	mov di, 0
	mov bl, 43
	int 0F4h
	;return a line
	mov dh, 2
	mov dl, 0
	mov di, 2
	int 0F1h
	;print lots of characters
	mov di, 1
	mov al, '1'
	mov bl, 1
	int 0F4h
	
	mov di, 1
	mov al, '2'
	mov bl, 2
	int 0F4h
	
	mov di, 1
	mov al, '3'
	mov bl, 3
	int 0F4h
	
	mov di, 1
	mov al, '4'
	mov bl, 4
	int 0F4h
	
	mov di, 1
	mov al, '5'
	mov bl, 5
	int 0F4h
	
	mov di, 1
	mov al, '6'
	mov bl, 6
	int 0F4h
	
	mov di, 1
	mov al, '7'
	mov bl, 7
	int 0F4h
	
	mov di, 1
	mov al, '8'
	mov bl, 8
	int 0F4h
	
	mov di, 1
	mov al, '9'
	mov bl, 9
	int 0F4h
	
	mov di, 1
	mov al, 'A'
	mov bl, 0xA
	int 0F4h
	
	mov di, 1
	mov al, 'B'
	mov bl, 0xB
	int 0F4h
	
	mov di, 1
	mov al, 'C'
	mov bl, 0xC
	int 0F4h
	
	mov di, 1
	mov al, 'D'
	mov bl, 0xD
	int 0F4h
	
	mov di, 1
	mov al, 'E'
	mov bl, 0xE
	int 0F4h
	
	mov di, 1
	mov al, 'F'
	mov bl, 0xF
	int 0F4h
	
	;return a line
	mov dh, 4
	mov dl, 0
	mov di, 2
	int 0F1h

	mov si, color_hex_prompt_msg
	mov bl, 43
	mov di, 0
	int 0F4h
	
.input:
	;ask for input
	mov di, 0
	int 0F3h
	cmp al, 13

	cmp al, 'h'
	je .hex_dialogue
	cmp al, 'H'
	je .hex_dialogue
	
	cmp al, '0'
	je .zero
	cmp al, '1'
	je .one
	cmp al, '2'
	je .two
	cmp al, '3'
	je .three
	cmp al, '4'
	je .four
	cmp al, '5'
	je .five
	cmp al, '6'
	je .six
	cmp al, '7'
	je .seven
	cmp al, '8'
	je .eight
	cmp al, '9'
	je .nine
	
	cmp al, 'a'
	je .a
	cmp al, 'b'
	je .b
	cmp al, 'c'
	je .c
	cmp al, 'd'
	je .d
	cmp al, 'e'
	je .e
	cmp al, 'f'
	je .f
	
	cmp al, 'A'
	je .a
	cmp al, 'B'
	je .b
	cmp al, 'C'
	je .c
	cmp al, 'D'
	je .d
	cmp al, 'E'
	je .e
	cmp al, 'F'
	je .f
	
	jmp .input
	
.hex_dialogue:
	;return a line
	mov dh, 6
	mov dl, 0
	mov di, 2
	int 0F1h

	mov si, color_hex_msg
	mov bl, 43
	mov di, 0
	int 0F4h
	
	mov ax, 4000h
	mov gs, ax
	
	;load the image to the screen
	mov ax, 192
	mov bx, 72
	mov si, 0
	mov di, 7
	int 0F2h
	
	mov ax, 3000h
	mov gs, ax
	
	mov di, color_hex_chars
	
.hex_input:
	;ask for input
	mov di, 0
	int 0F3h
	cmp al, 13
	je .done_typing
	cmp al, 27
	je render
	cmp al, 8
	je .backspace
	cmp al, 47
	jbe .hex_input
	cmp al, 103
	jae .hex_input
	
	cmp al, '0'
	je .typing
	cmp al, '1'
	je .typing
	cmp al, '2'
	je .typing
	cmp al, '3'
	je .typing
	cmp al, '4'
	je .typing
	cmp al, '5'
	je .typing
	cmp al, '6'
	je .typing
	cmp al, '7'
	je .typing
	cmp al, '8'
	je .typing
	cmp al, '9'
	je .typing
	
	cmp al, 'a'
	je .typing
	cmp al, 'b'
	je .typing
	cmp al, 'c'
	je .typing
	cmp al, 'd'
	je .typing
	cmp al, 'e'
	je .typing
	cmp al, 'f'
	je .typing
	
	cmp al, 'A'
	je .typing
	cmp al, 'B'
	je .typing
	cmp al, 'C'
	je .typing
	cmp al, 'D'
	je .typing
	cmp al, 'E'
	je .typing
	cmp al, 'F'
	je .typing
	
	jmp .hex_input

.typing:
	cmp byte [color_hex_counter], 2
	je .hex_input
	cmp byte [color_hex_counter], 0
	je .zero_count
	mov byte [color_hex_chars+1], al
	jmp .one_count
.zero_count:
	mov byte [color_hex_chars], al
	
.one_count:
	mov bl, 43
	pusha
	mov di, 1
	int 0F4h
	popa
	inc byte [color_hex_counter]
	jmp .hex_input
	
.backspace:
	cmp byte [color_hex_counter], 0
	je .hex_input
	pusha
	mov al, 8
	mov di, 1
	mov bl, 43
	int 0F4h
	mov al, 0

	cmp byte [color_hex_counter], 0
	je .zero_count_back
	mov byte [color_hex_chars+1], al
	jmp .one_count_back
	
.zero_count_back:
	mov byte [color_hex_chars], al
	
.one_count_back:
	mov al, 20h
	mov di, 1
	int 0F4h
	mov al, 8
	mov di, 1
	int 0F4h
	dec byte [color_hex_counter]
	popa
	jmp .hex_input

.done_typing:
	cmp byte [color_hex_counter], 2
	jne .hex_input
	;convert hex chars to hex numbers
	mov di, 7
	mov ax, 2000h
	mov bx, color_hex_chars
	int 0F4h
	;set pixel_color to the output of that function
	mov byte [pixel_color], al
	;reset counter
	mov ax, 0
	mov byte [color_hex_counter], al

	jmp render
	
.zero:	;black
	mov al, 0
	mov byte [pixel_color], al
	jmp render
	
.one:	;blue
	mov al, 1
	mov byte [pixel_color], al
	jmp render
	
.two:	;green
	mov al, 2
	mov byte [pixel_color], al
	jmp render
	
.three:	;cyan
	mov al, 3
	mov byte [pixel_color], al
	jmp render
	
.four:	;red
	mov al, 4
	mov byte [pixel_color], al
	jmp render
	
.five:	;purple
	mov al, 5
	mov byte [pixel_color], al
	jmp render
	
.six:	;brown
	mov al, 6
	mov byte [pixel_color], al
	jmp render
	
.seven:	;light gray
	mov al, 7
	mov byte [pixel_color], al
	jmp render
	
.eight:	;gray
	mov al, 8
	mov byte [pixel_color], al
	jmp render
	
.nine:	;light blue
	mov al, 9
	mov byte [pixel_color], al
	jmp render
	
.a:		;light green
	mov al, 0xA
	mov byte [pixel_color], al
	jmp render
	
.b:		;sky blue
	mov al, 0xB
	mov byte [pixel_color], al
	jmp render
	
.c:		;orange
	mov al, 0xC
	mov byte [pixel_color], al
	jmp render
	
.d:		;pink
	mov al, 0xD
	mov byte [pixel_color], al
	jmp render
	
.e:		;yellow
	mov al, 0xE
	mov byte [pixel_color], al
	jmp render
	
.f:		;white
	mov al, 0xF
	mov byte [pixel_color], al
	jmp render
	
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
	
	mov di, 0
	mov al, 3
	int 0F1h
	
	mov di, 1
	mov ax, 2000h
	mov bx, list_save
	mov cx, welcome_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	jmp edit_existing_file

up:
	;if we are at zero for y, don't try to go above the screen
	cmp word [pixel_y], 0
	je input
	
	dec word [pixel_y]
	jmp render
	
down:
	;if we are at the bottom of the screen, don't try to go below the screen
	cmp word [pixel_y], 199
	je input
	;this can be a problem for images that have heights greater than 200.
	;it's possible to fix this, but there are no plans to do so right now.
	
	;if we are at the bottom of the image, don't try to go below the image
	mov ax, word [img_height]
	dec ax
	cmp word [pixel_y], ax
	je input
	
	inc word [pixel_y]
	jmp render

left:
	;if we are at the leftmost position on the screen, don't try to go off the screen
	cmp word [pixel_x], 0
	je input
	
	dec word [pixel_x]
	jmp render

right:
	;if we are at the rightmost position in the image, don't go outside the image
	mov ax, word [img_width]
	dec ax
	cmp word [pixel_x], ax;255
	je input
	;there will be leftover space to the right of all images, because the supported format has a max size of 256x256 pixels.
	
	inc word [pixel_x]
	jmp render
	
bucket_fill:	;fills all pixels in the image that have the same color as the pixel where the cursor is with the currently selected color.
	mov ax, word [pixel_x]
	mov bx, word [pixel_y]
	call get_pixel
	
	mov di, 2
	mov bl, [pixel_color]
	
.loop:
	cmp di, word [filesize]
	je .done
	cmp byte [gs:di], cl
	je .change_color
	inc di
	jmp .loop
	
.change_color:
	mov byte [gs:di], bl
	inc di
	jmp .loop
	
.done:
	jmp render

plot_pixel:	;accepts ax as pixel row, and bx as pixel column. called as a function.
			;plot_pixel writes a pixel to the image file before it is rendered to the screen.
	mov di, 0
	xchg ax, bx
	mov dx, word [img_width];320
	mul dx
	add di, ax
	add di, bx
	add di, 2	;2 is added to account for the offset created by the header in the image file
	mov cl, byte [pixel_color]
	mov byte [gs:di], cl
	ret
	
get_pixel:	;accepts ax as pixel row, and bx as pixel column. called as a function.
			;get_pixel returns the color of a pixel in the image file.
	mov di, 0
	xchg ax, bx
	mov dx, word [img_width]
	mul dx
	add di, ax
	add di, bx
	add di, 2
	mov cl, byte [gs:di]
	ret
	
create_new_file:
	;prompt for file name
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
	
	;copy extension
	mov si, ext_13h
	mov di, filename
	add di, 8
	lodsb
	stosb
	lodsb
	stosb
	lodsb
	stosb
	
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

	;prompt for width of new image
	mov di, 2
	mov ax, width_subtitle
	mov bl, 8
	int 0F8h
	
	cmp ah, 0xFF
	je main
	
	;convert string to number
	mov eax, 0
	mov ax, 2000h
	mov di, 5
	int 0F4h
	
	;if an error occurs, it is too large or not a number or zero
	cmp eax, 255
	jg error_too_large
	
	cmp eax, 0
	je error_too_large
	
	mov word [img_width], ax
	
	;prompt for height of new image
	mov di, 2
	mov ax, height_subtitle
	mov bl, 8
	int 0F8h
	
	cmp ah, 0xFF
	je main
	
	;convert string to number
	mov eax, 0
	mov ax, 2000h
	mov di, 5
	int 0F4h
	
	;if an error occurs, it is too large or not a number or zero
	cmp eax, 255
	jg error_too_large
	
	cmp eax, 0
	je error_too_large
	
	mov word [img_height], ax
	
	;clears the segment where the file will go
	call clear_segment
	
	;insert the header
	mov ax, word [img_width]
	mov di, 0
	mov word [gs:di], ax
	mov bx, word [img_height]
	inc di
	mov word [gs:di], bx
	
	;calculate the size of the file
	mul bx
	add ax, 2
	mov word [filesize], ax
	
	;convert to uppercase
	mov di, 3
	mov ax, 2000h
	mov si, filename
	mov di, 3
	int 0F4h

	;create the file
	mov ax, 2000h
	mov bx, filename
	mov di, 7
	int 0F5h
	
	jc error_io	
	
	mov di, 0
	mov al, 13h
	int 0F1h
	
	;render the new file!
	jmp render
	
help:
	;clear the screen
	mov bl, 0x70
	mov di, 0xA
	int 0F1h

	;draws header at the top
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

	mov bl, 0x83
	mov dh, 3
	mov dl, 2
	mov cx, 76
	mov ax, 21
	mov di, 0xE
	int 0F1h
	
	mov bl, 0xF0
	mov dh, 4
	mov dl, 3
	mov cx, 74
	mov ax, 19
	mov di, 0xE
	int 0F1h
	
	mov dh, 3
	mov dl, 2
	mov di, 2
	int 0F1h
	
	mov si, help_msg_0
	mov di, 0
	int 0F4h
	
	mov dh, 4
	mov dl, 3
	mov di, 2
	int 0F1h
	
	mov si, help_msg
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, help_msg_2
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, help_msg_3
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	add dh, 2
	mov di, 2
	int 0F1h
	
	mov si, help_msg_4
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	add dh, 13
	mov di, 2
	int 0F1h
	
	mov si, back_msg
	mov di, 0
	int 0F4h
	
	mov di, 5
	int 0F1h
	
	mov di, 0
	int 0F3h
	
	mov di, 4
	int 0F1h
	
	jmp main
	
exit:
	retf
	
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
welcome_msg db 'GoldOS Image Editor 1.0',0
help_msg_0 db 'Image Editor Help', 0
help_msg db 'You can edit and view .13H files.', 0
help_msg_2 db 'Use ESC to quit without saving, S to save, SPACE to toggle brush,',0
help_msg_3 db 'C for color selection, B to fill, and arrow keys to move.', 0
help_msg_4 db 'For the fill command to work, the brush must be off.', 0
back_msg db 'Press any key to go back.', 0
list db 'Edit existing image,Create new image,Help', 0
list_save db 'File saved successfully.', 0
list_loc dw 0
filename times 13 db 0
ext_13h db '13H', 0
error_io_msg db 'A disk error occured. Unable to handle request.', 0
error_not_img_msg db 'Unable to open non-image file.', 0
error_too_large_msg db 'Error: dimensions incorrect!', 0
img_width dw 0
img_height dw 0
pixel_x dw 0
pixel_y dw 0
brush_toggle db 0
pixel_color db 0
filesize dw 0

width_subtitle db 'Width of image?', 0
height_subtitle db  'Height of image?', 0

color_msg db 'Keys for common colors: (0 for black)', 0
color_hex_prompt_msg db 'Press H for manual color selection.', 0
color_hex_msg db 'Enter color as hex value: 0x', 0
color_hex_chars times (3) db 0
color_hex_counter db 0

palette_file db 'VGA     13H', 0
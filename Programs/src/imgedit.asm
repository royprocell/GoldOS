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
	mov di, 13h_ext
	rep cmpsb
	je read_13h
	
	mov cx, 3
	mov si, filename
	add si, 8
	mov di, pcx_ext
	rep cmpsb
	je read_pcx
	
	jmp error_not_txt
	
read_13h:
	mov di, 0
	mov al, 13h
	int 0F1h

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
	
	;saves the width and height of the image
	mov si, 0
	cmp word [gs:si], 0
	je new_13h_file
	cmp word [gs:si], 320
	ja error_too_large
	mov ax, word [gs:si]
	mov word [img_width], ax
	inc si
	inc si
	cmp word [gs:si], 200
	ja error_too_large
	mov ax, word [gs:si]
	mov word [img_height], ax
	
render:
	;draw the image into video memory
	mov ax, 0
	mov bx, 0
	mov si, 0
	mov di, 7
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
	;if an inappropriate key is pressed, jump back to input
	jmp input
	
brush:

color:

save:

up:

down:

left:

right:
	
read_pcx:
	
create_new_file:

help:
	
exit:
	retf
	
vars:
welcome_msg db 'GoldOS Image Editor 1.0',0
help_msg db 'You can edit .13H files and view .PCX files.', 0
help_msg_2 db 'Use ESC to quit without saving, S to save, SPACE to toggle brush,',0
help_msg_3 db 'C for color selection, and arrow keys to move.', 0
list db 'Edit existing image,Create new image,Help', 0
list_loc dw 0
filename times 13 db 0
13h_ext db '13H', 0
pcx_ext db 'PCX', 0
error_io_msg db 'A disk error occured. Unable to handle request.', 0
error_not_txt_msg db 'Unable to open non-image file.', 0
img_width dw 0
img_height dw 0
pixel_x dw 0
pixel_y dw 0
brush_toggle db 0
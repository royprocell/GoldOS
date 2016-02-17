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
org 36864;49152

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

	;save the list location
	mov [list_loc], bx

	;int to draw and use menu
	mov di, 1
	mov ax, 2000h
	mov cx, welcome
	mov dh, 0x64 ;delete file option (d key)
	mov dl, 0x72 ;rename file option (r key)
	mov si, 0x63 ;create file option (c key)
	int 0F8h
	
	;if escape is pressed, exit the file manager
	jc exit
	
	cmp ah, 0
	je open
	cmp ah, 1
	je delete
	cmp ah, 2
	je rename
	cmp ah, 3
	je create
	ret ;just in case the menu returns an invalid option

open:
	
create:
	
delete:
	
rename:

exit:
ret
	

prgm_vars:
skip dw 0
current_entry dw 0
list_loc dw 0
list_size dw 0
	
prgm_strings:
welcome db 'GoldOS File Manager 3.0', 0
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
	mov si, welcome_msg
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
	mov cx, welcome_msg
	mov dh, 0x64 ;delete file option (d key)
	mov dl, 0x72 ;rename file option (r key)
	mov si, 0x63 ;create file option (c key)
	int 0F8h
	
	;if escape is pressed, exit the file manager
	jc exit
	
	;if the carry flag does not set, these two lines will ensure that the file manager exits
	cmp ah, 0xFF
	je exit
	
	;find the file in the list
	mov byte [skip], al
	mov byte [selected_option], ah
	mov si, word [list_loc]

	mov ah, 0
	
calculate_location:
	mov cl, 12
	dec al
	mul cl

	add si, ax
	
	mov word [si_tmp], si
	
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
	
	mov si, filename
	
choose_option:
	cmp byte [selected_option], 0
	je open
	cmp byte [selected_option], 1
	je delete
	cmp byte [selected_option], 2
	je rename
	cmp byte [selected_option], 3
	je create
	ret ;just in case the menu returns an invalid option

;executes the file. must be binary file
open:
	;reads the file into memory
	mov ax, 2000h
	mov bx, si
	mov cx, 2000h
	mov dx, 0xA000
	mov di, 3
	int 0F5h
	
	jc io_error
	
	;clears screen
	mov bh, 0x0F
	mov di, 0xA
	int 0F1h
	
	;moves cursor to 0,0
	mov dx, 0
	mov di, 2
	int 0F1h
	
	;clears registers for program
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
	
	;calls the newly-loaded program
	call 2000h:0A000h
	
	;retf
	
	;sets video mode for return to file manager
	mov al, 3
	mov di, 0
	int 0F1h
	
	;clears screen for return to file manager
	mov bh, 0x0F
	mov di, 0xA
	int 0F1h
	
	;moves cursor to 0,0
	mov dx, 0
	mov di, 2
	int 0F1h
	
	;clears registers for return to file manager
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
	
	;reset variables used to load program
	mov byte [skip], 0
	mov byte [selected_option], 0
	
	jmp main
	
;creates new file after a dialogue box.
create:
	mov ax, 2000h
	mov bx, test_f
	mov di, 7
	int 0F5h
	
	jmp main
	
;deletes a file. will not delete system files.
delete:
	mov ax, 2000h
	mov bx, si
	mov di, 5
	int 0F5h
	
	jmp main
	
rename:

io_error:

exit:
retf

prgm_vars:
skip db 0
selected_option db 0
list_loc dw 0
ax_tmp dw 0
si_tmp dw 0
db 0
test_f db 'FAFSA   BIN', 0
filename times 13 db 0
	
prgm_strings:
welcome_msg db 'GoldOS File Manager 3.0 | ENTER = open, D = delete, C = create, R = rename', 0
error_msg db 'Error!', 0
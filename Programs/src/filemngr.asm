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
	
	;0xFF is the option in the menu to exit
	cmp ah, 0xFF
	je exit
	
	;resets cursor to bar and hides it
	mov di, 7
	int 0F1h
	mov di, 5
	int 0F1h
	
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
	mov cx, 3
	mov si, filename
	add si, 8
	mov di, bin_ext
	rep cmpsb
	jne error_not_bin
	
	mov cx, 11
	mov si, filename
	mov di, kernel_name
	rep cmpsb
	je error_sys_file
	
	mov cx, 11
	mov si, filename
	mov di, filemngr_name
	rep cmpsb
	je error_sys_file

	;reads the file into memory
	mov ax, 2000h
	mov bx, filename
	mov cx, 2000h
	mov dx, 0xA000
	mov di, 3
	int 0F5h
	
	;clears screen
	mov bl, 0x0F
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
	
	;sets video mode for return to file manager
	mov al, 3
	mov di, 0
	int 0F1h
	
	;clears screen for return to file manager
	mov bl, 0x0F
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
	mov di, 2
	mov ax, welcome_input_msg
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
	mov cx, welcome_ext_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	cmp al, 1
	je .txt
	cmp al, 2
	je .13h
	cmp al, 3
	je .pcx
	cmp al, 4
	je .py
	cmp al, 5
	je .asm
	cmp al, 6
	je .c
	cmp al, 7
	je .cpp
	cmp ah, 0xFF
	je main
	
.txt:
	mov si, txt
	mov di, filename
	add di, 8
	lodsb
	stosb
	lodsb
	stosb
	lodsb
	stosb
	jmp .replace_zeroes_setup

.13h:
	mov si, ext_13h
	mov di, filename
	add di, 8
	lodsb
	stosb
	lodsb
	stosb
	lodsb
	stosb
	jmp .replace_zeroes_setup

.pcx:
	mov si, pcx
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
	mov si, py
	mov di, filename
	add di, 8
	lodsb
	stosb
	lodsb
	stosb
	jmp .replace_zeroes_setup

.asm:
	mov si, asm
	mov di, filename
	add di, 8
	lodsb
	stosb
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
	mov si, cpp
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
	
;deletes a file. will not delete system files.
delete:
	mov ax, 2000h
	mov bx, filename
	mov di, 9
	int 0F5h
	
	cmp al, 0x04
	je error_sys_file
	
	mov ax, 2000h
	mov bx, filename
	mov di, 5
	int 0F5h
	
	jmp main
	
rename:
	mov di, 2
	mov ax, welcome_input_msg
	mov bl, 8
	int 0F8h
	
	cmp ah, 0xFF
	je main
	
	;write spaces to filename_rename
	mov al, ' '
	mov di, filename_rename
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
	
	;keep extension
	mov si, filename
	add si, 8
	mov di, filename_rename
	add di, 8
	lodsw
	stosw
	lodsb
	stosb
	
	;copy new file name
	mov si, bx
	mov di, filename_rename
	lodsw
	stosw
	lodsw
	stosw
	lodsw
	stosw
	lodsw
	stosw
	
	mov si, filename_rename
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
	mov si, filename_rename
	mov di, 3
	int 0F4h

	mov ax, 2000h
	mov bx, filename
	mov cx, 2000h
	mov dx, filename_rename
	mov di, 6
	int 0F5h
	
	jc error_io
	
.cancel:
	jmp main

error_io:
	mov di, 1
	mov ax, 2000h
	mov bx, error_io_msg
	mov cx, welcome_error_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	jmp main

error_sys_file:
	mov di, 1
	mov ax, 2000h
	mov bx, error_sys_file_msg
	mov cx, welcome_error_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h

	jmp main
	
error_not_bin:
	mov di, 1
	mov ax, 2000h
	mov bx, error_not_bin_msg
	mov cx, welcome_error_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h

	jmp main

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
filename_rename times 13 db 0
bin_ext db 'BIN', 0
kernel_name db 'KERNEL  BIN', 0
filemngr_name db 'FILEMNGRBIN', 0
txt db 'TXT', 0
pcx db 'PCX', 0
ext_13h db '13H', 0
py db 'PY', 0
asm db 'ASM', 0
c_ext db 'C', 0
cpp db 'CPP', 0
selected_title dw 0
	
prgm_strings:
welcome_msg db 'GoldOS File Manager 3.0 | ENTER = open, D = delete, C = create, R = rename      ', 0
welcome_error_msg db 'GoldOS File Manager 3.0 | Error! Press ENTER or ESCAPE to go back               ', 0
welcome_input_msg db 'GoldOS File Manager 3.0 | Create a new file or rename an existing file          ', 0
welcome_ext_msg db 'GoldOS File Manager 3.0 | Add an extension to your new file                     ', 0
error_io_msg db 'A disk error occured. Unable to handle request.', 0
error_sys_file_msg db 'Unable to modify system files.', 0
error_not_bin_msg db 'Unable to execute non-binary file.', 0
ext_list db 'TXT,13H,PCX,PY,ASM,C,CPP', 0
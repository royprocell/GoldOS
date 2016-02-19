;Roy Procell
;2/18/2016
;GoldOS config.bin

org 40960

main:
	;sets video mode
	mov di, 0
	mov al, 3
	int 0F1h
	
	;clears screen
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
	
	mov di, 1
	mov ax, 2000h
	mov bx, list
	mov cx, welcome
	mov dx, 0
	mov si, 0
	int 0F8h
	
	;resets cursor to bar and hides it
	mov di, 7
	int 0F1h
	mov di, 5
	int 0F1h
	
choose_option:
	cmp ah, 0xFF
	je exit
	cmp al, 1
	je setting_blinking
	cmp al, 2
	je setting_remove_entries
	jmp main
	
setting_blinking:
	mov word [selected_title], title1
	call screen_setup
	
	mov si, msg11
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg12
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg13
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg14
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	add dh, 14
	mov di, 2
	int 0F1h
	
	mov si, back_msg_1
	mov di, 0
	int 0F4h
	
	mov di, 0
	int 0F3h
	
	cmp al, '0'
	je .off
	
	cmp al, '1'
	je .on
	
	jmp main
	
.on:
	mov di, 0
	int 0F9h
	
	mov si, ax
	mov byte [ds:si], 1
	
	jmp main

.off:
	mov di, 0
	int 0F9h
	
	mov si, ax
	mov byte [ds:si], 0
	
	jmp main
	
setting_remove_entries:
	mov word [selected_title], title2
	call screen_setup
	
	mov si, msg21
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	add dh, 3
	mov di, 2
	int 0F1h
	
	mov si, msg22
	mov di, 0
	int 0F4h
	
	mov di, 0
	int 0F3h
	
	cmp al, '1'
	je .do_it
	
	jmp main
	
.do_it:
	mov di, 0xA
	int 0F5h
	jmp main

screen_setup:
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
	mov si, welcome
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
	
	mov si, [selected_title]
	mov di, 0
	int 0F4h
	
	mov dh, 4
	mov dl, 3
	mov di, 2
	int 0F1h
	
	ret
	
exit:
	retf
	
vars:
welcome db 'GoldOS Settings', 0
title1 db 'Blinking text', 0
title2 db 'Remove deleted entries', 0
list db 'Blinking text,Remove deleted entries', 0
msg11 db 'If you are running GoldOS on an older computer, it is likely that the', 0
msg12 db 'colors are reduced and most text is blinking.', 0
msg13 db 'If you have noticed this problem, press 1 to stop the blinking text.', 0
msg14 db 'If you wish to turn off this setting, press 0.', 0
msg21 db 'This option will remove deleted entries from your disk.', 0
msg22 db 'To proceed, press 1. To cancel, press any other button.', 0
back_msg db 'Press any key to go back.', 0
back_msg_1 db 'Press any key except 0 or 1 to go back without changing settings.', 0
selected_title dw 0
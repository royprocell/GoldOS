;Roy Procell
;2/18/2016
;GoldOS info.bin

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
	je what_can_goldos_do
	cmp al, 2
	je who_created_goldos
	cmp al, 3
	je what_do_specific_error_codes_mean
	cmp al, 4
	je the_colors_are_weird
	cmp al, 5
	je computer_restarts_or_hangs
	jmp main
	
what_can_goldos_do:
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
	
	inc dh
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg15
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg16
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg17
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	add dh, 11
	mov di, 2
	int 0F1h
	
	mov si, back_msg
	mov di, 0
	int 0F4h
	
	mov di, 0
	int 0F3h
	
	jmp main

who_created_goldos:
	mov word [selected_title], title2
	call screen_setup
	
	mov si, msg21
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg22
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg23
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg24
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg25
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg26
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg27
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg28
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg29
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg2A
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg2B
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg2C
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg2D
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	inc dh
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, back_msg
	mov di, 0
	int 0F4h
	
	mov di, 0
	int 0F3h
	
	jmp main

what_do_specific_error_codes_mean:
	mov word [selected_title], title3
	call screen_setup
	
	mov si, msg31
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg32
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	add dh, 17
	mov di, 2
	int 0F1h
	
	mov si, back_msg
	mov di, 0
	int 0F4h
	
	mov di, 0
	int 0F3h
	
	jmp main
	
the_colors_are_weird:
	mov word [selected_title], title4
	call screen_setup
	
	mov si, msg41
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg42
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg43
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg44
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg45
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
	
	mov di, 0
	int 0F3h
	
	jmp main
	
computer_restarts_or_hangs:
	mov word [selected_title], title5
	call screen_setup
	
	mov si, msg51
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg52
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	inc dh
	mov di, 2
	int 0F1h
	
	mov si, msg53
	mov di, 0
	int 0F4h
	
	mov di, 3
	int 0F1h
	
	add dh, 16
	mov di, 2
	int 0F1h
	
	mov si, back_msg
	mov di, 0
	int 0F4h
	
	mov di, 0
	int 0F3h
	
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
welcome db 'Welcome to GoldOS! What would you like to know?', 0
title1 db 'What can GoldOS do?', 0
title2 db 'Who created GoldOS?', 0
title3 db 'What do specific error codes mean?', 0
title4 db "The colors are weird and everything is blinking. What's happening?", 0
title5 db "When I shutdown my computer it either restarts or hangs! Why's that?", 0
selected_title dw 0
msg11 db 'At the moment, GoldOS is under development.', 0
msg12 db 'This means that not all features have been added yet.', 0
msg13 db 'However, this is a complete list of features that will', 0
msg14 db "hopefully be added to GoldOS once it's finished:", 0
msg15 db 'File manager, text editor, image editor, calculator,', 0
msg16 db 'demo programs, sound support, basic network support,', 0
msg17 db 'graphics primitives, and a simple game.', 0
msg21 db 'GoldOS was created by Roy Procell back in 2013. He was interested in how', 0
msg22 db 'operating systems worked, and decided to teach himself assembly language.', 0
msg23 db 'Since then, he has worked on three versions of GoldOS: Versions 1, 2,', 0
msg24 db 'and 4, with each iteration having cleaner code and better user interfaces.', 0
msg25 db 'While versions 1 and 2 were never finished, Roy hopes to finish this', 0
msg26 db 'current version (Version 4) very soon.', 0
msg27 db 'GoldOS was inspired by MikeOS, a 16 bit OS project by Mike Saunders.', 0
msg28 db "GoldOS also inspired one of Roy's friends, Brian Kelley, to create GoldOS", 0
msg29 db 'Version 3: a 32 bit operating system.', 0
msg2A db 'Useful operating system development websites:', 0
msg2B db 'mikeos.sourceforge.net, wiki.osdev.org,', 0
msg2C db "Ralph Brown's Interrupt List,", 0
msg2D db 'and last but not least: Google & Wikipedia', 0
msg31 db 'GoldOS does not yet support error codes.', 0
msg32 db 'However, they may be added at a later date.', 0
msg41 db "You are probably running GoldOS on an older computer that doesn't", 0
msg42 db 'support the full range of colors for VGA. Fortunately, GoldOS has', 0
msg43 db 'a setting that will stop text from blinking on older computers.', 0
msg44 db 'Check out the settings option on the home screen to change this', 0
msg45 db 'setting.', 0
msg51 db "GoldOS's power management drivers might not be completely compatible", 0
msg52 db 'with your computer. There is no way to fix this other than manually', 0
msg53 db 'shutting down your computer by holding down the power button.', 0
back_msg db 'Press any key to go back.', 0
list db "What can GoldOS do?,Who created GoldOS?,What do specific error codes mean?,The colors are weird and everything is blinking. What's happening?,When I shutdown my computer it either restarts or hangs! Why's that?", 0
;GoldOS 4.0 Setup File
;
;Roy Procell
;7/21/2015
;
;Sets up the stack and interrupts for GoldOS.
stack_setup:
	cli
	mov ax, 2000h
	mov ss, ax
	mov sp, stack+4096
	sti
	cld
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov byte [os_disk_num], dl
	
interrupt_setup:
	cli
	mov ax, 0x0000
	mov gs, ax
	;program int F1h
	mov si, 0x3C4
	mov ax, intF1h_enter
	mov bx, 2000h
	mov word [gs:si], ax
	inc si
	inc si
	mov word [gs:si], bx
	;program int F2h
	mov si, 0x3C8
	mov ax, intF2h_enter
	mov bx, 2000h
	mov word [gs:si], ax
	inc si
	inc si
	mov word [gs:si], bx
	;program int F3h
	mov si, 0x3CC
	mov ax, intF3h_enter
	mov bx, 2000h
	mov word [gs:si], ax
	inc si
	inc si
	mov word [gs:si], bx
	;program int F4h
	mov si, 0x3D0
	mov ax, intF4h_enter
	mov bx, 2000h
	mov word [gs:si], ax
	inc si
	inc si
	mov word [gs:si], bx
	;program int F5h
	mov si, 0x3D4
	mov ax, intF5h_enter
	mov bx, 2000h
	mov word [gs:si], ax
	inc si
	inc si
	mov word [gs:si], bx
	;program int F6h
	mov si, 0x3D8
	mov ax, intF6h_enter
	mov bx, 2000h
	mov word [gs:si], ax
	inc si
	inc si
	mov word [gs:si], bx
	;program int F7h
	mov si, 0x3DC
	mov ax, intF7h_enter
	mov bx, 2000h
	mov word [gs:si], ax
	inc si
	inc si
	mov word [gs:si], bx
	;program int F8h
	mov si, 0x3E0
	mov ax, intF8h_enter
	mov bx, 2000h
	mov word [gs:si], ax
	inc si
	inc si
	mov word [gs:si], bx
	;program int F9h
	mov si, 0x3E4
	mov ax, intF9h_enter
	mov bx, 2000h
	mov word [gs:si], ax
	inc si
	inc si
	mov word [gs:si], bx
	
	;program int 1Bh
	mov si, 0x6C
	mov ax, int1Bh_enter
	mov bx, 2000h
	mov word [gs:si], ax
	inc si
	inc si
	mov word [gs:si], bx
	
	;program int 05h
	mov si, 20
	mov ax, int05h_enter
	mov bx, 2000h
	mov word [gs:si], ax
	inc si
	inc si
	mov word [gs:si], bx
	
	sti
	
program_setup:
	mov ax, 2000h
	mov bx, os_file_file
	mov cx, 2000h
	mov dx, 9000h
	call fat_file_read
	jc fatal_error
	
	
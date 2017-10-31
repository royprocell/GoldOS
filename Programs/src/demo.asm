;Roy Procell
;7/1/2016
;GoldOS demo programs

;Features:
;moving_pixel (done!)
;infinite_boxes (done!)
;regular_radar (done!)
;colorful_radar (done!)
;colorful_screensaver (done!)
;bouncy (done!)

org 40960

main:
	mov ax, 2000h
	mov bx, list
	mov cx, welcome_msg
	mov dx, 0
	mov si, 0
	mov di, 1
	int 0F8h
	
	cmp ah, 0xFF
	je exit
	
	cmp al, 1
	je moving_pixel
	cmp al, 2
	je infinite_boxes
	cmp al, 3
	je regular_radar
	cmp al, 4
	je colorful_radar
	cmp al, 5
	je colorful_screensaver
	cmp al, 6
	je bouncy
	
moving_pixel:
	mov di, 1
	int 0F3h
	cmp ah, 27
	je main

	mov di, 0
	mov al, 13h
	int 0F1h
	mov di, 2
	mov bl, 0
	int 0F2h
	mov ax, 0xFFFF
	mov bx, 100
	mov di, 0
	mov cl, 0x19
	
.loop:
	inc ax
	cmp ax, 320
	jae .overflow
	cmp cl, 0x67
	jae .color_overflow
	
.draw:
	inc cl
	int 0F2h
	pusha
	dec ax
	mov cl, 0
	int 0F2h
	mov di, 5
	;wait 50k microseconds
	mov cx, 0x0000
	mov dx, 50000
	int 0F8h
	popa
	jmp .loop
	
.overflow:
	mov ax, 0xFFFF
	pusha
	mov ax, 319
	mov cl, 0
	int 0F2h
	popa
	jmp .loop
	
.color_overflow:
	mov cl, 0x19
	jmp .draw

infinite_boxes:
	mov al, 13h
	mov di, 0
	int 0F1h

.loop:
	mov di, 6
	mov ax, 255
	mov bx, 0
	int 0F8h
	mov byte [.color], al
	
	mov di, 6
	mov ax, 319
	mov bx, 0
	int 0F8h
	mov word [.width], ax
	
	mov di, 6
	mov ax, 319
	mov bx, 0
	int 0F8h
	mov word [.height], ax
	
	mov di, 6
	mov ax, 319
	mov bx, 0
	int 0F8h
	mov word [.draw_loc_x], ax
	
	mov di, 6
	mov ax, 199
	mov bx, 0
	int 0F8h
	mov word [.draw_loc_y], ax
	
	mov di, 5
	mov bx, word [.draw_loc_x]
	mov cx, word [.draw_loc_y]
	mov dx, word [.width]
	mov si, word [.height]
	mov al, byte [.color]
	int 0F2h
	
	mov dh, 0
	mov dl, 0
	mov di, 2
	int 0F1h
	
	mov si, .msg
	mov di, 0
	int 0F4h
	
	mov cx, 0
	mov dx, 0xFFFF
	mov di, 5
	int 0F8h
	
	jmp .loop

.msg db 'Infinite boxes!', 0
.color db 0
.width dw 0
.height dw 0
.draw_loc_x dw 0
.draw_loc_y dw 0
	
regular_radar:
	mov di, 0
	mov al, 13h
	int 0F1h

	mov ax, 160
	mov bx, 100
	mov si, 0
	mov dx, 0
	mov cl, 43

	mov word [.bx], bx
	
.inc_y_loop:
	mov di, 2
	mov bl, 0
	int 0F2h
	mov bx, word [.bx]
	cmp dx, 200
	je .inc_x_loop
	call .save_line_data
	mov di, 3
	int 0F2h
	mov di, 5
	;wait 50k microseconds
	mov cx, 0x0000
	mov dx, 50000
	int 0F8h
	call .load_line_data
	inc dx
	jmp .inc_y_loop

.inc_x_loop:
	mov di, 2
	mov bl, 0
	int 0F2h
	mov bx, word [.bx]
	cmp si, 320
	je .dec_y_loop
	call .save_line_data
	mov di, 3
	int 0F2h
	mov di, 5
	;wait 50k microseconds
	mov cx, 0x0000
	mov dx, 50000
	int 0F8h
	call .load_line_data
	inc si
	jmp .inc_x_loop

.dec_y_loop:
	mov di, 2
	mov bl, 0
	int 0F2h
	mov bx, word [.bx]
	cmp dx, -1
	je .dec_x_loop
	call .save_line_data
	mov di, 3
	int 0F2h
	mov di, 5
	;wait 50k microseconds
	mov cx, 0x0000
	mov dx, 50000
	int 0F8h
	call .load_line_data
	dec dx
	jmp .dec_y_loop

.dec_x_loop:
	mov di, 2
	mov bl, 0
	int 0F2h
	mov bx, word [.bx]
	cmp si, -1
	je .inc_y_loop
	call .save_line_data
	mov di, 3
	int 0F2h
	mov di, 5
	;wait 50k microseconds
	mov cx, 0x0000
	mov dx, 50000
	int 0F8h
	call .load_line_data
	dec si
	jmp .dec_x_loop

.dx dw 0
.bx dw 0
.x1 dw 0
.y1 dw 0
.x2 dw 0
.y2 dw 0
.cl db 0

.load_line_data:
	mov ax, word [.x1]
	mov bx, word [.y1]
	mov si, word [.x2]
	mov dx, word [.y2]
	mov cl, byte [.cl]
	ret

.save_line_data:
	mov word [.x1], ax
	mov word [.y1], bx
	mov word [.x2], si
	mov word [.y2], dx
	mov byte [.cl], cl
	ret
	
colorful_radar:
	mov di, 0
	mov al, 13h
	int 0F1h

	mov ax, 160
	mov bx, 100
	mov si, 0
	mov dx, 0
	mov cl, 0

	mov word [.bx], bx
	
.inc_y_loop:
	inc cl
	mov bx, word [.bx]
	cmp dx, 200
	je .inc_x_loop
	call .save_line_data
	mov di, 3
	int 0F2h
	mov di, 5
	;wait 50k microseconds
	mov cx, 0x0000
	mov dx, 50000
	int 0F8h
	call .load_line_data
	inc dx
	jmp .inc_y_loop

.inc_x_loop:
	inc cl
	mov bx, word [.bx]
	cmp si, 320
	je .dec_y_loop
	call .save_line_data
	mov di, 3
	int 0F2h
	mov di, 5
	;wait 50k microseconds
	mov cx, 0x0000
	mov dx, 50000
	int 0F8h
	call .load_line_data
	inc si
	jmp .inc_x_loop

.dec_y_loop:
	inc cl
	mov bx, word [.bx]
	cmp dx, -1
	je .dec_x_loop
	call .save_line_data
	mov di, 3
	int 0F2h
	mov di, 5
	;wait 50k microseconds
	mov cx, 0x0000
	mov dx, 50000
	int 0F8h
	call .load_line_data
	dec dx
	jmp .dec_y_loop

.dec_x_loop:
	inc cl
	mov bx, word [.bx]
	cmp si, -1
	je .inc_y_loop
	call .save_line_data
	mov di, 3
	int 0F2h
	mov di, 5
	;wait 50k microseconds
	mov cx, 0x0000
	mov dx, 50000
	int 0F8h
	call .load_line_data
	dec si
	jmp .dec_x_loop

.dx dw 0
.bx dw 0
.x1 dw 0
.y1 dw 0
.x2 dw 0
.y2 dw 0
.cl db 0

.load_line_data:
	mov ax, word [.x1]
	mov bx, word [.y1]
	mov si, word [.x2]
	mov dx, word [.y2]
	mov cl, byte [.cl]
	ret

.save_line_data:
	mov word [.x1], ax
	mov word [.y1], bx
	mov word [.x2], si
	mov word [.y2], dx
	mov byte [.cl], cl
	ret

colorful_screensaver:
	mov di, 1
	int 0F3h
	cmp ah, 27
	je main

	mov di, 0
	mov al, 13h
	int 0F1h
	mov di, 2
	mov bl, 0
	int 0F2h
	mov bl, 0x20
	
.loop_forward:
	cmp bl, 0x67
	je .loop_backward
	int 0F2h
	inc bl
	pusha
	mov cx, 1
	mov dx, 1000011010100000b
	mov di, 5
	int 0F8h
	popa
	jmp .loop_forward
	
.loop_backward:
	cmp bl, 0x20
	je .loop_forward
	int 0F2h
	dec bl
	pusha
	mov cx, 1
	mov dx, 1000011010100000b
	mov di, 5
	int 0F8h
	popa
	jmp .loop_backward

bouncy:
	;set video mode
	mov di, 0
	mov al, 13h
	int 0F1h
	;load image file into memory
	mov di, 3
	mov ax, 2000h
	mov bx, file_ball
	mov cx, 3000h
	mov dx, 0
	int 0F5h
	
.render:
	mov di, 1
	int 0F3h
	cmp ah, 27
	je main

	;wait
	mov di, 5
	mov cx, 0x0001
	mov dx, 0;50000
	int 0F8h

	;clear screen
	mov di, 2
	mov bl, 0
	int 0F2h

	;draw the image
	mov di, 7
	mov ax, word [.x]
	mov bx, word [.y]
	mov cx, 3000h
	mov gs, cx
	mov si, 0
	int 0F2h
	
.update_acceleration:
	cmp word [.y], 184
	jae .reverse_acceleration
	add word [.dy], 10
	jmp .finished_anim

.hit_bottom:
	mov dx, 184
	mov word [.y], dx
	jmp .render

.reverse_acceleration:
	mov ax, word [.dy]
	mov bx, -1
	imul bx
	add ax, 10
	mov word [.dy], ax
	
.finished_anim:
	mov dx, word [.dx]
	add word [.x], dx
	mov dx, word [.dy]
	add word [.y], dx
	;if our next x value is too big, reset the animation
	cmp word [.x], 304
	jae .reset
	;if the next y value is at 184 or greater, we have hit the bottom
	;adjust the y value accordinly and jump to .hit_bottom
	cmp word [.y], 184
	jae .hit_bottom
	jmp .render
	
.reset:
	mov dx, 0
	mov word [.x], dx
	mov word [.y], dx
	mov word [.dy], dx
	jmp .render

.x dw 0
.y dw 0
.dx dw 7
.dy dw 0

exit:
	retf

vars:
welcome_msg db 'GoldOS Demo Programs | WARNING: WILL LOCK UP COMPUTER', 0
instructions_msg db 'Choose a demo program to see some cool graphical effects!', 0
list db 'Moving Pixel,Infinite Boxes,Radar,Colorful Radar,Screensaver,Bouncy', 0
file_logo db 'LOGO    13H', 0
file_ball db 'BALL    13H', 0
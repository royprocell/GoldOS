;Roy Procell
;6/30/2016
;GoldOS calculator

org 40960

main:
	;set all variables to zero
	call .clear_vars

	;set the video mode
	mov di, 0
	mov al, 3
	int 0F1h
	
	;let the user type in an equation
	mov di, 03h
	mov ax, welcome_msg
	mov bl, 21
	int 0F8h
	
	cmp ah, 0xFF
	je exit
	
	mov word [str_input_loc], bx
	
	jmp parse
	
.clear_vars:
	mov cx, 67
	mov di, num_one
	mov al, 0
	rep stosb
	ret
	
parse:
	mov si, bx
	
	;check to see if the user put an operation symbol first
	mov al, byte [ds:si]
	cmp al, 47
	jbe error_not_equation
	cmp al, 58
	jae error_not_equation
	
	mov cx, 11
	mov di, str_one
	
.first_loop:
	cmp cx, 0
	je error_overflow
	mov al, byte [ds:si]
	cmp al, 0
	je no_operation
	cmp al, 47
	jbe .operation_loop
	cmp al, 58
	jae .operation_loop
	mov byte [ds:di], al
	inc si
	inc di
	dec cx
	jmp .first_loop
	
.operation_loop:
	mov bl, 0
	mov byte [ds:di], bl
	
	cmp al, '+'
	je .set_op_add
	cmp al, '-'
	je .set_op_sub
	cmp al, '*'
	je .set_op_mul
	cmp al, '/'
	je .set_op_div
	cmp al, '^'
	je .set_op_exp
	
	jmp error_not_equation
	
.set_op_add:
	mov al, 1
	mov byte [operation], al
	jmp .post_operation_loop

.set_op_sub:
	mov al, 2
	mov byte [operation], al
	jmp .post_operation_loop
	
.set_op_mul:
	mov al, 3
	mov byte [operation], al
	jmp .post_operation_loop
	
.set_op_div:
	mov al, 4
	mov byte [operation], al
	jmp .post_operation_loop
	
.set_op_exp:
	mov al, 5
	mov byte [operation], al
	jmp .post_operation_loop
	
.post_operation_loop:
	inc si
	mov di, str_two
	mov cx, 11
	
.second_loop:
	cmp cx, 0
	je error_overflow
	mov al, byte [ds:si]
	cmp al, 0
	je .done
	cmp al, 47
	jbe error_too_long
	cmp al, 58
	jae error_too_long
	mov byte [ds:di], al
	inc si
	inc di
	dec cx
	jmp .second_loop
	
.done:
	cmp byte [operation], 0
	je no_operation
	cmp byte [operation], 1
	je addition
	cmp byte [operation], 2
	je subtraction
	cmp byte [operation], 3
	je multiplication
	cmp byte [operation], 4
	je division
	cmp byte [operation], 5
	je exponent
	
no_operation:	;copies str_one to str_ans because no operation was specified.
	mov si, str_one
	mov di, str_ans
	
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
	
	mov ax, str_ans
	mov word [str_ans_loc], ax
	
	jmp print_results
	
addition:
	mov ax, 2000h
	mov bx, str_one
	mov di, 5
	int 0F4h
	mov dword [num_one], eax
	mov ax, 2000h
	mov bx, str_two
	mov di, 5
	int 0F4h
	mov dword [num_two], eax
	mov eax, dword [num_one]
	mov ebx, dword [num_two]
	add eax, ebx
	jo error_overflow
	mov di, 6
	int 0F4h
	mov word [str_ans_loc], ax
	
	jmp print_results

subtraction:
	mov ax, 2000h
	mov bx, str_one
	mov di, 5
	int 0F4h
	mov dword [num_one], eax
	mov ax, 2000h
	mov bx, str_two
	mov di, 5
	int 0F4h
	mov dword [num_two], eax
	mov eax, dword [num_one]
	mov ebx, dword [num_two]
	sub eax, ebx
	jo error_overflow
	jc .is_negative
	mov di, 6
	int 0F4h
	mov word [str_ans_loc], ax
	
	jmp print_results
	
.is_negative:	;the answer overflowed because its negative.
	not eax
	inc eax
	mov di, 6
	int 0F4h
	mov word [str_ans_loc], ax
	
	mov al, 1
	mov byte [negative], al
	
	jmp print_results

multiplication:
	mov ax, 2000h
	mov bx, str_one
	mov di, 5
	int 0F4h
	mov dword [num_one], eax
	mov ax, 2000h
	mov bx, str_two
	mov di, 5
	int 0F4h
	mov dword [num_two], eax
	mov eax, dword [num_one]
	mov ebx, dword [num_two]
	mul ebx
	jo error_overflow
	mov di, 6
	int 0F4h
	mov word [str_ans_loc], ax
	
	jmp print_results

division:
	mov ax, 2000h
	mov bx, str_one
	mov di, 5
	int 0F4h
	mov dword [num_one], eax
	mov ax, 2000h
	mov bx, str_two
	mov di, 5
	int 0F4h
	cmp eax, 0
	je .divide_by_zero
	mov dword [num_two], eax
	mov eax, dword [num_one]
	mov ebx, dword [num_two]
	mov edx, 0
	div ebx
	jo error_overflow
	mov di, 6
	int 0F4h
	
	;we have to move the answer because otherwise it will be overwritten by the remainder!
	mov si, ax
	mov di, str_two
	
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
	
	mov ax, str_two
	
	mov word [str_ans_loc], ax
	
	mov di, 6
	mov eax, edx
	int 0F4h
	mov word [str_rem_loc], ax
	
	jmp print_results
	
.divide_by_zero:
	mov ax, .msg
	mov word [str_ans_loc], ax
	jmp print_results
	
.msg db 'You stumped me. Happy now?', 0

exponent:
	mov ax, 2000h
	mov bx, str_one
	mov di, 5
	int 0F4h
	mov dword [num_one], eax
	mov dword [.tmp], eax
	mov ax, 2000h
	mov bx, str_two
	mov di, 5
	int 0F4h
	cmp eax, 0
	je .exp_is_zero
	mov dword [num_two], eax
	mov eax, dword [num_one]
	mov ecx, dword [num_two]
	dec ecx
	
.mul_loop:
	mov ebx, dword [.tmp]
	cmp ecx, 0
	je .done
	mul ebx
	jo error_overflow
	dec ecx
	jmp .mul_loop
	
.exp_is_zero:
	mov eax, 1
	
.done:
	mov di, 6
	int 0F4h
	mov word [str_ans_loc], ax
	
	jmp print_results
	
.tmp dd 0

print_results:
	;clear the screen
	mov bl, 0x70
	mov di, 0xA
	int 0F1h

	mov bl, 0x83
	mov dh, 0
	mov di, 0xC
	int 0F1h
	;call os_draw_border
	mov bl, 0x83
	mov dh, 1
	int 0F1h
	;call os_draw_border
	mov dx, 0
	mov di, 2
	int 0F1h
	;call os_move_cursor
	mov si, welcome_msg
	mov di, 0
	int 0F4h
	;call os_print_string
	mov dh, 1
	mov dl, 0
	mov di, 2
	int 0F1h
	;call os_move_cursor
	mov si, back_msg
	mov di, 0
	int 0F4h
	;call os_print_string
	
	mov bl, 0x83
	mov dh, 3
	mov dl, 1
	mov cl, 78
	mov ax, 5
	mov di, 0xE
	int 0F1h
	;call os_draw_box
	
	mov bl, 0xF0
	mov dh, 4
	mov dl, 2
	mov cl, 76
	mov ax, 3
	mov di, 0xE
	int 0F1h
	
	;move cursor
	mov dh, 4
	mov dl, 2
	mov di, 2
	int 0F1h
	
	;draw equation, answer, and remainder
	mov si, equation_msg
	mov di, 0
	int 0F4h
	mov si, [str_input_loc]
	int 0F4h
	
	mov dh, 5
	mov dl, 2
	mov di, 2
	int 0F1h
	
	mov si, answer_msg
	mov di, 0
	int 0F4h
	cmp byte [negative], 1
	je .add_negative_sign
	mov si, [str_ans_loc]
	int 0F4h
	
	jmp .not_negative
	
.add_negative_sign:
	mov al, '-'
	mov di, 1
	int 0F4h
	mov si, [str_ans_loc]
	mov di, 0
	int 0F4h
	
.not_negative:
	mov dh, 6
	mov dl, 2
	mov di, 2
	int 0F1h
	
	mov si, remainder_msg
	mov di, 0
	int 0F4h
	cmp word [str_rem_loc], 0
	jne .remainder
	jmp .no_remainder
	
.remainder:
	mov si, [str_rem_loc]
	int 0F4h
	
.no_remainder:
	mov di, 0
	int 0F3h
	
	;clean the locations of the converted strings
	mov cx, 11
	mov di, [str_input_loc]
	mov al, 0
	rep stosb
	
	mov cx, 11
	mov di, [str_ans_loc]
	mov al, 0
	rep stosb
	
	mov cx, 11
	mov di, [str_rem_loc]
	mov al, 0
	rep stosb
	
	jmp main
	
error_not_equation:
	mov di, 1
	mov ax, 2000h
	mov bx, error_not_equation_msg
	mov cx, welcome_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	jmp main

error_overflow:
	mov di, 1
	mov ax, 2000h
	mov bx, error_overflow_msg
	mov cx, welcome_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	jmp main
	
error_too_long:
	mov di, 1
	mov ax, 2000h
	mov bx, error_too_long_msg
	mov cx, welcome_msg
	mov dh, 0
	mov dl, 0
	mov si, 0
	int 0F8h
	
	jmp main
	
exit:
	retf

vars:
welcome_msg db 'GoldOS Calculator 1.0', 0
instructions_msg db 'Enter an equation and press enter.', 0
equation_msg db 'Equation: ', 0
answer_msg db 'Answer: ', 0
remainder_msg db 'Remainder: ', 0
back_msg db 'Press any key to enter a new equation.', 0
error_not_equation_msg db 'Error: Not a valid equation!', 0
error_overflow_msg db 'Error: Overflow!', 0
error_too_long_msg db 'Error: Equation has too many operations!', 0

operation db 0	;0 = no operation, 1 = addition, 2 = subtraction, 3 = multiplication, 4 = division, 5 = exponent

num_one dd 0
num_two dd 0
num_ans dd 0
num_rem dd 0

str_one times (11) db 0
str_two times (11) db 0
str_ans times (11) db 0
str_rem times (11) db 0

str_input_loc dw 0
str_ans_loc dw 0
str_rem_loc dw 0

negative db 0
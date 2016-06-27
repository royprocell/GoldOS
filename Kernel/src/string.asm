;==============================
;GoldElfOS: Mk II
;
;Roy Procell
;2 May 2015
;
;Updated 7/18/2015 for GoldOS Mk IV
;
;String Manipulation System Calls
;Strings.asm
;
;Features:
;Strings:
;os_convert_string_upper (done!)
;os_convert_string_lower (done!)
;os_string_to_int
;os_int_to_string
;os_hex_to_ascii
;os_ascii_to_hex
;os_string_length (done!)
;os_string_truncate
;os_string_copy
;os_print_registers
;os_print_time
;==============================

;==================
;os_convert_string_upper
;Converts the specified string to upper case chars
;IN:	AX: string segment, SI: string address
;OUT:	Nothing
;==================
os_convert_string_upper:
	pusha
	mov es, ax
	
.convert:
	cmp byte [es:si], 0
	je .done
	cmp byte [es:si], 'a'
	jb .skip
	cmp byte [es:si], 'z'
	ja .skip
	sub byte [es:si], 20h
	inc si
	jmp .convert
	
.skip:
	inc si
	jmp .convert
	
.done:
	popa
	ret

;==================
;os_convert_string_lower
;Converts the specified string to upper case chars
;IN:	AX: string segment, SI: string address
;OUT:	Nothing
;==================
os_convert_string_lower:
	pusha
	mov es, ax
	
.convert:
	cmp byte [es:si], 0
	je .done
	cmp byte [es:si], 'a'
	jb .skip
	cmp byte [es:si], 'z'
	ja .skip
	add byte [es:si], 20h
	inc si
	jmp .convert
	
.skip:
	inc si
	jmp .convert
	
.done:
	popa
	ret
	
;==================
;os_string_length
;Counts how many chars are in a string
;IN: AX: segment of string, BX: offset of string
;OUT: CX: length of string
;==================
os_string_length:
	pusha
	mov es, ax
	mov si, bx
	mov cx, 0
	
.count_loop:
	cmp byte [es:si], 0
	je .done
	inc si
	inc cx
	jmp .count_loop
	
.done:
	mov word [.cx], cx
	popa
	mov cx, word [.cx]
	ret
	
.cx dw 0

;==================
;os_string_to_int
;Converts a decimal string into an integer
;IN: AX: segment of integer string, BX: offset of integer string
;OUT: EAX: integer
;==================
os_string_to_int:
	pusha
	call os_string_length
	add bx, cx
	mov si, bx
	dec si
	mov word [.count], cx
	mov es, ax
	mov dword [.mult], 1
	mov ebx, 0
	
.loop:
	mov eax, 0
	cmp word [.count], 0
	je .done
	mov al, byte [es:si]
	sub al, '0'
	mul dword [.mult]
	add ebx, eax
	mov eax, dword [.mult]
	mov edx, 10
	mul edx
	mov dword [.mult], eax
	dec word [.count]
	dec si
	jmp .loop
	
.done:
	mov dword [.mult], ebx
	popa
	mov eax, dword [.mult]
	ret
	
.mult dd 0
.count dw 0

;==================
;os_int_to_string
;Converts an integer into a decimal string
;Integer must be four bytes long
;IN: EAX: integer
;OUT: AX: string location
;==================
os_int_to_string:
	pusha
	;mov dx, 0
	;mov cx, 11
	;mov di, .number
	;rep stosb
	
	mov edx, 0
	mov ebx, 10
	mov cx, 9
	
.divide:	;divide eax by ebx, where the result is eax and the remainder is edx.
	cmp cx, 0xFFFF
	je .done
	mov di, .number
	add di, cx
	div ebx
	add dl, '0'
	mov byte [ds:di], dl
	mov edx, 0
	dec cx
	
	cmp eax, 0
	je .last_remainder
	
	jmp .divide
	
.last_remainder:
	cmp edx, 0
	je .done
	
	mov di, .number
	add dl, '0'
	mov byte [ds:di], dl
	
.done:
	mov di, .string
	mov si, .number
	mov cx, 11
	
.loop:
	cmp byte [ds:si], 0
	je .move_up
	jmp .copy
	
.move_up:
	inc si
	dec cx
	jmp .loop
	
.copy:
	lodsb
	stosb
	loop .copy
	
	mov byte [es:di], 0
	
	popa
	mov ax, .string
	ret
	
db 'NUMBER'
.number times (11) db 0
.string times (11) db 0
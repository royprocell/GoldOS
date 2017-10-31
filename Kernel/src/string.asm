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
;os_string_to_int (done!)
;os_int_to_string (done!)
;os_hex_to_int (done!)
;os_int_to_hex (done!)
;os_string_length (done!)
;os_string_truncate (done, untested!)
;os_string_copy (done, untested!)
;os_string_copy_num (done, untested!)
;os_print_registers (done!)
;os_print_time (done!)
;os_print_date (done!)
;
;os_strcat (done, untested!)
;os_strchr (done, untested!)
;os_strcmp (done, untested!)
;==============================

;==================
;os_convert_string_upper
;Converts the specified string to upper case chars
;IN:	AX: string segment, SI: string address
;OUT:	Nothing
;==================
os_convert_string_upper:
	pusha
	mov fs, ax
	
.convert:
	cmp byte [fs:si], 0
	je .done
	cmp byte [fs:si], 'a'
	jb .skip
	cmp byte [fs:si], 'z'
	ja .skip
	sub byte [fs:si], 20h
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
	mov fs, ax
	
.convert:
	cmp byte [fs:si], 0
	je .done
	cmp byte [fs:si], 'a'
	jb .skip
	cmp byte [fs:si], 'z'
	ja .skip
	add byte [fs:si], 20h
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
	mov fs, ax
	mov si, bx
	mov cx, 0
	
.count_loop:
	cmp byte [fs:si], 0
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
	mov fs, ax
	mov dword [.mult], 1
	mov ebx, 0
	
.loop:
	mov eax, 0
	cmp word [.count], 0
	je .done
	mov al, byte [fs:si]
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

	pusha
	mov cx, 11
	mov di, .number
	mov al, 0
	rep stosb
	popa
	
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

;==================
;os_hex_to_int
;Converts a hex string into an integer
;IN: AX: segment of hex string, BX: offset of hex string
;OUT: EAX: integer
;==================
os_hex_to_int:
	pusha
	mov si, bx
	call os_convert_string_upper
	call os_string_length
	add bx, cx
	mov si, bx
	dec si
	mov word [.count], cx
	mov fs, ax
	mov dword [.mult], 1
	mov ebx, 0
	
.loop:
	mov eax, 0
	cmp word [.count], 0
	je .done
	mov al, byte [fs:si]
	
	cmp al, 64
	jg .hex_char
	sub al, '0'
	jmp .norm_char

.hex_char:
	sub al, '7'

.norm_char:
	mul dword [.mult]
	add ebx, eax
	mov eax, dword [.mult]
	mov edx, 16
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
;os_int_to_hex
;Converts an integer into a hex string
;Integer must be four bytes long
;IN: EAX: integer
;OUT: AX: string location
;==================
os_int_to_hex:
	pusha

	pusha
	mov cx, 11
	mov di, .number
	mov al, 0
	rep stosb
	popa
	
	mov edx, 0
	mov ebx, 16
	mov cx, 9
	
.divide:	;divide eax by ebx, where the result is eax and the remainder is edx.
	cmp cx, 0xFFFF
	je .done
	mov di, .number
	add di, cx
	div ebx
	
	cmp dl, 9
	jg .hex_char
	add dl, '0'
	jmp .norm_char
	
.hex_char:
	add dl, '7'
	
.norm_char:
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
	
db 'NUMBERHEX'
.number times (11) db 0
.string times (11) db 0

;==================
;os_strcmp
;Compares two strings to see if they are equal
;IN: AX: segment of string 1, BX: location of string 1, CX: segment of string 2, DX: location of string 2
;OUT: Nothing, Carry Flag set on failure
;==================
os_strcmp:
	pusha
	mov word [.name1], bx
	mov word [.name2], dx
	mov ds, ax
	mov es, cx
	
.setup:
	mov cx, 1
	mov ax, 0
	mov dx, 0
	mov di, [.name2]
	
.search_loop:
	xchg cx, dx
	mov cx, 11
	mov si, word [.name1]
	rep cmpsb
	je .found
	add ax, 32
	mov di, fs_buffer
	add di, ax
	xchg dx, cx
	loop .search_loop
	stc
	ret
	
.found:
	clc
	sub di, 11
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	popa
	ret
	
.name1 dw 0
.name2 dw 0

;==================
;os_strcat
;Concatenates two strings. Only up to 256 chars!
;IN: AX: segment of string 1, BX: offset of string 1, CX: segment of string 2, DX: offset of string 2
;OUT: AX: segment of new string, BX: location of new string
;==================
os_strcat:
	;get length of first string
	call os_string_length
	mov word [.string1_length], cx
	
	;copy first string into .new_string
	pusha
	mov cx, 2000h
	mov dx, .new_string
	call os_string_copy
	popa
	
	;mov si, 256
	;sub si, word [.string1_length]
	;NEEDS WORK
	
	mov ax, cx
	mov bx, dx
	mov cx, 2000h
	mov dx, word [.string1_length]
	add dx, si
	
	call os_string_copy_num
	
	ret
	
.string1 dw 0
.string2 dw 0
.new_string times 257 db 0
.string1_length dw 0

;==================
;os_string_copy
;Copies one string into another.
;User is responsible for providing adequate space to copy.
;IN: AX: segment of string, BX: offset of string, CX: segment of string copy, DX: offset of string copy
;OUT: AX: segment of copied string, BX: location of end of copied string
;==================
os_string_copy:
	pusha
	;prepare segments to copy
	mov fs, ax
	mov gs, cx
	
	;prepare source and destination indexes
	mov si, bx
	mov di, dx
	;clear dl, we will use it
	mov dl, 0
	
.copy_loop:
	mov dl, byte [fs:si]
	mov byte [gs:di], dl
	cmp dl, 0
	je .done
	inc si
	inc di
	jmp .copy_loop
	
.done:
	mov word [.ax], cx
	mov word[.bx], di
	popa
	mov ax, word [.ax]
	mov bx, word [.bx]
	ret
	
.ax dw 0
.bx dw 0

;==================
;os_string_copy_num
;Copies a number of chars from one string into another.
;User is responsible for providing adequate space to copy.
;IN: AX: segment of string, BX: offset of string, CX: segment of string copy, DX: offset of string copy, SI: number to copy
;OUT: AX: segment of copied string, BX: location of end of copied string
;==================
os_string_copy_num:
	pusha
	;prepare segments to copy
	mov fs, ax
	mov gs, cx
	
	;save count
	mov word [.count], si
	
	;prepare source and destination indexes
	mov si, bx
	mov di, dx
	;clear dl, we will use it
	mov dl, 0
	;set cx, looping variable
	mov cx, word [.count]
	
.copy_loop:
	mov dl, byte [fs:si]
	mov byte [gs:di], dl
	cmp dl, 0
	je .done
	inc si
	inc di
	loop .copy_loop
	
.done:
	mov word [.ax], cx
	mov word[.bx], di
	popa
	mov ax, word [.ax]
	mov bx, word [.bx]
	ret
	
.ax dw 0
.bx dw 0
.count dw 0

;==================
;os_string_truncate
;Chops off part of a string.
;Does not work if chars to keep is longer than string itself
;IN: AX: segment of string, BX: location of string, CX: number of chars to keep
;OUT: Nothing
;==================
os_string_truncate:
	pusha
	mov fs, ax
	mov si, bx
	add si, cx
	mov dl, 0
	mov byte [fs:si], dl
	popa
	ret
	
;==================
;os_strchr
;Finds the first occurrance of a char.
;Does not work if chars to keep is longer than string itself
;IN: AX: segment of string, BX: location of string, CL: char to find
;OUT: AX: segment of first occurrance, BX: location of first occurrance. Carry Flag set if not found.
;==================
os_strchr:
	push si
	mov fs, ax
	mov si, bx
	
.search_loop:
	cmp byte [fs:si], 0
	je .not_found
	cmp byte [fs:si], cl
	je .found
	inc si
	jmp .search_loop
	
.found:
	pop si
	mov bx, si
	clc
	ret
	
.not_found:
	pop si
	stc
	ret
	
;==================
;os_print_registers
;Prints the values of all registers at the time of calling.
;IN: Nothing
;OUT: Nothing
;==================
os_print_registers:
	mov word [.cs], cs
	mov word [.ds], ds
	mov word [.es], es
	mov word [.fs], fs
	mov word [.gs], gs
	
	mov word [.ax], ax
	mov word [.bx], bx
	mov word [.cx], cx
	mov word [.dx], dx
	mov word [.si], si
	mov word [.di], di

	mov word [.sp], sp
	mov word [.bp], bp
	
	mov ax, 2000h
	mov ds, ax
	
	mov eax, 0
	
	mov si, .r
	call os_print_string
	call os_print_new_line
	
	mov si, .css
	call os_print_string
	mov ax, word [.cs]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	mov si, .dss
	call os_print_string
	mov ax, word [.ds]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	mov si, .ess
	call os_print_string
	mov ax, word [.es]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	mov si, .fss
	call os_print_string
	mov ax, word [.fs]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	mov si, .gss
	call os_print_string
	mov ax, word [.gs]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	call os_print_new_line
	
	mov si, .axs
	call os_print_string
	mov ax, word [.ax]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	mov si, .bxs
	call os_print_string
	mov ax, word [.bx]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	mov si, .cxs
	call os_print_string
	mov ax, word [.cx]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	mov si, .dxs
	call os_print_string
	mov ax, word [.dx]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	mov si, .sis
	call os_print_string
	mov ax, word [.si]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	mov si, .dis
	call os_print_string
	mov ax, word [.di]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	call os_print_new_line
	
	mov si, .sps
	call os_print_string
	mov ax, word [.sp]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	mov si, .bps
	call os_print_string
	mov ax, word [.bp]
	call os_int_to_hex
	mov si, ax
	call os_print_string
	
	call os_print_new_line
	
	ret
	
.cs dw 0
.ds dw 0
.es dw 0
.fs dw 0
.gs dw 0

.ax dw 0
.bx dw 0
.cx dw 0
.dx dw 0
.si dw 0
.di dw 0

.sp dw 0
.bp dw 0

.css db "CS: ", 0
.dss db " DS: ", 0
.ess db " ES: ", 0
.fss db " FS: ", 0
.gss db " GS: ", 0

.r db "Register Values:", 0
.axs db "AX: ", 0
.bxs db " BX: ", 0
.cxs db " CX: ", 0
.dxs db " DX: ", 0
.sis db " SI: ", 0
.dis db " DI: ", 0

.sps db "SP: ", 0
.bps db " BP: ", 0

;==================
;os_print_time
;Prints the current time.
;IN: Nothing
;OUT: Nothing
;==================
os_print_time:
	mov ah, 2
	int 1Ah
	
	mov ax, 2000h
	mov ds, ax
	
	mov si, .time
	call os_print_string
	
	;ch is hour, cl is mins, dh is sec, dl is savings
	mov eax, 0
	mov al, ch
	call os_bcd_to_int
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	mov al, 58
	call os_print_char
	
	cmp cl, 9
	jae .continue_min
	
	mov al, '0'
	call os_print_char
	
.continue_min:
	mov eax, 0
	mov al, cl
	call os_bcd_to_int
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	mov al, 58
	call os_print_char
	
	cmp dh, 9
	jae .continue_sec
	
	mov al, '0'
	call os_print_char
	
.continue_sec:
	mov eax, 0
	mov al, dh
	call os_bcd_to_int
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	call os_print_new_line
	
	ret
	
.time db "Time (H:M:S): ", 0

;==================
;os_print_date
;Prints the current date.
;IN: Nothing
;OUT: Nothing
;==================
os_print_date:
	mov ah, 4
	int 1Ah
	
	mov ax, 2000h
	mov ds, ax
	
	mov si, .date
	call os_print_string
	
	;ch = century
	;cl = year
	;dh = month
	;dl = day
	
	mov eax, 0
	mov al, dh
	call os_bcd_to_int
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	mov al, '/'
	call os_print_char
	
	cmp cl, 9
	jae .continue_day
	
	mov al, '0'
	call os_print_char
	
.continue_day:
	mov eax, 0
	mov al, dl
	call os_bcd_to_int
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	mov al, '/'
	call os_print_char
	
.continue_yr:
	;calculate year
	mov al, ch
	call os_bcd_to_int
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov al, cl
	call os_bcd_to_int
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	call os_print_new_line
	
	ret
	
.date db "Date (M:D:Y): ", 0
.year dw 0

;==================
;os_bcd_to_int
;Converts bcd number to int. used for reading date and time from bios.
;IN: AL: BCD number
;OUT: AL: integer number
;==================
os_bcd_to_int:
	pusha
	mov bl, al
	and ax, 0Fh
	mov cx, ax
	shr bl, 4
	mov al, 10
	mul bl
	add ax, cx
	mov [.tmp], ax
	popa
	mov ax, word [.tmp]
	ret
	
.tmp dw 0
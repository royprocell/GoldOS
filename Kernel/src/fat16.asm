;GoldOS 4.0
;
;fat16.asm
;
;Roy Procell
;7/18/2015
;
;fat_file_exist (done!)
;fat_file_list (done! untested!)
;fat_file_convert (done!)
;fat_file_read (done!)
;fat_file_write (done!)
;fat_file_delete (done! untested!)
;fat_file_rename (done!)
;fat_file_create (done!)
;fat_root_read (done!)
;fat_root_write (done!)
;fat_table_read (done!)
;fat_table_write (done!)
;fat_file_exec (done!)

;==================
;fat_table_read
;Loads the FAT table into memory.
;IN: Nothing
;OUT: Nothing
;=================
fat_table_read:
	pusha
	mov ax, 1
	mov bx, 16
	mov cx, 2000h
	mov dx, fs_buffer
	call os_read_sector
	popa
	ret

;==================
;fat_table_write
;Writes the FAT table back to the disk.
;IN: Nothing
;OUT: Nothing
;=================
fat_table_write:
	pusha
	mov ax, 1
	mov bx, 16
	mov cx, 2000h
	mov dx, fs_buffer
	call os_write_sector
	popa
	ret
	
;==================
;fat_root_read
;Loads the root directory into memory.
;IN: Nothing
;OUT: Nothing
;=================
fat_root_read:
	pusha
	mov ax, 17
	mov bx, 16
	mov cx, 2000h
	mov dx, fs_buffer
	call os_read_sector
	popa
	ret
	
;==================
;fat_root_write
;Writes the root directory back to the disk.
;IN: Nothing
;OUT: Nothing
;=================
fat_root_write:
	pusha
	mov ax, 17
	mov bx, 16
	mov cx, 2000h
	mov dx, fs_buffer
	call os_write_sector
	popa
	ret
	
;==================
;fat_file_exist
;Checks to see if a file exists.
;IN: AX: segment of file name string, BX: offset of file name string
;OUT: DI: pointer to file entry within the root table, Carry flag will be set on failure.
;=================
fat_file_exist:
	;make sure the file name string is not longer than max FAT16 name
	call os_string_length
	cmp cx, 12
	jg .error
	cmp cx, 0
	je .error
	call fat_root_read
	mov word [.filename], bx
	mov ds, ax
	mov bx, 2000h
	mov es, bx
	
.setup:
	mov cx, 256
	mov ax, 0
	mov dx, 0
	mov di, fs_buffer
	
.search_loop:
	xchg cx, dx
	mov cx, 11
	mov si, word [.filename]
	rep cmpsb
	je .found
	add ax, 32
	mov di, fs_buffer
	add di, ax
	xchg dx, cx
	loop .search_loop
	;bx is still 2000h, reset ds to 2000h for no confusion
	mov ds, bx
	stc
	ret
	
.found:
	clc
	sub di, 11
	ret
	
.error:
	stc
	ret
	
.filename dw 0

;==================
;fat_file_read
;Loads a file into memory.
;IN: AX: segment of file name string, BX: offset of file name string, CX: segment to load to, DX: offset to load to
;OUT: Nothing, Carry flag will be set on failure.
;==================
fat_file_read:
	pusha
	mov word [.segment_file], ax
	mov word [.offset_file], bx
	mov word [.segment_to_load], cx
	mov word [.offset_to_load], dx
	call fat_file_exist
	jc .error
	;mov word [.offset_file], bx
	mov word [.pointer], 0
	mov ax, word [es:di+1Eh]
	cmp ax, 0
	jne .error
	mov ax, word [es:di+1Ah]
	cmp ax, 0
	je .error
	mov word [.cluster], ax
	call fat_table_read

.read_sector:
	add ax, 31
	mov bx, 1
	mov cx, word [.segment_to_load]
	mov dx, word [.offset_to_load]
	add dx, word [.pointer]
	call os_read_sector
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	
.calc_next:
	mov ax, word [.cluster]
	mov bx, 2
	mul bx
	mov si, fs_buffer
	add si, ax
	mov ax, word [ds:si]
	mov word [.cluster], ax
	cmp ax, 0xFFFF
	jae .done
	add word [.pointer], 512
	jmp .read_sector
	
.done:
	popa
	clc
	ret
	
.error:
	popa
	stc
	ret
	
.segment_file dw 0
.offset_file dw 0
.segment_to_load dw 0
.offset_to_load dw 0
.cluster dw 0
.pointer dw 0

;==================
;fat_file_create
;Creates a new file with the file name stored in BX.
;IN: AX: segment of file name string, BX: offset of file name string
;OUT: Nothing, Carry flag will be set on failure.
;==================
fat_file_create:
	pusha
	mov word [.segment], ax
	mov word [.offset], bx
	call fat_file_exist
	jnc .error
	mov di, fs_buffer
	mov cx, 256
	
.search_loop:
	mov dl, byte [es:di]
	cmp dl, 0
	je .found_free_entry
	cmp dl, 0xE5
	je .found_free_entry
	add di, 32
	loop .search_loop
	jmp .error
	
.found_free_entry:
	mov cx, 16
	mov word [.di_tmp], di
	
.clear_loop:
	cmp cx, 0
	je .clear_done
	mov word [es:di], 0
	inc di
	inc di
	dec cx
	jmp .clear_loop
	
.clear_done:
	mov di, word [.di_tmp]
	
	mov ax, 2000h
	mov es, ax
	mov ax, word [.segment]
	mov ds, ax
	mov si, word [.offset]
	mov cx, 11
	
.copy_loop:
	mov dl, byte [ds:si]
	mov byte [es:di], dl
	inc si
	inc di
	loop .copy_loop
	
	call fat_root_write
	mov ax, 2000h
	mov ds, ax
	popa
	clc
	ret
	
.error:
	popa
	stc
	ret
	
.segment dw 0
.offset dw 0
.di_tmp dw 0

;==================
;fat_file_convert
;Converts "testfile.txt" into "TESTFILETXT".
;IN: AX: segment of file name string, BX: offset of file name string
;OUT: BX: offset of new file name string in the kernel segment (2000h)
;==================
fat_file_convert:
	pusha
	mov si, bx
	call os_convert_string_upper
	call os_string_length
	cmp cx, 12
	jg .error
	cmp cx, 0
	je .error
	mov dx, cx
	mov cx, 2000h
	mov es, cx
	mov ds, ax
	mov di, .new_file_name
	mov cx, dx
	mov dx, 0
	
.copy_loop:
	lodsb
	cmp al, '.'
	je .extension
	stosb
	inc dx
	;cmp dx, cx
	;jg .error
	jmp .copy_loop
	
.extension:
	cmp dx, 0
	je .error
	
	cmp dx, 8
	je .add_extension

.add_spaces:
	mov byte [di], ' '
	inc di
	inc dx
	cmp dx, 8
	jl .add_spaces
	
.add_extension:
	lodsb
	cmp al, 0
	je .error
	stosb
	lodsb
	cmp al, 0
	je .done
	stosb
	lodsb
	cmp al, 0
	je .done
	stosb
	
.done:
	mov byte [di], 0
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	popa
	mov bx, .new_file_name
	clc
	ret
	
.error:
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	popa
	stc
	ret
	
.new_file_name times (13) db 0

;==================
;fat_file_rename
;Renames the desired file.
;IN: AX: segment of original file name string, BX: offset of original file name string, CX: segment of new file name string, DX: offset of new file name string
;OUT: Nothing, Carry flag will be set on failure
;==================
fat_file_rename:
	pusha
	mov word [.org_segment], ax
	mov word [.org_offset], bx
	mov word [.new_segment], cx
	mov word [.new_offset], dx
	mov ax, word [.new_segment]
	mov bx, word [.new_offset]
	call fat_file_exist
	jnc .error
	mov ax, 2000h
	mov es, ax
	cmp byte [es:di+0xB], 04h
	je .error
	mov ax, word [.org_segment]
	mov bx, word [.org_offset]
	call fat_file_exist
	jc .error
	mov ax, word [.new_segment]
	mov ds, ax
	mov si, word [.new_offset]
	mov cx, 2000h
	mov es, cx
	mov cx, 8;11 ;only loop 8 times so that the extension remains the same
	
.copy_loop:
	mov dl, byte [ds:si]
	mov byte [es:di], dl
	inc si
	inc di
	loop .copy_loop
	
.done:
	call fat_root_write
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	popa
	clc
	ret
	
.error:
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	popa
	stc
	ret
	
.org_segment dw 0
.org_offset dw 0
.new_segment dw 0
.new_offset dw 0

;==================
;fat_file_list
;Creates a list of files on the disk, separated by commas and terminated with a zero.
;IN: Nothing
;OUT: AX: 2000h, BX: the offset in segment 2000h where the list of files exists
;==================
fat_file_list:
	pusha
	mov	ax, 2000h
	mov ds, ax
	mov es, ax
	mov si, fs_buffer
	mov di, .file_list
	call fat_root_read

.find_loop:
	mov al, byte [ds:si+11]
	cmp al, 0xF
	je .skip
	test al, 18h
	jnz .skip
	mov al, byte [ds:si]
	cmp al, 0xE5
	je .skip
	cmp al, 0
	je .done
	
	mov cx, 1
	mov dx, si
	
.test_entry:
	inc si
	mov al, byte [ds:si]
	cmp al, ' '
	jl .next
	cmp al, '~'
	ja .next
	inc cx
	cmp cx, 11
	je .entry_ok
	jmp .test_entry
	
.entry_ok:
	mov si, dx
	mov cx, 0
	
.copy_loop:
	mov al, byte [ds:si]
	;cmp al, ' '
	;je .space
	mov byte [es:di], al
	inc si
	inc di
	inc cx
	;cmp cx, 8
	;je .add_dot
	cmp cx, 11
	je .done_copy_loop
	jmp .copy_loop
	
.space:
	inc si
	inc cx
	cmp cx, 8
	je .add_dot
	jmp .copy_loop
	
.add_dot:
	mov byte [es:di], '.'
	inc di
	jmp .copy_loop
	
.done_copy_loop:
	mov byte [es:di], ','
	inc di
	
.next:
	mov si, dx
	
.skip:
	add si, 32
	jmp .find_loop
	
.done:
	dec di
	mov byte [es:di], 0
	popa
	mov ax, 2000h
	mov bx, .file_list
	ret
	
.file_list times (3072) db 0

;==================
;fat_file_delete
;Deletes the specified file from disk. Removes the file from the FAT and marks its entry as deleted.
;IN: AX: segment of file name string, BX: offset of file name string
;OUT: Nothing, Carry flag will be set on failure
;==================
fat_file_delete:
	pusha
	mov word [.segment], ax
	mov word [.offset], bx
	call fat_file_exist
	jc .error
	mov ax, 2000h
	mov es, ax
	mov ax, word [es:di+1Ah]
	mov word [.cluster], ax
	cmp byte [es:di+0xB], 04h
	je .error
	cmp byte [es:di+0xB], 64h
	je .error
	mov byte [es:di], 0xE5
	call fat_root_write
	
.clean_fat:
	call fat_table_read
	mov di, fs_buffer
	
.clean_loop:
	mov ax, word [.cluster]
	cmp ax, 0
	je .none
	mov bx, 2
	mul bx
	mov si, fs_buffer
	add si, ax
	mov ax, word [es:si]
	mov word [.cluster], ax
	mov ax, 0
	mov word [es:si], ax
	mov ax, word [.cluster]
	cmp ax, 0xFFFF
	je .done
	jmp .clean_loop
	
.done:
	call fat_table_write
	
.none:
	popa
	clc
	ret
	
.error:
	popa
	stc
	ret
	
.segment dw 0
.offset dw 0
.cluster dw 0

;==================
;fat_file_exec
;Loads a file and executes it.
;IN: AX: segment of file name string, BX: offset of file name string, CX: segment to load to, DX: offset to load to
;OUT: Nothing, Carry flag will be set on failure
;==================
fat_file_exec:
	mov word [.file_segment], ax
	mov word [.file_offset], bx
	mov cx, 2000h
	mov dx, 0xA000
	call fat_file_read
	jc .error
	
.prepare_jump:
	mov bl, 43
	call os_clear_screen_gfx
	mov al, 3
	call os_set_video_mode
	mov bh, 0x0F
	call os_clear_screen
	mov dx, 0
	call os_move_cursor
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
	clc
	call 2000h:0A000h
	clc
	ret
	
.error:
	stc
	ret
	
.file_segment dw 0
.file_offset dw 0

;==================
;fat_file_write
;Writes a file back to the disk.
;IN: AX: segment of file name string, BX: offset of file name string, CX: segment to write from, DX: offset to write from, SI: size of file to write
;OUT: Nothing, Carry flag will be set on failure
;==================
fat_file_write:
	pusha
	mov word [.string_segment], ax
	mov word [.string_offset], bx
	mov word [.segment], cx
	mov word [.offset], dx
	mov word [.size], si
	call fat_file_create
	jc .error
	call fat_table_read

.calc_size:
	mov ax, word [.size]
	mov dx, 0
	mov bx, 512
	div bx
	cmp dx, 0
	jg .one_more_cluster
	jmp .no_more_clusters
	
.one_more_cluster:
	add ax, 1
	
.no_more_clusters:
	mov word [.clusters], ax
	mov cx, ax
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov si, fs_buffer
	add si, 4
	mov di, .free_clusters
	
.clean_free:
	pusha
	mov cx, 128
	
.clean_loop:
	mov word [es:di], 0
	inc di
	inc di
	loop .clean_loop
	popa
	
.find_free_loop:
	cmp word [.clusters], 0
	;cmp cx, 0
	je .found_all_free
	cmp word [ds:si], 0
	je .found_free_cluster
	inc si
	inc si
	jmp .find_free_loop
	
.found_free_cluster:
	mov ax, si
	sub ax, fs_buffer
	mov dx, 0
	mov bx, 2
	div bx
	mov word [es:di], ax
	;mov bx, 2
	;div bx
	;mov ax, word [es:di]
	inc si
	inc si
	inc di
	inc di
	dec word [.clusters]
	jmp .find_free_loop
	
.found_all_free:
	mov di, .free_clusters
	mov ax, word [es:di]
	mov word [.first_cluster], ax
	
.write_loop:
	;cmp word [.clusters], 0
	;je .finish_write
	mov si, fs_buffer
	mov ax, word [es:di]
	mov word [.current_cluster], ax
	mov bx, 2
	mul bx
	add si, ax
	mov ax, word [es:di+2]
	cmp ax, 0x0000
	je .last_cluster
	mov word [ds:si], ax
	mov ax, word [.current_cluster]
	add ax, 31
	mov bx, 1
	mov cx, word [.segment]
	mov dx, word [.offset]
	add dx, word [.pointer]
	call os_write_sector
	inc si
	inc si
	inc di
	inc di
	add word [.pointer], 512
	;dec word [.clusters]
	jmp .write_loop
	
.last_cluster:
	;write 0xFFFF to last cluster
	mov word [ds:si], 0xFFFF
	mov ax, word [.current_cluster]
	add ax, 31
	mov bx, 1
	mov cx, word [.segment]
	mov dx, word [.offset]
	add dx, [.pointer]
	call os_write_sector
	call fat_table_write
	
.find_entry:
	mov ax, word [.string_segment]
	mov bx, word [.string_offset]
	call fat_file_exist
	jc .error
	mov ax, word [.first_cluster]
	mov word [es:di+1Ah], ax
	mov ax, word [.size]
	mov word [es:di+1Ch], ax
	call fat_root_write
	
.done:
	popa
	clc
	ret
	
.error:
	popa
	stc
	ret
	
.string_segment dw 0
.string_offset dw 0
.segment dw 0
.offset dw 0
.pointer dw 0
.size dw 0
.clusters dw 0
.current_cluster dw 0
.first_cluster dw 0
.free_clusters times (128) dw 0

;==================
;fat_file_attrib
;Finds a file and returns the file attribute.
;Default Attributes: 0x00 = normal file, 0x02 = hidden file, 0x04 = system file, 0x08 = volume label, 0x10 = subdirectory, 0x20 = archive file, 0x40 = device, 0x80 = reserved.
;Also returns file size.
;IN: AX: segment of file name string, BX: offset of file name string
;OUT: AL: file attributes, BX: file size
;==================
fat_file_attrib:
	call fat_file_exist
	jc .error
	mov al, byte [es:di+0xB]
	mov bx, word [es:di+0x1C]
	ret
	
.error:
	stc
	ret
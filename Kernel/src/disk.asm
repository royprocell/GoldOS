;GoldOS 4.0
;
;disk.asm
;
;Roy Procell
;7/18/2015
;
;os_read_sector (done!)
;os_write_sector (done!)
;DAP (done!)
;
;Note: This does not include FAT16 functions! FAT16 will have its own driver file at FAT16.asm.

;==================
;os_read_sector
;Reads a number of sectors to a specific location in memory.
;IN: AX: starting sector, BX: number of sectors to read, CX: segment to load sectors to, DX: offset to load sectors to
;OUT: Nothing, Carry flag will be set on failure.
;==================
os_read_sector:
	pusha
	mov word [DAP.start], ax
	mov word [DAP.txfr], bx
	mov word [DAP.segment], cx
	mov word [DAP.offset], dx
	mov ax, 2000h
	mov ds, ax
	mov ax, 0
	mov ah, 42h
	mov dl, [os_disk_num]
	mov si, DAP
	int 13h
	popa
	ret

;==================
;os_write_sector
;Writes a number of sectors to a specific location on the disk.
;IN: AX: starting sector, BX: number of sectors to write, CX: segment to write sectors from, DX: offset to write sectors from
;OUT: Nothing, Carry flag will be set on failure.
;==================
os_write_sector:
	pusha
	mov word [DAP.start], ax
	mov word [DAP.txfr], bx
	mov word [DAP.segment], cx
	mov word [DAP.offset], dx
	mov ax, 2000h
	mov ds, ax
	mov ax, 0
	mov ah, 43h
	mov dl, [os_disk_num]
	mov si, DAP
	int 13h
	popa
	ret

;==================
;DAP
;This is the Disk Address Packet: it is used in the BIOS extended read/write functions.
;.size: do not change, this must always be 10h!
;.res: reserved, must always be zero!
;.txfr: number of sectors to be copied into memory or to be written to disk.
;.offset: the offset in memory to the data we want to write or where we want to read data to.
;.segment: the segment in memory to the data we want to write or where we want to read data to.
;.start: the first sector to be read/written to from the disk.
;.resvd: reserved, must always be zero!
;.resvdmore: reserved, must always be zero!
;==================
db 'DAP'
DAP:
.size		db 10h
.res		db 00h
.txfr		dw 0000h
.offset		dw 0000h 
.segment	dw 0000h
.start		dw 0000h
.resvd		dw 0000h
.resvdmore	dd 00000000h
db 'END DAP'
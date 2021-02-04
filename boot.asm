        core_base_address equ 0x00040000
        core_start_sector equ 0x00000001
        e_entry_offset equ 24
        e_shoff_offset equ 32
        e_shentsize_offset equ 46
        e_shnum_offset equ 48

SECTION MBR vstart=0x00007c00
;===============================================================================
       
        ;from real mode to protect mode
     
        mov ax,cs ;initialize stack segment register to 0(let's forget about 8086 and 
        mov ss,ax ;assume your BIOS initialize code segment to 0,you could write 'mov 
                  ;ax,0' instead)
        mov sp,0x7c00 ;initialize stack pointer
        
;-------------------------------------------------------------------------------
        ;calculate address of GDT
        mov eax,[cs:pgdt+0x02] ;load 32 bits GDT address
        xor edx,edx ;calulate 16 bits GDT address
        mov ebx,16
        div ebx
        
        mov ds,eax ;load GDT segment adress
        mov ebx,edx ;load GDT offset to ebx
        
        ;create 1# code segment descriptor(processor requiring skip on 0# descriptor)
        mov dword [ebx+0x08],0x0000ffff
        mov dword [ebx+0x0c],0x00cf9800
        
        ;create 2# data segment(stack segment) descriptor
        mov dword [ebx+0x10],0x0000ffff
        mov dword [ebx+0x14],0x00cf9200
        
        mov word [cs:pgdt],23 ;modify GDT size
        lgdt [cs:pgdt] ;initialize GDT register

;-------------------------------------------------------------------------------
        ;JUST DO IT,for historical reason (about A20 line)
        in al,0x92
        or al,0000_0010B
        out 0x92,al

;-------------------------------------------------------------------------------
        cli ;shutdown interruption
        
        ;enter protect mode
        mov eax,cr0
        or eax,1
        mov cr0,eax
        
        ;empty pipeline
        jmp dword 0x0008:loader
;===============================================================================
       
        [bits 32]
loader:
        ;initialize segment registers to 2#(data segment) descriptor
        mov eax,0x00010
        mov ds,eax
        mov es,eax            
        mov fs,eax
        mov gs,eax
        mov ss,eax
        mov esp,0x7000 ;initialize stack pointer

        mov edi,core_base_address
        mov eax,core_start_sector
        mov ebx,edi
        call read_one_sector

        ;calculate core size
        mov eax,[edi+e_shentsize_offset]
        mul word [edi+e_shnum_offset]
        shl edx,16
        add edx,eax
        add edx,[edi+e_shoff_offset]
        mov eax,edx

        ;calsulate number of sector
        xor edx,edx
        mov ecx,512
        div ecx

        or edx,edx ;determine if the remainder is 0
        jnz @1 ;jump if not eliminated(need not descend 1 cause already load a 
               ;sector)
        dec eax ;
    @1:
        ;considering case that core size less than 512 bytes
        or eax,eax
        jz pge

        ;read remain sectors
        mov ecx,eax ;loop in protect mode using ecx
        mov eax,core_start_sector
        inc eax ;read from the next logical sector(already read one)
    @2:
        call read_one_sector
        inc eax
        loop @2

;-------------------------------------------------------------------------------
read_one_sector:
        push eax ;logical sector number
        ;target adress is stored in ebx,will change during the process to point 
        ;to next target address
        push ecx
        push edx

        push eax ;for later use

        mov dx,0x1f2 ;0x1f2,port for number of sectors
        mov al,1 ;number of sectors is 1
        out dx,al

        inc dx ;0x1f3,port for digits 0 to 7 of the LBA address
        pop eax
        out dx,al ;write lowest 8 bits of eax

        inc dx ;0x1f4,port for digits 8 to 15 of the LBA address
        mov cl,8
        shr eax,cl ;move 8 bits to the right to get digits 8 to 15 of the LBA address
        out dx,al

        inc dx ;0x1f5,port for digits 16 to 23 of the LBA address
        shr eax,cl
        out dx,al

        inc dx ;0x1f6,port for digits 24 to 27 of the LBA address
        shr eax,cl
        or al,0xe0 ;modify al to set LBA mode,master disk
        out dx,al

        inc dx ;0x1f7,port for r/w mode
        mov al,0x20 ;0x20,read mode
        out dx,al

    .waits:
        in al,dx ;0x1f7 port here for status(busy when 7th digit is 1,ready wh-
                 ;-en third digit is 1 and 7th digit is 0)
        and al,0x88 ;retain third and 7th digits
        cmp al,0x80
        jnz .waits

        mov ecx,256 ;number of words need to read
        mov dx,0x1f0 ;0x1f0,data port
    .readw:
        in ax,dx
        mov [ebx],ax
        add ebx,2
        loop .readw

        pop edx
        pop ecx
        pop eax

        ret
;===============================================================================

    ;enable paging
    pge:
        ;create page directory table(PDT)
        mov ebx,0x00020000 ;PDT physical address
        mov dword [ebx+4092],0x00020003 ;create an entry that points to the PDT
                                        ;itself in case the requirement of PDT 
                                        ;modification
        mov edx,0x00021003 ;PDT entry for PT adress 0x00021000
        mov [ebx+0x000],edx ;create an entry corresponding to the linear address
                            ;0x00000000 in PDT as a transition entry
        mov [ebx+0x800],edx ;create an entry corresponding to the linear address
                            ;0x80000000 in PDT(this is the entry we use)

        ;create page table(PT)
        mov ebx, 0x00021000 ;PT physical address

        ;create entries in a circular fashion,eax for physical address,esi for 
        ;index
        xor eax,eax 
        xor esi,esi
    .b1:
        mov edx,eax
        or edx,0x000000003
        mov [ebx+esi*4],edx
        add eax,0x1000
        inc esi
        cmp esi,256
        jl .b1

        ;turn on pagination
        mov eax,0x00020000
        mov cr3,eax

;===============================================================================
        ;map the linear address of GDT to the same location starting at 
        ;0x80000000
        sgdt [pgdt]
        mov ebx,[pgdt+2]
        add dword [pgdt+2],0x80000000
        lgdt [pgdt]
     
        mov eax,cr0
        or eax,0x80000000
        mov cr0,eax

        ;map stack adress as well
        add esp,0x80000000

        jmp [0x80040000+e_entry_offset]
;-------------------------------------------------------------------------------
        pgdt dw 0 ;GDT size space
             dd 0x00008000 ;GDT adress

;-------------------------------------------------------------------------------
        times 510-($-$$) db 0
                         db 0x55,0xaa
;===============================================================================

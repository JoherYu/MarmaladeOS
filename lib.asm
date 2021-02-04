global put_string
global memcpy
global out_byte
global in_byte

;-------------------------------------------------------------------------------
;void put_string(char* str_addr)
;-------------------------------------------------------------------------------
put_string:
        push ebp
        mov ebp,esp
        push ebx
        push ecx

        mov ebx,[ebp+8] ;load parameter pointer to ebx
        cli
    .getc:
        mov cl,[ebx] ;cl for a character
        or cl,cl ;test string end(0)
        jz .exit
        call put_char
        inc ebx
        jmp .getc
    .exit:
        sti
        pop ecx
        pop ebx
        retf

;-------------------------------------------------------------------------------
put_char:
        pushad

        mov dx,0x3d4 ;index port
        mov al,0x0e ;index for high 8 bits of current cursor position
        out dx,al
        inc dx ;switch to data port 0x3d5
        in al,dx ;get high 8 bits of current cursor position
       
        mov ah,al 

        dec dx ;switch to index port 0x3d4
        mov al,0x0f; index for low 8 bits of current cursor position
        out dx,al
        inc dx
        in al,dx
       
        mov bx,ax ;move (16-digit) current cursor position to bx
        and ebx,0x0000ffff ;convert to 32-bit address

        cmp cl,0x0d ;carriage return?
        jnz .put_0a

        mov ax,bx
        mov bl,80 ;80 characters per line
        div bl
        mul bl
        mov bx,ax; current line value
        jmp .set_cursor

    .put_0a:
        cmp cl,0x0a ;line break?
        jnz .put_other ;display character normally
        add bx,80 ;add a line
        jmp .roll_screen

    .put_other: 
        shl bx,1 ;multiply 2 to get offset address of a character in memory
        mov [0x800b8000+ebx],cl ;DISPLAY THE CHARACTER!
        ;move cursor to the next position
        shr bx,1
        inc bx

    .roll_screen:
        cmp bx,2000 ;out of screen?
        jl .set_cursor

        cld ;movs_ using esi,edi,ecx in protect mode
        mov esi,0x800b80a0 
        mov edi,0x800b8000
        mov ecx,1920 ;24(lines)*80(char per line)*2(bytes)
        rep movsd

        ;clear the bottom line of screen(fill with blank characters)
        mov bx,3840 ;offset address of (last row,first column)
        mov ecx,80 
    .cls:
        mov word [0x800b8000+ebx],0x0720
        add bx,2
        loop .cls
        
        mov bx,1920 ;last row,first column

    .set_cursor:
        mov dx,0x3d4
        mov al,0x0e
        out dx,al
        inc dx
        mov al,bh
        out dx,al
        dec dx
        mov al,0x0f
        out dx,al
        inc dx
        mov al,bl
        out dx,al

        popad

        ret

;-------------------------------------------------------------------------------
;void* memcpy(void* dst, void* src, int size)
;-------------------------------------------------------------------------------
memcpy:
        push ebp
        mov ebp,esp

        push esi
        push edi
        push ecx

        mov edi,[ebp+8] ;destination address
        mov esi,[ebp+12] ;source address
        mov ecx,[ebp+16] ;counter
    .1:
        cmp ecx,0
        jz .2 ;exit when counter equals 0

        mov al,[esi]
        inc esi
        mov byte [edi],al
        inc edi
        dec ecx
        jmp .1
    .2:
        mov eax,[ebp+8] ;return value

        pop ecx
        pop edi
        pop esi
        mov esp,ebp
        pop ebp

        ret

;-------------------------------------------------------------------------------
;void out_byte(u16 port, u8 value)
;-------------------------------------------------------------------------------
out_byte:
        mov edx,[esp+4] ;port
        mov al,[esp+4+4] ;value
        out dx,al
        nop ;add a little delay
        nop
        ret

;-------------------------------------------------------------------------------
;u8 in_byte(u16 port)
;-------------------------------------------------------------------------------
in_byte:
        mov edx,[esp+4]
        xor eax,eax
        in al,dx
        nop
        nop
        ret

; MSCC v1.0cs Unpacker
; Coded by dR.No // Delirium Tremens Group

model tiny
.code
.386
org 100h

Begin:
        mov     dx,offset Msg
        call    write
        mov     si,81h
        lodsb
        cmp     al,0Dh
        jne     FileOk
        mov     dx,offset Usage
        jmp     short write

FileOk:
        push    si si
        pop     cx di

@Str:
        mov     al,[di]
        cmp     al,0Dh
        je      _EndStr
        inc     di
        loop    @Str

_EndStr:
	mov	ax,2400h
	stosw
        mov     dx,si
        mov     ax,3D02h
        int     21h
        jnc     NoErr
        mov     dx,offset not_found
        jmp     short Write

NoErr:
        xchg    bx,ax
        mov     dx,offset Process
        call    write
        mov     dx,si
        int     21h
        xor     cx,cx
        xor     dx,dx
        mov     ax,4200h
        int     21h
        mov     ah,3Fh
        mov     dx,offset Buf
        mov     cx,-1
        int     21h

        mov     bp,offset Buf
        mov     di,bp
        add     bp,ax
        cmp     DWord Ptr [bp-3Bh],000516F7h
        je      CryptOk
        mov     dx,offset NotCrypt

Write:
        mov     ah,09
        int     21h
        ret

CryptOk:
        sub     ax,110
        mov     bp,ax

        mov     cx,bp
        push    cx
        push    di
        add     di,bp
        mov     eax,[di]
        mov     DWord Ptr Buf,eax
	mov	al,[di+4]
	mov	Byte Ptr Buf+4,al
        mov     ax,bp

        push    dx dx
        mov     cx,ax

        mov     ah,3Eh
        int     21h

        pop     si
        pop     di

        pusha

        add     bp,di
        mov     bl,[bp+52h]
	add	di,5

@Decode:
	inc	bl
        mov     al,[di]
	sub	al,bl
	stosb
        loop    @Decode

        popa

        mov     dx,offset _Out
        mov     ax,3C02h
        xor     cx,cx
        int     21h

        xchg    bx,ax

        pop     dx
        pop     cx
        mov     ah,40h
        int     21h

        mov     ah,3Eh
        int     21h
        mov     dx,offset Oki
        jmp     short write
Msg             db              0dh,0ah,'MSCC v1.0cs Unpacker Coded by dR.No // ViP // DTg ',0dh,0ah,24h
Usage           db              0dh,0ah,'Usage: UN-MSCC <CRYPTFiLE>',0dh,0ah,24h
Not_found       db              'File not found',0dh,0ah,24h
NotCrypt        db              0dh,0ah,'File is not crypted with MSCC v1.0cs',0dh,0ah,24h
Process         db              'Unpacking the file: $'
Oki             db              '... completed!',0dh,0ah,24h
_Out            db              'UNPACKED.COM',0
Buf:
End Begin
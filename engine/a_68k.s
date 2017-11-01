|
| 68030+ versions of most of the render-routines
| from a.c / a.nasm
|
| Dante/Oxyron 2003
|

    .text

    .globl    _asm1,_asm2,_asm3,_asm4
    .globl    _vplce,_vince
    .globl    _palookupoffse,_bufplce
    .globl    _ylookup
    .globl    _reciptable,_globalx3,_globaly3
    .globl    _fpuasm

    .globl    _shlookup,_sqrtable

    .globl    _gotpic,_walock,_pow2char

    .globl    _fixchain

|-----------------------------------------------------------------------------
| sethlinesizes
|-----------------------------------------------------------------------------
    .globl    _sethlinesizes
_sethlinesizes:
	move.l  d3,-(sp)
	
	move.l	4+1*4+0(sp),d0
	move.l	4+1*4+4(sp),d1
	move.l	4+1*4+8(sp),d2

	neg.b   d0
	move.b  d1,machxbits_bl
	move.l  d0,d3
	and.b   #0x1f,d3
	move.b  d3,machxbits_al
	moveq   #-1,d3
	sub.b   d1,d0
	move.l  d2,machxbits_ecx
	lsr.l   d0,d3
	move.l  d3,machxbits_edx

	move.l  (sp)+,d3
	rts

    .even

machxbits_ecx: .long    0
machxbits_edx: .long    0
machxbits_al: .byte    0
machxbits_bl: .byte    0

    .even

|-----------------------------------------------------------------------------
| setpalookupaddress
|-----------------------------------------------------------------------------
    .globl    _setpalookupaddress
_setpalookupaddress:
	move.l  4(sp),pal_eax
	rts

    .even

pal_eax: .long    0

    .even

|-----------------------------------------------------------------------------
| hlineasm4
| ---------
|   d0 = count
|   d1 = source (STUB!!!)
|   d2 = shade
|   a0 = i4
|   a1 = i5
|   a2 = i6
|-----------------------------------------------------------------------------
    .globl    _hlineasm4
_hlineasm4:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),d1
	move.l	4+11*4+8(sp),d2
	move.l	4+11*4+12(sp),a0
	move.l	4+11*4+16(sp),a1
	move.l	4+11*4+20(sp),a2

	move.l  pal_eax(pc),a3

	move.l  machxbits_ecx(pc),a4
	move.b  machxbits_al(pc),d5
	move.b  machxbits_bl(pc),d6
	moveq   #32,d7
	sub.b   d6,d7
	move.l  _asm1,a5
	move.l  _asm2,a6

	addq.l  #1,a2

	addq.l  #1,d0
	move.l  d0,count
	cmp.l   #3,d0
	ble.w   hlineasm4_writerest

	move.l  a2,d0
	and.l   #0x00000003,d0
	beq.b   hlineasm4_writelong
	sub.l   d0,count

hlineasm4_writefirst:
	move.l  a1,d1
	move.l  a0,d3
	lsr.l   d5,d1
	lsr.l   d7,d3
	lsl.l   d6,d1
	or.l    d3,d1
	sub.l   a5,a1
	move.b  (a4,d1.l),d2
	sub.l   a6,a0
	move.b  (a3,d2.l),-(a2)
	subq.l  #1,d0
	bne.b   hlineasm4_writefirst

hlineasm4_writelong:
	move.l  count(pc),d3
	lsr.l   #2,d3
	move.l  d3,count2
	beq.b   hlineasm4_writerest
	bra.b   hlineasm4_loop1

	.align	4

hlineasm4_loop1:
	move.l  a1,d1
	move.l  a0,d3
	lsr.l   d5,d1
	lsr.l   d7,d3
	lsl.l   d6,d1
	or.l    d3,d1
	sub.l   a5,a1
	move.b  (a4,d1.l),d2
	sub.l   a6,a0
	move.b  (a3,d2.l),d0

	move.l  a1,d1
	move.l  a0,d3
	lsr.l   d5,d1
	lsr.l   d7,d3
	lsl.l   d6,d1
	or.l    d3,d1
	ror.l   #8,d0
	move.b  (a4,d1.l),d2
	sub.l   a5,a1
	move.b  (a3,d2.l),d0
	sub.l   a6,a0

	move.l  a1,d1
	move.l  a0,d3
	lsr.l   d5,d1
	lsr.l   d7,d3
	lsl.l   d6,d1
	or.l    d3,d1
	ror.l   #8,d0
	move.b  (a4,d1.l),d2
	sub.l   a5,a1
	move.b  (a3,d2.l),d0
	sub.l   a6,a0

	move.l  a1,d1
	move.l  a0,d3
	lsr.l   d5,d1
	lsr.l   d7,d3
	lsl.l   d6,d1
	or.l    d3,d1
	ror.l   #8,d0
	move.b  (a4,d1.l),d2
	sub.l   a5,a1
	move.b  (a3,d2.l),d0
	sub.l   a6,a0

	ror.l   #8,d0

	move.l  d0,-(a2)
	subq.l  #1,count2
	bne.b   hlineasm4_loop1

hlineasm4_writerest:
	move.l  count(pc),d0
	and.l   #3,d0
	beq.b   hlineasm4_end
hlineasm4_loop2:
	move.l  a1,d1
	move.l  a0,d3
	lsr.l   d5,d1
	lsr.l   d7,d3
	lsl.l   d6,d1
	or.l    d3,d1
	sub.l   a5,a1
	move.b  (a4,d1.l),d2
	sub.l   a6,a0
	move.b  (a3,d2.l),-(a2)
	subq.l  #1,d0
	bne.b   hlineasm4_loop2
hlineasm4_end:
	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

count:  .long    0
count2: .long    0

    .even

|-----------------------------------------------------------------------------
| setuprhlineasm4
| setupqrhlineasm4
|-----------------------------------------------------------------------------
    .globl    _setuprhlineasm4
    .globl    _setupqrhlineasm4
_setuprhlineasm4:
_setupqrhlineasm4:
	move.l	4(sp),rmach_eax
	move.l	8(sp),rmach_ebx
	move.l	12(sp),rmach_ecx
	move.l	16(sp),rmach_edx
	move.l	20(sp),rmach_esi
	rts

    .even

rmach_eax: .long    0
rmach_ebx: .long    0
rmach_ecx: .long    0
rmach_edx: .long    0
rmach_esi: .long    0

    .even

|-----------------------------------------------------------------------------
| rhlineasm4
| qrhlineasm4
| -----------
|   d0 = i1
|   d1 = i2
|   d2 = i3
|   d3 = i4
|   d4 = i5
|   d5 = i6
|-----------------------------------------------------------------------------
    .globl    _rhlineasm4
    .globl    _qrhlineasm4
_rhlineasm4:
_qrhlineasm4:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),d1
	move.l	4+11*4+8(sp),d2
	move.l	4+11*4+12(sp),d3
	move.l	4+11*4+16(sp),d4
	move.l	4+11*4+20(sp),d5

	tst.l   d0
	ble.b   qrhlineasm4_end

	move.l  rmach_edx(pc),a2

	move.l  d5,a1

	sub.l   a0,a0
	move.l  rmach_eax(pc),a3
	move.l  rmach_ebx(pc),a4
	move.l  rmach_ecx(pc),d7
	move.l  rmach_esi(pc),d6

	bra.b   qrhlineasm4_loop

	.align	4
qrhlineasm4_loop:
	move.b  (a0,d1.l),d2
	sub.l   a3,d3
	subx.l  d5,d5
	sub.l   a4,d4
	subx.l  d7,d1
	and.l   d6,d5
	move.b  (a2,d2.l),-(a1)
	sub.l   d5,a0
	subq.l  #1,d0
	bne.b   qrhlineasm4_loop

qrhlineasm4_end:
	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

|-----------------------------------------------------------------------------
| setuprmhlineasm4
|-----------------------------------------------------------------------------
    .globl    _setuprmhlineasm4
_setuprmhlineasm4:
	move.l 4(sp),rmmach_eax
	move.l 8(sp),rmmach_ebx
	move.l 12(sp),rmmach_ecx
	move.l 16(sp),rmmach_edx
	move.l 20(sp),rmmach_esi
	rts

    .even

rmmach_eax: .long    0
rmmach_ebx: .long    0
rmmach_ecx: .long    0
rmmach_edx: .long    0
rmmach_esi: .long    0

    .even

|-----------------------------------------------------------------------------
| rmhlineasm4
| -----------
|   d0 = i1
|   d1 = i2
|   d2 = i3
|   d3 = i4
|   d4 = i5
|   d5 = i6
|-----------------------------------------------------------------------------
    .globl    _rmhlineasm4
_rmhlineasm4:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),d1
	move.l	4+11*4+8(sp),d2
	move.l	4+11*4+12(sp),d3
	move.l	4+11*4+16(sp),d4
	move.l	4+11*4+20(sp),d5

	tst.l   d0
	ble.b   rmhlineasm4_end

	move.l  rmmach_edx(pc),a2

	move.l  d5,a1
	subq.l  #1,a1

	sub.l   a0,a0
	move.l  rmmach_eax(pc),a3
	move.l  rmmach_ebx(pc),a4
	move.l  rmmach_ecx(pc),d7
	move.l  rmmach_esi(pc),d6

	bra.b   rmhlineasm4_loop

	.align	4
rmhlineasm4_loop:
	move.b  (a0,d1.l),d2
	sub.l   a3,d3
	subx.l  d5,d5
	sub.l   a4,d4
	subx.l  d7,d1
	and.l   d6,d5
	cmp.b   #0xff,d2
	beq.b   rmhlineasm4_j1
	move.b  (a2,d2.l),(a1)
rmhlineasm4_j1:
	sub.l   d5,a0
	subq.l  #1,a1
	subq.l  #1,d0
	bne.b   rmhlineasm4_loop

rmhlineasm4_end:
	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even


|-----------------------------------------------------------------------------
| setvlinebpl
|-----------------------------------------------------------------------------
    .globl    _setvlinebpl
_setvlinebpl:
	move.l  4(sp),_fixchain
	rts

    .even

_fixchain:   .long    0

    .even

|-----------------------------------------------------------------------------
| fixtransluscence
|-----------------------------------------------------------------------------
    .globl    _fixtransluscence
_fixtransluscence:
	move.l  4(sp),tmach
	rts

    .even

tmach:  .long    0

    .even

|-----------------------------------------------------------------------------
| setupvlineasm
|-----------------------------------------------------------------------------
    .globl    _setupvlineasm
_setupvlineasm:
	move.l	4(sp),d0
	
	move.b  d0,d1
	and.l   #0x1f,d1
	move.l  d1,mach3_al
	rts

    .even

mach3_al:   .long    0

    .even

|-----------------------------------------------------------------------------
| prevlineasm1
| ------------
|   d0 = i1
|   a0 = i2
|   d1 = i3
|   d2 = i4
|   a1 = i5
|   a2 = i6
|-----------------------------------------------------------------------------
    .globl    _prevlineasm1
_prevlineasm1:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),a0
	move.l	4+11*4+8(sp),d1
	move.l	4+11*4+12(sp),d2
	move.l	4+11*4+16(sp),a1
	move.l	4+11*4+20(sp),a2

	tst.l   d1
	bne.b   INT_vlineasm1

	move.l  mach3_al(pc),d3
	add.l   d2,d0
	lsr.l   d3,d2
	move.b  (a1,d2.l),d2
	move.b  (a0,d2.l),(a2)
prevlineasm1_end:
	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

|-----------------------------------------------------------------------------
| vlineasm1
| ---------
|   d0 = vince
|   a0 = palookupoffse
|   d1 = i3
|   d2 = vplce
|   a1 = bufplce
|   a2 = i6
|-----------------------------------------------------------------------------
    .globl    _vlineasm1
_vlineasm1:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),a0
	move.l	4+11*4+8(sp),d1
	move.l	4+11*4+12(sp),d2
	move.l	4+11*4+16(sp),a1
	move.l	4+11*4+20(sp),a2
	
	
INT_vlineasm1:
	move.l  mach3_al(pc),d3
	moveq   #0,d5
	move.l  _fixchain(pc),d6
	addq.l  #1,d1
	beq.b   NT_vlineasm1_end

	bra.b   NT_vlineasm1_loop

	.align	4
NT_vlineasm1_loop:
	move.l  d2,d4
	lsr.l   d3,d4
	move.b  (a1,d4.l),d5
	add.l   d0,d2
	move.b  (a0,d5.l),(a2)
	subq.l  #1,d1
	add.l   d6,a2
	bne.b   NT_vlineasm1_loop
NT_vlineasm1_end:
	move.l  d2,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

|-----------------------------------------------------------------------------
| vlineasm4
| ---------
|   d0 = i1
|   d1 = i2
|-----------------------------------------------------------------------------
    .globl    _vlineasm4
_vlineasm4:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),d1

	lea     _ylookup,a0
	move.l  (a0,d0.l*4),d0

	move.l  d0,a0
	add.l   d1,a0

	neg.l   d0

	lea     _bufplce,a1
	lea     _palookupoffse,a2

	lea     _vince,a4
	move.l  (a4),d3
	move.l  4(a4),d4
	move.l  8(a4),d5
	move.l  12(a4),d6

	lea     _vplce,a3
	move.l  12(a3),a6
	move.l  8(a3),a5
	move.l  4(a3),a4
	move.l  (a3),a3

	move.l  mach3_al(pc),d7
	moveq   #0,d1
	move.l  a3,d1
	lsr.l   d7,d1
	bra.b   vlineasm4_loop

	.align	4
vlineasm4_loop:
	move.b  ([a1],d1.w),d1
	add.l   d3,a3
	move.b  ([a2],d1.w),d2
	move.l  a4,d1
	lsl.l   #8,d2

	lsr.l   d7,d1
	move.b  ([4,a1],d1.w),d1
	add.l   d4,a4
	move.b  ([4,a2],d1.w),d2
	move.l  a5,d1
	lsl.l   #8,d2

	lsr.l   d7,d1
	move.b  ([8,a1],d1.w),d1
	add.l   d5,a5
	move.b  ([8,a2],d1.w),d2
	move.l  a6,d1
	lsl.l   #8,d2

	lsr.l   d7,d1
	move.b  ([12,a1],d1.w),d1
	add.l   d6,a6
	move.b  ([12,a2],d1.w),d2
	move.l  a3,d1

	move.l  d2,(a0,d0.l)
	lsr.l   d7,d1

	add.l   _fixchain(pc),d0
	bcc.b   vlineasm4_loop
vlineasm4_end:
	lea     _vplce,a2
	move.l  a3,(a2)
	move.l  a4,4(a2)
	move.l  a5,8(a2)
	move.l  a6,12(a2)

	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

|-----------------------------------------------------------------------------
| setuptvlineasm
|-----------------------------------------------------------------------------
    .globl    _setuptvlineasm
_setuptvlineasm:
	move.l  4(sp),transmach3_al
	rts

    .even

transmach3_al:  .long    0

    .even

|-----------------------------------------------------------------------------
| tvlineasm1
| ----------
|   d0 = i1
|   a0 = i2
|   d1 = i3
|   d2 = i4
|   a1 = i5
|   a2 = i6
|-----------------------------------------------------------------------------
    .globl    _tvlineasm1
_tvlineasm1:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),a0
	move.l	4+11*4+8(sp),d1
	move.l	4+11*4+12(sp),d2
	move.l	4+11*4+16(sp),a1
	move.l	4+11*4+20(sp),a2

	move.l  tmach(pc),a3
	moveq   #0,d7
	move.l  transmach3_al(pc),d7
	moveq   #0,d4
	moveq   #0,d5
	tst.b   transrev(pc)
	bne.w   tvlineasm1_rev
tvlineasm1_loop:
	move.l  d2,d3
	lsr.l   d7,d3
	move.b  (a1,d3.w),d4
	cmp.b   #0xff,d4
	beq.b   tvlineasm1_l2

	    move.b  (a2),d5
	    lsl.w   #8,d5
	    move.b  (a0,d4.w),d5
	    move.b  (a3,d5.l),(a2)
tvlineasm1_l2:
	add.l   d0,d2
	add.l   _fixchain(pc),a2
	subq.l  #1,d1
	bpl.b   tvlineasm1_loop

	move.l  d2,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

tvlineasm1_rev:
vlineasm1_rev_loop:
	move.l  d2,d3
	lsr.l   d7,d3
	move.b  (a1,d3.w),d4
	cmp.b   #0xff,d4
	beq.b   vlineasm1_rev_l2

	    move.b  (a0,d4.w),d5
	    lsl.w   #8,d5
	    move.b  (a2),d5
	    move.b  (a3,d5.l),(a2)
vlineasm1_rev_l2:
	add.l   d0,d2
	add.l   _fixchain(pc),a2
	subq.l  #1,d1
	bpl.b   vlineasm1_rev_loop

	move.l  d2,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

transrev:   .byte    0

    .even

|-----------------------------------------------------------------------------
| setuptvlineasm2
|-----------------------------------------------------------------------------
    .globl    _setuptvlineasm2
_setuptvlineasm2:
	move.l	d2,-(sp)
	
	move.l	4+1*4+0(sp),d0
	move.l	4+1*4+4(sp),d1
	move.l	4+1*4+8(sp),d2
	
	and.l   #0x1f,d0
	move.l  d0,tran2shr
	move.l  d1,tran2pal_ebx
	move.l  d2,tran2pal_ecx
	
	move.l	(sp)+,d2
	rts

    .even
tran2pal_ebx:   .long    0
tran2pal_ecx:   .long    0
tran2shr:       .long    0
    .even

|-----------------------------------------------------------------------------
| tvlineasm2
| ----------
|   d0 = ebp
|   d1 = tran2inca
|   a0 = tran2bufa
|   a1 = tran2bufb
|   a2 = i5
|   d2 = i6
|-----------------------------------------------------------------------------
    .globl    _tvlineasm2
_tvlineasm2:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),d1
	move.l	4+11*4+8(sp),a0
	move.l	4+11*4+12(sp),a1
	move.l	4+11*4+16(sp),a2
	move.l	4+11*4+20(sp),d2
	

	move.l  d1,tran2inca
	move.l  _asm1,tran2incb

	move.l  tran2shr(pc),d7
	move.l  tran2pal_ebx(pc),a3
	move.l  tran2pal_ecx(pc),a4
	move.l  _asm2,a5
	move.l  tmach(pc),a6

	moveq   #0,d4
	moveq   #0,d5
	moveq   #0,d6

	sub.l   a5,d2

	tst.b   transrev(pc)
	bne.w   tvlineasm2_rev
tvlineasm2_loop:
	move.l  a2,d1
	lsr.l   d7,d1       |d2 => i1=i5>>tran2shr
	move.l  d0,d3
	lsr.l   d7,d3       |d3 => i2=ebp>>tran2shr

	add.l   tran2inca(pc),a2    |a3 => i5+=tran2inca
	add.l   tran2incb(pc),d0    |d0 => ebp+=tran2incb

	move.b  (a0,d1.w),d4 |d4=i3
	move.b  (a1,d3.w),d5 |d5=i4

	cmp.b   #255,d4
	bne.b   tvlineasm2_skip
	    cmp.b   #255,d5
	    beq.b   tvlineasm2_skip3

		move.b  1(a5,d2.l),d6
		lsl.w   #8,d6
		move.b  (a4,d5.w),d6
		move.b  (a6,d6.l),1(a5,d2.l)
		bra.b   tvlineasm2_skip3
tvlineasm2_skip:
	cmp.b   #255,d5
	bne.b   tvlineasm2_skip2

	    move.b  (a5,d2.l),d6
	    lsl.w   #8,d6
	    move.b  (a3,d4.w),d6
	    move.b  (a6,d6.l),(a5,d2.l)
	    bra.b   tvlineasm2_skip3
tvlineasm2_skip2:
	move.b  (a5,d2.l),d6
	lsl.w   #8,d6
	move.b  (a3,d4.w),d6
	move.b  (a6,d6.l),d1

	move.b  1(a5,d2.l),d6
	lsl.w   #8,d1
	lsl.w   #8,d6
	move.b  (a4,d5.w),d6
	move.b  (a6,d6.l),d1

	move.w  d1,(a5,d2.l)
tvlineasm2_skip3:
	add.l   _fixchain(pc),d2
	bcc.b   tvlineasm2_loop

	move.l  a2,_asm1
	move.l  d0,_asm2

	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

tvlineasm2_rev:
vlineasm2_rev_loop:
	move.l  a2,d1
	lsr.l   d7,d1       |d2 => i1=i5>>tran2shr
	move.l  d0,d3
	lsr.l   d7,d3       |d3 => i2=ebp>>tran2shr

	add.l   tran2inca(pc),a2    |a3 => i5+=tran2inca
	add.l   tran2incb(pc),d0    |d0 => ebp+=tran2incb

	move.b  (a0,d1.w),d4 |d4=i3
	move.b  (a1,d3.w),d5 |d5=i4

	cmp.b   #255,d4
	bne.b   vlineasm2_rev_skip
	    cmp.b   #255,d5
	    beq.b   vlineasm2_rev_skip3

		move.b  (a4,d5.w),d6
		lsl.w   #8,d6
		move.b  1(a5,d2.l),d6
		move.b  (a6,d6.l),1(a5,d2.l)
		bra.b   vlineasm2_rev_skip3
vlineasm2_rev_skip:
	cmp.b   #255,d5
	bne.b   vlineasm2_rev_skip2

	    move.b  (a3,d4.w),d6
	    lsl.w   #8,d6
	    move.b  (a5,d2.l),d6
	    move.b  (a6,d6.l),(a5,d2.l)
	    bra.b   vlineasm2_rev_skip3
vlineasm2_rev_skip2:
	move.b  (a3,d4.w),d6
	lsl.w   #8,d6
	move.b  (a5,d2.l),d6
	move.b  (a6,d6.l),d1

	move.b  (a4,d5.w),d6
	lsl.w   #8,d1
	lsl.w   #8,d6
	move.b  1(a5,d2.l),d6
	move.b  (a6,d6.l),d1

	move.w  d1,(a5,d2.l)
vlineasm2_rev_skip3:
	add.l   _fixchain(pc),d2
	bcc.b   vlineasm2_rev_loop

	move.l  a2,_asm1
	move.l  d0,_asm2

	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

tran2inca:  .long    0
tran2incb:  .long    0

    .even

|-----------------------------------------------------------------------------
| settransnormal
|-----------------------------------------------------------------------------
    .globl    _settransnormal
_settransnormal:
	clr.b   transrev
	rts

    .even

|-----------------------------------------------------------------------------
| settransreverse
|-----------------------------------------------------------------------------
    .globl    _settransreverse
_settransreverse:
	move.b  #1,transrev
	rts

    .even

|-----------------------------------------------------------------------------
| setupmvlineasm
|-----------------------------------------------------------------------------
    .globl    _setupmvlineasm
_setupmvlineasm:
	move.l  4(sp),machmv
	rts

    .even

machmv:     .long    0

    .even

|-----------------------------------------------------------------------------
| mvlineasm1
| ----------
|   d0=vince
|   a0=palookupoffse
|   d1=i3
|   d2=vplce
|   a1=bufplce
|   a2=i6
|-----------------------------------------------------------------------------
    .globl    _mvlineasm1
_mvlineasm1:
    movem.l	d2-d7/a2-a6,-(sp)
    
    move.l	4+11*4+0(sp),d0
    move.l	4+11*4+4(sp),a0
    move.l	4+11*4+8(sp),d1
    move.l	4+11*4+12(sp),d2
    move.l	4+11*4+16(sp),a1
    move.l	4+11*4+20(sp),a2

    moveq   #0,d4
    move.l  _fixchain(pc),d6
    move.l  machmv(pc),d7
mvlineasm1_loop:
    move.l  d2,d3
    lsr.l   d7,d3
    move.b  (a1,d3.w),d4
    cmp.b   #255,d4
    beq.b   mvlineasm1_skip
    move.b  (a0,d4.w),(a2)
mvlineasm1_skip:
    add.l   d0,d2
    add.l   d6,a2
    subq.l  #1,d1
    bpl.b   mvlineasm1_loop

    move.l  d2,d0
    movem.l	(sp)+,d2-d7/a2-a6
    rts

    .even

|-----------------------------------------------------------------------------
| mvlineasm4
| ----------
|   d0=i1
|   d1=i2
|-----------------------------------------------------------------------------
    .globl    _mvlineasm4
_mvlineasm4:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),d1

	lea     _ylookup,a0
	move.l  (a0,d0.l*4),d0

	move.l  d0,a0
	add.l   d1,a0

	neg.l   d0

	lea     _bufplce,a1
	lea     _palookupoffse,a2

	lea     _vince,a4
	move.l  (a4),d3
	move.l  4(a4),d4
	move.l  8(a4),d5
	move.l  12(a4),d6

	lea     _vplce,a3
	move.l  12(a3),a6
	move.l  8(a3),a5
	move.l  4(a3),a4
	move.l  (a3),a3

	move.l  machmv(pc),d7
	moveq   #0,d1
	move.l  a3,d1
	lsr.l   d7,d1
	bra.b   mvlineasm4_loop

	.align	4
mvlineasm4_loop:
	move.b  ([a1],d1.w),d1
	add.l   d3,a3
	move.b  ([a2],d1.w),d2
	move.l  a4,d1
	cmp.b   #255,d2
	beq.b   mvlineasm4_l1
	move.b  d2,(a0,d0.l)
mvlineasm4_l1:
	lsr.l   d7,d1
	move.b  ([4,a1],d1.w),d1
	add.l   d4,a4
	move.b  ([4,a2],d1.w),d2
	move.l  a5,d1
	cmp.b   #255,d2
	beq.b   mvlineasm4_l2
	move.b  d2,1(a0,d0.l)
mvlineasm4_l2:
	lsr.l   d7,d1
	move.b  ([8,a1],d1.w),d1
	add.l   d5,a5
	move.b  ([8,a2],d1.w),d2
	move.l  a6,d1
	cmp.b   #255,d2
	beq.b   mvlineasm4_l3
	move.b  d2,2(a0,d0.l)
mvlineasm4_l3:
	lsr.l   d7,d1
	move.b  ([12,a1],d1.w),d1
	add.l   d6,a6
	move.b  ([12,a2],d1.w),d2
	move.l  a3,d1
	cmp.b   #255,d2
	beq.b   mvlineasm4_l4
	move.b  d2,3(a0,d0.l)
mvlineasm4_l4:
	lsr.l   d7,d1
	add.l   _fixchain(pc),d0
	bcc.b   mvlineasm4_loop
mvlineasm4_end:
	lea     _vplce,a2
	move.l  a3,(a2)
	move.l  a4,4(a2)
	move.l  a5,8(a2)
	move.l  a6,12(a2)

	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

|-----------------------------------------------------------------------------
| tsetupspritevline
|-----------------------------------------------------------------------------
    .globl    _tsetupspritevline
_tsetupspritevline:
	movem.l d2-d7,-(sp)
	
	move.l	4+6*4+0(sp),d0
	move.l	4+6*4+4(sp),d1
	move.l	4+6*4+8(sp),d2
	move.l	4+6*4+12(sp),d3
	move.l	4+6*4+16(sp),d4
	move.l	4+6*4+20(sp),d5

	moveq   #16,d7
	move.l  d0,tspal
	move.l  d4,d6
	lsl.l   d7,d4
	move.l  d4,tsmach_eax1
	lsr.l   d7,d6
	add.l   d1,d6
	move.l  d6,tsmach_eax2
	add.l   d3,d6
	move.l  d6,tsmach_eax3
	move.l  d2,tsmach_ecx

	movem.l (sp)+,d2-d7
	rts

    .even

tspal:          .long    0
tsmach_eax1:    .long    0
tsmach_eax2:    .long    0
tsmach_eax3:    .long    0
tsmach_ecx:     .long    0

    .even

|-----------------------------------------------------------------------------
| tspritevline
| ------------
|   d0=i1
|   d1=i2
|   d2=i3
|   d3=i4
|   a0=i5
|   a1=i6
|-----------------------------------------------------------------------------
    .globl    _tspritevline
_tspritevline:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),d1
	move.l	4+11*4+8(sp),d2
	move.l	4+11*4+12(sp),d3
	move.l	4+11*4+16(sp),a0
	move.l	4+11*4+20(sp),a1

	move.l  tspal(pc),a2
	move.l  tmach(pc),a3

	move.l  tsmach_eax1(pc),a4
	moveq   #0,d0
	move.l  tsmach_eax2(pc),d4
	moveq   #0,d6
	move.l  tsmach_eax3(pc),d5
	moveq   #0,d7
	move.l  tsmach_ecx(pc),a5

	subq.l  #1,d2
	beq.b   tspritevline_end

	tst.b   transrev(pc)
	bne.b   tspritevline_rev
tspritevline_loop:
	move.b  (a0,d7.l),d0
	add.l   a5,d3
	bcs.b   tspritevline_l1
	add.l   a4,d1
	addx.l  d4,d7
	cmp.b   #255,d0
	beq.b   tspritevline_skip1
	move.b  (a1),d6
	lsl.w   #8,d6
	move.b  (a2,d0.w),d6
	move.b  (a3,d6.l),(a1)
tspritevline_skip1:
	subq.l  #1,d2
	add.l   _fixchain(pc),a1
	bne.b   tspritevline_loop
	bra.b   tspritevline_end

tspritevline_l1:
	add.l   a4,d1
	addx.l  d5,d7
	cmp.b   #255,d0
	beq.b   tspritevline_skip2
	move.b  (a1),d6
	lsl.w   #8,d6
	move.b  (a2,d0.w),d6
	move.b  (a3,d6.l),(a1)
tspritevline_skip2:
	subq.l  #1,d2
	add.l   _fixchain(pc),a1
	bne.b   tspritevline_loop
tspritevline_end:
	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

tspritevline_rev:
spritevline_rev_loop:
	move.b  (a0,d7.l),d0
	add.l   a5,d3
	bcs.b   spritevline_rev_l1
	add.l   a4,d1
	addx.l  d4,d7
	cmp.b   #255,d0
	beq.b   spritevline_rev_skip1
	move.b  (a2,d0.w),d6
	lsl.w   #8,d6
	move.b  (a1),d6
	move.b  (a3,d6.l),(a1)
spritevline_rev_skip1:
	subq.l  #1,d2
	add.l   _fixchain(pc),a1
	bne.b   spritevline_rev_loop
	bra.b   spritevline_rev_end

spritevline_rev_l1:
	add.l   a4,d1
	addx.l  d5,d7
	cmp.b   #255,d0
	beq.b   spritevline_rev_skip2
	move.b  (a2,d0.w),d6
	lsl.w   #8,d6
	move.b  (a1),d6
	move.b  (a3,d6.l),(a1)
spritevline_rev_skip2:
	subq.l  #1,d2
	add.l   _fixchain(pc),a1
	bne.b   spritevline_rev_loop
spritevline_rev_end:
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

|-----------------------------------------------------------------------------
| mhline
| ------
|   d0=i1  - unused
|   d1=i2
|   d2=i3
|   d3=i4  - unused
|   a0=i5
|   a1=i6
|-----------------------------------------------------------------------------
    .globl    _mhline
_mhline:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),d1
	move.l	4+11*4+8(sp),d2
	move.l	4+11*4+12(sp),d3
	move.l	4+11*4+16(sp),a0
	move.l	4+11*4+20(sp),a1
	
	move.l  d0,mmach_eax
	move.l  _asm3,mmach_asm3
	move.l  _asm1,mmach_asm1
	move.l  _asm2,mmach_asm2

	move.l  _asm2,d0
	bra.b   INT_mhlineskipmodify

    .even

mmach_eax:  .long    0
mmach_asm3: .long    0
mmach_asm1: .long    0
mmach_asm2: .long    0

    .even

|-----------------------------------------------------------------------------
| mhlineskipmodify
| ----------------
|   d0=i1  - unused
|   d1=i2
|   d2=i3
|   d3=i4  - unused
|   a0=i5
|   a1=i6
|-----------------------------------------------------------------------------
    .globl    _mhlineskipmodify
_mhlineskipmodify:
	movem.l	d2-d7/a2-a6,(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),d1
	move.l	4+11*4+8(sp),d2
	move.l	4+11*4+12(sp),d3
	move.l	4+11*4+16(sp),a0
	move.l	4+11*4+20(sp),a1
	
INT_mhlineskipmodify:
	move.l  mshift_al(pc),d3
	lsr.l   #8,d2
	move.l  mshift_bl(pc),d5
	lsr.l   #8,d2
	move.l  mshift_bl_r(pc),d6
	moveq   #0,d4
	movem.l mmach_eax(pc),a2-a5
NT_mhlineskipmodify_loop:
	move.l  d1,d0
	lsr.l   d3,d0

	move.l  a0,d7
	lsl.l   d5,d0
	lsr.l   d6,d7
	or.l    d7,d0

	move.b  (a2,d0.l),d4
	cmp.b   #255,d4
	beq.b   NT_mhlineskipmodify_skip
	move.b  (a3,d4.w),(a1)
NT_mhlineskipmodify_skip:
	add.l   a4,d1
	add.l   a5,a0
	addq.l  #1,a1
	subq.l  #1,d2
	bpl.b   NT_mhlineskipmodify_loop

	movem.l	(sp)+,d2-d7/a2-a6
	rts

    .even

|-----------------------------------------------------------------------------
| msethlineshift
|-----------------------------------------------------------------------------
    .globl    _msethlineshift
_msethlineshift:
	move.l d2,-(sp)
	
	move.l	4+1*4+0(sp),d0
	move.l	4+1*4+4(sp),d1

	and.l   #0x1f,d0
	and.l   #0x1f,d1

	moveq   #32,d2
	sub.b   d0,d2
	move.l  d2,mshift_al

	move.l  d1,mshift_bl

	moveq   #32,d0
	sub.l   d1,d0
	move.l  d0,mshift_bl_r

	move.l (sp)+,d2
	rts

    .even

mshift_bl_r:    .long    26
mshift_bl:      .long    6
mshift_al:      .long    26

    .even

|-----------------------------------------------------------------------------
| thline
| ------
|   d0=i1  - unused
|   d1=i2
|   d2=i3
|   d3=i4  - unused
|   a0=i5
|   a1=i6
|-----------------------------------------------------------------------------
    .globl    _thline
_thline:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),d1
	move.l	4+11*4+8(sp),d2
	move.l	4+11*4+12(sp),d3
	move.l	4+11*4+16(sp),a0
	move.l	4+11*4+20(sp),a1
	
	move.l  d0,tmach_eax
	move.l  _asm3,tmach_asm3
	move.l  _asm1,tmach_asm1
	move.l  _asm2,tmach_asm2

	move.l  _asm2,d0
	bra.b   INT_thlineskipmodify

    .even

tmach_eax:  .long    0
tmach_asm3: .long    0
tmach_asm1: .long    0
tmach_asm2: .long    0

    .even

|-----------------------------------------------------------------------------
| thlineskipmodify
| ----------------
|   d0=i1  - unused
|   d1=i2
|   d2=i3
|   d3=i4  - unused
|   a0=i5
|   a1=i6
|-----------------------------------------------------------------------------
    .globl    _thlineskipmodify
_thlineskipmodify:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),d0
	move.l	4+11*4+4(sp),d1
	move.l	4+11*4+8(sp),d2
	move.l	4+11*4+12(sp),d3
	move.l	4+11*4+16(sp),a0
	move.l	4+11*4+20(sp),a1
	
INT_thlineskipmodify:
	move.l  tshift_al(pc),d3
	lsr.l   #8,d2
	move.l  tshift_bl(pc),d5
	lsr.l   #8,d2
	move.l  tshift_bl_r(pc),d6
	moveq   #0,d4
	movem.l tmach_eax(pc),a2-a5
	move.l  tmach(pc),a6

	tst.b   transrev(pc)
	bne.b   thlineskipmodify_rev
NT_thlineskipmodify_loop:
	move.l  d1,d0
	lsr.l   d3,d0

	move.l  a0,d7
	lsl.l   d5,d0
	lsr.l   d6,d7
	or.l    d7,d0

	move.b  (a2,d0.l),d4
	cmp.b   #255,d4
	beq.b   NT_thlineskipmodify_skip

	move.b  (a1),d7
	lsl.w   #8,d7
	move.b  (a3,d4.w),d7
	and.l   #0x0000ffff,d7
	move.b  (a6,d7.l),(a1)
NT_thlineskipmodify_skip:
	add.l   a4,d1
	add.l   a5,a0
	addq.l  #1,a1
	subq.l  #1,d2
	bpl.b   NT_thlineskipmodify_loop

	movem.l	d2-d7/a2-a6,-(sp)
	rts

    .even

thlineskipmodify_rev:
hlineskipmodify_rev_loop:
	move.l  d1,d0
	lsr.l   d3,d0

	move.l  a0,d7
	lsl.l   d5,d0
	lsr.l   d6,d7
	or.l    d7,d0

	move.b  (a2,d0.l),d4
	cmp.b   #255,d4
	beq.b   hlineskipmodify_rev_skip

	move.b  (a3,d4.w),d7
	lsl.w   #8,d7
	move.b  (a1),d7
	and.l   #0x0000ffff,d7
	move.b  (a6,d7.l),(a1)
hlineskipmodify_rev_skip:
	add.l   a4,d1
	add.l   a5,a0
	addq.l  #1,a1
	subq.l  #1,d2
	bpl.b   hlineskipmodify_rev_loop

	movem.l	d2-d7/a2-a6,-(sp)
	rts

    .even

|-----------------------------------------------------------------------------
| tsethlineshift
|-----------------------------------------------------------------------------
    .globl    _tsethlineshift
_tsethlineshift:
	move.l d2,-(sp)
	
	move.l	4+1*4+0(sp),d0
	move.l	4+1*4+4(sp),d1

	and.l   #0x1f,d0
	and.l   #0x1f,d1

	moveq   #32,d2
	sub.b   d0,d2
	move.l  d2,tshift_al

	move.l  d1,tshift_bl

	moveq   #32,d0
	sub.l   d1,d0
	move.l  d0,tshift_bl_r

	move.l (sp)+,d2
	rts

    .even

tshift_bl_r:    .long    26
tshift_bl:      .long    6
tshift_al:      .long    26

    .even

	.ifne	0
|-----------------------------------------------------------------------------
| setupslopevlin
|-----------------------------------------------------------------------------
    .globl    _setupslopevlin
_setupslopevlin:
	movem.l	d2-d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1
	move.l	4+2*4+8(sp),d2

	move.l  d1,slopemach_ebx
	move.l  d2,slopemach_ecx

	move.l  d0,d2
	moveq   #1,d3
	and.l   #0x000000ff,d2		| was 0x0000001f, this is BAD! (mikro)
	lsl.l   d2,d3
	subq.l  #1,d3

	move.l  d0,d2
	and.l   #0x0000ff00,d2		| again, 0x00001f00 ??? (mikro)
	lsr.l   #8,d2
	lsl.l   d2,d3

	move.l  d3,slopemach_edx


	move.l  d0,d2
	and.l   #0x0000ff00,d2
	lsr.l   #8,d2
	move.l  #256,d3
	sub.l   d2,d3

	and.l   #0x000000ff,d0
	move.l  d3,d2
	sub.l   d0,d2

	and.l   #0x1f,d3
	and.l   #0x1f,d2

	move.l  d3,slopemach_ah1
	move.l  d2,slopemach_ah2

	fmove.l _asm1,fp0
	fmove.s fp0,asm2_f
	move.l  asm2_f(pc),_asm2

	movem.l	(sp)+,d2-d3
	rts

    .even

slopemach_ebx:  .long    0
slopemach_ecx:  .long    0
slopemach_edx:  .long    0
slopemach_ah1:  .long    0
slopemach_ah2:  .long    0
asm2_f:         .long    0

    .even

|-----------------------------------------------------------------------------
| slopevlin
| ---------
| a0=i1
| a1=i2
| a2=i3
| d0=i4
| d1=i5
| a4=i6
|-----------------------------------------------------------------------------
    .globl    _slopevlin
_slopevlin:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.l	4+11*4+0(sp),a0
	move.l	4+11*4+4(sp),a1
	move.l	4+11*4+8(sp),a2
	move.l	4+11*4+12(sp),d0
	move.l	4+11*4+16(sp),d1
	move.l	4+11*4+20(sp),a4

	move.l  d0,_asm4

	move.l  slopemach_ah1(pc),d6
	move.l  slopemach_ah2(pc),d7
	move.l  slopemach_ebx(pc),a5


	fmove.l _asm3,fp0
	fmove.s asm2_f(pc),fp1
	fadd.x  fp1,fp0  | fp0 = a

	sub.l   slopemach_ecx(pc),a0

	move.l  a1,d3
	lsl.l   #3,d3
	move.l  _globalx3,d4
	mulu.l  d3,d5:d4
	add.l   d4,d1
	move.l  _globaly3,d4
	mulu.l  d3,d5:d4
	add.l   d4,a4

slopevlin_outerloop:
	fmove.s fp0,_fpuasm
	lea     _reciptable,a3
	move.l  _fpuasm,d3
	add.l   d3,d3
	subx.l  d4,d4
	move.l  d3,d5
	and.l   #0xff000000,d5
	and.l   #0x00ffe000,d3
	rol.l   #8,d5
	lsr.l   #8,d3
	subq.b  #2,d5
	lsr.l   #3,d3
	and.l   #0x1f,d5
	move.l  (a3,d3.w),d3
	lsr.l   d5,d3
	eor.l   d4,d3
	|--------------------------------------

	move.l  d3,d4
	sub.l   a1,d4
	move.l  d3,a1
	move.l  d4,d5

	mulu.l  _globaly3,d3:d4
	mulu.l  _globalx3,d3:d5

	fadd.x  fp1,fp0

	move.b  _asm4+3,d5
	cmp.l   #8,_asm4
	blt.b   slopevlin_o2
	move.b  #8,d5

slopevlin_o2:
	move.l  slopemach_ecx(pc),a3
	move.l  slopemach_edx(pc),d3

	move.l  d1,d0
	move.l  a4,d2

slopevlin_innerloop:
	lsr.l   d7,d0
	add.l   d5,d1

	and.l   d3,d0
	lsr.l   d6,d2

	add.l   a3,a0
	add.l   d0,d2

	move.l  (a2),a6
	and.w   #0x0000,d0

	subq.l  #4,a2
	move.b  (a5,d2.l),d0

	add.l   d4,a4
	move.b  (a6,d0.w),(a0)

	move.l  a4,d2
	move.l  d1,d0

	subq.b  #1,d5
	bne.b   slopevlin_innerloop
slopevlin_loopend:
	subq.l  #8,_asm4
	bgt.w   slopevlin_outerloop

	movem.l	d2-d7/a2-a6,-(sp)
	rts
	.endif

    .even

|-----------------------------------------------------------------------------
| nsqrtasm
| --------
| d0=param
|-----------------------------------------------------------------------------
    .globl    _nsqrtasm
_nsqrtasm:
	movem.l d2-d4,-(sp)
	
	move.l	4+3*4+0(sp),d0

	lea     _shlookup,a0
	lea     _sqrtable,a1
	moveq   #12,d3
	moveq   #24,d4

	move.l  d0,d2
	move.l  d0,d1

	and.l   #0xff000000,d2
	beq.b   nsqrtasm_o1
	lsr.l   d4,d1
	move.w  8192(a0,d1.l*2),d2
	bra.b   nsqrtasm_o2
nsqrtasm_o1:
	lsr.l   d3,d1
	move.w  (a0,d1.l*2),d2
nsqrtasm_o2:
	move.w  d2,d1
	and.w   #0x001f,d2
	lsr.w   #8,d1

	lsr.l   d2,d0
	move.w  (a1,d0.l*2),d0
	lsr.l   d1,d0

	movem.l (sp)+,d2-d4
	rts

    .even

|-----------------------------------------------------------------------------
| krecipasm
| ---------
| d0=param
|-----------------------------------------------------------------------------
    .globl    _krecipasm
_krecipasm:
	movem.l d2-d4,-(sp)
	
	move.l	4+3*4+0(sp),d0

	lea     _reciptable,a0
	moveq   #10,d3

	fmove.l d0,fp0
	moveq   #23,d4

	fmove.s fp0,d1
	add.l   d0,d0

	subx.l  d2,d2
	move.l  d1,d0

	and.l   #0x007ff000,d0
	sub.l   #0x3f800000,d1

	lsr.l   d3,d0
	lsr.l   d4,d1

	move.l  (a0,d0.l),d0
	lsr.l   d1,d0

	eor.l   d2,d0

	movem.l (sp)+,d2-d4
	rts

    .even

|-----------------------------------------------------------------------------
| setgotpic
| ---------
| d0=param
|-----------------------------------------------------------------------------
    .globl    _setgotpic
_setgotpic:
	move.l	a2,-(sp)
	
	move.l	4+1*4(sp),d0

	lea     _walock,a1
	move.l  d0,d1

	add.l   d0,a1
	lea     _pow2char,a2

	and.l   #7,d1
	lea     _gotpic,a0

	lsr.l   #3,d0
	move.b  (a2,d1.w),d1


	cmp.b   #200,(a1)
	bge.b   setgotpic_o1

	move.b  #199,(a1)
setgotpic_o1:
	or.b    d1,(a0,d0.l)

	move.l (sp)+,a2
	rts

    .even

|-----------------------------------------------------------------------------
| getclipmask
| -----------
| d0=i1
| d1=i2
| d2=i3
| d3=i4
|-----------------------------------------------------------------------------
    .globl    _getclipmask
_getclipmask:
	movem.l d2-d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1
	move.l	4+2*4+8(sp),d2
	move.l	4+2*4+12(sp),d3

	and.l   #0x80000000,d0
	rol.l   #1,d0

	add.l   d1,d1
	addx.l  d0,d0

	add.l   d2,d2
	addx.l  d0,d0

	add.l   d3,d3
	addx.l  d0,d0

	move.l  d0,d1
	lsl.l   #4,d1
	or.b    #0xf0,d0

	eor.l   d1,d0

	movem.l (sp)+,d2-d3
	rts

    .even


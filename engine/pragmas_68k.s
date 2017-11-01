    |section "dukepragmas",code

|-----------------------------------------------------------------------------
| msqrtasm
|-----------------------------------------------------------------------------
    .globl    _msqrtasm
_msqrtasm:
	movem.l d2-d3,-(sp)
	
	move.l	4+2*4+0(sp),d0

	move.l  #0x40000000,d1
	move.l  #0x20000000,d2
msqrtasm_begit:
	cmp.l   d1,d0
	blt.b   msqrtasm_skip
	sub.l   d1,d0
	move.l  d2,d3
	lsl.l   #2,d3
	add.l   d3,d1
msqrtasm_skip:
	sub.l   d2,d1
	lsr.l   #1,d1
	lsr.l   #2,d2
	bne.b   msqrtasm_begit

	cmp.l   d1,d0
	bcs.b   msqrtasm_fini
	addq.l  #1,d1
msqrtasm_fini:
	lsr.l   #1,d1
	move.l  d1,d0

	movem.l (sp)+,d2-d3
	rts

    .even

|-----------------------------------------------------------------------------
| sqr
|-----------------------------------------------------------------------------
    .globl    _sqr
_sqr:
	move.l	4(sp),d0
	muls.l  d0,d0
	rts

    .even

|-----------------------------------------------------------------------------
| scale
|-----------------------------------------------------------------------------
    .globl    _scale
_scale:
	move.l  d2,-(sp)
	
	move.l	4+1*4+0(sp),d0
	move.l	4+1*4+4(sp),d1
	move.l	4+1*4+8(sp),d2

	muls.l  d1,d1:d0
	divs.l  d2,d1:d0

	move.l  (sp)+,d2
	rts

    .even

|-----------------------------------------------------------------------------
| mulscale
|-----------------------------------------------------------------------------
    .globl    _mulscale
_mulscale:
	movem.l d2-d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1
	move.l	4+2*4+8(sp),d2

	muls.l  d1,d1:d0
	moveq   #32,d3
	sub.l   d2,d3
	lsr.l   d2,d0
	lsl.l   d3,d1
	or.l    d1,d0

	movem.l (sp)+,d2-d3
	rts

    .even

|-----------------------------------------------------------------------------
| mulscale1-8
|-----------------------------------------------------------------------------
	 .macro	mulscalesA in1
    .globl _mulscale\in1
_mulscale\in1:
	move.l  d2,-(sp)
	
	move.l	4+1*4+0(sp),d0
	move.l	4+1*4+4(sp),d1
	
	muls.l  d1,d1:d0
	moveq   #32-\in1,d2
	lsr.l   #\in1,d0
	lsl.l   d2,d1
	or.l    d1,d0

	move.l  (sp)+,d2
	rts

    .even

	.endm

    mulscalesA 1
    mulscalesA 2
    mulscalesA 3
    mulscalesA 4
    mulscalesA 5
    mulscalesA 6
    mulscalesA 7
    mulscalesA 8

|-----------------------------------------------------------------------------
| mulscale9-23
|-----------------------------------------------------------------------------
	 .macro	mulscalesB in1
    .globl _mulscale\in1
_mulscale\in1:
	movem.l d2-d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1

	muls.l  d1,d1:d0
	moveq   #\in1,d3
	moveq   #32-\in1,d2
	lsr.l   d3,d0
	lsl.l   d2,d1
	or.l    d1,d0

	movem.l (sp)+,d2-d3
	rts

    .even

	.endm

    mulscalesB 9
    mulscalesB 10
    mulscalesB 11
    mulscalesB 12
    mulscalesB 13
    mulscalesB 14
    mulscalesB 15
    mulscalesB 16
    mulscalesB 17
    mulscalesB 18
    mulscalesB 19
    mulscalesB 20
    mulscalesB 21
    mulscalesB 22
    mulscalesB 23

|-----------------------------------------------------------------------------
| mulscale24-31
|-----------------------------------------------------------------------------
	 .macro	mulscalesC in1
    .globl _mulscale\in1
_mulscale\in1:
	move.l  d2,-(sp)
	
	move.l	4+1*4+0(sp),d0
	move.l	4+1*4+4(sp),d1

	muls.l  d1,d1:d0
	moveq   #\in1,d2
	lsr.l   d2,d0
	lsl.l   #32-\in1,d1
	or.l    d1,d0

	move.l  (sp)+,d2
	rts

    .even

	.endm

    mulscalesC 24
    mulscalesC 25
    mulscalesC 26
    mulscalesC 27
    mulscalesC 28
    mulscalesC 29
    mulscalesC 30
    mulscalesC 31

|-----------------------------------------------------------------------------
| mulscale32
|-----------------------------------------------------------------------------
    .globl _mulscale32
_mulscale32:
	move.l	4+0(sp),d0
	move.l	4+4(sp),d1
	
	muls.l  d1,d1:d0
	move.l  d1,d0

	rts

    .even

|-----------------------------------------------------------------------------
| dmulscale
|-----------------------------------------------------------------------------
    .globl _dmulscale
_dmulscale:
	movem.l d2-d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1
	move.l	4+2*4+8(sp),d2
	move.l	4+2*4+12(sp),d3

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	add.l   d2,d0
	addx.l  d3,d1

	moveq   #32,d2
	sub.l   d4,d2
	lsr.l   d4,d0
	lsl.l   d2,d1
	or.l    d1,d0

	movem.l (sp)+,d2-d3
	rts

    .even

|-----------------------------------------------------------------------------
| dmulscale1-8
|-----------------------------------------------------------------------------
	 .macro	dmulscalesA in1
    .globl _dmulscale\in1
_dmulscale\in1:
	movem.l d2-d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1
	move.l	4+2*4+8(sp),d2
	move.l	4+2*4+12(sp),d3

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	add.l   d2,d0
	addx.l  d3,d1

	moveq   #32-\in1,d2
	lsr.l   #\in1,d0
	lsl.l   d2,d1
	or.l    d1,d0

	movem.l (sp)+,d2-d3
	rts

    .even

	.endm

    dmulscalesA 1
    dmulscalesA 2
    dmulscalesA 3
    dmulscalesA 4
    dmulscalesA 5
    dmulscalesA 6
    dmulscalesA 7
    dmulscalesA 8

|-----------------------------------------------------------------------------
| dmulscale9-23
|-----------------------------------------------------------------------------
	 .macro	dmulscalesB in1
    .globl _dmulscale\in1
_dmulscale\in1:
	movem.l d2-d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1
	move.l	4+2*4+8(sp),d2
	move.l	4+2*4+12(sp),d3

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	add.l   d2,d0
	addx.l  d3,d1

	moveq   #\in1,d2
	moveq   #32-\in1,d3
	lsr.l   d2,d0
	lsl.l   d3,d1
	or.l    d1,d0

	movem.l (sp)+,d2-d3
	rts

    .even

	.endm

    dmulscalesB 9
    dmulscalesB 10
    dmulscalesB 11
    dmulscalesB 12
    dmulscalesB 13
    dmulscalesB 14
    dmulscalesB 15
    dmulscalesB 16
    dmulscalesB 17
    dmulscalesB 18
    dmulscalesB 19
    dmulscalesB 20
    dmulscalesB 21
    dmulscalesB 22
    dmulscalesB 23

|-----------------------------------------------------------------------------
| dmulscale24-31
|-----------------------------------------------------------------------------
	 .macro	dmulscalesC in1
    .globl _dmulscale\in1
_dmulscale\in1:
	movem.l d2-d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1
	move.l	4+2*4+8(sp),d2
	move.l	4+2*4+12(sp),d3

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	add.l   d2,d0
	addx.l  d3,d1

	moveq   #\in1,d3
	lsr.l   d3,d0
	lsl.l   #32-\in1,d1
	or.l    d1,d0

	movem.l (sp)+,d2-d3
	rts

    .even

	.endm

    dmulscalesC 24
    dmulscalesC 25
    dmulscalesC 26
    dmulscalesC 27
    dmulscalesC 28
    dmulscalesC 29
    dmulscalesC 30
    dmulscalesC 31

|-----------------------------------------------------------------------------
| dmulscale32
|-----------------------------------------------------------------------------
    .globl _dmulscale32
_dmulscale32:
	movem.l d2-d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1
	move.l	4+2*4+8(sp),d2
	move.l	4+2*4+12(sp),d3

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	add.l   d2,d0
	addx.l  d3,d1
	move.l  d1,d0

	movem.l (sp)+,d2-d3
	rts

    .even

|-----------------------------------------------------------------------------
| tmulscale1-8
|-----------------------------------------------------------------------------
	 .macro	tmulscalesA in1
    .globl _tmulscale\in1
_tmulscale\in1:
	movem.l d2-d5,-(sp)
	
	move.l	4+4*4+0(sp),d0
	move.l	4+4*4+4(sp),d1
	move.l	4+4*4+8(sp),d2
	move.l	4+4*4+12(sp),d3
	move.l	4+4*4+16(sp),d4
	move.l	4+4*4+20(sp),d5

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	muls.l  d5,d5:d4
	add.l   d2,d0
	addx.l  d3,d1
	add.l   d4,d0
	addx.l  d5,d1
	moveq   #32-\in1,d3
	lsr.l   #\in1,d0
	lsl.l   d3,d1
	or.l    d1,d0

	movem.l (sp)+,d2-d5
	rts

    .even

	.endm

    tmulscalesA 1
    tmulscalesA 2
    tmulscalesA 3
    tmulscalesA 4
    tmulscalesA 5
    tmulscalesA 6
    tmulscalesA 7
    tmulscalesA 8

|-----------------------------------------------------------------------------
| tmulscale9-23
|-----------------------------------------------------------------------------
	 .macro	tmulscalesB in1
    .globl _tmulscale\in1
_tmulscale\in1:
	movem.l d2-d5,-(sp)
	
	move.l	4+4*4+0(sp),d0
	move.l	4+4*4+4(sp),d1
	move.l	4+4*4+8(sp),d2
	move.l	4+4*4+12(sp),d3
	move.l	4+4*4+16(sp),d4
	move.l	4+4*4+20(sp),d5

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	muls.l  d5,d5:d4
	add.l   d2,d0
	addx.l  d3,d1
	add.l   d4,d0
	addx.l  d5,d1
	moveq   #\in1,d2
	moveq   #32-\in1,d3
	lsr.l   d2,d0
	lsl.l   d3,d1
	or.l    d1,d0

	movem.l (sp)+,d2-d5
	rts

    .even

	.endm

    tmulscalesB 9
    tmulscalesB 10
    tmulscalesB 11
    tmulscalesB 12
    tmulscalesB 13
    tmulscalesB 14
    tmulscalesB 15
    tmulscalesB 16
    tmulscalesB 17
    tmulscalesB 18
    tmulscalesB 19
    tmulscalesB 20
    tmulscalesB 21
    tmulscalesB 22
    tmulscalesB 23

|-----------------------------------------------------------------------------
| tmulscale24-31
|-----------------------------------------------------------------------------
	 .macro	tmulscalesC in1
    .globl _tmulscale\in1
_tmulscale\in1:
	movem.l d2-d5,-(sp)
	
	move.l	4+4*4+0(sp),d0
	move.l	4+4*4+4(sp),d1
	move.l	4+4*4+8(sp),d2
	move.l	4+4*4+12(sp),d3
	move.l	4+4*4+16(sp),d4
	move.l	4+4*4+20(sp),d5

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	muls.l  d5,d5:d4
	add.l   d2,d0
	addx.l  d3,d1
	add.l   d4,d0
	addx.l  d5,d1
	moveq   #\in1,d2
	lsl.l   #32-\in1,d1
	lsr.l   d2,d0
	or.l    d1,d0

	movem.l (sp)+,d2-d5
	rts

    .even

	.endm

    tmulscalesC 24
    tmulscalesC 25
    tmulscalesC 26
    tmulscalesC 27
    tmulscalesC 28
    tmulscalesC 29
    tmulscalesC 30
    tmulscalesC 31

|-----------------------------------------------------------------------------
| tmulscale32
|-----------------------------------------------------------------------------
    .globl _tmulscale32
_tmulscale32:
	movem.l d2-d5,-(sp)
	
	move.l	4+4*4+0(sp),d0
	move.l	4+4*4+4(sp),d1
	move.l	4+4*4+8(sp),d2
	move.l	4+4*4+12(sp),d3
	move.l	4+4*4+16(sp),d4
	move.l	4+4*4+20(sp),d5

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	muls.l  d5,d5:d4
	add.l   d2,d0
	addx.l  d3,d1
	add.l   d4,d0
	addx.l  d5,d1
	move.l  d1,d0

	movem.l (sp)+,d2-d5
	rts

    .even

|-----------------------------------------------------------------------------
| boundmulscale
|-----------------------------------------------------------------------------
    .globl _boundmulscale
_boundmulscale:
	movem.l d2-d4,-(sp)
	
	move.l	4+3*4+0(sp),d0
	move.l	4+3*4+4(sp),d1
	move.l	4+3*4+8(sp),d2

	muls.l  d1,d1:d0
	moveq   #32,d4
	move.l  d1,d3
	sub.l   d2,d4
	lsr.l   d2,d0
	lsl.l   d4,d1
	or.l    d1,d0
	asr.l   d2,d1
	eor.l   d0,d1
	bmi.b   boundmulscale_checkit
	eor.l   d0,d1
	beq.b   boundmulscale_skipboundit
boundmulscale_checkit:
	moveq   #31,d4
	move.l  d3,d0
	asr.l   d4,d0
	eor.l   #0x7fffffff,d0
boundmulscale_skipboundit:
	movem.l (sp)+,d2-d4
	rts

    .even

|-----------------------------------------------------------------------------
| divscale
|-----------------------------------------------------------------------------
    .globl _divscale
_divscale:
	move.l  d2,-(sp)
	move.l  d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1
	move.l	4+2*4+8(sp),d2

	move.l  d0,d3
	lsl.l   d2,d0
	neg.b   d2
	and.b   #0x1f,d2
	asr.l   d2,d3
	divs.l  d1,d3:d0

	move.l  (sp)+,d3
	move.l  (sp)+,d2
	rts

    .even

|-----------------------------------------------------------------------------
| divscale1
|-----------------------------------------------------------------------------
    .globl _divscale1
_divscale1:
	move.l  d2,-(sp)
	
	move.l	4+1*4+0(sp),d0
	move.l	4+1*4+4(sp),d1

	add.l   d0,d0
	subx.l  d2,d2
	divs.l  d1,d2:d0

	move.l  (sp)+,d2
	rts

    .even

|-----------------------------------------------------------------------------
| divscale2-8
|-----------------------------------------------------------------------------
	 .macro	divscalesA in1
    .globl _divscale\in1
_divscale\in1:
	move.l  d2,-(sp)
	move.l  d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1

	move.l  d0,d2
	move.l  #32-\in1,d3
	lsl.l   #\in1,d0
	asr.l   d3,d2
	divs.l  d1,d2:d0

	move.l (sp)+,d3
	move.l (sp)+,d2
	rts

    .even

	.endm

    divscalesA 2
    divscalesA 3
    divscalesA 4
    divscalesA 5
    divscalesA 6
    divscalesA 7
    divscalesA 8

|-----------------------------------------------------------------------------
| divscale9-23
|-----------------------------------------------------------------------------
	 .macro	divscalesB in1
    .globl _divscale\in1
_divscale\in1:
	movem.l d2-d4,-(sp)
	
	move.l	4+3*4+0(sp),d0
	move.l	4+3*4+4(sp),d1

	move.l  d0,d2
	move.l  #\in1,d4
	move.l  #32-\in1,d3
	lsl.l   d4,d0
	asr.l   d3,d2
	divs.l  d1,d2:d0

	movem.l (sp)+,d2-d4
	rts

    .even

	.endm

    divscalesB 9
    divscalesB 10
    divscalesB 11
    divscalesB 12
    divscalesB 13
    divscalesB 14
    divscalesB 15
    divscalesB 16
    divscalesB 17
    divscalesB 18
    divscalesB 19
    divscalesB 20
    divscalesB 21
    divscalesB 22
    divscalesB 23

|-----------------------------------------------------------------------------
| divscale24-31
|-----------------------------------------------------------------------------
	 .macro	divscalesC in1
    .globl _divscale\in1
_divscale\in1:
	move.l  d2,-(sp)
	move.l  d3,-(sp)
	
	move.l	4+2*4+0(sp),d0
	move.l	4+2*4+4(sp),d1

	move.l  d0,d2
	move.l  #\in1,d3
	asr.l   #32-\in1,d2
	lsl.l   d3,d0
	divs.l  d1,d2:d0

	move.l  (sp)+,d3
	move.l  (sp)+,d2
	rts

    .even

	.endm

    divscalesC 24
    divscalesC 25
    divscalesC 26
    divscalesC 27
    divscalesC 28
    divscalesC 29
    divscalesC 30
    divscalesC 31

|-----------------------------------------------------------------------------
| divscale32
|-----------------------------------------------------------------------------
    .globl _divscale32
_divscale32:
	move.l  d2,-(sp)
	
	move.l	4+1*4+0(sp),d0
	move.l	4+1*4+4(sp),d1

	moveq   #0,d2
	divs.l  d1,d0:d2
	move.l  d2,d0

	move.l  (sp)+,d2
	rts

    .even

|-----------------------------------------------------------------------------
| swapchar
|-----------------------------------------------------------------------------
    .globl _swapchar
_swapchar:
	move.l	4+0(sp),a0
	move.l	4+4(sp),a1
	
	move.b  (a0),d0
	move.b  (a1),(a0)
	move.b  d0,(a1)

	rts

    .even

|-----------------------------------------------------------------------------
| swapshort
|-----------------------------------------------------------------------------
    .globl _swapshort
_swapshort:
	move.l	4+0(sp),a0
	move.l	4+4(sp),a1
	
	move.w  (a0),d0
	move.w  (a1),(a0)
	move.w  d0,(a1)

	rts

    .even

|-----------------------------------------------------------------------------
| swaplong
|-----------------------------------------------------------------------------
    .globl _swaplong
_swaplong:
	move.l	4+0(sp),a0
	move.l	4+4(sp),a1
	
	move.l  (a0),d0
	move.l  (a1),(a0)
	move.l  d0,(a1)

	rts

    .even

|-----------------------------------------------------------------------------
| swapchar2
|-----------------------------------------------------------------------------
    .globl _swapchar2
_swapchar2:
	move.l	4+0(sp),a0
	move.l	4+4(sp),a1
	move.l	4+8(sp),d0
	
	move.b  (a0),d1
	move.b  (a1),(a0)
	move.b  d1,(a1)

	move.b  1(a0),d1
	move.b  (a1,d0.l),(a0)
	move.b  d1,(a1,d0.l)

	rts

    .even

|-----------------------------------------------------------------------------
| ksgn
|-----------------------------------------------------------------------------
    .globl _ksgn
    .globl _sgn
_ksgn:
_sgn:
	move.l	4(sp),d1
	
	tst.l   d1
	bmi.b   sgn_neg
	beq.b   sgn_null
	moveq   #1,d0
	rts
sgn_neg:
	moveq   #-1,d0
	rts
sgn_null:
	moveq   #0,d0
	rts

    .even

|-----------------------------------------------------------------------------
| klabs
|-----------------------------------------------------------------------------
    .globl _klabs
_klabs:
	move.l	4+0(sp),d0

	tst.l   d0
	bpl.b   klabs_end
	neg.l   d0
klabs_end:
	rts

    .even

|-----------------------------------------------------------------------------
| mul3
|-----------------------------------------------------------------------------
    .globl _mul3
_mul3:
	move.l	4+0(sp),d1
	
	move.l  d1,d0
	add.l   d0,d0
	add.l   d1,d0
	rts

    .even

|-----------------------------------------------------------------------------
| mul5
|-----------------------------------------------------------------------------
    .globl _mul5
_mul5:
	move.l	4+0(sp),d1
	
	move.l  d1,d0
	lsl.l   #2,d0
	add.l   d1,d0
	rts

    .even

|-----------------------------------------------------------------------------
| mul9
|-----------------------------------------------------------------------------
    .globl _mul9
_mul9:
	move.l	4+0(sp),d1
	
	move.l  d1,d0
	lsl.l   #3,d0
	add.l   d1,d0
	rts

    .even

|-----------------------------------------------------------------------------
| getkensmessagecrc
|-----------------------------------------------------------------------------
    .globl _getkensmessagecrc
_getkensmessagecrc:
	move.l  #0x56c764d4,d0
	rts

    .even

|-----------------------------------------------------------------------------
| clearbuf
|-----------------------------------------------------------------------------
    .globl _clearbuf
_clearbuf:
	move.l	4+0(sp),a0
	move.l	4+4(sp),d0
	move.l	4+8(sp),d1

clearbuf_loop:
	move.l  d1,(a0)+
	subq.l  #1,d0
	bne.b   clearbuf_loop

	rts

    .even

|-----------------------------------------------------------------------------
| clearbufbyte
|-----------------------------------------------------------------------------
    .globl _clearbufbyte
_clearbufbyte:
	move.l	d2,-(sp)
	
	move.l	4+1*4+0(sp),a0
	move.l	4+1*4+4(sp),d0
	move.l	4+1*4+8(sp),d1

	cmp.l   #1,d0
	blt.b   clearbufbyte_end
	bne.b   clearbufbyte_cb2
	move.b  d1,(a0)
	bra.b   clearbufbyte_end
clearbufbyte_cb2:
	cmp.l   #2,d0
	bne.b   clearbufbyte_cb3
	move.w  d1,(a0)
	bra.b   clearbufbyte_end
clearbufbyte_cb3:
	cmp.l   #3,d0
	bne.b   clearbufbyte_cbdefault
	move.w  d1,(a0)
	move.b  d1,2(a0)
	bra.b   clearbufbyte_end
clearbufbyte_cbdefault:
	move.l  a0,d2
	btst    #0,d2
	beq.b   clearbufbyte_cbshort
	move.b  d1,(a0)+
	subq.l  #1,d0
clearbufbyte_cbshort:
	move.l  a0,d2
	btst    #1,d2
	beq.b   clearbufbyte_cblong
	move.w  d1,(a0)+
	subq.l  #2,d0
clearbufbyte_cblong:
	move.l  d0,d2
	lsr.l   #2,d2
	beq.b   clearbufbyte_cbrest
clearbufbyte_loop:
	move.l  d1,(a0)+
	subq.l  #1,d2
	bne.b   clearbufbyte_loop
clearbufbyte_cbrest:
	btst    #1,d0
	beq.b   clearbufbyte_cbchar
	move.w  d1,(a0)+
clearbufbyte_cbchar:
	btst    #0,d0
	beq.b   clearbufbyte_end
	move.b  d1,(a0)
clearbufbyte_end:
	move.l (sp)+,d2
	rts

    .even

|-----------------------------------------------------------------------------
| copybuf
|-----------------------------------------------------------------------------
    .globl _copybuf
_copybuf:
	move.l	4+0(sp),a0
	move.l	4+4(sp),a1
	move.l	4+8(sp),d0
	
	tst.l   d0
	beq.b   copybuf_end
copybuf_loop:
	move.l  (a0)+,(a1)+
	subq.l  #1,d0
	bne.b   copybuf_loop
copybuf_end:
	rts

    .even

|-----------------------------------------------------------------------------
| copybufbyte
|-----------------------------------------------------------------------------
    .globl _copybufbyte
_copybufbyte:
	move.l	4+0(sp),a0
	move.l	4+4(sp),a1
	move.l	4+8(sp),d0

	cmp.l   #1,d0
	blt.b   copybufbyte_end
	bne.b   copybufbyte_cb2
	move.b  (a0),(a1)
	bra.b   copybufbyte_end
copybufbyte_cb2:
	cmp.l   #2,d0
	bne.b   copybufbyte_cb3
	move.w  (a0),(a1)
	bra.b   copybufbyte_end
copybufbyte_cb3:
	cmp.l   #3,d0
	bne.b   copybufbyte_cbdefault
	move.w  (a0),(a1)
	move.b  2(a0),2(a1)
	bra.b   copybufbyte_end
copybufbyte_cbdefault:
	move.l  a0,d1
	btst    #0,d1
	beq.b   copybufbyte_cbshort
	move.b  (a0)+,(a1)+
	subq.l  #1,d0
copybufbyte_cbshort:
	move.l  a0,d1
	btst    #1,d1
	beq.b   copybufbyte_cblong
	move.w  (a0)+,(a1)+
	subq.l  #2,d0
copybufbyte_cblong:
	move.l  d0,d1
	lsr.l   #2,d1
	beq.b   copybufbyte_cbrest
copybufbyte_loop:
	move.l  (a0)+,(a1)+
	subq.l  #1,d1
	bne.b   copybufbyte_loop
copybufbyte_cbrest:
	btst    #1,d0
	beq.b   copybufbyte_cbchar
	move.w  (a0)+,(a1)+
copybufbyte_cbchar:
	btst    #0,d0
	beq.b   copybufbyte_end
	move.b  (a0),(a1)
copybufbyte_end:
	rts

    .even

|-----------------------------------------------------------------------------
| copybufreverse
|-----------------------------------------------------------------------------
    .globl _copybufreverse
_copybufreverse:
	move.l	4+0(sp),a0
	move.l	4+4(sp),a1
	move.l	4+8(sp),d0
	
	tst.l   d0
	beq.b   copybufreverse_end
copybufreverse_loop:
	move.b  (a0),(a1)+
	subq.l  #1,d0
	subq.l  #1,a0
	bne.b   copybufreverse_loop
copybufreverse_end:
	rts

    .even

|-----------------------------------------------------------------------------
| qinterpolatedown16
|-----------------------------------------------------------------------------
    .globl _qinterpolatedown16
_qinterpolatedown16:
	movem.l d2-d4,-(sp)
	
	move.l	4+3*4+0(sp),a0
	move.l	4+3*4+4(sp),d0
	move.l	4+3*4+8(sp),d1
	move.l	4+3*4+12(sp),d2

	moveq   #16,d3
	tst.l   d0
	bne.b   qinterpolatedown16_q1
	lsr.l   d3,d1
	move.l  d1,(a0)
	bra.b   qinterpolatedown16_end
qinterpolatedown16_q1:
	move.l  d1,d4
	lsr.l   d3,d4
	add.l   d2,d1
	move.l  d4,(a0)+
	subq.l  #1,d0
	bne.b   qinterpolatedown16_q1
qinterpolatedown16_end:
	movem.l (sp)+,d2-d4
	rts

    .even

|-----------------------------------------------------------------------------
| qinterpolatedown16short
|-----------------------------------------------------------------------------
    .globl _qinterpolatedown16short
_qinterpolatedown16short:
	movem.l d2-d5,-(sp)
	
	move.l	4+4*4+0(sp),a0
	move.l	4+4*4+4(sp),d0
	move.l	4+4*4+8(sp),d1
	move.l	4+4*4+12(sp),d2

	tst.l   d0
	beq.b   qinterpolatedown16short_end

	moveq   #16,d3
	move.l  a0,d4
	btst    #1,d4
	beq.b   qinterpolatedown16short_q1
	move.l  d1,d4
	lsr.l   d3,d4
	add.l   d2,d1
	move.w  d4,(a0)+
	subq.l  #1,d0
	beq.b   qinterpolatedown16short_end
qinterpolatedown16short_q1:
	subq.l  #2,d0
	bpl.b   qinterpolatedown16short_q2
	lsr.l   d3,d1
	move.w  d1,(a0)
	bra.b   qinterpolatedown16short_end
qinterpolatedown16short_q2:
	move.l  d1,d4
	add.l   d2,d1
	move.l  d1,d5
	lsr.l   d3,d5
	move.w  d5,d4
	add.l   d2,d1
	move.l  d4,(a0)+
	subq.l  #2,d0
	bpl.b   qinterpolatedown16short_q2

	btst    #0,d0
	beq.b   qinterpolatedown16short_end
	lsr.l   d3,d1
	move.w  d1,(a0)
qinterpolatedown16short_end:
	movem.l (sp)+,d2-d5
	rts

    .even




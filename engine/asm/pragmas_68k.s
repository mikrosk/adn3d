    ;section "dukepragmas",code

retregs macro
	movem.l d0-d7/a0-a6,-(sp)
	endm

putregs macro
	movem.l (sp)+,a0-a6/d0-d7
	endm

retregsnod0 macro
	movem.l d1-d7/a0-a6,-(sp)
	endm

putregsnod0 macro
	movem.l (sp)+,a0-a6/d1-d7
	endm


;-----------------------------------------------------------------------------
; msqrtasm
;-----------------------------------------------------------------------------
    XDEF    _msqrtasm
_msqrtasm:
	movem.l d1-d3,-(sp)

	move.l  #$40000000,d1
	move.l  #$20000000,d2
.begit
	cmp.l   d1,d0
	blt.b   .skip
	sub.l   d1,d0
	move.l  d2,d3
	lsl.l   #2,d3
	add.l   d3,d1
.skip
	sub.l   d2,d1
	lsr.l   #1,d1
	lsr.l   #2,d2
	bne.b   .begit

	cmp.l   d1,d0
	bcs.b   .fini
	addq.l  #1,d1
.fini
	lsr.l   #1,d1
	move.l  d1,d0

	movem.l (sp)+,d1-d3
	rts

    even

;-----------------------------------------------------------------------------
; sqr
;-----------------------------------------------------------------------------
    XDEF    _sqr
_sqr:
	muls.l  d0,d0
	rts

    even

;-----------------------------------------------------------------------------
; scale
;-----------------------------------------------------------------------------
    XDEF    _scale
_scale:
	move.l  d1,-(sp)
	move.l  d2,-(sp)

	muls.l  d1,d1:d0
	divs.l  d2,d1:d0

	move.l  (sp)+,d2
	move.l  (sp)+,d1
	rts

    even

;-----------------------------------------------------------------------------
; mulscale
;-----------------------------------------------------------------------------
    XDEF    _mulscale
_mulscale:
	movem.l d1-d3,-(sp)

	muls.l  d1,d1:d0
	moveq   #32,d3
	sub.l   d2,d3
	lsr.l   d2,d0
	lsl.l   d3,d1
	or.l    d1,d0

	movem.l (sp)+,d1-d3
	rts

    even

;-----------------------------------------------------------------------------
; mulscale1-8
;-----------------------------------------------------------------------------
mulscalesA    MACRO
    XDEF _mulscale\1
_mulscale\1:
	move.l  d1,-(sp)
	move.l  d2,-(sp)

	muls.l  d1,d1:d0
	moveq   #32-\1,d2
	lsr.l   #\1,d0
	lsl.l   d2,d1
	or.l    d1,d0

	move.l  (sp)+,d2
	move.l  (sp)+,d1
	rts

    even

	EndM

    mulscalesA 1
    mulscalesA 2
    mulscalesA 3
    mulscalesA 4
    mulscalesA 5
    mulscalesA 6
    mulscalesA 7
    mulscalesA 8

;-----------------------------------------------------------------------------
; mulscale9-23
;-----------------------------------------------------------------------------
mulscalesB   MACRO
    XDEF _mulscale\1
_mulscale\1:
	movem.l d1-d3,-(sp)

	muls.l  d1,d1:d0
	moveq   #\1,d3
	moveq   #32-\1,d2
	lsr.l   d3,d0
	lsl.l   d2,d1
	or.l    d1,d0

	movem.l (sp)+,d1-d3
	rts

    even

	EndM

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

;-----------------------------------------------------------------------------
; mulscale24-31
;-----------------------------------------------------------------------------
mulscalesC   MACRO
    XDEF _mulscale\1
_mulscale\1:
	move.l  d1,-(sp)
	move.l  d2,-(sp)

	muls.l  d1,d1:d0
	moveq   #\1,d2
	lsr.l   d2,d0
	lsl.l   #32-\1,d1
	or.l    d1,d0

	move.l  (sp)+,d2
	move.l  (sp)+,d1
	rts

    even

	EndM

    mulscalesC 24
    mulscalesC 25
    mulscalesC 26
    mulscalesC 27
    mulscalesC 28
    mulscalesC 29
    mulscalesC 30
    mulscalesC 31

;-----------------------------------------------------------------------------
; mulscale32
;-----------------------------------------------------------------------------
    XDEF _mulscale32
_mulscale32:
	move.l  d1,-(sp)

	muls.l  d1,d1:d0
	move.l  d1,d0

	move.l  (sp)+,d1
	rts

    even

;-----------------------------------------------------------------------------
; dmulscale
;-----------------------------------------------------------------------------
    XDEF _dmulscale
_dmulscale:
	movem.l d1-d3,-(sp)

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	add.l   d2,d0
	addx.l  d3,d1

	moveq   #32,d2
	sub.l   d4,d2
	lsr.l   d4,d0
	lsl.l   d2,d1
	or.l    d1,d0

	movem.l (sp)+,d1-d3
	rts

    even

;-----------------------------------------------------------------------------
; dmulscale1-8
;-----------------------------------------------------------------------------
dmulscalesA MACRO
    XDEF _dmulscale\1
_dmulscale\1:
	movem.l d1-d3,-(sp)

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	add.l   d2,d0
	addx.l  d3,d1

	moveq   #32-\1,d2
	lsr.l   #\1,d0
	lsl.l   d2,d1
	or.l    d1,d0

	movem.l (sp)+,d1-d3
	rts

    even

	ENDM

    dmulscalesA 1
    dmulscalesA 2
    dmulscalesA 3
    dmulscalesA 4
    dmulscalesA 5
    dmulscalesA 6
    dmulscalesA 7
    dmulscalesA 8

;-----------------------------------------------------------------------------
; dmulscale9-23
;-----------------------------------------------------------------------------
dmulscalesB MACRO
    XDEF _dmulscale\1
_dmulscale\1:
	movem.l d1-d3,-(sp)

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	add.l   d2,d0
	addx.l  d3,d1

	moveq   #\1,d2
	moveq   #32-\1,d3
	lsr.l   d2,d0
	lsl.l   d3,d1
	or.l    d1,d0

	movem.l (sp)+,d1-d3
	rts

    even

	ENDM

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

;-----------------------------------------------------------------------------
; dmulscale24-31
;-----------------------------------------------------------------------------
dmulscalesC MACRO
    XDEF _dmulscale\1
_dmulscale\1:
	movem.l d1-d3,-(sp)

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	add.l   d2,d0
	addx.l  d3,d1

	moveq   #\1,d3
	lsr.l   d3,d0
	lsl.l   #32-\1,d1
	or.l    d1,d0

	movem.l (sp)+,d1-d3
	rts

    even

	ENDM

    dmulscalesC 24
    dmulscalesC 25
    dmulscalesC 26
    dmulscalesC 27
    dmulscalesC 28
    dmulscalesC 29
    dmulscalesC 30
    dmulscalesC 31

;-----------------------------------------------------------------------------
; dmulscale32
;-----------------------------------------------------------------------------
    XDEF _dmulscale32
_dmulscale32:
	movem.l d1-d3,-(sp)

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	add.l   d2,d0
	addx.l  d3,d1
	move.l  d1,d0

	movem.l (sp)+,d1-d3
	rts

    even

;-----------------------------------------------------------------------------
; tmulscale1-8
;-----------------------------------------------------------------------------
tmulscalesA MACRO
    XDEF _tmulscale\1
_tmulscale\1:
	movem.l d1-d5,-(sp)

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	muls.l  d5,d5:d4
	add.l   d2,d0
	addx.l  d3,d1
	add.l   d4,d0
	addx.l  d5,d1
	moveq   #32-\1,d3
	lsr.l   #\1,d0
	lsl.l   d3,d1
	or.l    d1,d0

	movem.l (sp)+,d1-d5
	rts

    even

	ENDM

    tmulscalesA 1
    tmulscalesA 2
    tmulscalesA 3
    tmulscalesA 4
    tmulscalesA 5
    tmulscalesA 6
    tmulscalesA 7
    tmulscalesA 8

;-----------------------------------------------------------------------------
; tmulscale9-23
;-----------------------------------------------------------------------------
tmulscalesB MACRO
    XDEF _tmulscale\1
_tmulscale\1:
	movem.l d1-d5,-(sp)

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	muls.l  d5,d5:d4
	add.l   d2,d0
	addx.l  d3,d1
	add.l   d4,d0
	addx.l  d5,d1
	moveq   #\1,d2
	moveq   #32-\1,d3
	lsr.l   d2,d0
	lsl.l   d3,d1
	or.l    d1,d0

	movem.l (sp)+,d1-d5
	rts

    even

	ENDM

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

;-----------------------------------------------------------------------------
; tmulscale24-31
;-----------------------------------------------------------------------------
tmulscalesC MACRO
    XDEF _tmulscale\1
_tmulscale\1:
	movem.l d1-d5,-(sp)

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	muls.l  d5,d5:d4
	add.l   d2,d0
	addx.l  d3,d1
	add.l   d4,d0
	addx.l  d5,d1
	moveq   #\1,d2
	lsl.l   #32-\1,d1
	lsr.l   d2,d0
	or.l    d1,d0

	movem.l (sp)+,d1-d5
	rts

    even

	ENDM

    tmulscalesC 24
    tmulscalesC 25
    tmulscalesC 26
    tmulscalesC 27
    tmulscalesC 28
    tmulscalesC 29
    tmulscalesC 30
    tmulscalesC 31

;-----------------------------------------------------------------------------
; tmulscale32
;-----------------------------------------------------------------------------
    XDEF _tmulscale32
_tmulscale32:
	movem.l d1-d5,-(sp)

	muls.l  d1,d1:d0
	muls.l  d3,d3:d2
	muls.l  d5,d5:d4
	add.l   d2,d0
	addx.l  d3,d1
	add.l   d4,d0
	addx.l  d5,d1
	move.l  d1,d0

	movem.l (sp)+,d1-d5
	rts

    even

;-----------------------------------------------------------------------------
; boundmulscale
;-----------------------------------------------------------------------------
    XDEF _boundmulscale
_boundmulscale:
	movem.l d1-d4,-(sp)

	muls.l  d1,d1:d0
	moveq   #32,d4
	move.l  d1,d3
	sub.l   d2,d4
	lsr.l   d2,d0
	lsl.l   d4,d1
	or.l    d1,d0
	asr.l   d2,d1
	eor.l   d0,d1
	bmi.b   .checkit
	eor.l   d0,d1
	beq.b   .skipboundit
.checkit
	moveq   #31,d4
	move.l  d3,d0
	asr.l   d4,d0
	eor.l   #$7fffffff,d0
.skipboundit
	movem.l (sp)+,d1-d4
	rts

    even

;-----------------------------------------------------------------------------
; divscale
;-----------------------------------------------------------------------------
    XDEF _divscale
_divscale:
	move.l  d2,-(sp)
	move.l  d3,-(sp)

	move.l  d0,d3
	lsl.l   d2,d0
	neg.b   d2
	and.b   #$1f,d2
	asr.l   d2,d3
	divs.l  d1,d3:d0

	move.l  (sp)+,d3
	move.l  (sp)+,d2
	rts

    even

;-----------------------------------------------------------------------------
; divscale1
;-----------------------------------------------------------------------------
    XDEF _divscale1
_divscale1:
	move.l  d2,-(sp)

	add.l   d0,d0
	subx.l  d2,d2
	divs.l  d1,d2:d0

	move.l  (sp)+,d2
	rts

    even

;-----------------------------------------------------------------------------
; divscale2-8
;-----------------------------------------------------------------------------
divscalesA MACRO
    XDEF _divscale\1
_divscale\1:
	move.l  d2,-(sp)
	move.l  d3,-(sp)

	move.l  d0,d2
	move.l  #32-\1,d3
	lsl.l   #\1,d0
	asr.l   d3,d2
	divs.l  d1,d2:d0

	move.l (sp)+,d3
	move.l (sp)+,d2
	rts

    even

	ENDM

    divscalesA 2
    divscalesA 3
    divscalesA 4
    divscalesA 5
    divscalesA 6
    divscalesA 7
    divscalesA 8

;-----------------------------------------------------------------------------
; divscale9-23
;-----------------------------------------------------------------------------
divscalesB MACRO
    XDEF _divscale\1
_divscale\1:
	movem.l d1-d4,-(sp)

	move.l  d0,d2
	move.l  #\1,d4
	move.l  #32-\1,d3
	lsl.l   d4,d0
	asr.l   d3,d2
	divs.l  d1,d2:d0

	movem.l (sp)+,d1-d4
	rts

    even

	ENDM

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

;-----------------------------------------------------------------------------
; divscale24-31
;-----------------------------------------------------------------------------
divscalesC MACRO
    XDEF _divscale\1
_divscale\1:
	move.l  d2,-(sp)
	move.l  d3,-(sp)

	move.l  d0,d2
	move.l  #\1,d3
	asr.l   #32-\1,d2
	lsl.l   d3,d0
	divs.l  d1,d2:d0

	move.l  (sp)+,d3
	move.l  (sp)+,d2
	rts

    even

	ENDM

    divscalesC 24
    divscalesC 25
    divscalesC 26
    divscalesC 27
    divscalesC 28
    divscalesC 29
    divscalesC 30
    divscalesC 31

;-----------------------------------------------------------------------------
; divscale32
;-----------------------------------------------------------------------------
    XDEF _divscale32
_divscale32:
	move.l  d2,-(sp)

	moveq   #0,d2
	divs.l  d1,d0:d2
	move.l  d2,d0

	move.l  (sp)+,d2
	rts

    even

;-----------------------------------------------------------------------------
; swapchar
;-----------------------------------------------------------------------------
    XDEF _swapchar
_swapchar:
	move.l  d0,-(sp)

	move.b  (a0),d0
	move.b  (a1),(a0)
	move.b  d0,(a1)

	move.l  (sp)+,d0
	rts

    even

;-----------------------------------------------------------------------------
; swapshort
;-----------------------------------------------------------------------------
    XDEF _swapshort
_swapshort:
	move.l  d0,-(sp)

	move.w  (a0),d0
	move.w  (a1),(a0)
	move.w  d0,(a1)

	move.l  (sp)+,d0
	rts

    even

;-----------------------------------------------------------------------------
; swaplong
;-----------------------------------------------------------------------------
    XDEF _swaplong
_swaplong:
	move.l  d0,-(sp)

	move.l  (a0),d0
	move.l  (a1),(a0)
	move.l  d0,(a1)

	move.l  (sp)+,d0
	rts

    even

;-----------------------------------------------------------------------------
; swapchar2
;-----------------------------------------------------------------------------
    XDEF _swapchar2
_swapchar2:
	move.l  d1,-(sp)

	move.b  (a0),d1
	move.b  (a1),(a0)
	move.b  d1,(a1)

	move.b  1(a0),d1
	move.b  (a1,d0.l),(a0)
	move.b  d1,(a1,d0.l)

	move.l  (sp)+,d1
	rts

    even

;-----------------------------------------------------------------------------
; ksgn
;-----------------------------------------------------------------------------
    XDEF _ksgn
    XDEF _sgn
_ksgn:
_sgn:
	tst.l   d1
	bmi.b   .neg
	beq.b   .null
	moveq   #1,d0
	rts
.neg
	moveq   #-1,d0
	rts
.null
	moveq   #0,d0
	rts

    even

;-----------------------------------------------------------------------------
; klabs
;-----------------------------------------------------------------------------
    XDEF _klabs
_klabs:
	tst.l   d0
	bpl.b   .end
	neg.l   d0
.end
	rts

    even

;-----------------------------------------------------------------------------
; mul3
;-----------------------------------------------------------------------------
    XDEF _mul3
_mul3:
	move.l  d1,d0
	add.l   d0,d0
	add.l   d1,d0
	rts

    even

;-----------------------------------------------------------------------------
; mul5
;-----------------------------------------------------------------------------
    XDEF _mul5
_mul5:
	move.l  d1,d0
	lsl.l   #2,d0
	add.l   d1,d0
	rts

    even

;-----------------------------------------------------------------------------
; mul9
;-----------------------------------------------------------------------------
    XDEF _mul9
_mul9:
	move.l  d1,d0
	lsl.l   #3,d0
	add.l   d1,d0
	rts

    even

;-----------------------------------------------------------------------------
; getkensmessagecrc
;-----------------------------------------------------------------------------
    XDEF _getkensmessagecrc
_getkensmessagecrc:
	move.l  #$56c764d4,d0
	rts

    even

;-----------------------------------------------------------------------------
; clearbuf
;-----------------------------------------------------------------------------
    XDEF _clearbuf
_clearbuf:
	move.l  a0,-(sp)
	move.l  d0,-(sp)

.loop
	move.l  d1,(a0)+
	subq.l  #1,d0
	bne.b   .loop

	move.l  (sp)+,d0
	move.l  (sp)+,a0
	rts

    even

;-----------------------------------------------------------------------------
; clearbufbyte
;-----------------------------------------------------------------------------
    XDEF _clearbufbyte
_clearbufbyte:
	movem.l d0/d2/a0,-(sp)

	cmp.l   #1,d0
	blt.b   .end
	bne.b   .cb2
	move.b  d1,(a0)
	bra.b   .end
.cb2
	cmp.l   #2,d0
	bne.b   .cb3
	move.w  d1,(a0)
	bra.b   .end
.cb3
	cmp.l   #3,d0
	bne.b   .cbdefault
	move.w  d1,(a0)
	move.b  d1,2(a0)
	bra.b   .end
.cbdefault
	move.l  a0,d2
	btst    #0,d2
	beq.b   .cbshort
	move.b  d1,(a0)+
	subq.l  #1,d0
.cbshort
	move.l  a0,d2
	btst    #1,d2
	beq.b   .cblong
	move.w  d1,(a0)+
	subq.l  #2,d0
.cblong
	move.l  d0,d2
	lsr.l   #2,d2
	beq.b   .cbrest
.loop
	move.l  d1,(a0)+
	subq.l  #1,d2
	bne.b   .loop
.cbrest
	btst    #1,d0
	beq.b   .cbchar
	move.w  d1,(a0)+
.cbchar
	btst    #0,d0
	beq.b   .end
	move.b  d1,(a0)
.end
	movem.l (sp)+,d0/d2/a0
	rts

    even

;-----------------------------------------------------------------------------
; copybuf
;-----------------------------------------------------------------------------
    XDEF _copybuf
_copybuf:
	movem.l d0/a0/a1,-(sp)

	tst.l   d0
	beq.b   .end
.loop
	move.l  (a0)+,(a1)+
	subq.l  #1,d0
	bne.b   .loop
.end
	movem.l (sp)+,d0/a0/a1
	rts

    even

;-----------------------------------------------------------------------------
; copybufbyte
;-----------------------------------------------------------------------------
    XDEF _copybufbyte
_copybufbyte:
	movem.l d0-d1/a0-a1,-(sp)

	cmp.l   #1,d0
	blt.b   .end
	bne.b   .cb2
	move.b  (a0),(a1)
	bra.b   .end
.cb2
	cmp.l   #2,d0
	bne.b   .cb3
	move.w  (a0),(a1)
	bra.b   .end
.cb3
	cmp.l   #3,d0
	bne.b   .cbdefault
	move.w  (a0),(a1)
	move.b  2(a0),2(a1)
	bra.b   .end
.cbdefault
	move.l  a0,d1
	btst    #0,d1
	beq.b   .cbshort
	move.b  (a0)+,(a1)+
	subq.l  #1,d0
.cbshort
	move.l  a0,d1
	btst    #1,d1
	beq.b   .cblong
	move.w  (a0)+,(a1)+
	subq.l  #2,d0
.cblong
	move.l  d0,d1
	lsr.l   #2,d1
	beq.b   .cbrest
.loop
	move.l  (a0)+,(a1)+
	subq.l  #1,d1
	bne.b   .loop
.cbrest
	btst    #1,d0
	beq.b   .cbchar
	move.w  (a0)+,(a1)+
.cbchar
	btst    #0,d0
	beq.b   .end
	move.b  (a0),(a1)
.end
	movem.l (sp)+,d0-d1/a0-a1
	rts

    even

;-----------------------------------------------------------------------------
; copybufreverse
;-----------------------------------------------------------------------------
    XDEF _copybufreverse
_copybufreverse:
	movem.l d0/a0/a1,-(sp)

	tst.l   d0
	beq.b   .end
.loop
	move.b  (a0),(a1)+
	subq.l  #1,d0
	subq.l  #1,a0
	bne.b   .loop
.end
	movem.l (sp)+,d0/a0/a1
	rts

    even

;-----------------------------------------------------------------------------
; qinterpolatedown16
;-----------------------------------------------------------------------------
    XDEF _qinterpolatedown16
_qinterpolatedown16:
	movem.l d0-d4/a0,-(sp)

	moveq   #16,d3
	tst.l   d0
	bne.b   .q1
	lsr.l   d3,d1
	move.l  d1,(a0)
	bra.b   .end
.q1
	move.l  d1,d4
	lsr.l   d3,d4
	add.l   d2,d1
	move.l  d4,(a0)+
	subq.l  #1,d0
	bne.b   .q1
.end
	movem.l (sp)+,d0-d4/a0
	rts

    even

;-----------------------------------------------------------------------------
; qinterpolatedown16short
;-----------------------------------------------------------------------------
    XDEF _qinterpolatedown16short
_qinterpolatedown16short:
	movem.l d0-d5/a0,-(sp)

	tst.l   d0
	beq.b   .end

	moveq   #16,d3
	move.l  a0,d4
	btst    #1,d4
	beq.b   .q1
	move.l  d1,d4
	lsr.l   d3,d4
	add.l   d2,d1
	move.w  d4,(a0)+
	subq.l  #1,d0
	beq.b   .end
.q1
	subq.l  #2,d0
	bpl.b   .q2
	lsr.l   d3,d1
	move.w  d1,(a0)
	bra.b   .end
.q2
	move.l  d1,d4
	add.l   d2,d1
	move.l  d1,d5
	lsr.l   d3,d5
	move.w  d5,d4
	add.l   d2,d1
	move.l  d4,(a0)+
	subq.l  #2,d0
	bpl.b   .q2

	btst    #0,d0
	beq.b   .end
	lsr.l   d3,d1
	move.w  d1,(a0)
.end
	movem.l (sp)+,d0-d5/a0
	rts

    even

    END


/*
 * atari_display_asm.s -- video handling for Atari Falcon 060
 *
 * Copyright (c) 2006 Miro Kropacek; miro.kropacek@gmail.com
 * 
 * This file is part of the Atari Duke Nukem 3D project, 3D shooter game by 3D Realms,
 * for Atari Falcon 060 computers.
 *
 * Atari Duke Nukem 3D is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Atari Duke Nukem 3D is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Atari Duke Nukem 3D; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

	.globl	_video_atari_init
	.globl	_video_atari_shutdown
	.globl	_video_atari_set_palette
	.globl	_video_atari_c2p
	.globl	_video_atari_set_320x200

	.text

| void video_atari_init( char* screen )

_video_atari_init:
	move.l	4(sp),temp_1			| screen address
	
	movem.l	d2-d7/a2-a6,-(sp)
	
	pea	save_videl
	move.w	#0x26,-(sp)			| Supexec
	trap	#14				|
	addq.l	#6,sp				|
	
	pea	set_vram
	move.w	#0x26,-(sp)			| Supexec
	trap	#14				|
	addq.l	#6,sp				|
	
	pea	set_vbl				| Supexec
	move.w	#0x26,-(sp)			|
	trap	#14				|
	addq.l	#6,sp				|
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts

save_videl:
	bsr.w	wait_vbl			| avoid flicking
	
	lea	0xffff9800.w,a0			| save falcon palette
	lea	save_pal,a1			|
	moveq	#128-1,d7			|
save_loop:					|
	move.l	(a0)+,(a1)+			|
	move.l	(a0)+,(a1)+			|
	dbra	d7,save_loop			|

	movem.l	0xffff8240.w,d0-d7		| save st palette
	movem.l	d0-d7,(a1)			|

	lea	save_video,a0
	move.l	0xffff8200.w,(a0)+		| vidhm
	move.w	0xffff820c.w,(a0)+		| vidl
	
	move.l	0xffff8282.w,(a0)+		| h-regs
	move.l	0xffff8286.w,(a0)+		|
	move.l	0xffff828a.w,(a0)+		|
	
	move.l	0xffff82a2.w,(a0)+		| v-regs
	move.l	0xffff82a6.w,(a0)+		|
	move.l	0xffff82aa.w,(a0)+		|
	
	move.w	0xffff82c0.w,(a0)+		| vco
	move.w	0xffff82c2.w,(a0)+		| c_s
	
	move.l	0xffff820e.w,(a0)+		| offset
	move.w	0xffff820a.w,(a0)+		| sync
	
	move.b  0xffff8256.w,(a0)+		| p_o
	
	cmpi.w   #0xb0,0xffff8282.w		| st(e) / falcon test
	sle	(a0)+				| it's a falcon resolution
	
	move.w	0xffff8266.w,(a0)+		| f_s
	move.w	0xffff8260.w,(a0)+		| st_s

	rts
	
set_vram:
	move.l	temp_1,d0
	move.l	d0,d1				| set screen
	lsr.w	#8,d0				|
	move.l	d0,0xffff8200.w			|
	move.b	d1,0xffff820d.w			|
	
	move.l	d1,current_vram			| set pointer
	rts
	
set_vbl:
	move.w	0x454.w,d7			| number of slots
	beq.b	set_vbl_end
	
	movea.l	0x456.w,a0			| pointer to slots
	subq.w	#1,d7

set_vbl_loop:
	move.l	(a0),d0
	beq.b	set_vbl_found
	
	addq.l	#4,a0
	dbra	d7,set_vbl_loop
	
set_vbl_found:
	tst.l	d0				| not empty slot
	bne.b	set_vbl_end
	
	move.l	#vbl,(a0)
	move.l	a0,save_vbl
	
set_vbl_end:
	rts
	
	
vbl:	move.l	_screen1,d0			| check if the physical screen
	cmp.l	current_vram,d0			| changed
	bne.b	vbl_changed
	bra.b	vbl_skip
	
vbl_changed:
	move.l	d0,temp_1
	bsr.w	set_vram
	
vbl_skip:
	tst.l	palette_flag
	beq.b	vbl_no_pal
	
	clr.l	palette_flag
	
	lea	current_palette,a0
	lea	0xffff9800.w,a1
	moveq	#256/2-1,d7
vbl_copy_pal:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d7,vbl_copy_pal

vbl_no_pal:
	rts


| void video_atari_shutdown( void )

_video_atari_shutdown:
	movem.l	d2-d7/a2-a6,-(sp)
	
	pea	restore_videl
	move.w	#0x26,-(sp)			| Supexec
	trap	#14				|
	addq.l	#6,sp				|
	
	pea	restore_vbl			| Supexec
	move.w	#0x26,-(sp)			|
	trap	#14				|
	addq.l	#6,sp				|
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
restore_videl:
	bsr.w	wait_vbl			| avoid flicking

	lea	save_video,a0
	
	move.l	(a0)+,0xffff8200.w		| videobase_address:h&m
	move.w	(a0)+,0xffff820c.w		| l
	
	move.l	(a0)+,0xffff8282.w		| h-regs
	move.l	(a0)+,0xffff8286.w		|
	move.l	(a0)+,0xffff828a.w		|
	
	move.l	(a0)+,0xffff82a2.w		| v-regs
	move.l	(a0)+,0xffff82a6.w		|
	move.l	(a0)+,0xffff82aa.w		|
	
	move.w	(a0)+,0xffff82c0.w		| vco
	move.w	(a0)+,0xffff82c2.w		| c_s
	
	move.l	(a0)+,0xffff820e.w		| offset
	move.w	(a0)+,0xffff820a.w		| sync
	
	move.b  (a0)+,0xffff8256.w		| p_o
	
	tst.b   (a0)+   			| st(e) compatible mode?
	bne.b   restore_ok			| yes
        	
	move.w  (a0),0xffff8266.w		| falcon-shift
	
	move.w  0xffff8266.w,-(sp)		| Videl patch
	bsr.w	wait_vbl			| to avoid monochrome
	clr.w   0xffff8266.w			| sync errors
	bsr.w	wait_vbl			| (ripped from
	move.w	(sp)+,0xffff8266.w		| FreeMiNT kernel)
       	
	bra.b	restored

restore_ok:
	|clr.w	0xffff8266.w
	move.w	(a0)+,0xffff8266.w		| falcon-shift
	move.w  (a0),0xffff8260.w		| st-shift
	lea	save_video,a0
	move.w	32(a0),0xffff82c2.w		| c_s
	move.l	34(a0),0xffff820e.w		| offset		
restored:

	lea	save_pal,a0			| restore falcon palette
	lea	0xffff9800.w,a1			|		
	moveq	#128-1,d7			|
restore_loop:					|
	move.l	(a0)+,(a1)+			|
	move.l	(a0)+,(a1)+			|
	dbra	d7,restore_loop			|
	
	movem.l	(a0),d0-d7			| restore st palette
	movem.l	d0-d7,0xffff8240.w		|
	
	rts
	
restore_vbl:
	movea.l	save_vbl,a0
	clr.l	(a0)
	rts


| void video_atari_set_palette( char* palette, int offset, int count );

_video_atari_set_palette:
	move.l	d7,-(sp)
	
	movea.l	(4+4,sp),a0			| source palette
	lea	current_palette,a1
	
	move.l	(8+4,sp),d0			| start offset
	lea	(0.b,a0,d0.l*4),a0
	lea	(0.b,a1,d0.l*4),a1
	
	move.l	(12+4,sp),d7			| count
	subq.l	#1,d7
pal_loop:
	clr.l	d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	move.l	d0,(a1)+
	dbra	d7,pal_loop
	
	addq.l	#1,palette_flag			| reload
	
	move.l	(sp)+,d7
	rts
	

| void video_atari_c2p( char* buffer, char* screen, int size );

_video_atari_c2p:
	move.l	4(sp),temp_1			| source buffer
	move.l	8(sp),temp_2			| screen
	move.l	12(sp),temp_3			| size
	
	movem.l	d2-d7/a2-a6,-(sp)

	movea.l	temp_1,a0
	movea.l	temp_2,a1
	movea.l	a0,a2
	adda.l	temp_3,a2
	
	move.l	#0x0f0f0f0f,d4
	move.l	#0x00ff00ff,d5
	move.l	#0x55555555,d6

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	move.l	d1,d7
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d1
	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d2,d7
	and.l	d4,d7
	eor.l	d7,d2
	lsl.l	#4,d7
	eor.l	d7,d3

	move.l	d2,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsr.l	#8,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#8,d7
	eor.l	d7,d3
	
	bra.b	c2p_start
c2p_pix16:	
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	move.l	d1,d7
	lsr.l	#4,d7
	move.l	a3,(a1)+
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d1
	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d2,d7
	and.l	d4,d7
	eor.l	d7,d2
	move.l	a4,(a1)+
	lsl.l	#4,d7
	eor.l	d7,d3

	move.l	d2,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	move.l	a5,(a1)+
	lsl.l	#8,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsr.l	#8,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	move.l	a6,(a1)+
	lsl.l	#8,d7
	eor.l	d7,d3
	
c2p_start:
	move.l	d2,d7
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	add.l	d7,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsr.l	#1,d7
	eor.l	d1,d7
	and.l	d6,d7
	eor.l	d7,d1
	add.l	d7,d7
	eor.l	d7,d3

	move.w	d2,d7
	move.w	d0,d2
	swap	d2
	move.w	d2,d0
	move.w	d7,d2
	move.w	d3,d7
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	move.l	d2,d7
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	#0x33333333,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsr.l	#2,d7
	eor.l	d1,d7
	and.l	#0x33333333,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d3

	swap	d0
	swap	d1
	swap	d2
	swap	d3

	move.l	d0,a6
	move.l	d2,a5
	move.l	d1,a4
	move.l	d3,a3

	cmp.l	a0,a2
	bne.w	c2p_pix16

	move.l	a3,(a1)+
	move.l	a4,(a1)+
	move.l	a5,(a1)+
	move.l	a6,(a1)+
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
	
_video_atari_set_320x200:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.w	#0x59,-(sp)			| VgetMonitor()
	trap	#14				|
	addq.l	#2,sp				|

	cmp.w	#2,d0
	bne.b	rgb
vga:	move.l	#vga_320x200,temp_1
	bra.b	monitor_ok

rgb:	and.b	#0x01,d0			| %00000001
	beq.b	mono
	move.l	#rgb_320x200,temp_1
	
monitor_ok:
	pea	set_res
	move.w	#0x26,-(sp)			| Supexec
	trap	#14				|
	addq.l	#6,sp				|
		
mono:	movem.l	(sp)+,d2-d7/a2-a6
	rts

set_res:
	bsr.w	wait_vbl			| avoid flicking
	
	movea.l	temp_1,a0
	move.l	(a0)+,0xffff8282.w
	move.l	(a0)+,0xffff8286.w
	move.l	(a0)+,0xffff828a.w
	move.l	(a0)+,0xffff82a2.w
	move.l	(a0)+,0xffff82a6.w
	move.l	(a0)+,0xffff82aa.w
	move.w	(a0)+,0xffff820a.w
	move.w	(a0)+,0xffff82c0.w
	clr.w	0xffff8266.w
	move.w	(a0)+,0xffff8266.w
	move.w	(a0)+,0xffff82c2.w
	move.w	(a0)+,0xffff8210.w

	rts


wait_vbl:
	move.l	a0,-(sp)
	move.w	#0x25,-(sp)			| Vsync()
	trap	#14				| 
	addq.l	#2,sp				|
	movea.l	(sp)+,a0
	rts
	
	
	.data
	
vga_320x200:
	dc.l	0x00C6008D
	dc.l	0x0015029A
	dc.l	0x007B0097
	dc.l	0x041903AD
	dc.l	0x008D008D
	dc.l	0x03AD0415
	dc.w	0x0200
	dc.w	0x0186
	dc.w	0x0010
	dc.w	0x0005
	dc.w	0x00A0

rgb_320x200:
	dc.l	0x00C7009B
	dc.l	0x002402BA
	dc.l	0x008900AB
	dc.l	0x02710205
	dc.l	0x00750075
	dc.l	0x0205026B
	dc.w	0x0200
	dc.w	0x0187
	dc.w	0x0010
	dc.w	0x0000
	dc.w	0x00A0
	
	

	.bss
	
temp_1:	ds.l	1
temp_2:	ds.l	1
temp_3:	ds.l	1

save_pal:
	ds.l	256+16/2			| old colours (falcon+st/e)
save_video:
	ds.b	32+12+2				| videl save
save_vbl:
	ds.l	1				| vbl pointer save
current_vram:
	ds.l	1				| pointer to current buffer
palette_flag:
	ds.l	1				| 1: reload palette
current_palette:
	ds.l	256				| copy of palette registers

/*
 * atari_driver_asm.s -- system handling for Atari Falcon 060
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

	.globl	_atari_ikbd_init
	.globl	_atari_ikbd_shutdown
	
	.globl	_g_scancodeBuffer
	.globl	_g_scancodeBufferHead
	.globl	_g_scancodeShiftDepressed
	.globl	_g_mouseInfo
	.globl	_reset_mouse_deltas
	
	.globl	_atari_timer_init
	.globl	_atari_timer_shutdown
	.globl	_timerhandler
	.globl	_atari_ticks_count

| ----------------------------------------------
	.text
| ----------------------------------------------

_atari_ikbd_init:
	movem.l	d2-d7/a2-a6,-(sp)
	
	pea	ikbd_init			| Supexec
	move.w	#0x26,-(sp)			|
	trap	#14				|
	addq.l	#6,sp				|
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
ikbd_init:
	move	#0x2700,sr			| Disable interrupts

	lea	0xfffffa00.w,a0			| Save MFP registers used for keyboard
	btst	#6,(9.w,a0)			|
	sne	ikbd_ierb			|
	btst	#6,(15.w,a0)			|
	sne	ikbd_imrb			|

	move.l	0x118.w,old_ikbd		| Set our routine
	move.l	#ikbd,0x118.w			|
	bset	#6,0xfffffa09.w			| IERB
	bset	#6,0xfffffa15.w			| IMRB

	move.b	#8,0xfffffc02.w			| Set mouse relative mode
	
	move	#0x2300,sr			| Reenable interrupts
	rts
	
	
_atari_ikbd_shutdown:
	movem.l	d2-d7/a2-a6,-(sp)
	
	pea	ikbd_exit			| Supexec
	move.w	#0x26,-(sp)			|
	trap	#14				|
	addq.l	#6,sp				|
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
ikbd_exit:
	move	#0x2700,sr			| Disable interrupts

	lea	0xfffffa00.w,a0			| Restore previous MFP registers

	bclr	#6,(0x09.w,a0)
	tst.b	ikbd_ierb
	beq.b	ikbd_restoreierb
	bset	#6,(0x09.w,a0)
ikbd_restoreierb:

	bclr	#6,(0x15.w,a0)
	tst.b	ikbd_imrb
	beq.b	ikbd_restoreimrb
	bset	#6,(0x15.w,a0)
ikbd_restoreimrb:

	move.l	old_ikbd,0x118.w

	lea	0xfffffc00.w,a0			| Clear keyboard buffer
ikbd_videbuffer:
	btst	#0,(a0)
	beq.b	ikbd_finbuffer
	tst.b	a0@(0x02)
	bra.b	ikbd_videbuffer
ikbd_finbuffer:

	move	#0x2300,sr			| Reenable interrupts
	rts
	
	
ikbd:
	| Check if source is IKBD or MIDI
	btst	#0,0xfffffc00.w
	beq.w	ikbd_oldmidi

	moveml	d0-d1/a0,sp@-
	moveb	0xfffffc02:w,d0

	| Joystick packet ?
	
	cmpb	#0xff,d0
	beqs	ikbd_yes_joystick

	| Mouse packet ?

	cmpb	#0xf8,d0
	bmis	ikbd_no_mouse
	cmpb	#0xfc,d0
	bpls	ikbd_no_mouse

	| Mouse packet, byte #1

ikbd_yes_mouse:
	lea	_g_mouseInfo,a0
	clr.l	(8.w,a0)			| g_mouseInfo.leftButtonDepressed = false;
	clr.l	(12.w,a0)			| g_mouseInfo.rightButtonDepressed = false;

	move.b	d0,d1
	and.b	#0x01,d1
	beq.b	no_right_button
	addq.l	#1,(12.w,a0)			| g_mouseInfo.rightButtonDepressed = true;
no_right_button:
	move.b	d0,d1
	and.b	#0x02,d1
	beq.b	no_left_button
	addq.l	#1,(8.w,a0)			| g_mouseInfo.leftButtonDepressed = true;
no_left_button:

	movel	#ikbd_mousex,0x118:w
	bras	ikbd_endit_stack

	| Joystick packet, byte #1

ikbd_yes_joystick:
	movel	#ikbd_joystick,0x118:w
	bras	ikbd_endit_stack

	| Keyboard press/release

ikbd_no_mouse:
	moveb	d0,d1
	
	lea	_g_scancodeBuffer,a0
	move.l	_g_scancodeBufferHead,d0
	
	move.b	d1,(0.b,a0,d0.l)		| g_scancodeBuffer[g_scancodeBufferHead] = scancode
	
	addq.l	#1,d0
	and.l	#256-1,d0			| SCANCODE_BUFFER_SIZE-1
	move.l	d0,_g_scancodeBufferHead

	| End of interrupt

ikbd_endit_stack:
	moveml	sp@+,d0-d1/a0
ikbd_endit:
	bclr	#6,0xfffffa11:w
	rte

	| Call old MIDI interrupt

ikbd_oldmidi:
	movel	old_ikbd,sp@-
	rts

	| Mouse packet, byte #2

ikbd_mousex:

	| Check if source is IKBD or MIDI
	btst	#0,0xfffffc00.w
	beqs	ikbd_oldmidi

	movem.l	d0/a0,-(sp)

	lea	_g_mouseInfo,a0			| get pointer to g_mouseInfo structure
	move.b	0xfffffc02,d0
	dc.w	0x49c0				| extb	d0
	
	tst.l	_reset_mouse_deltas
	bne.b	reset_mx
	
	add.l	d0,(0.w,a0)
	bra.b	skip_mx

reset_mx:
	move.l	d0,(0.w,a0)			| save as mx

skip_mx:
	movem.l	(sp)+,d0/a0
	
	movel	#ikbd_mousey,0x118:w
	bras	ikbd_endit

	| Mouse packet, byte #3

ikbd_mousey:

	| Check if source is IKBD or MIDI
	btst	#0,0xfffffc00.w
	beqs	ikbd_oldmidi

	movem.l	d0/a0,-(sp)
	
	lea	_g_mouseInfo,a0			| get pointer to g_mouseInfo structure
	move.b	0xfffffc02,d0
	dc.w	0x49c0				| extb	d0
	
	tst.l	_reset_mouse_deltas
	bne.b	reset_my
	
	add.l	d0,(4.w,a0)
	bra.b	skip_my

reset_my:
	move.l	d0,(4.w,a0)			| save as my
	clr.l	_reset_mouse_deltas
	
skip_my:
	movem.l	(sp)+,d0/a0

	movel	#ikbd,0x118:w
	bra.w	ikbd_endit

	| Joystick packet, byte #2

ikbd_joystick:

	| Check if source is IKBD or MIDI
	btst	#0,0xfffffc00.w
	beq.w	ikbd_oldmidi

	moveb	0xfffffc02:w,d0

	movel	#ikbd,0x118:w
	bra.w	ikbd_endit


_atari_timer_init:
	movem.l	d2-d7/a2-a6,-(sp)
	
	pea	set_timer
	move.w	#0x26,-(sp)			| Supexec
	trap	#14				|
	addq.l	#6,sp				|
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
set_timer:
	move.w	sr,d0				|save sr
	move.w	#0x2700,sr			|ints off

	lea.l	save_mfp,a0			|save mfp
	move.b	0xfffffa09.w,(a0)+		|
	move.b	0xfffffa15.w,(a0)+		|
	move.b	0xfffffa1d.w,(a0)+		|
	move.b	0xfffffa25.w,(a0)+		|

	bset	#4,0xfffffa09.w			|timer-d
	bset	#4,0xfffffa15.w			|
	or.b	#0b111,0xfffffa1d.w		|%111 = divide by 200
	move.b	#123,0xfffffa25.w		|2457600/200/123 approx 100 Hz

	move.l	0x110.w,save_timer_d		|save timer-d vector
	move.l	#timer_d,0x110.w		|own timer-d

	move.w	d0,sr				|ints back
	rts
	
	
_atari_timer_shutdown:
	movem.l	d2-d7/a2-a6,-(sp)
	
	pea	restore_timer
	move.w	#0x26,-(sp)			| Supexec
	trap	#14				|
	addq.l	#6,sp				|
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts

restore_timer:
	move.w	sr,d0				|save sr
	move.w	#0x2700,sr			|ints off
	
	move.l	save_timer_d,0x110.w		|timer_d
	
	lea.l	save_mfp,a0			|mfp regs
	move.b	(a0)+,0xfffffa09.w		|
	move.b	(a0)+,0xfffffa15.w		|
	move.b	(a0)+,0xfffffa1d.w		|
	move.b	(a0)+,0xfffffa25.w		|
	move.w	d0,sr				|ints back
	rts
	

timer_d:
	addq.l	#1,_atari_ticks_count
	
	movem.l	d0-a6,-(sp)
	
	jsr	_timerhandler
	
	movem.l	(sp)+,d0-a6
	bclr	#4,0xfffffa11.w			|clear busybit
	rte
	
	
| ----------------------------------------------
	.data
| ----------------------------------------------
	
_reset_mouse_deltas:
	dc.l	1				| true
_atari_ticks_count:
	.long	0
	

| ----------------------------------------------
	.bss
| ----------------------------------------------
	
save_mfp:
	ds.b	4
save_timer_d:
	ds.l	1

ikbd_ierb:
	ds.b	1
ikbd_imrb:
	ds.b	1
old_ikbd:
	ds.l	1

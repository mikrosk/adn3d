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
	
	move.w	#0x22,-(sp)			| Kbdvbase()
	trap	#14
	addq.l	#2,sp
	
	movea.l	d0,a0
	lea	(32.w,a0),a0			| get adress to ikbdsys
	move.l	a0,ikbdsys_pointer
	move.l	(a0),old_ikbdsys
	move.l	#new_ikbdsys,(a0)
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
	
_atari_ikbd_shutdown:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.w	#0x22,-(sp)			| Kbdvbase()
	trap	#14
	addq.l	#2,sp
	
	movea.l	d0,a0
	move.l	old_ikbdsys,(32.w,a0)
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	

new_ikbdsys:
	movem.l	d0-d1/a0,-(sp)

	move.b	0xfffffc02.w,d1
	cmp.b	#0xf6,d1
	blo.b	not_ikbd_packet
	
	cmp.b	#0xf6,d1
	|beq.w	mouse_status
	beq.w	not_ikbd_packet
	
	cmp.b	#0xf7,d1
	|beq.w	mouse_absolute
	beq.w	not_ikbd_packet
	
	move.b	d1,d0
	lsr.b	#2,d0
	cmp.b	#0b111110,d0
	beq.w	mouse_relative
	
	cmp.b	#0xfc,d1
	|beq.w	time_of_day
	beq.w	not_ikbd_packet
	
	cmp.b	#0xfd,d1
	|beq.w	joy_report
	beq.w	not_ikbd_packet
	
	move.b	d1,d0
	lsr.b	#1,d0
	cmp.b	#0b1111111,d0
	|beq.w	joy_event
	
not_ikbd_packet:
	cmp.b	#0x2a,d1
	bne.b	shift_not_pressed
	move.l	#1,_g_scancodeShiftDepressed
	bra.b	shift_skip

shift_not_pressed:
	cmp.b	#0x36,d1
	bne.b	shift_skip
	move.l	#1,_g_scancodeShiftDepressed

shift_skip:
	lea	_g_scancodeBuffer,a0
	move.l	_g_scancodeBufferHead,d0
	
	move.b	d1,(0.b,a0,d0.l)		| g_scancodeBuffer[g_scancodeBufferHead] = scancode
	
	addq.l	#1,d0
	and.l	#256-1,d0			| SCANCODE_BUFFER_SIZE-1
	move.l	d0,_g_scancodeBufferHead
	
	movem.l	(sp)+,d0-d1/a0
	|jmp	([old_ikbdsys])
	rts

mouse_status:
	| TODO: reading 'ikbdstate'-times (found in KBDVECS)
	movem.l	(sp)+,d0-d1/a0
	|jmp	([old_ikbdsys])
	rts
	
mouse_absolute:
	| TODO: reading two times LSB+MSB bytes
	movem.l	(sp)+,d0-d1/a0
	|jmp	([old_ikbdsys])
	rts

mouse_relative:
	lea	_g_mouseInfo,a0
	clr.l	(8.w,a0)			| g_mouseInfo.leftButtonDepressed = false;
	clr.l	(12.w,a0)			| g_mouseInfo.rightButtonDepressed = false;

	move.b	d1,d0
	and.b	#0x01,d0
	beq.b	no_right_button
	addq.l	#1,(12.w,a0)			| g_mouseInfo.rightButtonDepressed = true;
no_right_button:
	and.b	#0x02,d1
	beq.b	no_left_button
	addq.l	#1,(8.w,a0)			| g_mouseInfo.leftButtonDepressed = true;
no_left_button:
	
	movea.l	ikbdsys_pointer,a0
	move.l	#mouse_ikbd_sys_1,(a0)		| set pointer to proceed relative x
	movem.l	(sp)+,d0-d1/a0
	|jmp	([old_ikbdsys])
	rts
		
time_of_day:
	| TODO: reading six bytes
	movem.l	(sp)+,d0-d1/a0
	|jmp	([old_ikbdsys])
	rts

joy_report:
	movea.l	ikbdsys_pointer,a0
	move.l	#joy_read_two_bytes,(a0)	| set pointer to proceed two dummy bytes
	
	movem.l	(sp)+,d0-d1/a0
	|jmp	([old_ikbdsys])
	rts
	
joy_event:
	movea.l	ikbdsys_pointer,a0
	move.l	#joy_read_byte,(a0)		| set pointer to proceed one dummy byte
	
	movem.l	(sp)+,d0-d1/a0
	|jmp	([old_ikbdsys])
	rts
	
joy_read_byte:
	movem.l	d0/a0,-(sp)
	
	move.b	0xfffffc02,d0
	movea.l	ikbdsys_pointer,a0
	move.l	#new_ikbdsys,(a0)		| set original pointer
	
	movem.l	(sp)+,d0/a0
	|jmp	([old_ikbdsys])
	rts
	
joy_read_two_bytes:
	movem.l	d0/a0,-(sp)
	
	move.b	0xfffffc02,d0
	movea.l	ikbdsys_pointer,a0
	move.l	#joy_read_byte,(a0)		| set pointer to proceed one dummy byte
	
	movem.l	(sp)+,d0/a0
	|jmp	([old_ikbdsys])
	rts

mouse_ikbd_sys_1:
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
	movea.l	ikbdsys_pointer,a0
	move.l	#mouse_ikbd_sys_2,(a0)		| set pointer to proceed relative y
	
	movem.l	(sp)+,d0/a0
	|jmp	([old_ikbdsys])
	rts

mouse_ikbd_sys_2:
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
	movea.l	ikbdsys_pointer,a0
	move.l	#new_ikbdsys,(a0)		| set original pointer
	
	movem.l	(sp)+,d0/a0
	|jmp	([old_ikbdsys])
	rts


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
	
old_ikbdsys:
	ds.l	1
ikbdsys_pointer:
	ds.l	1
save_mfp:
	ds.b	4
save_timer_d:
	ds.l	1

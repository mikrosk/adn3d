/*
 * atari_dsl_asm.s -- sound and dma handling for Atari Falcon 060
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

	.globl	_sound_atari_init
	.globl	_sound_atari_shutdown
	.globl	_sound_atari_set_buffer
	
	.globl	_mixer_callback

| void sound_atari_init( void );

_sound_atari_init:
	movem.l	d2-d7/a2-a6,-(sp)
	
	pea	save_regs			| Supexec
	move.w	#0x26,-(sp)			|
	trap	#14				|
	addq.l	#6,sp				|
	
	pea	set_timer_a			| Supexec
	move.w	#0x26,-(sp)			|
	trap	#14				|
	addq.l	#6,sp				|
		
	movem.l	(sp)+,d2-d7/a2-a6
	rts

save_regs:
	| audio regs
	lea	save_audio,a0
	move.w	0xffff8930.w,(a0)+
	move.w	0xffff8932.w,(a0)+
	move.b	0xffff8934.w,(a0)+
	move.b	0xffff8935.w,(a0)+
	move.b	0xffff8936.w,(a0)+
	move.b	0xffff8937.w,(a0)+
	move.b	0xffff8938.w,(a0)+
|	move.b	0xffff8939.w,(a0)+
|	move.w	0xffff893a.w,(a0)+
	move.b	0xffff893c.w,(a0)+
	move.b	0xffff8941.w,(a0)+
	move.b	0xffff8943.w,(a0)+
	move.b	0xffff8900.w,(a0)+
	move.b	0xffff8901.w,(a0)+
	move.b	0xffff8920.w,(a0)+
	move.b	0xffff8921.w,(a0)+
	
	| mfp regs
	lea	save_mfp,a0
	move.l	0x134.w,(a0)+
	move.b	0xfffffa1f.w,(a0)+
	move.b	0xfffffa19.w,(a0)+
	move.b	0xfffffa17.w,(a0)+
	move.b	0xfffffa07.w,(a0)+
	move.b	0xfffffa13.w,(a0)+
	rts
	
set_timer_a:
	move	sr,d0				| save sr
	ori	#0x0700,sr			| ints off
		
	move.l	#timer_a,0x134.w		| set timer a handler
	clr.b	0xfffffa19.w			| clear timer a control register
	move.b	#1,0xfffffa1f.w			| count to value '1'
	move.b	#0b1000,0xfffffa19.w		| event count mode
	bclr	#3,0xfffffa17.w			| automatic end-of-interrupt mode
	bset	#5,0xfffffa07.w			| enable timer a
	bset	#5,0xfffffa13.w			| same here (mask register)
	
	move	d0,sr				| ints back
	
	move.w	#1,-(sp)			| interrupt at end of play buffer
	move.w	#0,-(sp)			| timer a
	move.w	#0x87,-(sp)			| setinterrupt()
	trap	#14
	addq.l	#6,sp
	rts
	
timer_a:
	movem.l	d0-d7/a0-a6,-(sp)
	
	bsr.l	_mixer_callback			| call C function
	
	move.b	#1,0xfffffa1f.w			| reset to value '1'
	movem.l	(sp)+,d0-d7/a0-a6
	rte
	

| void sound_atari_set_buffer( unsigned char* pStart, unsigned char* pEnd );
| (called in supervisor, for some strange reason we can't use XBIOS call
| in timer a interrupt)

_sound_atari_set_buffer:
	bclr	#7,0xffff8901.w			| playback select
	
	move.l	4(sp),d0			| buffer start ($00123456)
	swap	d0				| $34560012
	move.b	d0,0xffff8903.w			| high byte
	rol.l	#8,d0				| $56001234
	move.b	d0,0xffff8905.w			| middle byte
	rol.l	#8,d0				| $00123456
	move.b	d0,0xffff8907.w			| low byte
	
	move.l	8(sp),d0			| buffer end ($00123456)
	swap	d0				| $34560012
	move.b	d0,0xffff890f.w			| high byte
	rol.l	#8,d0				| $56001234
	move.b	d0,0xffff8911.w			| middle byte
	rol.l	#8,d0				| $00123456
	move.b	d0,0xffff8913.w			| low byte
		
	rts
	

| void sound_atari_shutdown( void );

_sound_atari_shutdown:
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.w	#0,-(sp)			| disable
	move.w	#0,-(sp)			| timer a
	move.w	#0x87,-(sp)			| setinterrupt()
	trap	#14
	addq.l	#6,sp

	pea	restore_regs			| Supexec
	move.w	#0x26,-(sp)			|
	trap	#14				|
	addq.l	#6,sp				|
		
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
restore_regs:
	| mfp regs
	move	sr,d0				| save sr
	ori	#0x0700,sr			| ints off
	
	lea	save_mfp,a0
	move.l	(a0)+,0x134.w
	move.b	(a0)+,0xfffffa1f.w
	move.b	(a0)+,0xfffffa19.w
	move.b	(a0)+,0xfffffa17.w
	move.b	(a0)+,0xfffffa07.w
	move.b	(a0)+,0xfffffa13.w
	
	move	d0,sr				| ints back
	
	| audio regs
	lea	save_audio,a0
	move.w	(a0)+,0xffff8930.w
	move.w	(a0)+,0xffff8932.w
	move.b	(a0)+,0xffff8934.w
	move.b	(a0)+,0xffff8935.w
	move.b	(a0)+,0xffff8936.w
	move.b	(a0)+,0xffff8937.w
	move.b	(a0)+,0xffff8938.w
|	move.b	(a0)+,0xffff8939.w
|	move.w	(a0)+,0xffff893a.w
	move.b	(a0)+,0xffff893c.w
	move.b	(a0)+,0xffff8941.w
	move.b	(a0)+,0xffff8943.w
	move.b	(a0)+,0xffff8900.w
	move.b	(a0)+,0xffff8901.w
	move.b	(a0)+,0xffff8920.w
	move.b	(a0)+,0xffff8921.w
	rts
	

	.bss

save_audio:
	ds.b	19
save_mfp:
	ds.b	4+5

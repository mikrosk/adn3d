/*
 * atari_dsl_asm.h -- header file for atari_dsl_asm.s
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

#ifndef _SND_ATARI_ASM_H_
#define _SND_ATARI_ASM_H_

extern void sound_atari_init( void );
extern void sound_atari_shutdown( void );
extern void sound_atari_set_callback( void );
extern void sound_atari_set_buffer( unsigned char* pStart, unsigned char* pEnd );

#endif

/*
 * atari_driver.h -- header file for atari_driver.c
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

#ifndef _IN_ATARI_H_
#define _IN_ATARI_H_

#include "atari_compat.h"

typedef struct
{
	int			mx;
	int			my;
	int			leftButtonDepressed;
	int			rightButtonDepressed;
} SMouse;

extern SMouse 	g_mouseInfo;
extern int		reset_mouse_deltas;

extern void atari_ikbd_init();
extern void atari_ikbd_shutdown();
extern void atari_timer_init();
extern void atari_timer_shutdown();

extern unsigned long atari_ticks_count;

extern void ATARI_Quit( void );

#endif

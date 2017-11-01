/*
 * atari_display.h -- header file for atari_display.c
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

#ifndef _ATARI_DISPLAY_H_
#define _ATARI_DISPLAY_H_

#include "atari_compat.h"

#define SCREEN_WIDTH	320
#define SCREEN_HEIGHT	200

unsigned char* g_pChunkyBuffer;

BOOL ATARI_ScreenInit( void );
void ATARI_ScreenQuit( void );
void ATARI_SetPalette( unsigned char *palette, int start, int num );
void ATARI_ScreenUpdate( void );
void ATARI_ScreenSet( void );

#endif

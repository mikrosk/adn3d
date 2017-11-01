/*
 * atari_display.c -- video handling for Atari Falcon 060
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

#include <mint/osbind.h>
#include <mint/ostruct.h>
#include <stdlib.h>
#include <string.h>

#include "atari_compat.h"
#include "atari_display.h"
#include "atari_display_asm.h"

//#define NO_ATARI_VIDEO

unsigned char* g_pChunkyBuffer;

char* screen1 = NULL;	// physical screen

static BOOL isVideoInited = FALSE;

static char* screen2 = NULL;	// logical screen
static char* screen3 = NULL;	// temp screen
#define screen	screen2


BOOL ATARI_ScreenInit( void )
{
	// alloc triplebuffer
	screen1 = (char*)Mxalloc( 3 * SCREEN_WIDTH * SCREEN_HEIGHT + 15, MX_STRAM );
	if( screen1 == NULL )
	{
		printf( "Not enough memory to allocate screens!\n" );
		return FALSE;
	}
	
	// align on 16 bytes & assign the rest of pointers
	screen1 = (char*)( ( (long)screen1 + 15 ) & 0xfffffff0 );
	screen2 = (char*)( (long)screen1 + SCREEN_WIDTH * SCREEN_HEIGHT );
	screen3 = (char*)( (long)screen2 + SCREEN_WIDTH * SCREEN_HEIGHT );
	
	memset( screen1, 0, SCREEN_WIDTH * SCREEN_HEIGHT );
	memset( screen2, 0, SCREEN_WIDTH * SCREEN_HEIGHT );
	memset( screen3, 0, SCREEN_WIDTH * SCREEN_HEIGHT );
	
	
	g_pChunkyBuffer = (unsigned char*)malloc( SCREEN_WIDTH * SCREEN_HEIGHT + 15 );
	if( g_pChunkyBuffer == NULL )
	{
		printf( "Not enough memory to allocate chunky buffer!\n" );
		return FALSE;
	}
	
	g_pChunkyBuffer = (char*)( ( (long)g_pChunkyBuffer + 15 ) & 0xfffffff0 );
	memset( g_pChunkyBuffer, 0, SCREEN_WIDTH * SCREEN_HEIGHT );
	
	return TRUE;
}

void ATARI_ScreenSet( void )
{
	#ifndef NO_ATARI_VIDEO
	video_atari_init( screen1 );
	video_atari_set_320x200();
	isVideoInited = TRUE;
	#endif
}

void ATARI_ScreenQuit( void )
{
	if( isVideoInited == TRUE )
	{
		#ifndef NO_ATARI_VIDEO
		video_atari_shutdown();
		isVideoInited = FALSE;
		#endif
	}
}

void ATARI_SetPalette( unsigned char *palette, int start, int num )
{
	#ifndef NO_ATARI_VIDEO
	video_atari_set_palette( palette, start, num );
	#endif
}

void ATARI_ScreenUpdate( void )
{
	#ifndef NO_ATARI_VIDEO
	char* temp;
	
	video_atari_c2p( g_pChunkyBuffer, screen, SCREEN_WIDTH * SCREEN_HEIGHT );
	
	// cycle 3 screens
	temp	= screen1;
	screen1	= screen2;	// now physical screen = logical screen (i.e. "screen")
	screen2	= screen3;
	screen3 = temp;
	#endif
}

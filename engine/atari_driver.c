/*
 * atari_driver.c -- system handling for Atari Falcon 060
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

/*
 * "Build Engine & Tools" Copyright (c) 1993-1997 Ken Silverman
 * Ken Silverman's official web site: "http://www.advsys.net/ken"
 * See the included license file "BUILDLIC.TXT" for license info.
 * This file IS NOT A PART OF Ken Silverman's original release
 */

#include <mint/osbind.h>
#include <mint/ostruct.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <assert.h>
#include <string.h>
#include "platform.h"
#include "atari_display.h"

#include "build.h"
#include "display.h"
#include "pragmas.h"
#include "engine.h"

#include "a.h"
#include "cache1d.h"

#include "atari_driver.h"
#include "../game/types.h"
#include "../game/keyboard.h"

//#define NO_ATARI_KEYBOARD


int _argc = 0;
char **_argv = NULL;

static long mouse_x = 0;
static long mouse_y = 0;
static long mouse_relative_x = 0;
static long mouse_relative_y = 0;
static short mouse_buttons = 0;

/* so we can make use of setcolor16()... - DDOI */
static unsigned char drawpixel_color=0;

static long last_render_ticks = 0;
long total_render_time = 1;
long total_rendered_frames = 0;

static char *titlelong = NULL;
static char *titleshort = NULL;

#define SCANCODE_BUFFER_SIZE 256
unsigned char g_scancodeBuffer[SCANCODE_BUFFER_SIZE];
int g_scancodeBufferHead = 0;
int g_scancodeBufferTail = 0;
static unsigned char lastkey = 0x00;

long frameplace, imageSize;
char* screen;
long bytesperline;
char permanentupdate = 0, vgacompatible;
long buffermode, origbuffermode, linearmode;

SMouse g_mouseInfo = { 0 };

static unsigned char scancodeTable[256] =
{
	sc_None, sc_Escape, sc_1, sc_2, sc_3, sc_4, sc_5, sc_6,
	sc_7, sc_8, sc_9, sc_0, sc_Minus, sc_Equals, sc_BackSpace, sc_Tab,
	sc_Q, sc_W, sc_E, sc_R, sc_T, sc_Y, sc_U, sc_I,
	sc_O, sc_P, sc_OpenBracket, sc_CloseBracket, sc_Enter, sc_LeftControl, sc_A, sc_S,
	sc_D, sc_F, sc_G, sc_H, sc_J, sc_K, sc_L, sc_SemiColon,
	sc_Quote, sc_Tilde, sc_LeftShift, sc_BackSlash, sc_Z, sc_X, sc_C,
	sc_V, sc_B, sc_N, sc_M, sc_Comma, sc_Period, sc_Slash, sc_RightShift,
	sc_None, sc_LeftAlt, sc_Space, sc_CapsLock, sc_F1, sc_F2, sc_F3, sc_F4,

	sc_F5, sc_F6, sc_F7, sc_F8, sc_F9, sc_F10, sc_None, sc_None,
	sc_Home, sc_UpArrow, sc_None, sc_kpad_Minus, sc_LeftArrow, sc_None, sc_RightArrow,
	sc_kpad_Plus, sc_None, sc_DownArrow, sc_None, sc_Insert, sc_Delete, sc_None, sc_None,
	sc_BackSlash, sc_F11, sc_F12, sc_None, sc_kpad_Slash, sc_Kpad_Star, sc_Kpad_Star, sc_kpad_7,
	sc_kpad_8, sc_kpad_9, sc_kpad_4, sc_kpad_5, sc_kpad_6, sc_kpad_1, sc_kpad_2, sc_kpad_3,
	sc_kpad_0, sc_kpad_Period, sc_kpad_Enter, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,

	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,

	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None,
	sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None, sc_None
};

/* lousy -ansi flag.  :) */
static char *string_dupe(const char *str)
{
    char *retval = malloc(strlen(str) + 1);
    if (retval != NULL)
	strcpy(retval, str);
    return(retval);
} /* string_dupe */

void _handle_events(void)
{
	unsigned char scancode;

	while( g_scancodeBufferHead != g_scancodeBufferTail )
	{
		scancode = g_scancodeBuffer[g_scancodeBufferTail++];
		g_scancodeBufferTail &= SCANCODE_BUFFER_SIZE-1;

		if( scancodeTable[scancode & 0x7f] != sc_None )
		{
			lastkey = scancodeTable[scancode & 0x7f];
			
			if( ( scancode & 0x80 ) != 0 )
			{
				lastkey |= 0x80;	/* +128 signifies that the key is released in DOS. */
			}

			keyhandler();
			//printf( "Scancode: %x\n", scancode );
		}
		else
		{
			//printf( "Scancode (none): %x\n", scancode );
		}
	}

	mouse_relative_x = g_mouseInfo.mx;
	mouse_relative_y = g_mouseInfo.my;

	g_mouseInfo.mx = 0;
	g_mouseInfo.my = 0;

    mouse_x += mouse_relative_x;
    mouse_y += mouse_relative_y;

    if (mouse_x < 0) mouse_x = 0;
    if (mouse_x > SCREEN_WIDTH - 1) mouse_x = SCREEN_WIDTH - 1;
    if (mouse_y < 0) mouse_y = 0;
    if (mouse_y > SCREEN_HEIGHT - 1) mouse_y = SCREEN_HEIGHT - 1;

	if( g_mouseInfo.leftButtonDepressed == TRUE )
	{
		g_mouseInfo.leftButtonDepressed = FALSE;
		mouse_buttons |= 0x01;
	}
	else
	{
		mouse_buttons &= 0xfe;
	}

	if( g_mouseInfo.rightButtonDepressed == TRUE )
	{
		g_mouseInfo.rightButtonDepressed = FALSE;
		mouse_buttons |= 0x02;
	}
	else
	{
		mouse_buttons &= 0xfd;
	}
} /* _handle_events */


void _joystick_init(void)
{
} /* _joystick_init */


void _joystick_deinit(void)
{
} /* _joystick_deinit */


int _joystick_update(void)
{
    return 1;
} /* _joystick_update */


int _joystick_axis(int axis)
{
    return 0;
} /* _joystick_axis */


int _joystick_button(int button)
{
    return 0;
} /* _joystick_button */


unsigned char _readlastkeyhit(void)
{
    return lastkey;
} /* _readlastkeyhit */




void _platform_init(int argc, char **argv, const char *title, const char *icon)
{
    _argc = argc;
    _argv = argv;

    if (title == NULL)
	title = "BUILD";

    if (icon == NULL)
	icon = "BUILD";

    titlelong = string_dupe(title);
    titleshort = string_dupe(icon);

	// clear scancode buffer
	memset( g_scancodeBuffer, 0, SCANCODE_BUFFER_SIZE );

	// setup new ikbd handler
	#ifndef NO_ATARI_KEYBOARD
	atari_ikbd_init();
	#endif

    if( ATARI_ScreenInit() == FALSE )
    {
    	ATARI_Quit();
    	exit( 1 );
    }
} /* _platform_init */


int setvesa(long x, long y)
{
    fprintf(stderr, "setvesa() called in ATARI driver!\n");
    exit(23);
    return(0);
} /* setvesa */


int screencapture(char *filename, char inverseit)
{
    fprintf(stderr, "screencapture() is a stub in the ATARI driver.\n");
    return(0);
} /* screencapture */


/*
 * this is real mess. at first, it's called setvmode( 0x03 )
 * (probably for to be sure we're in text mode) and then
 * _setgamemode( 2, 320, 200 ) so we have to set all important
 * stuff there. (mikro)
 */
void setvmode(int mode)
{
	if( mode == 0x03 )
	{
		// text mode, i.e. restore resolution (MSDOS rulez...)
		ATARI_ScreenQuit();
	}
	else if( mode == 0x13 )
	{
		// famous 320x200/256 mode (13h)
		ATARI_ScreenSet();
	}
	else
	{
		printf( "Mode 0x%x not supported on ATARI!\n", mode );
	}

	return;

} /* setvmode */

int _setgamemode(char davidoption, long daxdim, long daydim)
{
	int i, j;

	frameplace = (long)g_pChunkyBuffer;
	screen = g_pChunkyBuffer;
	imageSize = SCREEN_WIDTH * SCREEN_HEIGHT;

	xdim = SCREEN_WIDTH;
	ydim = SCREEN_HEIGHT;

	vgacompatible = 1;
    linearmode = 1;
    qsetmode = SCREEN_HEIGHT;
    activepage = visualpage = 0;
    horizlookup = horizlookup2 = NULL;
    bytesperline = SCREEN_WIDTH;

    // alloc lookup tables
    horizlookup = (long*)malloc( ydim*4*sizeof(long) );
    horizlookup2 = (long*)malloc( ydim*4*sizeof(long) );

    j = 0;
    for(i = 0; i <= ydim; i++)
    {
	ylookup[i] = j;
	j += bytesperline;
    } /* for */

    horizycent = ((ydim*4)>>1);

    /* Force drawrooms to call dosetaspect & recalculate stuff */
    oxyaspect = oxdimen = oviewingrange = -1;

    setvlinebpl(bytesperline);

    if (searchx < 0) { searchx = halfxdimen; searchy = (ydimen>>1); }

	ATARI_ScreenSet();

	last_render_ticks = getticks();
	return 0;
} /* setgamemode */


int VBE_setPalette(long start, long num, char *palettebuffer)
/*
 * (From Ken's docs:)
 *   Set (num) palette palette entries starting at (start)
 *   palette entries are in a 4-byte format in this order:
 *       0: Blue (0-63)
 *       1: Green (0-63)
 *       2: Red (0-63)
 *       3: Reserved
 *
 * Naturally, the bytes are in the reverse order that SDL wants them...
 *  More importantly, SDL wants the color elements in a range from 0-255,
 *  so we do a conversion.
 */
{
	Uint8 fmt_swap[256*3];
    Uint8 *sdlp = &fmt_swap[start*3];
    char *p = palettebuffer;
    int i;

    for (i = 0; i < num; i++)
    {
	sdlp[2] = (Uint8) ((((float) *p++) / 63.0) * 255.0);
	sdlp[1] = (Uint8) ((((float) *p++) / 63.0) * 255.0);
	sdlp[0] = (Uint8) ((((float) *p++) / 63.0) * 255.0);
	p++;

	sdlp += 3;
    }

	ATARI_SetPalette( fmt_swap, start, num );

	return TRUE;
} /* VBE_setPalette */

void ATARI_FlushKeyboard( void )
{
	while( Cconis() != 0 )
	{
		Cnecin();
	}
}

void ATARI_Quit( void )
{
	ATARI_ScreenQuit();
	#ifndef NO_ATARI_KEYBOARD
	atari_ikbd_shutdown();
	#endif
	ATARI_FlushKeyboard();
}

void _uninitengine(void)
{
	ATARI_Quit();
} /* _uninitengine */

int setupmouse(void)
{
    mouse_x = SCREEN_WIDTH / 2;
    mouse_y = SCREEN_HEIGHT / 2;
    mouse_relative_x = mouse_relative_y = 0;

    return(1);
} /* setupmouse */

void readmousexy(short *x, short *y)
{
    if (x) *x = mouse_relative_x;
    if (y) *y = mouse_relative_y;

    mouse_relative_x = mouse_relative_y = 0;
} /* readmousexy */


void readmousebstatus(short *bstatus)
{
    if (bstatus)
    {
    	*bstatus = mouse_buttons;
    }

    // special wheel treatment
    //if(mouse_buttons&8) mouse_buttons ^= 8;
    //if(mouse_buttons&16) mouse_buttons ^= 16;

} /* readmousebstatus */


void _updateScreenRect(long x, long y, long w, long h)
{
	ATARI_ScreenUpdate();
} /* _updatescreenrect */

// next frame
void _nextpage(void)
{
    Uint32 ticks;

    _handle_events();

    //if (qsetmode == 200)
	//AMIGA_PutPixels((unsigned char*)frameplace,surface->w,surface->h);

	ATARI_ScreenUpdate();

    ticks = getticks();
    total_render_time = (ticks - last_render_ticks);
    if (total_render_time > 1000)
    {
	total_rendered_frames = 0;
	total_render_time = 1;
	last_render_ticks = ticks;
    } /* if */
    total_rendered_frames++;
} /* _nextpage */

unsigned char readpixel(long offset)
{
    return( *((unsigned char *) offset) );
} /* readpixel */

void drawpixel(long offset, unsigned char pixel)
{
    *((unsigned char *) offset) = pixel;
} /* drawpixel */

/* Fix this up The Right Way (TM) - DDOI */
void setcolor16(int col)
{
	drawpixel_color = col;
}

void _idle(void)
{
	_handle_events();
    //AMIGA_Delay(1);
} /* _idle */

void* _getVideoBase(void)
{
    return g_pChunkyBuffer;
}

void inittimer(void)
{
	atari_timer_init();
}

void uninittimer(void)
{
	atari_timer_shutdown();
}

unsigned long getticks(void)
{
	return totalclock;
} /* getticks */



//
// Unused (stub) but referenced functions
//

void setactivepage(long dapagenum)
{
	/* !!! Is this really still needed? - DDOI */
    /*fprintf(stderr, "%s, line %d; setactivepage(): STUB.\n", __FILE__, __LINE__);*/
} /* setactivepage */

void limitrate(void)
{
    /* this is a no-op in SDL. It was for buggy VGA cards in DOS. */
} /* limitrate */

void clear2dscreen(void)
{
} /* clear2dscreen */

/* Most of this line code is taken from Abrash's "Graphics Programming Blackbook".
Remember, sharing code is A Good Thing. AH */
/*static __inline void DrawHorizontalRun (char **ScreenPtr, int XAdvance, int RunLength, char Color)
{
    int i;
    char *WorkingScreenPtr = *ScreenPtr;

    for (i=0; i<RunLength; i++)
    {
	*WorkingScreenPtr = Color;
	WorkingScreenPtr += XAdvance;
    }
    WorkingScreenPtr += surface->w;
    *ScreenPtr = WorkingScreenPtr;
}

static __inline void DrawVerticalRun (char **ScreenPtr, int XAdvance, int RunLength, char Color)
{
    int i;
    char *WorkingScreenPtr = *ScreenPtr;

    for (i=0; i<RunLength; i++)
    {
	*WorkingScreenPtr = Color;
	WorkingScreenPtr += surface->w;
    }
    WorkingScreenPtr += XAdvance;
    *ScreenPtr = WorkingScreenPtr;
}
*/

void drawline16(long XStart, long YStart, long XEnd, long YEnd, char Color)
{
/*    int Temp, AdjUp, AdjDown, ErrorTerm, XAdvance, XDelta, YDelta;
    int WholeStep, InitialPixelCount, FinalPixelCount, i, RunLength;
    char *ScreenPtr;
    long dx, dy;

    if (SDL_MUSTLOCK(surface))
	SDL_LockSurface(surface);

	dx = XEnd-XStart; dy = YEnd-YStart;
	if (dx >= 0)
	{
		if ((XStart > 639) || (XEnd < 0)) return;
		if (XStart < 0) { if (dy) YStart += scale(0-XStart,dy,dx); XStart = 0; }
		if (XEnd > 639) { if (dy) YEnd += scale(639-XEnd,dy,dx); XEnd = 639; }
	}
	else
	{
		if ((XEnd > 639) || (XStart < 0)) return;
		if (XEnd < 0) { if (dy) YEnd += scale(0-XEnd,dy,dx); XEnd = 0; }
		if (XStart > 639) { if (dy) YStart += scale(639-XStart,dy,dx); XStart = 639; }
	}
	if (dy >= 0)
	{
		if ((YStart >= ydim16) || (YEnd < 0)) return;
		if (YStart < 0) { if (dx) XStart += scale(0-YStart,dx,dy); YStart = 0; }
		if (YEnd >= ydim16) { if (dx) XEnd += scale(ydim16-1-YEnd,dx,dy); YEnd = ydim16-1; }
	}
	else
	{
		if ((YEnd >= ydim16) || (YStart < 0)) return;
		if (YEnd < 0) { if (dx) XEnd += scale(0-YEnd,dx,dy); YEnd = 0; }
		if (YStart >= ydim16) { if (dx) XStart += scale(ydim16-1-YStart,dx,dy); YStart = ydim16-1; }
	}

	if (!pageoffset) { YStart += 336; YEnd += 336; }

    if (YStart > YEnd) {
	Temp = YStart;
	YStart = YEnd;
	YEnd = Temp;
	Temp = XStart;
	XStart = XEnd;
	XEnd = Temp;
    }

    ScreenPtr = (char *) (get_framebuffer()) + XStart + (surface->w * YStart);

    if ((XDelta = XEnd - XStart) < 0)
    {
	XAdvance = (-1);
	XDelta = -XDelta;
    } else {
	XAdvance = 1;
    }

    YDelta = YEnd - YStart;

    if (XDelta == 0)
    {
	for (i=0; i <= YDelta; i++)
	{
	    *ScreenPtr = Color;
	    ScreenPtr += surface->w;
	}

	UNLOCK_SURFACE_AND_RETURN;
    }
    if (YDelta == 0)
    {
	for (i=0; i <= XDelta; i++)
	{
	    *ScreenPtr = Color;
	    ScreenPtr += XAdvance;
	}
	UNLOCK_SURFACE_AND_RETURN;
    }
    if (XDelta == YDelta)
    {
	for (i=0; i <= XDelta; i++)
	{
	    *ScreenPtr = Color;
	    ScreenPtr += XAdvance + surface->w;
	}
	UNLOCK_SURFACE_AND_RETURN;
    }

    if (XDelta >= YDelta)
    {
	WholeStep = XDelta / YDelta;
	AdjUp = (XDelta % YDelta) * 2;
	AdjDown = YDelta * 2;
	ErrorTerm = (XDelta % YDelta) - (YDelta * 2);

	InitialPixelCount = (WholeStep / 2) + 1;
	FinalPixelCount = InitialPixelCount;

	if ((AdjUp == 0) && ((WholeStep & 0x01) == 0)) InitialPixelCount--;
	if ((WholeStep & 0x01) != 0) ErrorTerm += YDelta;

	DrawHorizontalRun(&ScreenPtr, XAdvance, InitialPixelCount, Color);

	for (i=0; i<(YDelta-1); i++)
	{
	    RunLength = WholeStep;
	    if ((ErrorTerm += AdjUp) > 0)
	    {
		RunLength ++;
		ErrorTerm -= AdjDown;
	    }

	    DrawHorizontalRun(&ScreenPtr, XAdvance, RunLength, Color);
	 }

	 DrawHorizontalRun(&ScreenPtr, XAdvance, FinalPixelCount, Color);

	 UNLOCK_SURFACE_AND_RETURN;
    } else {
	WholeStep = YDelta / XDelta;
	AdjUp = (YDelta % XDelta) * 2;
	AdjDown = XDelta * 2;
	ErrorTerm = (YDelta % XDelta) - (XDelta * 2);
	InitialPixelCount = (WholeStep / 2) + 1;
	FinalPixelCount = InitialPixelCount;

	if ((AdjUp == 0) && ((WholeStep & 0x01) == 0)) InitialPixelCount --;
	if ((WholeStep & 0x01) != 0) ErrorTerm += XDelta;

	DrawVerticalRun(&ScreenPtr, XAdvance, InitialPixelCount, Color);

	for (i=0; i<(XDelta-1); i++)
	{
	    RunLength = WholeStep;
	    if ((ErrorTerm += AdjUp) > 0)
	    {
		RunLength ++;
		ErrorTerm -= AdjDown;
	    }

	    DrawVerticalRun(&ScreenPtr, XAdvance, RunLength, Color);
	}

	DrawVerticalRun(&ScreenPtr, XAdvance, FinalPixelCount, Color);
	UNLOCK_SURFACE_AND_RETURN;
     }*/
} /* drawline16 */

#if 0
void fillscreen16(long offset, long color, long blocksize)
{
    Uint8 *surface_end;
    Uint8 *wanted_end;
    Uint8 *pixels;

    if (SDL_MUSTLOCK(surface))
	SDL_LockSurface(surface);

    pixels = get_framebuffer();

    if (!pageoffset) {
	    offset = offset << 3;
	    offset += 640*336;
    }

    surface_end = (pixels + (surface->w * surface->h)) - 1;
    wanted_end = (pixels + offset) + blocksize;

    if (offset < 0)
	offset = 0;

    if (wanted_end > surface_end)
	blocksize = ((unsigned long) surface_end) - ((unsigned long) pixels + offset);

    memset(pixels + offset, (int) color, blocksize);

    if (SDL_MUSTLOCK(surface))
	SDL_UnlockSurface(surface);

    _nextpage();
} /* fillscreen16 */
#endif

/* !!! These are incorrect. */
//void drawpixels(long offset, unsigned short pixels)
//{
/*    Uint8 *surface_end;
    Uint16 *pos;

		printf("Blargh!\n");
		exit(91);

    if (SDL_MUSTLOCK(surface))
	SDL_LockSurface(surface);

    surface_end = (((Uint8 *) surface->pixels) + (surface->w * surface->h)) - 2;
    pos = (Uint16 *) (((Uint8 *) surface->pixels) + offset);
    if ((pos >= (Uint16 *) surface->pixels) && (pos < (Uint16 *) surface_end))
	*pos = pixels;

    if (SDL_MUSTLOCK(surface))
	SDL_UnlockSurface(surface);
*/
//} /* drawpixels */

void drawpixel16(long offset)
{
    //drawpixel(((long) surface->pixels + offset), drawpixel_color);
} /* drawpixel16 */


// patch PC mixrates to atari values
int32 PatchAtariMixrate( int32 mixrate )
{
	switch( mixrate )
	{
		case 8000:
			return 8195;
		break;

		case 11000:
			return 12292;
		break;

		case 16000:
			return 16390;
		break;

		case 22000:
			return 24585;
		break;

		case 44000:
			return 49170;
		break;

		default:
			return mixrate;
		break;
	}
}

/* end of atari_driver.c ... */

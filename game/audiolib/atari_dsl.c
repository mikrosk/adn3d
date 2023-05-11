/*
 * atari_dsl.c -- sound and dma handling for Atari Falcon 060
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

#include <mint/falcon.h>
#include <mint/osbind.h>
#include <mint/ostruct.h>
#include <string.h>

#include "atari_dsl_asm.h"

#include "dsl.h"
#include "atari_compat.h"

//#define NO_SOUND

static int mixer_initialized = FALSE;
static int DSL_ErrorCode = DSL_Ok;

static void ( *_CallBackFunc )( void );
extern volatile int MV_MixPage;
static volatile char *_BufferStart;
static int _BufferSize;
static int _NumDivisions;
static int _SampleRate;
static int _remainder;
static int _chunksize;

static int actsound;
static unsigned char *blank_buf[2];

char *DSL_ErrorString( int ErrorNumber )
{
	char *ErrorString;
	
	switch (ErrorNumber) {
		case DSL_Warning:
		case DSL_Error:
			ErrorString = DSL_ErrorString(DSL_ErrorCode);
			break;
		
		case DSL_Ok:
			ErrorString = "Sound system ok.";
			break;
		
		case DSL_SDLInitFailure:
			ErrorString = "Sound system initilization failed.";
			break;
		
		case DSL_MixerActive:
			ErrorString = "Sound system already intialized.";
			break;  
	
		case DSL_MixerInitFailure:
			ErrorString = "Sound system initilization failed.";
			break;
			
		default:
			ErrorString = "Unknown sound system error.";
			break;
	}
	
	return ErrorString;
}

static void DSL_SetErrorCode(int ErrorCode)
{
	DSL_ErrorCode = ErrorCode;
}

int DSL_Init( void )
{
	DSL_SetErrorCode(DSL_Ok);
	
	#ifndef NO_SOUND
	if( Locksnd() == SNDLOCKED )
	{
		DSL_SetErrorCode(DSL_MixerActive);
 		return DSL_Error;
	}
	
	// save sound regs and set timer a for callback
	sound_atari_init();
	#endif
	
	return DSL_Ok;
}

void DSL_Shutdown( void )
{
	#ifndef NO_SOUND
	DSL_StopPlayback();
		
	// restore sound regs
	sound_atari_shutdown();
	
	Unlocksnd();
	#endif
}

void mixer_callback( void )
{
	unsigned char *stptr;
	unsigned char *fxptr;
	int copysize;
	int len;
	
	#ifndef NO_SOUND
	actsound^=1;
	/* len should equal _BufferSize, else this is screwed up */

	stptr = (unsigned char*)blank_buf[actsound];
	len=_chunksize;
	
	if (_remainder > 0) {
		copysize = min(len, _remainder);
		
		fxptr = (unsigned char *)(&_BufferStart[MV_MixPage * _BufferSize]);
		
		memcpy(stptr, fxptr+(_BufferSize-_remainder), copysize);

		len -= copysize;
		_remainder -= copysize;
		
		stptr += copysize;
	}
	
	while (len > 0) {
		/* new buffer */

		_CallBackFunc();
		
		fxptr = (unsigned char *)(&_BufferStart[MV_MixPage * _BufferSize]);

		copysize = min(len, _BufferSize);

		memcpy(stptr, fxptr, copysize);

		len -= copysize;
		
		stptr += copysize;
	}
	
	sound_atari_set_buffer( blank_buf[actsound], blank_buf[actsound] + _chunksize );
	
	_remainder = len;
	#endif
}

int   DSL_BeginBufferedPlayback( char *BufferStart,
      int BufferSize, int NumDivisions, unsigned SampleRate,
      int MixMode, void ( *CallBackFunc )( void ) )
{
	#ifndef NO_SOUND
	if (mixer_initialized) {
		DSL_SetErrorCode(DSL_MixerActive);
		
		return DSL_Error;
	}

	_CallBackFunc = CallBackFunc;
	_BufferStart = BufferStart;
	_BufferSize = (BufferSize / NumDivisions);
	_NumDivisions = NumDivisions;
	_SampleRate = SampleRate;

	_remainder = 0;
	
	_chunksize=4096;
	
	// alloc sound buffers
	blank_buf[0] = (unsigned char *)Mxalloc( _chunksize + 1, MX_STRAM );
	blank_buf[1] = (unsigned char *)Mxalloc( _chunksize + 1, MX_STRAM );
	
	blank_buf[0] = (char*)( ( (int)blank_buf[0] + 1 ) & 0xfffffffe );
	blank_buf[1] = (char*)( ( (int)blank_buf[1] + 1 ) & 0xfffffffe );
	
	memset( blank_buf[0], 0, _chunksize );
	memset( blank_buf[1], 0, _chunksize );
	
	Sndstatus( SND_RESET );
	Soundcmd( ADDERIN, MATIN );	/* input from connection matrix */
	
	/* DMA playback -> DAC */
	switch( SampleRate )
	{
		case 8195:
			Devconnect( DMAPLAY, DAC, CLK25M, CLK8K, NO_SHAKE );
		break;
		
		case 12292:
			Devconnect( DMAPLAY, DAC, CLK25M, CLK12K, NO_SHAKE );
		break;
		
		case 16390:
			Devconnect( DMAPLAY, DAC, CLK25M, CLK16K, NO_SHAKE );
		break;
		
		case 24585:
			Devconnect( DMAPLAY, DAC, CLK25M, CLK25K, NO_SHAKE );
		break;
		
		case 49170:
			Devconnect( DMAPLAY, DAC, CLK25M, CLK50K, NO_SHAKE );
		break;
		
		default:
			Devconnect( 0x0000, DAC, CLK25M, CLK12K, NO_SHAKE );	/* nothing -> DAC */
		break;
	}
	
	if( ( MixMode & STEREO ) && ( MixMode & SIXTEEN_BIT ) )
	{
		Setmode( MODE_STEREO16 );
	}
	else if( ( MixMode & STEREO ) && !( MixMode & SIXTEEN_BIT ) )
	{
		Setmode( MODE_STEREO8 );
	}
	else
	{
		// mono 8bit
		Setmode( MODE_MONO );
	}
	
	
	Dsptristate( DSP_TRISTATE, DSP_TRISTATE );
	
	Setbuffer( SR_PLAY, blank_buf[0], blank_buf[0] + _chunksize );
	
	Buffoper( SB_PLA_ENA | SB_PLA_RPT );	/* enable playback in loop mode */
	
	actsound=0;
	#endif

	mixer_initialized = TRUE;

	return DSL_Ok;
}

void DSL_StopPlayback( void )
{
	#ifndef NO_SOUND
	Buffoper( 0x0000 );	/* disable playback */
	Devconnect( 0x0000, DAC, CLK25M, CLK12K, NO_SHAKE );	/* nothing -> DAC */
	#endif
	
	if (blank_buf[0]  != NULL)
	{
	    Mfree(blank_buf[0]);
	    blank_buf[0] = NULL;
	}
	if (blank_buf[1]  != NULL)
	{
	    Mfree(blank_buf[1]);
	    blank_buf[1] = NULL;
	}
		
	mixer_initialized = FALSE;
}

unsigned DSL_GetPlaybackRate( void )
{
	return _SampleRate;
}

unsigned long DisableInterrupts( void )
{
	return 0;
}

void RestoreInterrupts( unsigned long flags )
{
}


// dummy function referenced somewhere ...
int MUSIC_ErrorCode;
char *MUSIC_ErrorString( int ErrorNumber )
{
	return "MUSIC_ErrorString";
}

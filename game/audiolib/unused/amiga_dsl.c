#define SETUPVERSION    2

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "dsl.h"
#include "util.h"

#include <exec/exec.h>
#include <proto/ahi.h>
#include <proto/dos.h>
#include <proto/exec.h>

#include <devices/ahi.h>
#include "amigasetupstructs.h"

struct Library *AHIBase;
struct MsgPort      *AHImp     = NULL;
struct AHIRequest   *AHIio     = NULL;
BYTE                 AHIDevice = -1;
struct AHIAudioCtrl *actrl     = NULL;

#define CHANNELS   2
#define INT_FREQ   50
LONG mixfreq = 0;

#ifdef __MORPHOS__
#ifndef __interrupt
#define __interrupt
#endif
#endif

static SetupData setupdata;
static BOOL amigasetup;
static ULONG ahiID;


extern volatile int MV_MixPage;

static int DSL_ErrorCode = DSL_Ok;

static int mixer_initialized;

static void ( *_CallBackFunc )( void );
static volatile char *_BufferStart;
static int _BufferSize;
static int _NumDivisions;
static int _SampleRate;
static int _remainder;
static int _chunksize;

static int actsound;
static unsigned char *blank_buf[2];


/*
possible todo ideas: cache sdl/sdl mixer error messages.
*/

char *DSL_ErrorString( int ErrorNumber )
{
	char *ErrorString;
	
	switch (ErrorNumber) {
		case DSL_Warning:
		case DSL_Error:
			ErrorString = DSL_ErrorString(DSL_ErrorCode);
			break;
		
		case DSL_Ok:
			ErrorString = "AHI Driver ok.";
			break;
		
		case DSL_SDLInitFailure:
			ErrorString = "AHI initialization failed.";
			break;
		
		case DSL_MixerActive:
			ErrorString = "AHI already initialized.";
			break;  
	
		case DSL_MixerInitFailure:
			ErrorString = "AHI initialization failed.";
			break;
			
		default:
			ErrorString = "Unknown AHI Driver error.";
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
    FILE *fp;
    LONG setupversion;

    /* read setup for sound */
    amigasetup=FALSE;
    if((fp=fopen("duke3d:amigaduke.prefs","rb")))
    {
	fread(&setupversion,4,1,fp);
	if(setupversion==SETUPVERSION)
	{
	    fread(&setupdata,sizeof(SetupData),1,fp);
	    fclose(fp);
	    amigasetup=TRUE;

	    ahiID=setupdata.sounddata.ahi_id;
	}
    }

    if(!amigasetup)
    {
	ahiID=AHI_INVALID_ID;
    }


    /* open ahi device */
    DSL_SetErrorCode(DSL_Ok);
	
    if((AHImp = CreateMsgPort()))
    {
	if((AHIio = (struct AHIRequest *)CreateIORequest(AHImp,sizeof(struct AHIRequest))))
	{
	    if(!(AHIDevice = OpenDevice(AHINAME, AHI_NO_UNIT,(struct IORequest *) AHIio,NULL)))
	    {
		AHIBase = (struct Library *) AHIio->ahir_Std.io_Device;
		return DSL_Ok;
	    }
	}
    }
    DSL_Shutdown();
    DSL_SetErrorCode(DSL_SDLInitFailure);
    return DSL_Error;
}

void DSL_Shutdown( void )
{
    DSL_StopPlayback();

    if(actrl)
    {
	AHI_FreeAudio(actrl);
	actrl = NULL;
    }

    if(!AHIDevice)
    {
	CloseDevice((struct IORequest *)AHIio);
	AHIDevice=-1;
    }

    if(AHIio)
    {
	DeleteIORequest((struct IORequest *)AHIio);
	AHIio=NULL;
    }

    if(AHImp)
    {
	DeleteMsgPort(AHImp);
	AHImp=NULL;
    }


}

__interrupt static void mixer_callback(struct Hook *hook, struct AHIAudioCtrl *a, APTR bleh)
{
	unsigned char *stptr;
	unsigned char *fxptr;
	int copysize;
	int len;

	actsound^=1;
	/* len should equal _BufferSize, else this is screwed up */

	stptr = (unsigned char*)blank_buf[actsound];
	len=_chunksize;
	
	if (_remainder > 0) {
		copysize = min(len, _remainder);
		
		fxptr = (unsigned char *)(&_BufferStart[MV_MixPage *
			_BufferSize]);
		
		memcpy(stptr, fxptr+(_BufferSize-_remainder), copysize);

		len -= copysize;
		_remainder -= copysize;
		
		stptr += copysize;
	}
	
	while (len > 0) {
		/* new buffer */

		_CallBackFunc();
		
		fxptr = (unsigned char *)(&_BufferStart[MV_MixPage *
			_BufferSize]);

		copysize = min(len, _BufferSize);

		memcpy(stptr, fxptr, copysize);

		len -= copysize;
		
		stptr += copysize;
	}

	AHI_SetSound(0, actsound, 0, 0, actrl, NULL);

	_remainder = len;
}



#ifdef __MORPHOS__

#include <emul/emulinterface.h>

int mixer_callback_stub(void)
{
	struct Hook *hook = (struct Hook *) REG_A0;
	APTR obj = (APTR) REG_A2;
	APTR msg = (APTR) REG_A1;

	mixer_callback(hook, obj, msg);

	return 0;
}

struct EmulLibEntry mixer_callback_GATE = { TRAP_LIBNR, 0, (void (*)(void)) mixer_callback_stub };

struct Hook SoundHook = {
  0,0,
  (ULONG (* )()) &mixer_callback_GATE,
  NULL,
  NULL,
};

#else

struct Hook SoundHook = {
  0,0,
  (ULONG (* )()) mixer_callback,
  NULL,
  NULL,
};

#endif




int   DSL_BeginBufferedPlayback( char *BufferStart,
      int BufferSize, int NumDivisions, unsigned SampleRate,
      int MixMode, void ( *CallBackFunc )( void ) )
{
	unsigned short format;
	int channels;

    struct AHISampleInfo sample[2];

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
	
	format = (MixMode & SIXTEEN_BIT) ? AHIST_S16S : AHIST_S8S;
	channels = (MixMode & STEREO) ? 2 : 1;

	/*_chunksize = 512;
	if(SampleRate>=16000) _chunksize *= 2;
	if(SampleRate>=32000) _chunksize *= 2;

	if (MixMode & SIXTEEN_BIT) _chunksize *= 2;
	if (MixMode & STEREO) _chunksize *= 2;

	printf("buffer: %d  chunk: %d\n",_BufferSize,_chunksize); */

	_chunksize=4096;

	/* get AHI ModeID for stereo, panning and frequency */
	if(!amigasetup)
	{
	    ahiID = AHI_BestAudioID(
				     AHIDB_Stereo,TRUE,
				     AHIDB_Panning,TRUE,
				     AHIDB_Bits,8,
				     AHIDB_MaxChannels,2,
				     AHIDB_MinMixFreq,11025,
				     AHIDB_MaxMixFreq,44100,
				     TAG_DONE);

	    if(ahiID==AHI_INVALID_ID)
	    {
		ahiID=AHI_DEFAULT_ID;
	    }
	}

	actrl = AHI_AllocAudio( AHIA_AudioID,ahiID,
				AHIA_MixFreq,SampleRate,
				AHIA_Channels,1,
				AHIA_Sounds, 2,
				AHIA_SoundFunc,(int)&SoundHook,
				TAG_DONE);
	if(actrl)
	{
	    // Get real mixing frequency
	    AHI_ControlAudio(actrl, AHIC_MixFreq_Query, (int)&mixfreq, TAG_DONE);

	    /* create 2 empty samples */
	    blank_buf[0] = (unsigned char *)calloc(_chunksize,1);
	    blank_buf[1] = (unsigned char *)calloc(_chunksize,1);
	    
	    sample[0].ahisi_Type = format;
	    sample[0].ahisi_Address = blank_buf[0];
	    sample[0].ahisi_Length = _BufferSize;

	    sample[1].ahisi_Type = format;
	    sample[1].ahisi_Address = blank_buf[1];
	    sample[1].ahisi_Length = _BufferSize;

	    AHI_LoadSound(0, AHIST_DYNAMICSAMPLE, &sample[0], actrl);
	    AHI_LoadSound(1, AHIST_DYNAMICSAMPLE, &sample[1], actrl);

	    /* start playing sample 0 */
	    if(!(AHI_ControlAudio(actrl, AHIC_Play, TRUE, TAG_DONE)))
	    {
		AHI_SetFreq(0, mixfreq, actrl, AHISF_IMM);
		AHI_SetVol(0, 0x10000, 0x8000, actrl, AHISF_IMM);
		AHI_SetSound(0, 0, 0, 0, actrl, AHISF_IMM);

		actsound=0;

		mixer_initialized = 1;

		return DSL_Ok;
	    }
	}
	DSL_SetErrorCode(DSL_SDLInitFailure);
	return DSL_Error;
}

void DSL_StopPlayback( void )
{
	AHI_ControlAudio(actrl, AHIC_Play,FALSE,TAG_DONE);
	AHI_UnloadSound(0,actrl);
	AHI_UnloadSound(1,actrl);

	if (blank_buf[0]  != NULL)
	{
	    free(blank_buf[0]);
	    blank_buf[0] = NULL;
	}
	if (blank_buf[1]  != NULL)
	{
	    free(blank_buf[1]);
	    blank_buf[1] = NULL;
	}
	
	mixer_initialized = 0;
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

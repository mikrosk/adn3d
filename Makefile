#
# Duke Nukem 3D Makefile for Atari 1.0
#
# Sep '06 by Miro Kropacek <miro.kropacek@gmail.com>
#

BUILD_DEBUG_DIR=debug
BUILD_RELEASE_DIR=release

CC=m68k-atari-mint-gcc
AS=m68k-atari-mint-as

BASE_CFLAGS=-DPLATFORM_ATARI -DSTUB_NETWORKING -Iengine -funsigned-char -Wno-pointer-sign -Wno-unused-but-set-variable -Wno-unused-variable #-DUSE_M68K_ASM
RELEASE_CFLAGS=$(BASE_CFLAGS) -s -Wall -m68020-60 -O2 -fomit-frame-pointer
DEBUG_CFLAGS=$(BASE_CFLAGS) -g -Wall -m68020-60

DO_CC=$(CC) $(CFLAGS) -o $@ -c $<
DO_AS=$(AS) -m68030 -o $@ $<

#############################################################################
# SETUP AND BUILD
#############################################################################

TARGETS=$(BUILDDIR)/duke3d.ttp

build_debug:
	@mkdir -p $(BUILD_DEBUG_DIR) \
		$(BUILD_DEBUG_DIR)/obj
	$(MAKE) targets BUILDDIR=$(BUILD_DEBUG_DIR) CFLAGS="$(DEBUG_CFLAGS)"

build_release:
	@mkdir -p $(BUILD_RELEASE_DIR) \
		$(BUILD_RELEASE_DIR)/obj
	$(MAKE) targets BUILDDIR=$(BUILD_RELEASE_DIR) CFLAGS="$(RELEASE_CFLAGS)"

all: build_debug

targets: $(TARGETS)

#	$(BUILDDIR)/obj/pragmas_68k.o \
#	$(BUILDDIR)/obj/a_68k_C.o \
#	$(BUILDDIR)/obj/a_68k.o \

ENGINE	= \
	$(BUILDDIR)/obj/atari_compat.o \
	$(BUILDDIR)/obj/cache1d.o \
	$(BUILDDIR)/obj/engine.o \
	$(BUILDDIR)/obj/mmulti.o \
	$(BUILDDIR)/obj/atari_driver.o \
	$(BUILDDIR)/obj/atari_display.o \
	\
	$(BUILDDIR)/obj/pragmas.o \
	$(BUILDDIR)/obj/a.o \
	\
	$(BUILDDIR)/obj/atari_display_asm.o \
	$(BUILDDIR)/obj/atari_driver_asm.o

GAME	= \
	$(BUILDDIR)/obj/actors.o \
	$(BUILDDIR)/obj/animlib.o \
	$(BUILDDIR)/obj/config.o \
	$(BUILDDIR)/obj/control.o \
	$(BUILDDIR)/obj/game.o \
	$(BUILDDIR)/obj/gamedef.o \
	$(BUILDDIR)/obj/global.o \
	$(BUILDDIR)/obj/keyboard.o \
	$(BUILDDIR)/obj/menues.o \
	$(BUILDDIR)/obj/player.o \
	$(BUILDDIR)/obj/premap.o \
	$(BUILDDIR)/obj/rts.o \
	$(BUILDDIR)/obj/scriplib.o \
	$(BUILDDIR)/obj/sector.o \
	$(BUILDDIR)/obj/sounds.o

AUDIO	= \
	$(BUILDDIR)/obj/atari_dsl.o \
	$(BUILDDIR)/obj/atari_dsl_asm.o \
	$(BUILDDIR)/obj/fx_man.o \
	$(BUILDDIR)/obj/ll_man.o \
	$(BUILDDIR)/obj/multivoc.o \
	$(BUILDDIR)/obj/mv_mix.o \
	$(BUILDDIR)/obj/mvreverb.o \
	$(BUILDDIR)/obj/nodpmi.o \
	$(BUILDDIR)/obj/pitch.o \
	$(BUILDDIR)/obj/user.o
	  
$(BUILDDIR)/duke3d.ttp : $(ENGINE) $(GAME) $(AUDIO)
	$(CC) $(CFLAGS) -o $@ $(ENGINE) $(GAME) $(AUDIO) $(LDFLAGS)
	m68k-atari-mint-stack --fix=512k $(BUILDDIR)/duke3d.ttp
	m68k-atari-mint-flags -S $(BUILDDIR)/duke3d.ttp
	mv $(BUILDDIR)/duke3d.ttp .

#####

$(BUILDDIR)/obj/atari_compat.o:	engine/atari_compat.c engine/atari_compat.h
	$(DO_CC)
	
$(BUILDDIR)/obj/a_68k_C.o:	engine/a_68k_C.c engine/build.h engine/a.h
	$(DO_CC)
	
$(BUILDDIR)/obj/cache1d.o:	engine/cache1d.c
	$(DO_CC)
	
$(BUILDDIR)/obj/engine.o:	engine/engine.c
	$(DO_CC)
	
$(BUILDDIR)/obj/mmulti.o:	engine/mmulti.c
	$(DO_CC)
	
$(BUILDDIR)/obj/atari_driver.o:	engine/atari_driver.c engine/atari_display.h
	$(DO_CC)
	
$(BUILDDIR)/obj/atari_display.o:engine/atari_display.c
	$(DO_CC)

$(BUILDDIR)/obj/atari_driver_asm.o:	engine/atari_driver_asm.s
	$(DO_AS)
	
$(BUILDDIR)/obj/atari_display_asm.o:engine/atari_display_asm.s
	$(DO_AS)
	
$(BUILDDIR)/obj/a.o:		engine/a.c
	$(DO_CC)
	
$(BUILDDIR)/obj/pragmas.o:	engine/pragmas.c
	$(DO_CC)

#####

$(BUILDDIR)/obj/actors.o:	game/actors.c
	$(DO_CC)
	
$(BUILDDIR)/obj/animlib.o:	game/animlib.c
	$(DO_CC)
	
$(BUILDDIR)/obj/config.o:	game/config.c
	$(DO_CC)
	
$(BUILDDIR)/obj/control.o:	game/control.c
	$(DO_CC)
	
$(BUILDDIR)/obj/game.o:		game/game.c
	$(DO_CC)
	
$(BUILDDIR)/obj/gamedef.o:	game/gamedef.c
	$(DO_CC)
	
$(BUILDDIR)/obj/global.o:	game/global.c
	$(DO_CC)
	
$(BUILDDIR)/obj/keyboard.o:	game/keyboard.c
	$(DO_CC)
	
$(BUILDDIR)/obj/menues.o:	game/menues.c
	$(DO_CC)
	
$(BUILDDIR)/obj/player.o:	game/player.c
	$(DO_CC)
	
$(BUILDDIR)/obj/premap.o:	game/premap.c
	$(DO_CC)
	
$(BUILDDIR)/obj/rts.o:		game/rts.c
	$(DO_CC)
	
$(BUILDDIR)/obj/scriplib.o:	game/scriplib.c
	$(DO_CC)
	
$(BUILDDIR)/obj/sector.o:	game/sector.c
	$(DO_CC)
	
$(BUILDDIR)/obj/sounds.o:	game/sounds.c
	$(DO_CC)
	
#####

$(BUILDDIR)/obj/atari_dsl.o: 	game/audiolib/atari_dsl.c
	$(DO_CC)

$(BUILDDIR)/obj/atari_dsl_asm.o:	game/audiolib/atari_dsl_asm.s
	$(DO_AS)
	
$(BUILDDIR)/obj/fx_man.o:	game/audiolib/fx_man.c
	$(DO_CC)
	
$(BUILDDIR)/obj/ll_man.o:	game/audiolib/ll_man.c
	$(DO_CC)
	
$(BUILDDIR)/obj/multivoc.o:	game/audiolib/multivoc.c
	$(DO_CC)
	
$(BUILDDIR)/obj/mv_mix.o:	game/audiolib/mv_mix.c
	$(DO_CC)
	
$(BUILDDIR)/obj/mvreverb.o:	game/audiolib/mvreverb.c
	$(DO_CC)
	
$(BUILDDIR)/obj/nodpmi.o:	game/audiolib/nodpmi.c
	$(DO_CC)
	
$(BUILDDIR)/obj/pitch.o:	game/audiolib/pitch.c
	$(DO_CC)
	
$(BUILDDIR)/obj/user.o:		game/audiolib/user.c
	$(DO_CC)
	
#####

$(BUILDDIR)/obj/a_68k.o:	engine/a_68k.s
	$(DO_AS)
	
$(BUILDDIR)/obj/pragmas_68k.o:	engine/pragmas_68k.s
	$(DO_AS)

#####

clean:
	rm -f $(BUILD_DEBUG_DIR)/obj/*.o
	rm -f $(BUILD_RELEASE_DIR)/obj/*.o
	rm -f engine/*~ game/*~
	rm -f duke3d.ttp

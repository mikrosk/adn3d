#!/usr/bin/perl -p

# devpac to gnu as converter 1.1
# powered by perl
# Miro Kropacek 09/2006

# convert local labels to form global_local for each block
(/^[_A-Za-z0-9]([._A-Za-z0-9]*):?/ and $l=$1);
s/^\.([._A-Za-z0-9]+):?(\s*)/${l}_$1:$2/;
s/((?!\.)\W)\.([._A-Za-z0-9]+)/$1${l}_$2/g;
# replace setso <number>/rsreset + so.X/rs.X directives with .set definitions (!)
((s/setso\s*([$()<>0-9*+-\/%]+)// and $num=$1, $count=0) || (s/rsreset// and $count=0, $num=0))
|| (s/^([a-z0-9._]+):?\s*(so|rs)\.b\s*([$()<>0-9*+-\/%]+)/\t.set\t$1,$num+$count/i and $count+=$3*1)
|| (s/^([a-z0-9._]+):?\s*(so|rs)\.w\s*([$()<>0-9*+-\/%]+)/\t.set\t$1,$num+$count/i and $count+=$3*2)
|| (s/^([a-z0-9._]+):?\s*(so|rs)\.[ls]\s*([$()<>0-9*+-\/%]+)/\t.set\t$1,$num+$count/i and $count+=$3*4)
|| (s/^([a-z0-9._]+):?\s*(so|rs)\.d\s*([$()<>0-9*+-\/%]+)/\t.set\t$1,$num+$count/i and $count+=$3*8)
|| (s/^([a-z0-9._]+):?\s*(so|rs)\.x\s*([$()<>0-9*+-\/%]+)/\t.set\t$1,$num+$count/i and $count+=$3*12)
# count also with empty structures
|| (s/^\s*(so|rs)\.b\s*([$()<>0-9*+-\/%]+)//i and $count+=$2*1)
|| (s/^\s*(so|rs)\.w\s*([$()<>0-9*+-\/%]+)//i and $count+=$2*2)
|| (s/^\s*(so|rs)\.[ls]\s*([$()<>0-9*+-\/%]+)//i and $count+=$2*4)
|| (s/^\s*(so|rs)\.d\s*([$()<>0-9*+-\/%]+)//i and $count+=$2*8)
|| (s/^\s*(so|rs)\.x\s*([$()<>0-9*+-\/%]+)//i and $count+=$2*12);
# symbol =/equ value -> .set symbol,value
s/^([A-Za-z0-9._]+)\s*=\s*([$()<>0-9*+-\/%]+)/\t.set\t$1,$2/;
# special patch for equ.s -- there's no .set for flonums! (nonworking)
#s/^([A-Za-z0-9._]+)\s*equ\.s\s*([.$()<>0-9*+-\/%]+)// and $label=$1 and $value=$2;
#s/$label/$value/g;
# : after each label
s/^([A-Za-z0-9._]+)(\s|\n)+/$1:$2/;
# include -> .include
s/^(\s+|[a-z0-9._]+:)(\s*)include/$1$2.include/i;
# xxx: macro -> .macro xxx
s/^([a-z0-9._]+):?(\s*)macro/\t$2.macro\t$1/i;
# endm -> .endm
s/^(\s+|[a-z0-9._]+:)(\s*)endm/$1$2.endm/i;
# even -> .even
s/^(\s+|[a-z0-9._]+:)(\s*)even/$1$2.even/i;
# end -> (nothing)
s/^(\s+|[a-z0-9._]+:)(\s*)end//i;
# incbin -> .incbin
s/^(\s+|[a-z0-9._]+:)(\s*)incbin/$1$2.incbin/i;
# ifXX -> .ifXX
s/^(\s+|[a-z0-9._]+:)(\s*)if(..)/$1$2.if$3/i;
# elseXX -> .else
s/^(\s+|[a-z0-9._]+:)(\s*)else.?.?/$1$2.else/i;
# endc -> .endif
s/^(\s+|[a-z0-9._]+:)(\s*)endc/$1$2.endif/i;
# code -> .text
s/^(\s+|[a-z0-9._]+:)(\s*)code(\s)/$1$2.text$3/i;
# data -> .data
s/^(\s+|[a-z0-9._]+:)(\s*)data(\s)/$1$2.data$3/i;
# bss -> .bss
s/^(\s+|[a-z0-9._]+:)(\s*)bss(\s)/$1$2.bss$3/i;
# rept -> .rept
s/^(\s+|[a-z0-9._]+:)(\s*)rept(\s)/$1$2.rept$3/i;
# endr -> .endr
s/^(\s+|[a-z0-9._]+:)(\s*)endr(\s)/$1$2.endr$3/i;
# xdef, xref -> .globl
s/^(\s+|[a-z0-9._]+:)(\s*)x[dr]ef(\s)/$1$2.globl$3/i;
# cnop 0,4 -> .align 4
s/^(\s+|[a-z0-9._]+:)(\s*)cnop\s*\d,(\d)/$1$2.align\t$3/i;
# dc.b -> .byte
s/^(\s+|[a-z0-9._]+:)(\s*)dc\.b(\s)/$1$2.byte$3/i;
# dc.w -> .word
s/^(\s+|[a-z0-9._]+:)(\s*)dc\.w(\s)/$1$2.word$3/i;
# dc.l -> .long
s/^(\s+|[a-z0-9._]+:)(\s*)dc\.l(\s)/$1$2.long$3/i;
# dc.s -> .float
s/^(\s+|[a-z0-9._]+:)(\s*)dc\.s(\s)/$1$2.float32/i;
# dc.d -> .double
s/^(\s+|[a-z0-9._]+:)(\s*)dc\.d(\s)/$1$2.double$3/i;
# dc.x -> .extend
s/^(\s+|[a-z0-9._]+:)(\s*)dc\.x(\s)/$1$2.extend$3/i;
# ; -> |
s/\;(.+)/|$1/;
# $ -> 0x
s/\$/0x/g;
# %x -> #0bx
s/%(\d+)/0b$1/g;
# <fp number> -> 0e<fp number>
s/(-?\d+\.\d+)/0e$1/;
# convert fp instructions <instr> fpreg1[,fpreg2] -> <instr>.x fpreg1[,fpreg2]
s/(\s+|[a-z0-9._]+:)(\s*f[a-z]+)(\s+fp.)(,fp.|\n|\s)/$1$2.x$3$4/i;
# convert fbXX.[bw] instructions -> fbXXX
s/(\s+|[a-z0-9._]+:)(\s*fb[a-z]+)\.[bw]/$1$2/i;
# remove fpu directive
s/^(\s+)fpu(\s*)\n//i;

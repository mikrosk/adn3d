/*
 * "Build Engine & Tools" Copyright (c) 1993-1997 Ken Silverman
 * Ken Silverman's official web site: "http://www.advsys.net/ken"
 * See the included license file "BUILDLIC.TXT" for license info.
 * This file IS NOT A PART OF Ken Silverman's original release
 */

#ifndef _INCLUDE_A_H_
#define _INCLUDE_A_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifdef USE_M68K_ASM

//#define REG(reg,arg)  arg __asm( #reg )
#define REG(reg,arg) arg

long mmxoverlay(void);
void setuphlineasm4(long,long);

extern void sethlinesizes(REG(d0,long),REG(d1,long),REG(d2,long));
extern void setpalookupaddress(REG(d0,char *));
extern void hlineasm4(REG(d0,long count),REG(d1,long source),REG(d2,long shade),REG(a0,long i4),REG(a1,long i5),REG(a2,long i6));
extern void setuprhlineasm4(REG(d0,long),REG(d1,long),REG(d2,long),REG(d3,long),REG(d4,long),REG(d5,long));
extern void rhlineasm4(REG(d0,long i1),REG(d1,long i2),REG(d2,long i3),REG(d3,long i4),REG(d4,long i5),REG(d5,long i6));
extern void setuprmhlineasm4(REG(d0,long),REG(d1,long),REG(d2,long),REG(d3,long),REG(d4,long),REG(d5,long));
extern void rmhlineasm4(REG(d0,long i1),REG(d1,long i2),REG(d2,long i3),REG(d3,long i4),REG(d4,long i5),REG(d5,long i6));
extern void setupqrhlineasm4(REG(d0,long i1),REG(d1,long i2),REG(d2,long i3),REG(d3,long i4),REG(d4,long i5),REG(d5,long i6));
extern void qrhlineasm4(REG(d0,long i1),REG(d1,long i2),REG(d2,long i3),REG(d3,long i4),REG(d4,long i5),REG(d5,long i6));
extern void setvlinebpl(REG(d0,long));
extern void fixtransluscence(REG(d0,long));
extern long prevlineasm1(REG(d0,long),REG(a0,long),REG(d1,long),REG(d2,long),REG(a1,long),REG(a2,long));
extern long vlineasm1(REG(d0,long),REG(a0,long),REG(d1,long),REG(d2,long),REG(a1,long),REG(a2,long));
extern void setuptvlineasm(REG(d0,long));
extern long tvlineasm1(REG(d0,long i1),REG(a0,long i2),REG(d1,long i3),REG(d2,long i4),REG(a1,long i5),REG(a2,long i6));
extern void setuptvlineasm2(REG(d0,long),REG(d1,long),REG(d2,long));
extern void tvlineasm2(REG(d0,unsigned long i1),REG(d1,unsigned long i2),REG(a0,unsigned long i3),REG(a1,unsigned long i4),REG(a2,unsigned long i5),REG(d2,unsigned long i6));
extern long mvlineasm1(REG(d0,long),REG(a0,long),REG(d1,long),REG(d2,long),REG(a1,long),REG(a2,long));
extern void setupvlineasm(REG(d0,long));
extern void vlineasm4(REG(d0,long),REG(d1,long));
extern void setupmvlineasm(REG(d0,long));
extern void mvlineasm4(REG(d0,long),REG(d1,long));

void setupspritevline(long,long,long,long,long,long);
void spritevline(long i1, unsigned long i2, long i3, unsigned long i4, long i5, long i6);
void msetupspritevline(long,long,long,long,long,long);
void mspritevline(long,long,long,long,long,long);

extern void tsetupspritevline(REG(d0,long),REG(d1,long),REG(d2,long),REG(d3,long),REG(d4,long),REG(d5,long));
extern void tspritevline(REG(d0,long i1),REG(d1,long i2),REG(d2,long i3),REG(d3,unsigned long i4),REG(a0,long i5),REG(a1,long i6));
extern void mhline(REG(d0,long),REG(d1,long),REG(d2,long),REG(d3,long),REG(a0,long),REG(a1,long));
extern void mhlineskipmodify(REG(d0,long),REG(d1,unsigned long),REG(d2,unsigned long),REG(d3,long),REG(a0,long),REG(a1,long));
extern void msethlineshift(REG(d0,long),REG(d1,long));
extern void thline(REG(d0,long),REG(d1,long),REG(d2,long),REG(d3,long),REG(a0,long),REG(a1,long));
extern void thlineskipmodify(REG(d0,long),REG(d1,unsigned long),REG(d2,unsigned long),REG(d3,long),REG(a0,long),REG(a1,long));
extern void tsethlineshift(REG(d0,long),REG(d1,long));

extern void setupslopevlin(REG(d0,long),REG(d1,long),REG(d2,long));
extern void slopevlin(REG(a0,long i1),REG(a1,unsigned long i2),REG(a2,long i3),REG(d0,long i4),REG(d1,long i5),REG(a4,long i6));
//void setupslopevlin(long,long,long);
//void slopevlin(long i1, unsigned long i2, long i3, long i4, long i5, long i6);

extern void settransnormal(void);
extern void settransreverse(void);

long setupdrawslab(long i1, long i2);
long drawslab(long i1, long i2, long i3, long i4, long i5, long i6);
long stretchhline(long i1, long i2, long i3, long i4, long i5, long i6);
long is_vmware_running(void);


extern long nsqrtasm(REG(d0,unsigned long));
extern long krecipasm(REG(d0,long));
extern void setgotpic(REG(d0,unsigned long));
extern long getclipmask(REG(d0,long),REG(d1,long),REG(d2,long),REG(d3,long));

#else

long mmxoverlay(void);
void setuphlineasm4(long,long);
void sethlinesizes(long,long,long);
void setpalookupaddress(unsigned char *);
void hlineasm4(long,unsigned long,long,unsigned long,unsigned long,long);
void setuprhlineasm4(long,long,long,long,long,long);
void rhlineasm4(long,long,long,unsigned long,unsigned long,long);
void setuprmhlineasm4(long,long,long,long,long,long);
void rmhlineasm4(long,long,long,long,long,long);
void setupqrhlineasm4(long,long,long,long,long,long);
void qrhlineasm4(long,long,long,long,long,long);
void setvlinebpl(long);
void fixtransluscence(long);
long prevlineasm1(long,long,long,long,long,long);
long vlineasm1(long,long,long,long,long,long);
void setuptvlineasm(long);
long tvlineasm1(long,long,long,long,long,long);
void setuptvlineasm2(long,long,long);
void tvlineasm2(unsigned long i1, unsigned long i2, unsigned long i3, unsigned long i4, unsigned long i5, unsigned long i6);
long mvlineasm1(long,long,long,long,long,long);
void setupvlineasm(long);
void vlineasm4(long,long);
void setupmvlineasm(long);
void mvlineasm4(long,long);
void setupspritevline(long,long,long,long,long,long);
void spritevline(long i1, unsigned long i2, long i3, unsigned long i4, long i5, long i6);
void msetupspritevline(long,long,long,long,long,long);
void mspritevline(long,long,long,long,long,long);
void tsetupspritevline(long,long,long,long,long,long);
void tspritevline(long i1, long i2, long i3, unsigned long i4, long i5, long i6);
void mhline(long,long,long,long,long,long);
void mhlineskipmodify(long i1, unsigned long i2, unsigned long i3, long i4, long i5, long i6);
void msethlineshift(long,long);
void thline(long,long,long,long,long,long);
void thlineskipmodify(long i1, unsigned long i2, unsigned long i3, long i4, long i5, long i6);
void tsethlineshift(long,long);
void setupslopevlin(long,long,long);
void slopevlin(long i1, unsigned long i2, long i3, long i4, long i5, long i6);
void settransnormal(void);
void settransreverse(void);
long setupdrawslab(long i1, long i2);
long drawslab(long i1, long i2, long i3, long i4, long i5, long i6);
long stretchhline(long i1, long i2, long i3, long i4, long i5, long i6);
long is_vmware_running(void);

    /* !!! This part might be better stated as "USE_ASM".  --ryan. */
#ifdef USE_I386_ASM
  long asm_mmxoverlay(void);
  long asm_sethlinesizes(long,long,long);
  long asm_setpalookupaddress(char *);
  long asm_setuphlineasm4(long,long);
  long asm_hlineasm4(long,long,long,long,long,long);
  long asm_setuprhlineasm4(long,long,long,long,long,long);
  long asm_rhlineasm4(long,long,long,long,long,long);
  long asm_setuprmhlineasm4(long,long,long,long,long,long);
  long asm_rmhlineasm4(long,long,long,long,long,long);
  long asm_setupqrhlineasm4(long,long,long,long,long,long);
  long asm_qrhlineasm4(long,long,long,long,long,long);
  long asm_setvlinebpl(long);
  long asm_fixtransluscence(long);
  long asm_prevlineasm1(long,long,long,long,long,long);
  long asm_vlineasm1(long,long,long,long,long,long);
  long asm_setuptvlineasm(long);
  long asm_tvlineasm1(long,long,long,long,long,long);
  long asm_setuptvlineasm2(long,long,long);
  long asm_tvlineasm2(long,long,long,long,long,long);
  long asm_mvlineasm1(long,long,long,long,long,long);
  long asm_setupvlineasm(long);
  long asm_vlineasm4(long,long);
  long asm_setupmvlineasm(long);
  long asm_mvlineasm4(long,long);
  void asm_setupspritevline(long,long,long,long,long,long);
  void asm_spritevline(long,long,long,long,long,long);
  void asm_msetupspritevline(long,long,long,long,long,long);
  void asm_mspritevline(long,long,long,long,long,long);
  void asm_tsetupspritevline(long,long,long,long,long,long);
  void asm_tspritevline(long,long,long,long,long,long);
  long asm_mhline(long,long,long,long,long,long);
  long asm_mhlineskipmodify(long,long,long,long,long,long);
  long asm_msethlineshift(long,long);
  long asm_thline(long,long,long,long,long,long);
  long asm_thlineskipmodify(long,long,long,long,long,long);
  long asm_tsethlineshift(long,long);
  long asm_setupslopevlin(long,long,long);
  long asm_slopevlin(long,long,long,long,long,long);
  long asm_settransnormal(void);
  long asm_settransreverse(void);
  long asm_setupdrawslab(long,long);
  long asm_drawslab(long,long,long,long,long,long);
  long asm_stretchhline(long,long,long,long,long,long);
  long asm_isvmwarerunning(void);

  /*
   * !!! I need a reference to this, for mprotect(), but the actual function
   * !!!  is never called in BUILD...just from other ASM routines. --ryan.
   */
  long asm_prohlineasm4(void);

  #if ((defined __GNUC__) && (!defined C_IDENTIFIERS_UNDERSCORED))

    long asm_mmxoverlay(void) __attribute__ ((alias ("_asm_mmxoverlay")));
    long asm_sethlinesizes(long,long,long) __attribute__ ((alias ("_asm_sethlinesizes")));
    long asm_setpalookupaddress(char *) __attribute__ ((alias ("_asm_setpalookupaddress")));
    long asm_setuphlineasm4(long,long) __attribute__ ((alias ("_asm_setuphlineasm4")));
    long asm_hlineasm4(long,long,long,long,long,long) __attribute__ ((alias ("_asm_hlineasm4")));
    long asm_setuprhlineasm4(long,long,long,long,long,long) __attribute__ ((alias ("_asm_setuprhlineasm4")));
    long asm_rhlineasm4(long,long,long,long,long,long) __attribute__ ((alias ("_asm_rhlineasm4")));
    long asm_setuprmhlineasm4(long,long,long,long,long,long) __attribute__ ((alias ("_asm_setuprmhlineasm4")));
    long asm_rmhlineasm4(long,long,long,long,long,long) __attribute__ ((alias ("_asm_rmhlineasm4")));
    long asm_setupqrhlineasm4(long,long,long,long,long,long) __attribute__ ((alias ("_asm_setupqrhlineasm4")));
    long asm_qrhlineasm4(long,long,long,long,long,long) __attribute__ ((alias ("_asm_qrhlineasm4")));
    long asm_setvlinebpl(long) __attribute__ ((alias ("_asm_setvlinebpl")));
    long asm_fixtransluscence(long) __attribute__ ((alias ("_asm_fixtransluscence")));
    long asm_prevlineasm1(long,long,long,long,long,long) __attribute__ ((alias ("_asm_prevlineasm1")));
    long asm_vlineasm1(long,long,long,long,long,long) __attribute__ ((alias ("_asm_vlineasm1")));
    long asm_setuptvlineasm(long) __attribute__ ((alias ("_asm_setuptvlineasm")));
    long asm_tvlineasm1(long,long,long,long,long,long) __attribute__ ((alias ("_asm_tvlineasm1")));
    long asm_setuptvlineasm2(long,long,long) __attribute__ ((alias ("_asm_setuptvlineasm2")));
    long asm_tvlineasm2(long,long,long,long,long,long) __attribute__ ((alias ("_asm_tvlineasm2")));
    long asm_mvlineasm1(long,long,long,long,long,long) __attribute__ ((alias ("_asm_mvlineasm1")));
    long asm_setupvlineasm(long) __attribute__ ((alias ("_asm_setupvlineasm")));
    long asm_vlineasm4(long,long) __attribute__ ((alias ("_asm_vlineasm4")));
    long asm_setupmvlineasm(long) __attribute__ ((alias ("_asm_setupmvlineasm")));
    long asm_mvlineasm4(long,long) __attribute__ ((alias ("_asm_mvlineasm4")));
    void asm_setupspritevline(long,long,long,long,long,long) __attribute__ ((alias ("_asm_setupspritevline")));
    void asm_spritevline(long,long,long,long,long,long) __attribute__ ((alias ("_asm_spritevline")));
    void asm_msetupspritevline(long,long,long,long,long,long) __attribute__ ((alias ("_asm_msetupspritevline")));
    void asm_mspritevline(long,long,long,long,long,long) __attribute__ ((alias ("_asm_mspritevline")));
    void asm_tsetupspritevline(long,long,long,long,long,long) __attribute__ ((alias ("_asm_tsetupspritevline")));
    void asm_tspritevline(long,long,long,long,long,long) __attribute__ ((alias ("_asm_tspritevline")));
    long asm_mhline(long,long,long,long,long,long) __attribute__ ((alias ("_asm_mhline")));
    long asm_mhlineskipmodify(long,long,long,long,long,long) __attribute__ ((alias ("_asm_mhlineskipmodify")));
    long asm_msethlineshift(long,long) __attribute__ ((alias ("_asm_msethlineshift")));
    long asm_thline(long,long,long,long,long,long) __attribute__ ((alias ("_asm_thline")));
    long asm_thlineskipmodify(long,long,long,long,long,long) __attribute__ ((alias ("_asm_thlineskipmodify")));
    long asm_tsethlineshift(long,long) __attribute__ ((alias ("_asm_tsethlineshift")));
    long asm_setupslopevlin(long,long,long) __attribute__ ((alias ("_asm_setupslopevlin")));
    long asm_slopevlin(long,long,long,long,long,long) __attribute__ ((alias ("_asm_slopevlin")));
    long asm_settransnormal(void) __attribute__ ((alias ("_asm_settransnormal")));
    long asm_settransreverse(void) __attribute__ ((alias ("_asm_settransreverse")));
    long asm_setupdrawslab(long,long) __attribute__ ((alias ("_asm_setupdrawslab")));
    long asm_drawslab(long,long,long,long,long,long) __attribute__ ((alias ("_asm_drawslab")));
    long asm_stretchhline(long,long,long,long,long,long) __attribute__ ((alias ("_asm_stretchhline")));
    long asm_isvmwarerunning(void) __attribute__ ((alias ("_asm_isvmwarerunning")));

    /*
	 * !!! I need a reference to this, for mprotect(), but the actual function
     * !!!  is never called in BUILD...just from other ASM routines. --ryan.
	 */
    long asm_prohlineasm4(void) __attribute__ ((alias ("_asm_prohlineasm4")));

  #endif /* ELF/GCC */
#endif /* defined USE_I386_ASM */
#endif /* defined USE_M68K_ASM */

#ifdef __cplusplus
}
#endif

#endif /* include-once-blocker. */

/* end of a.h ... */



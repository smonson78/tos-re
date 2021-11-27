.section .text

addr_0:
os_entry:
    bras _main        /* OS entry, branch to main() */
addr_2:
os_version:
	.short 0x0104       /* TOS v1.04 */
addr_4:
reseth:    
	.long _main         /* Reset handler */
addr_8:
os_beg:	
	.long os_entry      /* Start of OS */
addr_c:
os_end:
	.long 0x0000611c    /* Value of _endvdibss (start of free RAM) */
os_res1:
	.long _main         /* Reserved */
addr_14:    
os_magic:
	.long gem_magic     /* Address for GEM magic */
addr_18:    
os_date:
	.long 0x04061989    /* TOS date 04/06/1989 */
addr_1c:    
os_conf:
	.short 0x0007       /* Country flag, PAL version flag */
addr_1e:    
os_dosdate:
	.short 0x1286       /* Date in DOS format */
addr_20:
os_root:
	.long 0x0000378c    /* Value of _pool (pointer to GEMDOS mem pool) */
addr_24:
os_kbshift:
	.long 0x00000e7d    /* Pointer to keyboard shift key states */
addr_28:
os_run:
	.long 0x00005622    /* Pointer to a pointer to the actual basepage */
os_dummy:
	.long 0x00000000    /*  */

.global os_entry
.global os_conf
.global os_beg
.global os_end
.global os_res1
.global os_magic
.global os_date
.global os_conf
.global os_dosdate
.global os_root
.global os_kbshift
.global os_run
.global os_dummy

/*
.section .data

	dc.l GEM_MUPB_MAGIC
	dc.l _endgembss
	dc.l gemstart
*/

/*
 * Get in supervisor mode and reset all Hardware
 *
 * The following considerations have been taken into account:
 * 1. for unknown reasons, real Falcons need an access to location $ffff8006
 *    before and after the reset instruction
 * 2. in order to run the same code on systems without a register at $ffff8006,
 *    the bus error vector must be intercepted prior to #1
 * 3. since non-68000 systems use the VBR to point to the start of the exception
 *    vectors, the VBR must be zeroed prior to #2 via MOVEC
 * 4. in order to run the same code on 68000 systems (which don't have MOVEC),
 *    the illegal instruction vector must be intercepted prior to #3.  for this,
 *    it doesn't matter if the VBR is non-zero because, if it is, the MOVEC
 *    instruction must be legal so the trap won't get taken ...
 */
_main:
.global _main
	movew #0x2700,%sr
	reset
	subal %a5,%a5
	cmpil #0xfa52235f,cart_magic            /* Is cartridge present? */
	bnes no_cart
	lea %pc@(no_cart),%fp                   /* Return address */
	jmp cart_boot                           /* Jump to cartridge */
no_cart:
	lea %pc@(no_ram),%fp                    /* Return address */
	braw ram_test
no_ram:
	bnes addr_5e
	moveb %a5@(1060),%a5@(memctrl + 1)      /* Get memctrl */
addr_5e:
	cmpil #0x31415926,%a5@(1062)            /* resvalid, revector valid ? */
	bnes os_beg0                            /* No */
	movel %a5@(resvector),%d0               /* Load resvector */
	tstb %a5@(resvector)                    /* Test bits 31-24 */
	bnes os_beg0                            /* Set - vector invalid */
    btst #0,%d0                             /* Address odd? */
	bnes os_beg0                            /* Yes, invalid */
	moveal %d0,%a0                          /* Load address */
	lea %pc@(addr_5e),%fp                   /* Load return address */
	jmp %a0@                                /* Jump via vector */

/* Runs on first startup, otherwise goes to resvector */
os_beg0:
	subal %a5,%a5
	lea %a5@(psg),%a0                       /* Load address of PSG */
	moveb #7,%a0@                           /* Port A and B */
	.short 0x117c,0x00c0,0x0002             /* moveb #0xc0,%a0@(2) - GAS assembles this differently. Comment: To output */
	moveb #0x0E,%a0@                        /* Select port A */
	moveb #7,%a0@(2)                        /* Deselect floppies */   
	btst #0,%pc@(os_conf + 1)               /* PAL version? */
	beqs addr_b0                            /* No */
	lea %pc@(addr_aa),%fp			        /* Load return address */
	braw waitvbl					
	
addr_aa:
	moveb #2,%a5@(shifter_sync_mode)        /* Sync mode to 50Hz PAL - I guess 60Hz is the default. */

addr_b0:
	lea %a5@(palette),%a1                   /* Address of the colour palette */
	movew #15,%d0                           /* 16 colours */
	lea %pc@(default_palette),%a0           /* Address of the default colour table */
addr_bc:
	movew %a0@+,%a1@+                       /* Copy colour into palette */
	dbf %d0,addr_bc                         /* Next colour */

	moveb #1,%a5@(video_baseh + 1)          /* dbaseh - set video address to 0x10000 */
	clrb %a5@(video_basem + 1)              /* dbasel */

	moveb %a5@(memcntlr),%d6                /* memctrl */
	movel %a5@(phystop),%d5                 /* phystop */
	lea %pc@(addr_dc),%fp                   /* Load return address */
	braw ram_test                           /* Memory configuration valid? */
addr_dc:
	beqw addr_1f2                           /* Yes */
	clrw %d6                                /* Start value for memory controller */
	moveb #10,%a5@(memctrl + 1)             /* Memory controller to 2 * 2MB */

	moveaw #8,%a0                           /* Start address for memory test - 0x8 */
	lea 0x200008,%a1                        /* A1 points to second bank - 0x200008 */
	clrw %d0                                /* Clear bit pattern to be written */
addr_f4:
	movew %d0,%a0@+                         /* Write pattern to addresses 0x00000008 to 0x00000406 */
	movew %d0,%a1@+                         /* Write to other address range 0x00200008 to 0x00200406 */
	.short 0xd07c,0xfa54                    /* GNU as assembles this differently. addw #0xfa54,%d0 - next bit pattern */
	cmpal #0x200,%a0                        /* End address reached? */
	bnes addr_f4                            /* No, keep looping */

	movel #0x200000,%d1                     /* D1 equals second bank */
addr_10a:
	lsrw #2,%d6                     
	moveaw #0x208,%a0                       /* Is bit pattern at 0x208? */
	lea %pc@(addr_118),%a5                  /* Load return address */   
	braw memtest                            /* Memory test */

addr_118:
	beqs addr_13a                           /* OK, 128KB */
	moveaw #1032,%a0                        /* At 0x408? */
	lea %pc@(addr_126),%a5                  /* Load return address */
	braw memtest                            /* Memory test */
addr_126:
	beqs addr_138                           /* OK, 512KB */
	moveaw #8,%a0                           /* At 0x8 */
	lea %pc@(addr_134),%a5                  /* Load return address */
	braw memtest                            /* Memory test */
addr_134:
	bnes addr_13a                           /* Nothing in this bank */
	addqw #4,%d6
addr_138:
	addqw #4,%d6                            /* Configuration bank to 2MB */

addr_13a:
	.short 0x92bc                           /* as assembles this differently: subl #0x200000,%d1 - next bank */
	.short 0x0020
	.short 0x0000

	beqs addr_10a                           /* Test for first bank */
	
	.short 0x13c6                           /* moveb %d6,0xffff8001 - Program memory controller */
	.short 0xffff                   
	.short 0x8001

	lea 0x8000,%sp                  
    moveal vector_bus_error,%a4             /* moveal 0x8,%a4 - Save Bus Error vector */
	lea %pc@(ram_test_fail),%a0             /* Address of routine to terminate RAM test */
    movel %a0,vector_bus_error              /* Set */

	movew #0xfb55,%d3                       /* Start bit pattern */
	movel #0x20000,%d7                      /* Start address is 128K */
	moveal %d7,%a0                          /* Save current */

addr_16a:
	moveal %a0,%a1                          /* address */
	movew %d0,%d2
	moveq #42,%d1                           /* 43 words */

addr_170:
    movew %d2,%a1@-                         /* Write bit pattern in RAM */
    addw %d3,%d2                            /* Change pattern */
    dbf %d1,addr_170                        /* Write next bit pattern */
    moveal %a0,%a1                          /* Repeat address */
    moveq #42,%d1                           /* 43 words */
addr_17c:
    cmpw %a1@-,%d0                          /* Is bit pattern in RAM? */
    bnes ram_test_fail                      /* No, terminate test */
    clrw %a1@                               /* Clear RAM */
    addw %d3,%d0                            /* Change bit pattern */
    dbf %d1,addr_17c                        /* Test next word */
    addal %d7,%a0                           /* Increment address by 128K */
    bras addr_16a                           /* Continue testing */

addr_18c:
ram_test_fail:
    subal %d7,%a0                           /* Address minus 128K - to go back to the last block that passed */
    movel %a0,%d5                           /* Save */
    movel %a4,vector_bus_error              /* Restore old bus-error vector */
    subal %a5,%a5                   

    /* Locate screen buffer in RAM - in the top 32KB (note this wastes a few bytes) */
    movel %d5,%d0                           /* Highest address for clear */
    .short 0x90bc,0x0000,0x8000             /* subl #32768,%d0 - minus 32KB */
    lsrw #8,%d0                     
    moveb %d0,%a5@(video_basem + 1)
    swap %d0
    moveb %d0,%a5@(video_baseh + 1)

    /* Clear RAM from top downwards to 0x400 */
    moveal %d5,%a0
    movel #0x400,%d4                        /* Lower bound for clear */
    moveq #0,%d0                            /* Clear d0-d3 */ 
    moveq #0,%d1
    moveq #0,%d2
    moveq #0,%d3
addr_1bc:
    moveml %d0-%d3,%a0@-                    /* Clear 16 bytes */
    moveml %d0-%d3,%a0@-                    /* Clear 16 bytes */
    moveml %d0-%d3,%a0@-                    /* Clear 16 bytes */
    moveml %d0-%d3,%a0@-                    /* Clear 16 bytes */
    cmpal %d4,%a0                           /* Lower bound reached? */
    bnes addr_1bc                           /* No, continue */
    subal %a5,%a5                           /* Clear a5 (I think it was already clear) */
    moveb %d6,%a5@(memcntlr)                /* TOS's copy of the contents of memctrl register */
    movel %d5,%a5@(phystop)                 /* Highest RAM address as phystop */

    /* RAM-valid magic numbers - to skip this test next time */
    movel #0x752019f3,%a5@(memvalid)
    movel #0x237698aa,%a5@(memval2)
    movel #0x5555aaaa,%a5@(memval3)

    /* Clear RAM from 0x980 to 0x10000 one word at a time */
addr_1f2:
    subal %a5,%a5                           /* Clear a5 (even though it's still already clear) */
    moveal #0x980,%a0                       /* End of system variables */
    moveal #0x10000,%a1                     /* To current video address (eh? no it isn't) */
    moveq #0,%d0
addr_202:    
    movew %d0,%a0@+                         /* Clear memory */
    cmpal %a0,%a1                           /* End address reached? */
    bnes addr_202                           /* No, continue */

    moveal %a5@(phystop),%a0                /* Top of memory */
    subal #0x8000,%a0                       /* minus 32KB */
    movew #0x7ff,%d1                        /* 2048 * 16 = 32KB screen size (almost) */
    movel %a0,%a5@(_v_bas_ad)               /* Last 32KB of RAM --> video out address */

    /* Set up the screen a second time */
    moveb %a5@(_v_bas_ad + 1),%a5@(video_baseh + 1)     /* High byte of video address (bits 24-17) */
    moveb %a5@(_v_bas_ad + 2),%a5@(video_basem + 1)     /* Low byte of video address (bits 16-9) */

addr_226:
    movel %d0,%a0@+                         /* Clear screen 16 bytes at a time */
    movel %d0,%a0@+
    movel %d0,%a0@+
    movel %d0,%a0@+
    dbf %d1,addr_226                        /* Next 16 bytes */

    moveal %pc@(os_magic),%a0               /* Address os_magic */
    cmpil #0x87654321,%a0@                  /* Magic present? */
    beqs addr_242                           /* Yes */
    lea %pc@(os_beg),%a0                    /* Else use system addresses */

addr_242:    
    movel %a0@(4),%a5@(end_os)
    movel %a0@(8),%a5@(exec_os)
    movel #_bhdv_init,%a5@(hdv_init)
    movel #_bhdv_rwabs,%a5@(hdv_rw)
    movel #_bhdv_getbpb,%a5@(hdv_bpb)
    movel #_bhdv_mediach,%a5@(hdv_mediach)
    movel #_bhdv_boot,%a5@(hdv_boot)
    movel #addr_3392,%a5@(prt_stat)
    movel #addr_32f6,%a5@(prt_vec)
    movel #addr_3408,%a5@(aux_stat)
    movel #addr_3422,%a5@(aux_vec)
    movel #addr_d0c,%a5@(dump_vec)
    movel %a5@(_v_bas_ad),%a5@(_memtop)
    movel %a5@(end_os),%a5@(_membot)

    lea stack_top,%sp                           /* Initialise system stack pointer */
    movew #8,%a5@(nvbls)                        /* nvbls - 8 vectors in list */
    st %a5@(_fverify)                           /* _fverify - yes */
    movew #3,%a5@(seekrate)                     /* Seek rate 3ms */
    movel #disk_buffer,%a5@(_dskbufp)           /* Set up disk buffer pointer */
    movew #-1,%a5@(_dumpflg)                    /* Clear _dumpflg */
    movel #os_entry,%a5@(_sysbase)              /* _sysbase to ROM start */
    movel #tos_register_buffer,%a5@(savptr)     /* savptr for BIOS */
    movel #dummy_subroutine,%a5@(swv_vec)       /* swv_vec for monitor change */
    clrl %a5@(_drvbits)                         /* No drives present to start with */
    clrw %a5@(_longframe)                       /* Use short stack frames */
    bsrw addr_e62
    lea %pc@(dummy_exception),%a3               /* Address rte */
    lea %pc@(dummy_subroutine),%a4              /* Address rts */
    cmpil #0xfa52235f,cart_magic                /* Diagnostic cartridge inserted? */
    beqs addr_32c                               /* Yes */

    lea %pc@(addr_b0a),%a1                      /* Indicate address for exception */
    addal #0x2000000,%a1                        /* Vector number in bits 24-31 to 2 */
    lea vector_bus_error,%a0                    /* Start with Bus Error */
    movew #61,%d0                               /* 62 vectors */
addr_31a:
    movel %a1,%a0@+                             /* Set vector */
    addal #0x1000000,%a1                        /* Increment vector number */
    dbf %d0,addr_31a                            /* Initialise next exception vector */
    movel %a3,vector_divide_by_zero             /* Division By Zero to rte */
addr_32c:
    moveq #6,%d0                                /* Loop 7 times for autovectors */
    lea %a5@(autovectors),%a1                   /* Load target address (0x64) */
addr_332:
    movel #dummy_exception,%a1@+                /* Set up dummy vector */
    dbf %d0,addr_332                            /* Next vector */
    
    movel #autovec_lvl_4,%a5@(autovectors + 12) /* Level 4 autovector (on VBL) */
    movel #autovec_lvl_2,%a5@(autovectors + 4)  /* Level 2 autovector */
    movel %a3,%a5@(traps + 8)                   /* Trap #2 (AES/VDI) */
    movel #trap13_handler,%a5@(traps + 52)      /* Trap #13 (BIOS) */
    movel #trap14_handler,%a5@(traps + 56)      /* Trap #14 (XBIOS) */
    movel #linea_handler,%a5@(vector_linea)     /* Line 1010 emulator (LineA) */

    movel %a4,%a5@(etv_timer)                   /* GEM timer event */
    movel #gem_critical_evt_handler,%a5@(etv_critic) /* GEM critical event handler */
    movel %a4,%a5@(etv_term)                    /* GEM program termination vector */
    lea %a5@(_vbl_lis),%a0                      /* Vertical blank handlers */
    movel %a0,%a5@(_vblqueue)                   /* Vertical blank queue */
    movew #7,%d0                                /* Clear 8 VBL entries */
addr_384:
    clrl %a0@+                                  /* Clear entry in VBL list */
    dbf %d0,addr_384                            /* Next entry */
    lea bios_vectors,%a0                        /* - ROM copy of BIOS routine vectors */
    moveaw #xconstat_vec,%a1                    /* 4 tables of 8 vectors each: xconstat, xconin, xcostat, xconout */
    moveq #31,%d0                               /* Copy 32 longwords */
addr_396:    
    movel %a0@+,%a1@+                           /* Copy */
    dbf %d0,addr_396                            /* Next vector */
    bsrw initmfp
    movel #ikbdres,%sp@-                        /* Push 2 params */
    movew #1,%sp@-                              
    jsr ikbdws
    addql #6,%sp                                /* Restore stack */
    movel #32767,%d0
addr_3b8:
    bsrw addr_54a
    dbf %d0,addr_3b8
    moveq #2,%d0                                /* Bit 2 */
    bsrw cartscan
    subal %a5,%a5
    moveb %a5@(video_res),%d0                   /* Get current video resolution */
    .short 0xc03c,0x0003                        /* andb #3,%d0 - strip all but bottom 2 bits */
    .short 0xb03c,0x0003                        /* cmpb #3,%d0 - check for invalid value 3 */
    bnes addr_3d8                               /* No - do nothing */
    moveq #2,%d0                                /* Yes - default to high-res mode */
addr_3d8:    
    moveb %d0,%a5@(sshiftmod)                   /* Copy video mode to sshiftmod variable */
    moveb %a5@(mfp_pp),%d0                      /* MFP parallel port register */
    bmis addr_3f6                               /* No mono monitor? */
    lea %pc@(addr_3ea),%fp                      /* Return address */
    braw waitvbl
addr_3ea:
    moveb #2,%a5@(video_res)                    /* Go to high res (2) */
    moveb #2,%a5@(sshiftmod)
addr_3f6:    
    bsrw blittest                               /* Test if the blitter is installed */                               
    jsr linea_init                              /* Initialise line-a routines */
    jsr esc_init
    cmpib #1,%a5@(sshiftmod)                    /* sshiftmod */
    bnes addr_414                               /* Not medium res? */
    movew %a5@(palette + 30),%a5@(palette + 6)  /* Copy colour 15 (black) to colour 3 */
addr_414:
    movel #_main,%a5@(swv_vec)                  /* Reboot on resolution-change vector */
    movew #1,%a5@(vblsem)
    clrw %d0
    bsrw cartscan
    movew #0x2300,%sr                           /* IPL 3 */
    moveq #1,%d0
    bsrw cartscan
    jsr init_dos                                /* Initialise DOS */
    
    .short 0x33f9                               /* movew os_dosdate,ram_unknown2 - creation date in DOS format */
    .long os_dosdate
    .long ram_unknown2

    jsr addr_1f4c
    bccs addr_462                               /* 2 calls out of these three: Boot from floppy? */
    bsrw igetdt                                 /* Boot from DMA bus? */
                                                /* Execute reset-resident programs? */
    swap %d0

    tstb %d0
    beqs addr_462
    .short 0x33c0                               /* movew %d0,0x60be */
    .long ram_unknown2
    swap %d0
    movew %d0,stack_top

addr_462:
    bsrw diskboot
    bsrw addr_54c
    bsrw addr_dfe
    tstw _cmdload                               /* _cmdload? */
    beqs addr_494                               /* No */
    bsrw autoexec                               /* execute programs in AUTO folder */
    movel #os_entry,_sysbase
    pea %pc@(empty_string)                      /* Empty string */
    pea %pc@(empty_string)                      /* Empty string */
    pea %pc@(addr_518)                          /* "COMMAND.PRG" string */
    clrw %sp@-                                  /* Load and start program */
    bras addr_4fc                               /* Load to program */
addr_494:    
    bsrw autoexec                               /* autoexec, execute programs in AUTO folder */
    movel #os_entry,_sysbase

    /*
        Copy the environment from 0x50c in ROM to 0x840 in RAM. The environment consists of 3 null-terminated strings,
        the last of which is empty. The # character is replaced with the boot drive.

        PATH=
        #:\

    */
    lea %pc@(default_env),%a0                   /* "PATH=" string - environment in ROM to be copied to RAM */
    moveal #environment,%a1                     /* Destination address for environment */
addr_4ac:
    cmpib #35,%a0@                              /* Are we about to copy a '#' character, place holder for drive? */
    bnes addr_4b4                               /* No, skip ahead */
    moveal %a1,%a2                              /* Save address */
addr_4b4:    
    moveb %a0@+,%a1@+                           /* Copy one byte of the environment */
    bpls addr_4ac                               /* Keep copying until we reach a negative number, which is 0xff in this case */

    moveb _bootdev,%d0
    .short 0xd03c,0x0041                        /* addb #65,%d0 - Add 'A' to drive number to get drive letter */
    moveb %d0,%a2@                              /* Insert drive letter over the top of the # placeholder. */
    
    pea environment

    .short 0x4879                               /* pea empty_string - Empty string */
    .long empty_string

    pea %pc@(empty_string)                      /* Does the same as the last one, but written differently for some reason */

    movew #5,%sp@-                              /* GEMDOS Pexec function 5 - Create base page */
    movew #0x4b,%sp@-                           /* Pexec(5, "", "", environment) - creates new basepage, returned in %d0 */
    trap #1                                     /* GEMDOS */

    addaw #14,%sp                               /* Correct stack pointer */
    moveal %d0,%a0                              /* Address of the base page */
    movel exec_os,%a0@(8)                       /* Put start address of AES and Desktop into the basepage */
    
    pea environment

    movel %a0,%sp@-                             /* Address of the base page */
    pea %pc@(empty_string)                      /* Empty string */
    movew #4,%sp@-                              /* Start program */
addr_4fc:
    movew #0x4b,%sp@-                           /* Pexec(4, "", basepage, environment) - launch an already-loaded program */
    trap #1                                     /* GEMDOS */
    addaw #14,%sp                               /* Correct stack pointer */
    .short 0x4ef9                               /* jmp boot - Reboot the machine */
    .long _main

addr_50c:
default_env:
    .ascii "PATH="
    .byte 0

addr_512:
    .ascii "#:\\"
    .byte 0,0
    .byte 0xff

addr_518:  
	.ascii "COMMAND.PRG"
    .byte 0

addr_524:
    /* Note null terminator shared with next label */
    .ascii "GEM.PRG"

addr_52b:
empty_string:
.global empty_string
    .byte 0,0,0

ikbdres:
.global ikbdres
.byte 0x80,0x01

addr_530:
diskboot:
.global diskboot
  moveq #3,%d0
  bsrw cartscan
  moveal hdv_boot,%a0                     /* go through boot vector */
  jsr %a0@
  tstw %d0                                /* any errors? */
  bnes addr_54a                           /* (yes -- punt) */
  lea disk_buffer,%a0
  jsr %a0@                                /* execute boot sector (it might return) */
addr_54a:
.global addr_54a
  rts


addr_54c:
dmaboot:
.global dmaboot
  moveq #0,%d7
addr_54e:
  subal %a4,%a4
  bsrs addr_578
  bnes addr_570
  moveal %a4@(_dskbufp),%a0
  movew #255,%d1
  moveq #0,%d0
addr_55e:
  addw %a0@+,%d0
  dbf %d1,addr_55e
  cmpw #0x1234,%d0
  bnes addr_570
  moveal %a4@(_dskbufp),%a0
  jsr %a0@
addr_570:
  addb #32,%d7
  bnes addr_54e
  rts
addr_578:
  moveq #1,%d5
addr_57a:
  lea %a4@(dma_mode_control),%fp
  lea %a4@(dma_sector_count),%a5
  st %a4@(flock)
  movel %a4@(_dskbufp),%sp@-              /* Set up DMA pointer to point to _dskbufp */
  moveb %sp@(3),%a4@(dma_pointer_low + 1)
  moveb %sp@(2),%a4@(dma_pointer_mid + 1)
  moveb %sp@(1),%a4@(dma_pointer_high + 1)
  addqw #4,%sp
  movew #152,%fp@
  movew #408,%fp@
  movew #152,%fp@
  movew #1,%a5@                           /* DMA 1 sector */
  movew #136,%fp@
  moveb %d7,%d0
  orb #8,%d0
  swap %d0
  movew #138,%d0                          /* 138 sectors */
  bsrs addr_60e
  bnes addr_5f0
  moveq #3,%d6
  lea %pc@(addr_5fe),%a0
addr_5c8:
  movel %a0@+,%d0                         /* Take a longword from the table */
  bsrs addr_60e
  bnes addr_5f0
  dbf %d6,addr_5c8
  movel #10,%a5@
  movew #400,%d1
  bsrs addr_612
  bnes addr_5f0
  movew #138,%fp@
  movew %a5@,%d0
  andw #255,%d0
  beqs addr_5f2
  dbf %d5,addr_57a
addr_5f0:
  moveq #-1,%d0
addr_5f2:
  movew #128,%fp@
  tstb %d0
  sf %a4@(flock)                          /* Is this right? Seems like it wouldn't do anything */
	rts
addr_5fe:
  .long 0x0000008a
  .long 0x0000008a
  .long 0x0000008a
  .long 0x0001008a
addr_60e:
  movel %d0,%a5@                          /* Put the param in the DMA sector count register */
  moveq #10,%d1
addr_612:
  addl %a4@(_hz_200),%d1                  /* add value of 200Hz counter - so 50ms in the future */
addr_616:
  btst #5,%a4@(mfp_pp)                    /* Parallel port data register - "interrupt" pin */
  beqs addr_626
  cmpl %a4@(_hz_200),%d1
  bnes addr_616                           /* Keep looping until the time is up */
  moveq #-1,%d1                           /* -1 for failure */
addr_626:
  rts

addr_628:
cartscan:
.global cartscan
  lea cart_magic,%a0
  cmpil #0xabcdef42,%a0@+
  bnes addr_650
addr_636:
  btst %d0,%a0@(4)
  beqs addr_64a
  moveml %d0-%fp,%sp@-
  moveal %a0@(4),%a0
  jsr %a0@
  moveml %sp@+,%d0-%fp
addr_64a:
  tstl %a0@
  moveal %a0@,%a0
  bnes addr_636
addr_650:
  rts


addr_652:
dummy_subroutine:
.global dummy_subroutine
	rts                                     /* Dummy callback */

addr_654:
memtest:                                  /* %a5=return address, %a0=a small number (0x208), %d1=a big number (2MB) */
.global memtest
  addal %d1,%a0                           /* add big param to small, %a0 = 0x200208 - start address */
  clrw %d0                                /* Clear bit pattern */
  lea %a0@(0x1f8),%a1                     /* End address, start plus 504 bytes */
addr_65c:
  cmpw %a0@+,%d0                          /* Test this word for bit pattern */
  bnes addr_668                           /* Not equal - exit loop */
  addw #0xfa54,%d0											  /* Next bit pattern */
  cmpal %a0,%a1                           /* End address reached? */
  bnes addr_65c                           /* No, go back */
addr_668:
  jmp %a5@                                /* Jump directly back */

addr_66a:
ram_test:
.global ram_test
  subal %a5,%a5
  cmpil #0x752019f3,%a5@(memvalid)
  bnes addr_688
  cmpil #0x237698aa,%a5@(memval2)
  bnes addr_688
  cmpil #0x5555aaaa,%a5@(memval3)
addr_688:
  jmp %fp@

default_palette:
.global default_palette
	.short 0x777, 0x700, 0x070, 0x770, 0x007, 0x707, 0x077, 0x555, 0x333, 0x733, 0x373, 0x773, 0x337, 0x737, 0x377
	.short 0

/* This is the horizontal blank interrupt handler */
addr_6aa:
autovec_lvl_2:
.global autovec_lvl_2
  movew %d0,%sp@-                         /* Save d0 */
	movew %sp@(2),%d0
	andw #0x700,%d0													/* check something, I think this is %sr maybe */
  bnes addr_6bc
  oriw #0x300,%sp@(2)                     /* Set two bits in word on stack */
addr_6bc:
  movew %sp@+,%d0                         /* Restore d0 */
  rte
  
/* This is the VBL interrupt handler. */
addr_6c0:
autovec_lvl_4:
.global autovec_lvl_4
  addql #1,_frlock
  subqw #1,vblsem
  bmiw addr_79a
  moveml %d0-%fp,%sp@-
  addql #1,_vbclock
  subal %a5,%a5
  moveb %a5@(mfp_pp),%d1
  moveb %a5@(video_res),%d0
  andb #3,%d0
  cmpb #2,%d0
  bges addr_702                          /* Are we in mono mode? */
  /* In colour modes: */
  btst #7,%d1                             /* Check mono detect */
  bnes lvl4_vec_nochange                  /* No mono monitor --> skip */
  movew #2000,%d0                         /* Delay loop */
lvl4_vec_delay:
  dbf %d0,lvl4_vec_delay
  moveb #2,%d0                            /* Set resolution to mono */
  bras lvl4_vec_chmode
addr_702:
  /* In mono: */
  btst #7,%d1                             /* Check mono detect */
  beqs lvl4_vec_nochange                  /* Monitor is present */
  moveb %a5@(defshiftmod),%d0             /* Get default shifter mode */
  cmpb #2,%d0
  blts lvl4_vec_chmode                    /* Default shifter mode compatible with colour monitor --> jump over */
  clrb %d0                                /* Set to fallback mode 0 (low) */
lvl4_vec_chmode:
  moveb %d0,%a5@(sshiftmod)               /* Set TOS copy of shifter resolution */
  moveb %d0,%a5@(video_res)               /* Set shifter resolution register */
  moveal %a5@(swv_vec),%a0
  jsr %a0@                                /* Call resolution-change handler */
lvl4_vec_nochange:
.global lvl4_vec_nochange
  jsr addr_a694
  subal %a5,%a5
  tstl %a5@(colorptr)                     /* Check it new palette is waiting */
  beqs addr_746                          /* No? --> skip */
  moveal %a5@(colorptr),%a0
  lea %a5@(palette),%a1
  movew #15,%d0                           /* Copy 16 palette entries into the shifter */
addr_73c:
  movew %a0@+,%a1@+
  dbf %d0,addr_73c
  clrl %a5@(colorptr)                     /* Clear the new-palette pointer */
addr_746:
  tstl %a5@(screenpt)                     /* Check for a new video address waiting to be loaded into the shifter */
  beqs addr_75e                          /* No --> skip */
  movel %a5@(screenpt),%a5@(_v_bas_ad)    /* Copy it to TOS variable */
  moveb %a5@(_v_bas_ad + 2),%a5@(video_basem + 1)  /* Copy bits 15-8 to hardware register */
  moveb %a5@(_v_bas_ad + 1),%a5@(video_baseh + 1)  /* Copy bits 23-16 to hardware register */
addr_75e:
  bsrw addr_1360
  movew nvbls,%d7
  beqs addr_78a
  subql #1,%d7
  moveal _vblqueue,%a0
addr_772:
  moveal %a0@+,%a1
  cmpal #0,%a1
  beqs addr_786
  moveml %d7-%a0,%sp@-
  jsr %a1@
  moveml %sp@+,%d7-%a0
addr_786:
  dbf %d7,addr_772
addr_78a:
  subal %a5,%a5
  tstw %a5@(_dumpflg)                     /* Check for screen dump flag */
  bnes addr_796
  bsrw scrdmp
addr_796:
  moveml %sp@+,%d0-%fp                    /* Restore registers */
addr_79a:
  addqw #1,vblsem
  /* Note: falls through to dummy handler below */
dummy_exception:
.global dummy_exception
	rte


addr_7a2:
vsync:
  movew %sr,%sp@-                         /* Save sr */
  andiw #0xf8ff,%sr
  movel _frlock,%d0                       /* Frame counter */
addr_7ae:
  cmpl _frlock,%d0                        /* Keep looping until it changes. */
  beqs addr_7ae
  movew %sp@+,%sr                         /* Restore sr */
	rts

addr_7ba:
callcrit:
.global callcrit
	movel etv_critic,%sp@-                    /* Falls through to next ... */

addr_7c0:
gem_critical_evt_handler:
.global gem_critical_evt_handler
	.short 0x70ff
	rts

addr_7c4:
trap14_handler:
.global trap14_handler
  lea %pc@(trap14_vectors),%a0
  bras addr_7ce

addr_7ca:
trap13_handler:
.global trap13_handler
  lea %pc@(trap13_vectors),%a0
addr_7ce:                                 /* Lookup and jump from table - table address in a0 */
  moveal savptr,%a1                       /* location of saved registers */
  movew %sp@+,%d0                         /* Get a word off the stack (sr)... */
  movew %d0,%a1@-                         /* ...put it on saved stack location */
  movel %sp@+,%a1@-                       /* Same with next longword from stack (original pc) */
  moveml %d3-%d7/%a3-%sp,%a1@-            /* Save a bunch of registers, including sp */
  movel %a1,savptr                        /* Store the new saved-registers location */
  btst #13,%d0                            /* Was bit 13 set in sr? 0x2000 */
  bnes addr_7ec
  movel %usp,%sp                          /* Switch to the user stack pointer */
addr_7ec:
  movew %sp@+,%d0                         /* Take the routine number off the stack */
  cmpw %a0@+,%d0                          /* Get the number of vectors in the table */
  bges addr_802                           /* Is the routine number valid? No - then skip calling */
  lslw #2,%d0                             /* Multiply routine number by 4 for address */
  movel %a0@(0,%d0:w),%d0                 /* Get vector to call */
  moveal %d0,%a0                          /* Put address in a0 */
  bpls addr_7fe                           /* Was it a 0x8xxxxxxx style address? */
  moveal %a0@,%a0                         /* If so, load the real vector from that address instead (only low 24 bits matter) */
addr_7fe:
  subal %a5,%a5                           /* Clear a5 */
  jsr %a0@                                /* Call routine */
addr_802:
  moveal savptr,%a1
  moveml %a1@+,%d3-%d7/%a3-%sp            /* Restore previously-saved registers, including sp */
  movel %a1@+,%sp@-                       /* Restore longword to stack */
  movew %a1@+,%sp@-                       /* Restore word to stack */
  movel %a1,savptr	                      /* Store the new saved-registers location */
  rte

/* BIOS functions */
addr_818:
trap13_vectors:
	.short 12                               /* 12 vectors */
	.long Getmpb                            /* Getmbp(MBP *ptr) - Get memory parameter block */
	.long Bconstat                          /* int16_t Bconstat(uint16_t dev) - check for waiting data on BIOS device */
	.long Bconin                            /* int32_t Bconin(uint16_t dev) - read character from BIOS device */
	.long Bconout                           /* void Bconout(uint16_t dev, int16_t c) - write character to BIOS device */
	.long hdv_rw + 0x80000000               /* Rwabs from system variable */
	.long Setexc
	.long Tickcal
	.long hdv_bpb + 0x80000000              /* Getbpb from system variable */
	.long Bcostat                           /* int32_t Bcostat(uint16_t dev) - check for available buffer on BIOS device */
	.long hdv_mediach + 0x80000000          /* Mediach from system variable */
	.long Drvmap
	.long Kbshift

/* XBIOS functions */
addr_84a:
trap14_vectors:
	.short 65                               /* 65 vectors */
	.long initmouse                         /* 0 - Initmouse(int16_t type, MOUSE *par, void (*mousevec)()) */
	.long dummy_subroutine                  /* 1 - Ssbrk() - not implemented */
	.long physbase                          /* 2 - Physbase() - returns physical address of screen memory */
	.long logbase                           /* 3 - Logbase() */
	.long getrez                            /* 4 - int16_t Getrez() */
	.long setscreen                         /* 5 - Setscreen(void *laddr, void *paddr, int16_t rez) */
	.long setpalette                        /* 6 - Setpalette(void *pal) */
	.long setcolor                          /* 7 - int16_t Setcolor(int16_t colornum, int16_t color) */
  /* 8 - int16_t Floprd(void *buf, int32_t filler, int16_t devno, int16_t sectno, int16_t trackno, int16_t sideno, int16_t count); */
	.long floprd
  /* 9 - int16_t Flopwr(void *buf, int32_t filler, int16_t devno, int16_t sectno, int16_t trackno, int16_t sideno, int16_t count); */
	.long flopwr
  /* 10 - int16_t Flopfmt(void *buf, int32_t filler, int16_t devno, int16_t spt, int16_t trackno, int16_t sideno, int16_t interlv, int32_t magic, int16_t virgin); */
	.long flopfmt
  /* 11 - uint32_t Dbmsg(int16_t rsrvd, int16_t msg_num, int32_t msg_arg) */
	.long _dbmsg
	.long midiws                            /* 12 - void Midiws(int16_t cnt, void *ptr); */
	.long mfpint                            /* 13 - void Mfpint(int16_t number, int16_t (*vector)()); */
	.long iorec                             /* 14 - IOREC *Iorec(int16_t dev); */
  /* 15 - int32_t Rsconf(int16_t baud, int16_t ctr, int16_t ucr, int16_t rsr, int16_t tsr, int16_t scr); */
  .long rsconf
  /* 16 - KEYTAB *Keytbl(void *unshift, void *shift, void *capslock); */
	.long keytbl
	.long _random                           /* 17 - int32_t Random(); */
  /* 18 - void Protobt(void *buf, int32_t serialno, int16_t disktype, int16_t execflag); */
	.long _protobt
  /* 19 - int16_t Flopver(void *buf, int32_t filler, int16_t devno, int16_ sectno, int16_t trackno, int16_t sideno, int16_t count); */
	.long flopver
	.long scrdmp                            /* 20 - void Scrdmp(); */
	.long cursconf                          /* 21 - int16_t Cursconf(int16_t func, int16_t rate); */
	.long settime                           /* 22 - void Settime(uint32_t time); */
	.long gettime                           /* 23 - uint32_t Gettime(); */
	.long bioskeys                          /* 24 - void Bioskeys(); */
	.long ikbdws                            /* 25 - void Ikbdws(int16_t count, const int8_t *ptr); */
	.long jdisint                           /* 26 - void Jdisint(int16_t number); */
	.long jenabint                          /* 27 - void Jenabint(int16_t number); */
	.long giaccess                          /* 28 - int8_t Giaccess(int16_t data, int16_t regno); */
	.long offgibit                          /* 29 - void Offgibit(int16_t bitno); */
	.long ongibit                           /* 30 - void Ongibit(int16_t bitno); */
	.long xbtimer                           /* 31 - void Xbtimer(int16_t timer, int16_t control, int16_t data, void(*vector)()); */
	.long dosound                           /* 32 - void *Dosound(const int8_t *buf); */
	.long setprt                            /* 33 - int16_t Setprt(int16_t config); */
	.long kbdvbase                          /* 34 - KBDVBASE *Kbdvbase(); */
	.long kbrate                            /* 35 - int16_t Kbrate(int16_t initial, int16_t repeat); */
	.long prtblk                            /* 36 - int16_t Prtblk(PBDEF *par); */
	.long vsync                             /* 37 - void Vsync(); */
	.long supexec                           /* 38 - int32_t Supexec(int32_t (*func)()); */
	.long puntaes                           /* 39 - void Puntaes(); */
	.long dummy_subroutine
	.long floprate                          /* 41 - int16_t Floprate(int16_t devno, int16_t newrate); */
	.long dummy_subroutine                  /* 42 - int16_t DMAread(int32_t sector, int16_t count, void *buffer, int16_t devno); */
	.long dummy_subroutine                  /* 43 - int16_t DMAwrite(int32_t sector, int16_t count, void *buffer, int16_t devno); */
	.long dummy_subroutine                  /* 44 - int32_t Bconmap(int16_t devno); */
	.long dummy_subroutine
  .long dummy_subroutine                  /* 46 - int16_t NVMaccess(int16_t op, int16_t start, int16_t count, int8_t *buffer); */
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long blitmode                          /* int16_t Blitmode(int16_t mode);  */
/* end of vectors */

addr_950:
supexec:
  moveal %sp@(4),%a0
  jmp %a0@

addr_956:
Bconstat:
.global Bconstat
	lea %a5@(xconstat_vec),%a0
	bras addr_96c

addr_95c:
Bconin:
.global Bconin
  lea %a5@(xconin_vec),%a0
  bras addr_96c

addr_962:
Bcostat:
.global Bcostat
  lea %a5@(xcostat_vec),%a0
	bras addr_96c
addr_968:

Bconout:
.global Bconout
	lea %a5@(xconout_vec),%a0
  /* Just fall through to next function */
/* Shared BIOS calling code for Bconstat, Bconin, Bcostat and Bconout. Jumps to a vector in system RAM based on the paramater passed. */
addr_96c:
  movew %sp@(4),%d0                       /* Get a vector number off the stack */
  lslw #2,%d0                             /* Multiply by 4 to get vector address */
  moveal %a0@(0,%d0:w),%a0                /* Get entry in vector table */
	jmp %a0@                                /* Jump straight into it */




/* Default BIOS vectors */
addr_978:
bios_vectors:
.global bios_vectors
  /* xconstat */
	.long dummy_subroutine
	.long addr_33a6
	.long addr_3494
	.long addr_32a6
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
  /* xconin */
	.long addr_3372
	.long addr_33be
	.long addr_34aa
	.long addr_32c0
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
  /* xcostat */
	.long addr_3392
	.long addr_3408
	.long addr_34e0
	.long addr_344a
	.long addr_326a
	.long dummy_subroutine
	.long dummy_subroutine
	.long dummy_subroutine
  /* xconout */
	.long addr_32f6
	.long addr_3422
	.long addr_a30a
	.long addr_327a
	.long addr_345c
	.long addr_a2fe
	.long dummy_subroutine
	.long dummy_subroutine

addr_9f8:
Drvmap:
.global Drvmap
  movel %a5@(_drvbits),%d0
	rts

addr_9fe:
Kbshift:
.global Kbshift
  moveq #0,%d0
  moveb %a5@(ram_unknown93),%d0
  movew %sp@(4),%d1
  bmis addr_a0e
  moveb %d1,%a5@(ram_unknown93)
addr_a0e:
	rts

addr_a10:
Getmpb:
.global Getmpb
  moveal %sp@(4),%a0
  lea %a5@(themd),%a1
  movel %a1,%a0@
  clrl %a0@(4)
  movel %a1,%a0@(8)
  clrl %a1@
  movel %a5@(_membot),%a1@(4)
  movel %a5@(_memtop),%d0
  subl %a5@(_membot),%d0
  movel %d0,%a1@(8)
  clrl %a1@(12)
	rts

addr_a3c:
Setexc:
.global Setexc
  movew %sp@(4),%d0
  lslw #2,%d0
  subal %a0,%a0
  lea %a0@(0,%d0:w),%a0
  movel %a0@,%d0
  movel %sp@(6),%d1
  bmis addr_a52
  movel %d1,%a0@
addr_a52:
	rts

addr_a54:
Tickcal:
.global Tickcal
  moveq #0,%d0
  movew %a5@(_timr_ms),%d0
	rts

addr_a5c:
physbase:
.global physbase
  moveq #0,%d0
  moveb %a5@(video_baseh + 1),%d0
  lslw #8,%d0
  moveb %a5@(video_basem + 1),%d0
  lsll #8,%d0
	rts

addr_a6c:
logbase:
.global logbase
  movel %a5@(_v_bas_ad),%d0
	rts

/*
  int16_t Getrez()
  0 - low res
  1 - med res
  2 - high res
*/
addr_a72:
getrez:
	moveq #0,%d0
  moveb %a5@(video_res),%d0
  andb #3,%d0
	rts

/* Trap 14, opcode 5 */
/* void Setscreen(void *laddr, void *paddr, int16_t rez) */
addr_a7e:
setscreen:
  tstl %sp@(4)                            /* Check longword on stack */
  bmis addr_a8a
  movel %sp@(4),%a5@(_v_bas_ad)           /* If positive, copy it to logical screen address */
addr_a8a:
  tstl %sp@(8)                            /* Check next longword on stack */
  bmis addr_a9c
  moveb %sp@(9),%a5@(video_baseh + 1)     /* If positive, copy it to the video base address */
  moveb %sp@(10),%a5@(video_basem + 1)
addr_a9c:
  tstw %sp@(12)                           /* Check next word on stack */
  bmis addr_ac2
  moveb %sp@(13),%a5@(sshiftmod)          /* If positive, update screen resolution */
  bsrw vsync
  moveb %a5@(sshiftmod),%a5@(video_res)   /* Setting the video register from sshiftmod */
  clrw %a5@(vblsem)
  jsr esc_init
  movew #1,%a5@(vblsem)
addr_ac2:
  rts

addr_ac4:
setpalette:
.global setpalette
	movel %sp@(4),%a5@(colorptr)
	rts

/* int16_t Setcolor(int16_t colornum, int16_t color) */
addr_acc:
setcolor:
.global setcolor
  movew %sp@(4),%d1
  addw %d1,%d1
  andw #31,%d1														/* (colornum * 2) & 0b11111 */
  lea %a5@(palette),%a0
  movew %a0@(0,%d1:w),%d0                 /* Get that colour from the palette */
  andw #0x777,%d0													/* Limit to STFM palette range, and return that value */
  tstw %sp@(6)
  bmis addr_aee                           /* Check color is positive */
  movew %sp@(6),%a0@(0,%d1:w)             /* Write color into palette */
addr_aee:
	rts

addr_af0:
puntaes:
  moveal %pc@(os_magic),%a0
  cmpil #0x87654321,%a0@
  bnes addr_b08
  cmpal %a5@(phystop),%a0
  bges addr_b08
  clrl %a0@
  braw _main
addr_b08:
	rts

/* Default exception handler - saves everything in the Processor Save State Area */
addr_b0a:
.global addr_b0a
  bsrs addr_b0e                           /* Not sure what the point of this is */
  nop
addr_b0e:
  subal %a5,%a5
  movel %sp@+,%a5@(proc_pc)               /* Save PC */
  moveml %d0-%sp,%a5@(proc_dregs)         /* Save all data and address registers */
  movel %usp,%a0                          /* Save USP */
  movel %a0,%a5@(proc_usp)
  moveq #15,%d0                           /* Save 16 words of the supervisor stack */
  lea %a5@(proc_stk),%a0
  moveal %sp,%a1
addr_b28:
  movew %a1@+,%a0@+
  dbf %d0,addr_b28
  movel #0x12345678,%a5@(proc_lives)      /* Save magic number */
  moveq #0,%d1
  moveb %a5@(proc_pc),%d1                 /* Get high byte of calling address */
  subqw #1,%d1
  bsrs drawbombs
  movel #tos_register_buffer,%a5@(savptr)
  movew #-1,%sp@-
  movew #76,%sp@-                         /* Call Pterm */
  trap #1
  braw _main                              /* Reboot */

addr_b56:
drawbombs:
  moveb %a5@(video_res),%d7
  andw #3,%d7
  addw %d7,%d7                            /* Twice the video mode = 0, 2, or 4 */
  moveq #0,%d0
  moveb %a5@(video_baseh + 1),%d0
  lslw #8,%d0
  moveb %a5@(video_basem + 1),%d0
  lsll #8,%d0
  moveal %d0,%a0
  addaw %pc@(addr_b9e,%d7:w),%a0
  lea bomb_image,%a1
  movew #15,%d6
addr_b7e:
  movew %d1,%d2
  moveal %a0,%a2
addr_b82:
  movew %pc@(addr_ba6,%d7:w),%d5
addr_b86:
  movew %a1@,%a0@+
  dbf %d5,addr_b86
  dbf %d2,addr_b82
  addqw #2,%a1
  addaw %pc@(addr_bae,%d7:w),%a2
  moveal %a2,%a0
  dbf %d6,addr_b7e
	rts
  
addr_b9e:
	.short 0x3e80
	.short 0x3e80
	.short 0x3e80
	.short 0x3e80
addr_ba6:
	.short 0x0003
	.short 0x0001
	.short 0x0000
	.short 0x0000
addr_bae:
	.short 0x00a0
	.short 0x00a0
	.short 0x0050
	.short 0x0050

addr_bb6:
.global addr_bb6
  .short 0x206f
  .short 0x0004
  .short 0x226f
.short 0x0008
addr_bd2:
  movew #63,%d0
addr_bc2:
  moveb %a0@+,%a1@+
  moveb %a0@+,%a1@+
  moveb %a0@+,%a1@+
  moveb %a0@+,%a1@+
  moveb %a0@+,%a1@+
  moveb %a0@+,%a1@+
  moveb %a0@+,%a1@+
  moveb %a0@+,%a1@+
  dbf %d0,addr_bc2
  rts

addr_bd8:
.global addr_bd8
  movel hdv_init,%sp@-
  rts

addr_be0:
autopath:
  .byte 0x5c
  .ascii "AUTO"
  .byte 0x5c

addr_be6:
autoname:
  .ascii "*.PRG"
	.byte 0
	.long 0x12345678
	.long 0x9abcdef0


addr_bf4:
autoexec:
.global autoexec
  lea %pc@(autopath),%a0
  lea %pc@(autoname),%a1
  movel %sp@+,ram_unknown139
  subal %a5,%a5
  movel %a0,%a5@(ram_unknown140)
  movel %a1,%a5@(ram_unknown141)
  movel %a5@(_drvbits),%d0
  movew _bootdev,%d1
  btst %d1,%d0
  beqs addr_c50
  lea %pc@(empty_string),%a0
  movel %a0,%sp@-
  movel %a0,%sp@-
  movel %a0,%sp@-
  movew #5,%sp@-
  movew #75,%sp@-
  trap #1
  addaw #16,%sp
  moveal %d0,%a0
  movel #addr_c58,%a0@(8)
  movel %a3,%sp@-
  movel %d0,%sp@-
  movel %a3,%sp@-
  movew #4,%sp@-
  movew #75,%sp@-
  trap #1
  addaw #16,%sp
addr_c50:
  movel ram_unknown139,%sp@-
  rts
addr_c58:
  clrl %sp@-
  movew #32,%sp@-
  trap #1
  addqw #6,%sp
  moveal %d0,%a4
  moveal %sp@(4),%a5
  lea %a5@(256),%sp
  movel #256,%sp@-
  movel %a5,%sp@-
  clrw %sp@-
  movew #74,%sp@-
  trap #1
  addqw #6,%sp
  tstw %d0
  bnes addr_cec
  movew #7,%sp@-
  movel ram_unknown140,%sp@-
  movew #78,%sp@-
  moveq #8,%d7
addr_c92:
  pea ram_unknown154
  movew #26,%sp@-
  trap #1
  addqw #6,%sp
  trap #1
  addaw %d7,%sp
  tstw %d0
  bnes addr_cec
  moveal ram_unknown140,%a0
  moveal ram_unknown141,%a2
  lea ram_unknown155,%a1
addr_cba:
  moveb %a0@+,%a1@+
  cmpal %a0,%a2
  bnes addr_cba
  lea ram_unknown156,%a0

addr_cc6:
.global addr_cc6
  moveb %a0@+,%a1@+
  bnes addr_cc6
  pea %pc@(empty_string)
  pea %pc@(empty_string)
  pea ram_unknown155
  clrw %sp@-
  movew #75,%sp@-
  trap #1
  addaw #16,%sp
  moveq #2,%d7
  movew #79,%sp@-
  bras addr_c92
addr_cec:
  lea stack_top,%sp
  movel ram_unknown139,%sp@-
  rts


/* Screen dump */
addr_cfa:
scrdmp:
.global scrdmp
  moveal dump_vec,%a0
  jsr %a0@
  movew #-1,_dumpflg
  rts

addr_d0c:
.global addr_d0c
  subal %a5,%a5
  movel %a5@(_v_bas_ad),%a5@(ram_unknown143)
  clrw %a5@(ram_unknown144)
  clrw %d0
  moveb %a5@(sshiftmod),%d0
  movew %d0,%a5@(ram_unknown145)
  addw %d0,%d0
  lea %pc@(hardcopy_parameter_table),%a0
  movew %a0@(0,%d0:w),%a5@(ram_unknown146)
  movew %a0@(6,%d0:w),%a5@(ram_unknown147)
  clrw %a5@(ram_unknown148)
  clrw %a5@(ram_unknown149)
  movel #palette_24_bit,%a5@(ram_unknown150)
  clrw %a5@(ram_unknown151)
  movew %a5@(ram_unknown24),%d1
  lsrw #3,%d1
  andw #1,%d1
  movew %d1,%a5@(ram_unknown152)
  movew %a5@(ram_unknown24),%d1
  movew %d1,%d0
  lsrw #4,%d0
  andw #1,%d0
  movew %d0,%a5@(ram_unknown153)
  andw #7,%d1
  moveb %pc@(printer_types, %d1:w),%d0
  movew %d0,ram_unknown142
  pea %a5@(ram_unknown143)
  movew #1,%a5@(_dumpflg)
  bsrw prtblk
  movew #-1,_dumpflg
  addqw #4,%sp
  rts

addr_d8e:
hardcopy_parameter_table:
	.short 320, 640, 640
  .short 200, 200, 400

addr_d9a:
printer_types:
	.byte 0             /* ATARI B/W dot-matrix */
  .byte 2             /* ATARI B/W daisy-wheel */
  .byte 1             /* ATARI colour dot-matrix */
  .byte -1            /* ATARI colour daisy-wheel - not implemented */
  .byte 3             /* Epson B/W dot-matrix */
  .byte -1            /* Epson B/W daisy wheel - not implemented */
  .byte -1            /* Epson colour dot-matrix - not implemented */
  .byte -1            /* Epson colour daisy-wheel - not implemented */

addr_da2:
bomb_image:
	.short 0x0600
	.short 0x2900
	.short 0x0080
	.short 0x4840
	.short 0x11f0
	.short 0x01f0
	.short 0x07fc
	.short 0x0ffe
	.short 0x0dfe
	.short 0x1fff
	.short 0x1fef
	.short 0x0fee
	.short 0x0fde
	.short 0x07fc
	.short 0x03f8
	.short 0x00e0


addr_dc2:
waitvbl:
.global waitvbl
  lea mfp_timerb + 1,%a0
  lea mfp_timerbc + 1,%a1
  moveb #16,%a1@                          	/* Reset timer B */
  moveq #1,%d4                            	/* Wait for the timer to expire */
  moveb #0,%a1@                           	/* Stop timer B */
  moveb #0xf0,%a0@                        	/* Event every 240 scanlines */
  moveb #8,mfp_timerbc + 1                	/* Timer B: event count mode (HBL) */
addr_de4:
  moveb %a0@,%d0
  cmpb %d4,%d0                            	/* Wait for HBL 239 scanlines to pass */
  bnes addr_de4
addr_dea:
  moveb %a0@,%d4
  movew #615,%d3                          	/* Wait until we are inside the VBL area */
addr_df0:
  cmpb %a0@,%d4
  bnes addr_dea
  dbf %d3,addr_df0
  moveb #16,%a1@                          	/* Reset timer B */
  jmp %fp@

addr_dfe:
run_reset_resident:
.global addr_dfe
  moveal phystop,%a0
addr_e04:
  subaw #512,%a0
  cmpal #1024,%a0
  beqs addr_e3c
  cmpil #0x12123456,%a0@
  bnes addr_e04
  cmpal %a0@(4),%a0
  bnes addr_e04
  clrw %d0
  moveal %a0,%a1
  movew #255,%d1
addr_e26:
  addw %a1@+,%d0
  dbf %d1,addr_e26
  cmpw #0x5678,%d0
  bnes addr_e04
  movel %a0,%sp@-
  jsr %a0@(8)
  moveal %sp@+,%a0
  bras addr_e04
addr_e3c:
  rts

addr_e3e:
gettime:
	lea addr_1fc2,%a3
	lea igetdt,%a4
	bras addr_e58

addr_e4c:
settime:
  lea addr_2080,%a3
  lea isetdt,%a4
addr_e58:
  bsrw addr_1f70
  bccs addr_e60
  moveal %a4,%a3
addr_e60:
  jmp %a3@

	addr_e62:
instoshdr:
.global addr_e62
  lea %pc@(os_entry),%a0
  lea ram_unknown15,%a1
  moveq #47,%d0
addr_e6e:
  moveb %a0@(0,%d0:w),%a1@(0,%d0:w)
  dbf %d0,addr_e6e
  movew %pc@(addr_e96),%a1@(-6)
  movel %a1@(4),%a1@(-4)
  movew %pc@(addr_e9c),%a1@
  movew %a1@(30),%a1@(28)
  movel %a1,_sysbase
	rts
addr_e96:
  jmp ram_start
addr_e9c:
  bras addr_e96

addr_e9e:
blitmode:
  bsrs blittest
  movew %d0,%d4
  movew %d0,%d5
  lsrw #1,%d5
  orw #-2,%d5
  jsr addr_b5d2
  movew %d0,%d3
  movew %sp@(4),%d0
  bmis addr_ec2
  andw %d5,%d0
  orw %d4,%d0
  jsr rout_init
addr_ec2:
  movew %d3,%d0
	rts

addr_ec6:
blittest:
.global blittest
  movew %sr,%d1
  movew #0,%d0
  subal %a0,%a0
  moveal %sp,%a2
  oriw #1792,%sr
  moveal %a0@(8),%a1
  movel #addr_ee6,%a0@(8)
  tstw %a0@(blitter_halftone_ram)
  moveq #2,%d0
addr_ee6:
  movel %a1,%a0@(8)
  movew %d1,%sr
  moveal %a2,%sp
  rts

/* There's an include here for tospatch/hdwait<x>.S */

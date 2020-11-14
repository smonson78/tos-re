.section .text

addr_0:
os_entry:
    bras boot           /* Initial SP */
addr_2:
os_version:
	.short 0x0104       /* TOS v1.04 */
addr_4:
reseth:    
	.long boot          /* Initial PC */
addr_8:
os_beg:	
	.long os_entry      /* Start of OS */
addr_c:
os_end:
	.long 0x0000611c    /* Start of free RAM */
	.long boot          /* Default shell (reset) */
addr_14:    
os_magic:
	.long gem_magic     /* Address for GEM magic */
addr_18:    
os_date:
	.long 0x04061989    /* TOS date 04/06/1989 */
addr_1c:    
os_conf:
	.short 0x0007       /* PAL version */
addr_1e:    
os_dosdate:
	.short 0x1286       /* Date in DOS format */
addr_20:
pp_root:
	.long 0x0000378c    /*  */
addr_24:
ppbkshift:
	.long 0x00000e7d    /*  */
addr_28:    
pp_run:
	.long 0x00005622    /*  */
	.long 0x00000000    /*  */

.global os_entry
.global os_magic

boot:
.global boot
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
    movel #addr_16ba,%a5@(hdv_init)
    movel #addr_1a24,%a5@(hdv_rw)
    movel #addr_173c,%a5@(hdv_bpb)
    movel #addr_18ec,%a5@(hdv_mediach)
    movel #addr_1cc6,%a5@(hdv_boot)
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
    
    .short 0x41f9                               /* lea bios_vectors,%a0 - ROM copy of BIOS routine vectors */
    .long bios_vectors

    moveaw #xconstat,%a1                        /* 4 tables of 8 vectors each: xconstat, xconin, xcostat, xconout */
    moveq #31,%d0                               /* Copy 32 longwords */
addr_396:    
    movel %a0@+,%a1@+                           /* Copy */
    dbf %d0,addr_396                            /* Next vector */
    bsrw addr_34fc
    movel #addr_52e,%sp@-                       /* Push 2 params */
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
    movel #boot,%a5@(swv_vec)                   /* Reboot on resolution-change vector */
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
    bsrw addr_31a8                              /* Boot from DMA bus? */
                                                /* Execute reset-resident programs? */
    swap %d0

    tstb %d0
    beqs addr_462
    .short 0x33c0                               /* movew %d0,0x60be */
    .long ram_unknown2
    swap %d0
    movew %d0,stack_top

addr_462:
    bsrw addr_530
    bsrw addr_54c
    bsrw addr_dfe
    tstw _cmdload                               /* _cmdload? */
    beqs addr_494                               /* No */
    bsrw addr_bf4                               /* Possibly: autoexec, execute programs in AUTO folder */
    movel #os_entry,_sysbase
    pea %pc@(empty_string)                      /* Empty string */
    pea %pc@(empty_string)                      /* Empty string */
    pea %pc@(addr_518)                          /* "COMMAND.PRG" string */
    clrw %sp@-                                  /* Load and start program */
    bras addr_4fc                               /* Load to program */
addr_494:    
    bsrw addr_bf4                               /* autoexec, execute programs in AUTO folder */
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
    .long boot

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
    .byte 0,0,0

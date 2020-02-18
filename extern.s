.section .ram

.set ram_start,0
.global ram_start

vectors:
    .long 0
    .long 0
vector_bus_error:
    .long 0
vector_address_error:
    .long 0
vector_illegal_instruction:
    .long 0    
vector_divide_by_zero:
    .long 0
vector_chk_instruction:
    .long 0
vector_trapv_instruction:
    .long 0
vector_privilege_violation:
    .long 0
vector_trace:
    .long 0
vector_linea:
    .long 0
vector_linef:
    .long 0
    .long 0
 
. = 0x64
autovectors:
    .long 0

. = 0x80
traps:
    .long 0

. = 0x400
etv_timer:
    .long 0
etv_critic:
    .long 0
etv_term:
    .long 0

.set memvalid,0x420                         /* On warm boot, contains 0x752019f3 */
.set memcntlr,0x424                         /* Copy of memory controller state (bits 11-8) */
.set resvector,0x42a                        /* Vector to call on warm boot */
.set phystop,0x42e                          /* Top of physical RAM */
.set _membot,0x432                          /* Bottom of heap */
.set _memtop,0x436                          /* Top of heap */
.set memval2,0x43a                          /* On warm boot, contains 0x237698aa */
.set seekrate,0x440                         /* Floppy disk seek rate */
.set _fverify,0x444                         /* Flag indicating floppy writes will be verified */
.set _bootdev,0x446                         /* Device booted from 0=A, 1=B, and so on */
.set sshiftmod,0x44c                        /* Copy of current shifter mode */
.set _v_bas_ad,0x44e                        /* Logical screen address */
.set vblsem,0x452
.set nvbls,0x454                            /* Number of slots in deferred VBL handler list, _vblqueue */
.set _vblqueue,0x456                        /* Pointer to list of pointers to deferred VBL handlers */
.set colorptr,0x45a                         /* Pointer to new palette to be loaded on next VBL */
.set _vbclock,0x462                         /* Number of VBLs since reset */
.set _frlock,0x466                          /* Number of VBLs processed by VBL interrupt */
.set hdv_init,0x46a                         /* Pointer to hard drive init handler */
.set swv_vec,0x46e                          /* Resolution-change vector */
.set hdv_bpb,0x472                          /* Vector for Getbpb() */
.set hdv_rw,0x476                           /* Vector for Rwabs() */
.set hdv_boot,0x47a                         /* Hard disk boot vector. 0 = no hard disk */
.set hdv_mediach,0x47e                      /* Vector for Mediach() */
.set _cmdload,0x482                         /* If non-zero, load COMMAND.PRG instead of desktop at boot */
.set savptr,0x4a2                           /* Pointer to buffer used by TOS for saving registers */
.set con_state,0x4a8                        /* Vector to internal console output routines */
.set _bufl,0x4b2                            /* 8 bytes: first longword is a pointer to a Buffer Control Block for data sectors.
                                               Second longword is a BCB for FAT/directory sectors */
.set _drvbits,0x4c2                         /* One bit for each of 32 possible drives present */
.set _dskbufp,0x4c6                         /* Pointer to a 1KB disk buffer */
.set _vbl_lis,0x4ce                         /* 8 VBL handler entries */
.set _dumpflg,0x4ee                         /* ALT+HELP screen dump flag */
.set _sysbase,0x4f2                         /* Beginning of TOS and _osheader structure */
.set end_os,0x4fa                           /* Pointer to end of TOS ram */
.set exec_os,0x4fe                          /* Start address AES and Desktop */
.set dump_vec,0x502                         /* Vector for screen dump */
.set prt_stat,0x506                         /* Vector for printer device status */
.set prt_vec,0x50a                          /* Vector for printer device byte output */
.set aux_stat,0x50e                         /* Vector for printer device status */
.set aux_vec,0x512                          /* Vector for printer device byte output */
.set memval3,0x51a                          /* On warm boot, contains 0x5555aaaa */
.set xconstat,0x51e
.set _longframe,0x59e                       /* Something to do with C calling conventions */

.global memvalid
.global memcntlr
.global resvector
.global phystop
.global _membot
.global _memtop
.global memval2
.global seekrate
.global _fverify
.global _bootdev
.global sshiftmod
.global _v_bas_ad
.global vblsem
.global nvbls
.global _vblqueue
.global colorptr
.global _vbclock
.global _frlock
.global _cmdload
.global savptr
.global con_state
.global _bufl
.global hdv_init
.global swv_vec
.global hdv_bpb
.global hdv_rw
.global hdv_boot
.global hdv_mediach
.global _drvbits
.global _dskbufp
.global _vbl_lis
.global _dumpflg
.global _sysbase
.global end_os
.global exec_os
.global dump_vec
.global prt_stat
.global prt_vec
.global aux_stat
.global aux_vec
.global memval3
.global xconstat
.global _longframe



/* 5b0 is the last TOS system variable */

/* Environment - as in the environment that the Desktop runs under. It's a maximum of 251 bytes as far as we can tell so far. */
.set environment,0x840
.global environment

.set tos_register_buffer,0x93a
.global tos_register_buffer

/* Saved copy of SR register */
.set saved_sr_register,0xffa
.global saved_sr_register

.set ram_unknown16,0x1810
.global ram_unknown16

/* Some kind of array of 2 vectors */
.set saved_vectors,0x1814
.global saved_vectors

/* This is a 1KB disk buffer from 0x181c to 0x221c */
.set disk_buffer,0x181c
.global disk_buffer

/* This is used by TOS but appears to be within the above buffer */
.set ram_unknown24,0x1860
.global ram_unknown24

.set ram_unknown23,0x2752
.global ram_unknown23

.set ram_unknown22,0x283c
.global ram_unknown22

.set ram_unknown25,0x290c
.global ram_unknown25

.set ram_unknown20,0x291c
.global ram_unknown20

.set ram_unknown28,0x2982
.global ram_unknown28

.set ram_unknown27,0x2ab6
.global ram_unknown27

.set ram_unknown19,0x2ae0
.global ram_unknown19

.set ram_unknown21,0x2b00
.global ram_unknown21

.set ram_unknown29,0x2b7e
.global ram_unknown29

.set ram_unknown48,0x3426
.global ram_unknown48

.set ram_unknown45,0x3436
.global ram_unknown45

.set ram_unknown44,0x343a
.global ram_unknown44

.set ram_unknown46,0x34ca
.global ram_unknown46

.set ram_unknown47,0x354e
.global ram_unknown47

.set ram_unknown38,0x3552
.global ram_unknown38

.set ram_unknown39,0x3556
.global ram_unknown39

.set ram_unknown37,0x35a8
.global ram_unknown37

.set stack_top,0x378a
.global stack_top

.set ram_unknown17,0x52c8
.global ram_unknown17

.set ram_unknown6,0x5622
.global ram_unknown6

.set ram_unknown9,0x5680
.global ram_unknown9

.set ram_unknown8,0x5681
.global ram_unknown8

.set ram_unknown7,0x5682
.global ram_unknown7

/* These buffers are 512 bytes each and hold disk sectors */
.set data_sector_buf,0x5690
.global data_sector_buf
.set data_sector_buf2,0x5890
.global data_sector_buf2
.set dir_sector_buf,0x5a90
.global dir_sector_buf
.set dir_sector_buf2,0x5c90
.global dir_sector_buf2

.set ram_unknown12,0x5e90
.global ram_unknown12

.set ram_unknown18,0x5f36
.global ram_unknown18

.set ram_unknown11,0x60b2
.global ram_unknown11

.set ram_unknown2,0x60be
.global ram_unknown2

/* These 4 buffer control blocks are for data sectors and FAT/dir sectors respectively.
typedef struct _bcb
{
  struct _bcb   *b_link;          // Next BCB              
  int16_t       b_negl;           // Initialize to -1      
  int16_t       b_private[5];     // Unknown               
  void          *b_buf;           // Actual buffer         
} BCB; 
*/
.set tos_bcb_data,0x60c0
.global tos_bcb_data
.set tos_bcb_data2,0x60d4
.global tos_bcb_data2
.set tos_bcb_dir,0x60e8
.global tos_bcb_dir
.set tos_bcb_dir2,0x60fc
.global tos_bcb_dir2

.set ram_unknown10,0x6110
.global ram_unknown10

.set retsave,0x611e
.global retsave

.set _autoexec,0x6122
.global _autoexec

/* 2 bytes */
.set _gl_rschange,0x6124
.global _gl_rschange

/* User stack - 132 bytes */
.set ustak,0x6126
.global ustak

.set _diskin,0x61aa
.global _diskin

/* Used by interrupts_off and interrupts_on subroutines */
.set saved_sr,0x63ca
.global saved_sr

.set aes_trap2_next_vec,0x6662
.global aes_trap2_next_vec

.set _drawaddr,0x666a
.global _drawaddr

.set _drwaddr,0x6b02
.global _drwaddr

.set _tikaddr,0x6b06
.global _tikaddr

.set ram_unknown35,0x6dc0
.global ram_unknown35

.set ram_unknown34,0x6dd4
.global ram_unknown34

.set _sh_iscart,0x6de0
.global _sh_iscart

.set ram_unknown33,0x6e1a
.global ram_unknown33

.set _DOS_AX,0x6e20
.global _DOS_AX

.set _ad_envrn,0x6e28
.global _ad_envrn

.set _pglobal,0x6e6c
.global _pglobal

.set _sh_gem,0x6f0c
.global _sh_gem

.set _g_wsend,0x6fee
.global _g_wsend

.set _sh_doexec,0x7006
.global _sh_doexec

.set _sh_isgem,0x708a
.global _sh_isgem

.set _DOS_ERR,0x742a
.global _DOS_ERR

.set ram_unknown40,0x776c
.global ram_unknown40

/* rlr is a pointer to pd structure. */
.set _rlr,0xa792
.global _rlr

.set ram_unknown43,0xa788
.global ram_unknown43

.set ram_unknown41,0xa7b6
.global ram_unknown41

.set ram_unknown42,0xa7ba
.global ram_unknown42

.set ram_unknown32,0xa7c4
.global ram_unknown32

.set ram_unknown36,0xa792
.global ram_unknown36

/* The end of RAM used by GEM is a84e */

.global vectors
.global vector_bus_error
.global vector_address_error
.global vector_illegal_instruction
.global vector_divide_by_zero
.global vector_chk_instruction
.global vector_trapv_instruction
.global vector_privilege_violation
.global vector_trace
.global vector_linea
.global vector_linef

.global autovectors

.global traps

.global etv_timer
.global etv_critic
.global etv_term

.section .cart

cart_magic:
    .space 4,0
cart_boot:

.global cart_magic
.global cart_boot

/* These are negative for use with 16-bit offsets */
.section .mmu
.set memctrl,0xffff8000
.set video_baseh,0xffff8200
.set video_basem,0xffff8202
.set shifter_sync_mode,0xffff820a
.set palette,0xffff8240
.set video_res,0xffff8260
.set psg,0xffff8800
.set mfp_pp,0xfffffa01

.global memctrl
.global video_baseh
.global video_basem
.global shifter_sync_mode
.global palette
.global video_res
.global psg
.global mfp_pp

.set STACK_SIZE,448
.set uda_size,74+(4*STACK_SIZE)
/* This should be 1866 */
.set init_size,uda_size
.set fsize,100
.global init_size
.global fsize

/* I still don't know what this is - it's just a constant 0x369e in the 3.06 source */
/* but it's 0x745e in 1.4 */
.set _D,0x745e                              /* sizeof(THEGLO) */
.global _D

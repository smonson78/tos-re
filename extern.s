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
.set flock,0x43e                            /* Tells other routines not to access DMA registers */
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
.global flock
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

.set ram_unknown30,0x6662
.global ram_unknown30



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

/* Some of these are the same, but one's for read and one's for write */
.set dma_data_register,0xffff8604           /* R */
.set dma_sector_count,0xffff8604            /* W */
.set dma_status,0xffff8606                  /* R */
.set dma_mode_control,0xffff8606            /* W */
.set dma_pointer_high,0xffff8608
.set dma_pointer_mid,0xffff860a
.set dma_pointer_low,0xffff860c

.set psg,0xffff8800
.set mfp_pp,0xfffffa01

.global memctrl
.global video_baseh
.global video_basem
.global shifter_sync_mode
.global palette
.global video_res
.global dma_data_register
.global dma_sector_count
.global dma_status
.global dma_mode_control
.global dma_pointer_high
.global dma_pointer_mid
.global dma_pointer_low
.global psg
.global mfp_pp


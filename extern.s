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

/* Processor Save State Area */
.set proc_lives,0x380                       /* Longword set to 0x12345678 if state was saved after a crash */
.global proc_lives
.set proc_dregs,0x384                       /* 8 longwords which are the data registers 0 to 7 */
.global proc_dregs
.set proc_aregs,0x3a4                       /* 8 longwords which are the address registers 0 to 7 */
.global proc_aregs
.set proc_pc,0x3c4                          /* Saved PC */
.global proc_pc
.set proc_usp,0x3c8                         /* Saved USP */
.global proc_usp
.set proc_stk,0x3cc                         /* Top 16 words from the supervisor stack */
.global proc_stk


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
.set _timr_ms,0x442                         /* System timer duration in milliseconds */
.set _fverify,0x444                         /* Flag indicating floppy writes will be verified */
.set _bootdev,0x446                         /* Device booted from 0=A, 1=B, and so on */
.set defshiftmod,0x44a                      /* Default shifter mode */
.set sshiftmod,0x44c                        /* Copy of current shifter mode */
.set _v_bas_ad,0x44e                        /* Logical screen address */
.set vblsem,0x452
.set nvbls,0x454                            /* Number of slots in deferred VBL handler list, _vblqueue */
.set _vblqueue,0x456                        /* Pointer to list of pointers to deferred VBL handlers */
.set colorptr,0x45a                         /* Pointer to new palette to be loaded on next VBL */
.set screenpt,0x45e                         /* Pointer to new video address to be loaded on next VBL */
.set _vbclock,0x462                         /* Number of VBLs since reset */
.set _frlock,0x466                          /* Number of VBLs processed by VBL interrupt */
.set hdv_init,0x46a                         /* Pointer to hard drive init handler */
.set swv_vec,0x46e                          /* Resolution-change vector */
.set hdv_bpb,0x472                          /* Vector for Getbpb() */
.set hdv_rw,0x476                           /* Vector for Rwabs() */
.set hdv_boot,0x47a                         /* Hard disk boot vector. 0 = no hard disk */
.set hdv_mediach,0x47e                      /* Vector for Mediach() */
.set _cmdload,0x482                         /* If non-zero, load COMMAND.PRG instead of desktop at boot */
.set conterm,0x484                          /* Key repeat, click, etc */
.set themd,0x48e                            /* This is the Memory Descriptor structure initialized by the BIOS */
.set savptr,0x4a2                           /* Pointer to buffer used by TOS for saving registers */
.set con_state,0x4a8                        /* Vector to internal console output routines */
.set _bufl,0x4b2                            /* 8 bytes: first longword is a pointer to a Buffer Control Block for data sectors.
                                               Second longword is a BCB for FAT/directory sectors */
.set _hz_200,0x4ba                          /* 200Hz counter, random seed */
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
.set xconstat,0x51e                         /* 8 Bconstat() vectors for 8 BIOS devices */
.set xconin,0x53e                           /* 8 Bconin() vectors for 8 BIOS devices */
.set xcostat,0x55e                          /* 8 Bcostat() vectors for 8 BIOS devices */
.set xconout,0x57e                          /* 8 Bconout() vectors for 8 BIOS devices */
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
.global _timr_ms
.global _fverify
.global _bootdev
.global defshiftmod
.global sshiftmod
.global _v_bas_ad
.global vblsem
.global nvbls
.global _vblqueue
.global colorptr
.global screenpt
.global _vbclock
.global _frlock
.global _cmdload
.global conterm
.global themd
.global savptr
.global con_state
.global _bufl
.global _hz_200
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
.global xconin
.global xcostat
.global xconout
.global _longframe



/* 5b0 is the last TOS system variable */

/* Environment - as in the environment that the Desktop runs under. It's a maximum of 251 bytes as far as we can tell so far. */
.set environment,0x840
.global environment

.set ram_unknown14,0x8d4
.global ram_unknown14

.set tos_register_buffer,0x93a
.global tos_register_buffer

.set ram_unknown15,0x940
.global ram_unknown15

.set ram_unknown139,0x980
.global ram_unknown139

.set ram_unknown140,0x984
.global ram_unknown140

.set ram_unknown141,0x988
.global ram_unknown141

.set ram_unknown154,0x98c
.global ram_unknown154

.set ram_unknown156,0x9aa
.global ram_unknown156

.set ram_unknown155,0x9b8
.global ram_unknown155

.set ram_unknown143,0x9d8
.global ram_unknown143

.set ram_unknown144,0x9dc
.global ram_unknown144

.set ram_unknown146,0x9de
.global ram_unknown146

.set ram_unknown147,0x9e0
.global ram_unknown147

.set ram_unknown148,0x9e2
.global ram_unknown148

.set ram_unknown149,0x9e4
.global ram_unknown149

.set ram_unknown145,0x9e6
.global ram_unknown145

.set ram_unknown152,0x9e8
.global ram_unknown152

.set ram_unknown150,0x9ea
.global ram_unknown150

.set ram_unknown142,0x9ee
.global ram_unknown142

.set ram_unknown153,0x9f0
.global ram_unknown153

.set ram_unknown151,0x9f2
.global ram_unknown151

.set fd_retry,0x9f6
.global fd_retry

.set fd_curtrack,0xa0a
.global fd_curtrack

.set fd_sect,0xa0c
.global fd_sect

.set fd_side,0xa0e
.global fd_side

.set ram_unknown130,0xa08
.global ram_unknown130

.set fd_scount,0xa10
.global fd_scount

.set fd_buffer,0xa12
.global fd_buffer

.set fd_spt,0xa16
.global fd_spt

.set fd_interlv,0xa18
.global fd_interlv

.set fd_virgin,0xa1a
.global fd_virgin

.set ram_unknown1,0xa1b
.global ram_unknown1

.set fd_secmap,0xa1c
.global fd_secmap

.set ram_unknown88,0xa24
.global ram_unknown88

.set fd_curerr,0xa26
.global fd_curerr

.set ram_unknown128,0xa4c
.global ram_unknown128

.set ram_unknown129,0xa50
.global ram_unknown129

.set baudrate,0xa6e
.global baudrate

.set rs232iorec,0xc70
.global rs232iorec

.set ram_unknown134,0xc7e
.global ram_unknown134

.set ram_unknown135,0xc8d
.global ram_unknown135

.set ram_unknown132,0xc92
.global ram_unknown132

.set ram_unknown133,0xda0
.global ram_unknown133

.set ram_unknown30,0xe2e
.global ram_unknown30

/* A mouse vector */
.set mouseint,0xe3e
.global mouseint

.set ram_unknown93,0xe7d
.global ram_unknown93

/* KEYTAB strucutre is at least 3 pointers long (7 pointers in TOS 4, but probably 3 here) */
/* 
  0xe7e - unshift 
  0xe82 - shift
  0xe86 - capslock
*/
.set keytab,0xe7e
.global keytab

.set ram_unknown31,0xe9e
.global ram_unknown31

.set ram_unknown136,0xea0
.global ram_unknown136

.set ram_unknown19,0xea6
.global ram_unknown19

.set ram_unknown22,0xeaa
.global ram_unknown22

.set ram_unknown24,0xeac
.global ram_unknown24

/* 32 bits */
.set rseed,0xeb0
.global rseed

.set ram_unknown51,0xeb4
.global ram_unknown51

.set ram_unknown127,0xeb6
.global ram_unknown127

.set prtbbval,0xeb8
.global prtbbval

.set ram_unknown109,0xeba
.global ram_unknown109

.set ram_unknown80,0xebc
.global ram_unknown80

.set ram_unknown123,0xebe
.global ram_unknown123

.set ram_unknown131,0xecc
.global ram_unknown131

.set ram_unknown114,0xed0
.global ram_unknown114

.set ram_unknown118,0xed2
.global ram_unknown118

.set ram_unknown103,0xed6
.global ram_unknown103

.set ram_unknown106,0xed8
.global ram_unknown106

.set ram_unknown117,0xedc
.global ram_unknown117

.set ram_unknown101,0xeca
.global ram_unknown101

.set ram_unknown104,0xece
.global ram_unknown104

.set ram_unknown120,0xee0
.global ram_unknown120

.set ram_unknown116,0xee2
.global ram_unknown116

.set prtbgval,0xee6
.global prtbgval

.set ram_unknown112,0xee8
.global ram_unknown112

.set ram_unknown119,0xeec
.global ram_unknown119

.set ram_unknown110,0xeee
.global ram_unknown110

.set ram_unknown87,0xef0
.global ram_unknown87

.set ram_unknown126,0xef2
.global ram_unknown126

.set ram_unknown113,0xef4
.global ram_unknown113

.set prtbrval,0xef6
.global prtbrval

/*
struct _pbdef
{ 
   /  0 / char *   pb_scrptr;  / Pointer to start of screen memory /
   /  4 / uint16_t pb_offset;  / Offset to be added to this        /
   /  6 / uint16_t pb_width;   / Screen width in dots              /
   /  8 / uint16_t pb_height;  / Screen height in dots             /
   / 10 / uint16_t pb_left;    / Left margin in dots               /
   / 12 / uint16_t pb_right;   / Right margin in dots              /
   / 14 / uint16_t pb_screz;   / Resolution                        /
   / 16 / uint16_t pb_prrez;   / Printer type (Atari/Epson)        /
   / 18 / const int16_t *pb_colptr;  / Pointer to color palette    /
   / 22 / uint16_t pb_prtype;  / 0: Atari matrix monochrome
                           1: Atari matrix color
                           2: Atari daisywheel monochrome
                           3: Epson matrix monochrome        /
   / 24 / uint16_t pb_prport;  / Centronics/RS-232 port            /
   / 26 / const char *pb_mask; / Pointer to halftone mask          /
   / 30 /
};
*/

.set ram_unknown36,0xef8
.global ram_unknown36

.set ram_unknown58,0xefc
.global ram_unknown58

/* pbpar.pb_width */
.set ram_unknown52,0xefe
.global ram_unknown52

.set ram_unknown50,0xf00
.global ram_unknown50

.set ram_unknown100,0xf02
.global ram_unknown100

.set ram_unknown74,0xf04
.global ram_unknown74

.set ram_unknown57,0xf06
.global ram_unknown57

.set ram_unknown56,0xf08
.global ram_unknown56

/* pbpar.pb_colptr */
.set ram_unknown86,0xf0a
.global ram_unknown86

.set ram_unknown55,0xf0e
.global ram_unknown55

.set ram_unknown49,0xf10
.global ram_unknown49

.set ram_unknown79,0xf12
.global ram_unknown79

.set ram_unknown105,0xf56
.global ram_unknown105

.set ram_unknown96,0xf58
.global ram_unknown96

.set ram_unknown99,0xf78
.global ram_unknown99

.set ram_unknown107,0xf7a
.global ram_unknown107

.set prtbtcol,0xf7c
.global prtbtcol

.set ram_unknown67,0xf7e
.global ram_unknown67

.set ram_unknown94,0xf80
.global ram_unknown94

.set ram_unknown73,0xfa0
.global ram_unknown73

.set ram_unknown122,0xfa2
.global ram_unknown122

.set ram_unknown111,0xfae
.global ram_unknown111

.set ram_unknown124,0xfb0
.global ram_unknown124

.set ram_unknown63,0xfb8
.global ram_unknown63

.set ram_unknown61,0xfba
.global ram_unknown61

.set ram_unknown125,0xfbc
.global ram_unknown125

.set ram_unknown98,0xfbe
.global ram_unknown98

.set ram_unknown102,0xfc0
.global ram_unknown102

.set ram_unknown121,0xfc2
.global ram_unknown121

.set ram_unknown97,0xfc4
.global ram_unknown97

.set ram_unknown115,0xfc6
.global ram_unknown115

.set ram_unknown95,0xfc8
.global ram_unknown95

.set ram_unknown66,0xfe8
.global ram_unknown66

.set ram_unknown68,0xfea
.global ram_unknown68

.set ram_unknown59,0xfec
.global ram_unknown59

.set ram_unknown108,0xfee
.global ram_unknown108

/* Saved copy of SR register */
.set saved_sr_register,0xffa
.global saved_sr_register

.set ram_unknown16,0x1810
.global ram_unknown16

/* Some kind of array of 2 vectors */
.set saved_vectors,0x1814
.global saved_vectors

/* This is a 1KB disk buffer from 0x181c to 0x221c (maybe it's just a pointer to the buffer) */
.set disk_buffer,0x181c
.global disk_buffer

/* This is used by TOS but appears to be within the above buffer */
.set _flip_y,0x1860
.global _flip_y

.set ptsin_array,0x1b1c
.global ptsin_array

.set ram_unknown23,0x2752
.global ram_unknown23

/* 45 words from 27ce to 2828 */
.set inq_tab,0x27ce
.global inq_tab

/* 45 words from 2828 to 2882 */
.set dev_tab,0x2828
.global dev_tab

.set gcurx,0x2882
.global gcurx

.set gcury,0x2884
.global gcury

.set req_col,0x288a
.global req_col

.set siz_tab,0x28ea
.global siz_tab

.set ram_unknown60,0x28fc
.global ram_unknown60

.set ram_unknown137,0x2908
.global ram_unknown137

.set chc_mode,0x290a
.global chc_mode

.set cur_work,0x290c
.global cur_work

/* This is an array of 4 pointers to struct font_head. */
.set font_ring,0x2914
.global font_ring

.set ram_unknown20,0x291c
.global ram_unknown20

.set line_cw,0x2926
.global line_cw

.set loc_mode,0x2928
.global loc_mode

.set str_mode,0x297c
.global str_mode

.set val_mode,0x297e
.global val_mode

.set disab_cnt,0x2982
.global disab_cnt

.set ram_unknown138,0x2a9e
.global ram_unknown138

/* Background colour */
.set v_col_bg,0x2ab6
.global v_col_bg

/* Foreground colour */
.set v_col_fg,0x2ab8
.global v_col_fg

/* Cursor location? */
.set v_cur_ad,0x2aba
.global v_cur_ad

.set v_cur_off,0x2abe
.global v_cur_off

.set v_curcx,0x2ac0
.global v_curcx

.set vct_init,0x2ac4
.global vct_init

.set v_cur_tim,0x2ac5
.global v_cur_tim

.set v_curcy,0x2ac2
.global v_curcy

/* Video characteristics */
.set v_stat_0,0x2ad6
.global v_stat_0

/* Cursor redisplay interval */
.set v_delay,0x2ad7
.global v_delay

/* Video memory config parameters: */
.set v_hz_rez,0x2ad0
.global v_hz_rez
.set ram_unknown13,0x2ad6
.global ram_unknown13
.set v_vt_rez,0x2ad8
.global v_vt_rez
.set bytes_lin,0x2ada
.global bytes_lin
.set v_planes,0x2adc
.global v_planes
.set v_lin_wr,0x2ade
.global v_lin_wr

.set contrl,0x2ae0
.global contrl

/* A reusable pointer to the intin table */
.set INTIN,0x2ae4
.global INTIN

.set INTOUT,0x2aec
.global INTOUT

.set ram_unknown21,0x2b00
.global ram_unknown21

.set ram_unknown54,0x2b56
.global ram_unknown54

.set ram_unknown29,0x2b7e
.global ram_unknown29

.set ram_unknown53,0x2b82
.global ram_unknown53

.set blt_mode,0x2b86
.global blt_mode

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

/* Virtual workstation "ATTRIBUTE" structure (308+ bytes - to 3cde) */
.set virt_work,0x3baa
.global virt_work

.set ram_unknown17,0x52c8
.global ram_unknown17

/* A big font struct */
.set ram8x8,0x52ca
.global ram8x8

.set ram_unknown6,0x5622
.global ram_unknown6

.set ram8x16,0x5626
.global ram8x16

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

/* AES+DESKTOP vars start here according to TOS306, with retsava at 0x611e */

.set retsava,0x611e
.global retsava

.set _gl_restype,0x6122
.global _gl_restype

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

.set pblock,0x6aee
.global pblock

.set iioff,0x6af2
.global iioff

.set pioff,0x6af6
.global pioff

.set iooff,0x6afa
.global iooff

.set pooff,0x6afe
.global pooff

.set _drwaddr,0x6b02
.global _drwaddr

.set _tikaddr,0x6b06
.global _tikaddr

.set ram_unknown62,0x6c56
.global ram_unknown62

.set ptsout,0x6c6a
.global ptsout

.set xrat,0x6cde
.global xrat

.set yrat,0x6ce0
.global yrat

.set gl_bdelay,0x6cec
.global gl_bdelay

.set gl_bclick,0x6d56
.global gl_bclick

.set ram_unknown76,0x6d5e
.global ram_unknown76

.set _gl_mode,0x6dd8
.global _gl_mode

.set _gl_handle,0x6d5c
.global _gl_handle

.set ram_unknown77,0x6d88
.global ram_unknown77

.set gl_recd,0x6db0
.global gl_recd

.set gl_bdesired,0x6db2
.global gl_bdesired

.set ram_unknown89,0x6db6
.global ram_unknown89

.set ram_unknown35,0x6dc0
.global ram_unknown35

.set ram_unknown78,0x6dc2
.global ram_unknown78

.set ad_windspb,0x6dd0
.global ad_windspb

.set ram_unknown34,0x6dd4
.global ram_unknown34

.set _sh_iscart,0x6de0
.global _sh_iscart

.set _gl_graphic,0x6e10
.global _gl_graphic

.set _gl_lcolor,0x6e12
.global _gl_lcolor

.set ram_unknown33,0x6e1a
.global ram_unknown33

.set _DOS_AX,0x6e20
.global _DOS_AX

.set _ad_envrn,0x6e28
.global _ad_envrn

.set gl_rbuf,0x6e52
.global gl_rbuf

.set _pglobal,0x6e6c
.global _pglobal

.set _sh_gem,0x6f0c
.global _sh_gem

.set gl_rlen,0x6f14
.global gl_rlen

.set _gl_tcolor,0x6f26
.global _gl_tcolor

.set _g_wsend,0x6fee
.global _g_wsend

.set elinkoff,0x6ff8
.global elinkoff

.set _sh_doexec,0x7006
.global _sh_doexec

.set ad_sysglo,0x700a
.global ad_sysglo

.set ram_unknown69,0x702a
.global ram_unknown69

.set gl_btrue,0x7040
.global gl_btrue

.set ram_unknown75,0x7052
.global ram_unknown75

.set ram_unknown70,0x705c
.global ram_unknown70

.set ram_unknown72,0x7060
.global ram_unknown72

.set wind_spb,0x706a
.global wind_spb

.set _sh_isgem,0x708a
.global _sh_isgem

.set drawstk,0x70bc
.global drawstk

.set ram_unknown84,0x70e8
.global ram_unknown84

.set _gl_ws,0x70ea
.global _gl_ws

.set _intin,0x715e
.global _intin

.set cda,0x725e
.global cda

.set _DOS_ERR,0x742a
.global _DOS_ERR

.set ptsin,0x742c
.global ptsin

.set ram_unknown82,0x7454
.global ram_unknown82

.set ram_unknown85,0x7456
.global ram_unknown85

.set ram_unknown90,0x745a
.global ram_unknown90

.set ram_unknown40,0x776c
.global ram_unknown40

.set eul,0xa782
.global eul

.set ram_unknown43,0xa788
.global ram_unknown43

.set ram_unknown83,0xa78c
.global ram_unknown83

.set ram_unknown91,0xa78e
.global ram_unknown91

/* rlr is a pointer to pd structure. */
.set rlr,0xa792
.global rlr

.set evx,0xa79a
.global evx

.set ram_unknown41,0xa7b6
.global ram_unknown41

.set ram_unknown42,0xa7ba
.global ram_unknown42

.set ram_unknown92,0xa7be
.global ram_unknown92

.set ram_unknown32,0xa7c4
.global ram_unknown32

.set no_aes,0xa7ca
.global no_aes

.set ram_unknown71,0xa7cc
.global ram_unknown71

.set er_num,0xa81a
.global er_num

.set curpid,0xa81c
.global curpid

/* { int16_t sy_tas; PD *sy_owner; EVB *sy_wait } */
.set ram_unknown81,0xa820
.global ram_unknown81

/* Not to be confused with contrl, two different variables */
.set _contrl,0xa828
.global _contrl

.set ram_unknown65,0xa832
.global ram_unknown65

.set ram_unknown64,0xa834
.global ram_unknown64


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
.set video_baseh,0xffff8200                 /* -32254 */
.set video_basem,0xffff8202                 /* -32256 */
.set shifter_sync_mode,0xffff820a           /* -32246 */
.set palette,0xffff8240                     /* -32192 */
.set palette_24_bit,0xff8240
.set video_res,0xffff8260                   /* -32160 */

/* Some of these are the same, but one's for read and one's for write */
.set dma_data_register,0xffff8604           /* R */
.set dma_sector_count,0xffff8604            /* W */
.set dma_status,0xffff8606                  /* R */
.set dma_mode_control,0xffff8606            /* W */
.set dma_pointer_high,0xffff8608            /* -31222 */
.set dma_pointer_mid,0xffff860a             /* -31220 */
.set dma_pointer_low,0xffff860c             /* -31218 */

.set psg,0xffff8800
.set blitter_halftone_ram,0x8a00            /* -30208 */
.set mfp_pp,0xfffffa01                      /* -1536 */
.set mfp_timerbc,0xfffffa1a
.set mfp_timerb,0xfffffa20

.set kbd_acia_control,0xfffffc00
.set kbd_acia_data,0xfffffc02
.set midi_acia_control,0xfffffc04           /* -1020 */
.set midi_acia_data,0xfffffc06

.global memctrl
.global video_baseh
.global video_basem
.global shifter_sync_mode
.global palette
.global palette_24_bit
.global video_res
.global dma_data_register
.global dma_sector_count
.global dma_status
.global dma_mode_control
.global dma_pointer_high
.global dma_pointer_mid
.global dma_pointer_low
.global psg
.global blitter_halftone_ram
.global mfp_pp
.global mfp_timerbc
.global mfp_timerb
.global kbd_acia_control
.global kbd_acia_data
.global midi_acia_control
.global midi_acia_data

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

/* BIOS errors */
.set E_ERR,-1
.global E_ERR
.set E_READF,-11
.global E_READF

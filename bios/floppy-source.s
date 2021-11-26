.section .text


addr_ef0:
_flopini:
.global _flopini
  lea ram_unknown128,%a1
  tstw %sp@(12)
  beqs addr_f02
  lea ram_unknown129,%a1
addr_f02:
  movew seekrate,%a1@(2)
  moveq #-1,%d0
  .short 0x4269,0                         /* clrw %a1@(0) */
  bsrw addr_13dc
  bsrw addr_159c
  .short 0x337c,-256,0                    /* movew #-256,%a1@(0) */
  bsrw addr_1528
  beqs addr_f30
  moveq #10,%d7
  bsrw addr_14b6
  bnes addr_f34
  bsrw addr_1528
addr_f30:
  beqw addr_146a
addr_f34:
  braw flopfail


/* int16_t Floprd(void *buf, int32_t filler, int16_t devno, int16_t sectno, int16_t trackno, int16_t sideno, int16_t count); */
addr_f38:
floprd:
.global floprd
  bsrw fdchange
  moveq #E_READF,%d0                      /* set default error# E_READF */
  bsrw floplock
addr_f42:
  bsrw select
  bsrw go2track
  bnew addr_fd0
addr_f4e:
  movew #E_ERR,fd_curerr                  /* set general error# E_ERR */
  movew #144,%fp@                         /* toggle DMA data direction */
  movew #400,%fp@                         /* toggle DMA data direction */
  movew #144,%fp@                         /* leave hardware in READ state */
  movew #1,dma_sector_count               /* set sector count register */
  movew #128,%fp@                         /* startup 1770 "read sector" command */
  movew #128,%d7                          /* (read single) */
  bsrw wrfdcd7
  movel #0x40000,%d7
/* --- Wait for read completion: */
addr_f7c:
  btst #5,%a5@(mfp_pp)                    /* 1770 done yet? */
  beqs addr_f94                           /* (yes) */
  subql #1,%d7
  bnes addr_f7c
/* ---- check status after read */
  movew #-2,%a5@(fd_curerr)               /* set "timeout" error */
  bsrw fdcreset                           /* (clobber 1770) */
  bras addr_fd0                           /* (go retry) */
/* --- check status after read: */
addr_f94:
  movew #144,%fp@                         /* examine DMA status register */
  movew %fp@,%d0
  btst #0,%d0                             /* bit zero inidcates DMA ERROR */
  beqs addr_fd0                           /* (when its zero -- retry) */
  movew #128,%fp@                         /* examine 1770 status register */
  bsrw rdfdcd0
  andb #28,%d0														/* check for RNF, checksum, lost-data */
  bnes addr_fce                           /* (bail on error) */
  movew #2,%a5@(fd_retry)                 /* reset retry count for next sector */
  addqw #1,%a5@(fd_sect)                  /* advance sector # */
  addil #512,%a5@(fd_buffer)              /* advance buffer by 512 bytes */
  subqw #1,%a5@(fd_scount)                /* decrement sector count */
  beqw flopok                             /* (done) */
  bsrw addr_15c4
  bras addr_f4e
addr_fce:
	bsrs fdcerr                             /* set error# from 1770 bits */
addr_fd0:
  cmpiw #1,%a5@(fd_retry)                 /* are we on the "middlemost" retry? */
  bnes addr_fdc
  bsrw addr_14ce                          /* yes, home and reseek the head */
addr_fdc:
  subqw #1,%a5@(fd_retry)                 /* drop retry count */
  bplw addr_f42                           /* (continue of any retries left) */
  braw flopfail                           /* fail when we run out of patience */

/*
 * err_bits - set "curr_err" according to 1770 error status
 * Passed:       d0 = 1770 status
 * Returns:      curr_err, containing current error number
 */
addr_fe8:
fdcerr:
  moveq #-13,%d1
  btst #6,%d0
  bnes addr_1004
  moveq #-8,%d1
  btst #4,%d0
  bnes addr_1004
  moveq #-4,%d1
  btst #3,%d0
  bnes addr_1004
  movew %a5@(ram_unknown88),%d1
addr_1004:
  movew %d1,%a5@(fd_curerr)
	rts
  
addr_100a:
flopwr:
.global flopwr
  bsrw addr_1640
  moveq #-10,%d0
  bsrw addr_13dc
  movew %a5@(fd_sect),%d0
  subqw #1,%d0
  orw %a5@(fd_curtrack),%d0
  orw %a5@(fd_side),%d0
  bnes addr_102a
  moveq #2,%d0
  bsrw addr_1682
addr_102a:
  bsrw addr_159c
  bsrw addr_1502
  bnew addr_10b6
addr_1036:
  movew #-1,%a5@(fd_curerr)
  movew #400,%fp@
  movew #144,%fp@
  movew #400,%fp@
  movew #1,%d7
  bsrw addr_1612
  movew #384,%fp@
  movew #160,%d7
  bsrw addr_1612
  movel #262144,%d7
addr_1062:
  btst #5,%a5@(mfp_pp)
  beqs addr_1074
  subql #1,%d7
  bnes addr_1062
  bsrw addr_1582
  bras addr_10ae
addr_1074:
  movew #384,%fp@
  bsrw addr_1626
  bsrw addr_fe8
  btst #6,%d0
  bnew flopfail
  andb #92,%d0
  bnes addr_10ae
  movew #2,%a5@(fd_retry)
  addqw #1,%a5@(fd_sect)
  addil #512,%a5@(fd_buffer)
  subqw #1,%a5@(fd_scount)
  beqw addr_146a
  bsrw addr_15c4
  bras addr_1036
addr_10ae:
  cmpiw #1,%a5@(fd_retry)
  bnes addr_10ba
addr_10b6:
  bsrw addr_14ce
addr_10ba:
  subqw #1,%a5@(fd_retry)
  bplw addr_102a
  braw flopfail

addr_10c6:
flopfmt:
.global flopfmt
  cmpil #0x87654321,%sp@(22)              /* Look for magic number */
  bnew flopfail
  bsrw fdchange
  moveq #-1,%d0                           /* Default return value */
  bsrw floplock
  bsrw select
  movew %sp@(14),%a5@(fd_spt)
  movew %sp@(20),%a5@(fd_interlv)
  movew %sp@(26),%a5@(fd_virgin)
  movel %sp@(8),%a5@(fd_secmap)
  moveq #2,%d0                            /* 2 = MEDIACHANGE */
  bsrw setdchg
  bsrw hardseek
  bnew flopfail
  .short 0x336d,fd_curtrack,0             /* movew %a5@(fd_curtrack),%a1@(0) */
  movew #-1,%a5@(fd_curerr)
  bsrs fmtrack
  bnew flopfail
  movew %a5@(fd_spt),%a5@(fd_scount)
  movew #1,%a5@(fd_sect)                  /* Starting sector 1 */
  bsrw verify1
  moveal %a5@(fd_buffer),%a2
  tstw %a2@
  beqw flopok
  movew #-16,%a5@(fd_curerr)
  braw flopfail
addr_113c:
fmtrack:
  movew #-10,%a5@(ram_unknown88)          /* default error E_WRITF */
  moveal %a5@(fd_buffer),%a2
  moveal %a5@(fd_secmap),%a3
  movew #60 - 1,%d1                       /* 60 * 0x4e track lead-in */
  moveb #0x4e,%d0
  bsrw wmult
  clrw %d3                                /* interleave index - table start */
  tstw %a5@(fd_interlv)                   /* interleave < 0 */
  bmiw addr_124c
  movew #1,%d3                            /* first sector = 1 */
addr_1164:
  movew %d3,%d4                           /* d4 = starting sector (this pass) */
addr_1166:
  movew #12 - 1,%d1                       /* 12 * 0x00 */
  clrb %d0
  bsrw wmult
  movew #3 - 1,%d1                        /* 3 * 0xf5 */
  .short 0x103c,0x00f5                    /* moveb #-11,%d0 */
  bsrw wmult
  .short 0x14fc,0x00fe                    /* moveb #-2,%a2@+ - 0xfe - address mark info */
  moveb %a5@(fd_curtrack + 1),%a2@+       /* Track */
  moveb %a5@(fd_side + 1),%a2@+           /* Side */
  moveb %d4,%a2@+                         /* Sector */
  moveb #2,%a2@+                          /* Sector size 512 */
  .short 0x14fc,0x00f7                    /* moveb #-9,%a2@+ - checksum 0xf7 */
  movew #21,%d1
  moveb #78,%d0
  bsrw wmult
  movew #11,%d1
  clrb %d0
  bsrw wmult
  movew #2,%d1
  .short 0x103c,0x00f5                    /* moveb #-11,%d0 */
  bsrw wmult
  .short 0x14fc,0x00fb                    /* moveb #-5,%a2@+ */
  movew #255,%d1
addr_11bc:
  moveb %a5@(fd_virgin),%a2@+
  moveb %a5@(ram_unknown1),%a2@+
  dbf %d1,addr_11bc
  .short 0x14fc,0x00f7                    /* moveb #-9,%a2@+ */
  movew #39,%d1
  moveb #78,%d0
  bsrw wmult
  tstw %a5@(fd_interlv)
  bmis addr_124c
  addw %a5@(fd_interlv),%d4
  cmpw %a5@(fd_spt),%d4
  blew addr_1166
  addqw #1,%d3
  cmpw %a5@(fd_interlv),%d3
  blew addr_1164
addr_11f4:
  movew #1400,%d1
  moveb #78,%d0
  bsrw wmult
  moveb %a5@(fd_buffer + 3),%a5@(dma_pointer_low + 1)
  moveb %a5@(fd_buffer + 2),%a5@(dma_pointer_mid + 1)
  moveb %a5@(fd_buffer + 1),%a5@(dma_pointer_high + 1)
  movew #400,%fp@                         /* Toggle R/W flag */
  movew #144,%fp@                         /* Toggle R/W flag */
  movew #400,%fp@                         /* Select sector-count register */
  movew #31,%d7                           /* (absurd sector count) */
  bsrw wrfdcd7
  movew #384,%fp@                         /* Select 1770 cmd register */
  movew #240,%d7                          /* Write format_track command */
  bsrw wrfdcd7
  movel #262144,%d7
addr_1238:
  btst #5,%a5@(mfp_pp)                    /* Is 1770 done? */
  beqs addr_1260                          /* (yes) */
  subql #1,%d7
  bnes addr_1238
  bsrw fdcreset
addr_1248:
  moveq #1,%d7                            /* return error */
  rts
addr_124c:
  cmpw %a5@(fd_spt),%d3                   /* Last sector reached? */
  beqs addr_11f4                          /* Yes, end of track */
  movew %d3,%d6
  addw %d6,%d6
  movew %a3@(0,%d6:w),%d4                 /* Pick next sector number from table */
  addqw #1,%d3
  braw addr_1166
addr_1260:
  movew #400,%fp@                         /* Check DMA status bit */
  movew %fp@,%d0
  btst #0,%d0                             /* If zero --> DMA error */
  beqs addr_1248
  movew #384,%fp@                         /* Get 1770 status */
  bsrw rdfdcd0                            /* Check for write protect and lost data */
  bsrw fdcerr                             /* Return error (NE) on 1770 error */
  andb #68,%d0
	rts
addr_127e:
wmult:
  moveb %d0,%a2@+                         /* record byte in proto buffer */
  dbf %d1,wmult                           /* (do it again) */
	rts

addr_1286:
flopver:
.global flopver
  bsrw fdchange
  moveq #-11,%d0
  bsrw floplock
  bsrw select
  bsrw go2track
  bnew flopfail
  bsrs verify1
  braw flopok
addr_12a2:
verify1:
  movew #-11,%a5@(ram_unknown88)
  moveal %a5@(fd_buffer),%a2
  addil #512,%a5@(fd_buffer)
addr_12b4:
  movew #2,%a5@(fd_retry)
  movew #132,%fp@
  movew %a5@(fd_sect),%d7
  bsrw addr_1612
addr_12c6:
  moveb %a5@(fd_buffer + 3),%a5@(dma_pointer_low + 1)
  moveb %a5@(fd_buffer + 2),%a5@(dma_pointer_mid + 1)
  moveb %a5@(fd_buffer + 1),%a5@(dma_pointer_high + 1)
  movew #144,%fp@
  movew #400,%fp@
  movew #144,%fp@
  movew #1,%d7
  bsrw addr_1612
  movew #128,%fp@
  movew #128,%d7
  bsrw addr_1612
  movel #262144,%d7
addr_12fe:
  btst #5,%a5@(mfp_pp)
  beqs addr_1310
  subql #1,%d7
  bnes addr_12fe
  bsrw addr_1582
  bras addr_1346
addr_1310:
  movew #144,%fp@
  movew %fp@,%d0
  btst #0,%d0
  beqs addr_1346
  movew #128,%fp@
  bsrw addr_1626
  bsrw addr_fe8
  andb #28,%d0
  bnes addr_1346
addr_132e:
  addqw #1,%a5@(fd_sect)
  subqw #1,%a5@(fd_scount)
  bnew addr_12b4
  subil #512,%a5@(fd_buffer)
  clrw %a2@
  rts
addr_1346:
  cmpiw #1,%a5@(fd_retry)
  bnes addr_1352
  bsrw addr_14ce
addr_1352:
  subqw #1,%a5@(fd_retry)
  bplw addr_12c6
  movew %a5@(fd_sect),%a2@+
  bras addr_132e

addr_1360:
.global addr_1360
  subal %a5,%a5
  lea %a5@(dma_mode_control),%fp
  st %a5@(ram_unknown161)
  tstw %a5@(flock)
  bnes addr_13da
  movel %a5@(_frlock),%d0
  moveb %d0,%d1
  andb #7,%d1
  bnes addr_13b0
  movew #128,%fp@
  lsrb #3,%d0
  andw #1,%d0
  lea %a5@(ram_unknown162),%a0
  addaw %d0,%a0
  cmpw %a5@(_nflops),%d0
  bnes addr_1394
  clrw %d0
addr_1394:
  addqb #1,%d0
  lslb #1,%d0
  eorib #7,%d0
  bsrw addr_15e2
  movew %a5@(dma_data_register),%d0
  btst #6,%d0
  sne %a0@
  moveb %d2,%d0
  bsrw addr_15e2
addr_13b0:
  movew %a5@(ram_unknown162),%d0
  orw %d0,%a5@(ram_unknown158)
  tstw %a5@(ram_unknown164)
  bnes addr_13d6
  bsrw addr_1626
  btst #7,%d0
  bnes addr_13da
  moveb #7,%d0
  bsrw addr_15e2
  movew #1,%a5@(ram_unknown164)
addr_13d6:
  clrw %a5@(ram_unknown161)
addr_13da:
  rts

addr_13dc:
floplock:
.global floplock
  moveml %d3-%d7/%a3-%fp,ram_unknown160
  subal %a5,%a5
  lea %a5@(dma_mode_control),%fp
  st %a5@(ram_unknown161)
  movew %d0,%a5@(ram_unknown88)
  movew %d0,%a5@(fd_curerr)
  movew #1,%a5@(flock)
  movel %sp@(8),%a5@(fd_buffer)
  movew %sp@(16),%a5@(ram_unknown130)
  movew %sp@(18),%a5@(fd_sect)
  movew %sp@(20),%a5@(fd_curtrack)
  movew %sp@(22),%a5@(fd_side)
  movew %sp@(24),%a5@(fd_scount)
  movew #2,%a5@(fd_retry)
  lea %a5@(ram_unknown128),%a1
  tstw %a5@(ram_unknown130)
  beqs addr_1434
  lea %a5@(ram_unknown129),%a1
addr_1434:
  .short 0x4a69,0                         /* tstw %a1@(0) */
  bpls addr_145a
  bsrw select
  .short 0x4269,0                         /* clrw %a1@(0) */
  bsrw addr_1528
  beqs addr_145a
  moveq #10,%d7
  bsrb addr_14b6
  bnes addr_1454
  bsrw addr_1528
  beqs addr_145a
addr_1454:
  .short 0x337c,-256,0                    /* movew #-256,%a1@(0) */
addr_145a:
  rts

addr_145c:
flopfail:
  moveq #1,%d0
  bsrw addr_1682
  movew %a5@(0xa26),%d0
  extl %d0
  bras addr_146c
addr_146a:
flopok:
  clrl %d0
addr_146c:
  movel %d0,%sp@-
  movew #134,%fp@
  .short 0x3e29,0                         /* movew %a1@(0),%d7 */
  bsrw addr_1612
  movew #16,%d6
  bsrw addr_153e
  movew %a5@(ram_unknown130),%d0
  lslw #2,%d0
  lea %a5@(ram_unknown159),%a0
  movel %a5@(_frlock),%a0@(0,%d0:w)
  cmpiw #1,%a5@(_nflops)
  bnes addr_14a0
  movel %a5@(_frlock),%a0@(4)
addr_14a0:
  movel %sp@+,%d0
  moveml %a5@(ram_unknown160),%d3-%d7/%a3-%fp
  clrw flock
  rts

addr_14b0:
hardseek:
  movew fd_curtrack,%d7
addr_14b6:
  movew #-6,fd_curerr
  movew #134,%fp@
  bsrw addr_1612
  movew #16,%d6
  braw addr_153e
addr_14ce:
  movew #-6,fd_curerr
  bsrb addr_1528
  bnes addr_1526
  .short 0x4269,0                         /* clrw %a1@(0) */
  movew #130,%fp@
  clrw %d7
  bsrw addr_1612
  movew #134,%fp@
  movew #5,%d7
  bsrw addr_1612
  movew #16,%d6
  bsrb addr_153e
  bnes addr_1526
  .short 0x337c,5,0                       /* movew #5,%a1@(0) */
addr_1502:
go2track:
.global go2track
  movew #-6,fd_curerr
  movew #134,%fp@
  movew %a5@(fd_curtrack),%d7
  bsrw addr_1612
  moveq #20,%d6
  bsrb addr_153e
  bnes addr_1526
  .short 0x336d,fd_curtrack,0             /* movew %a5@(fd_curtrack),%a1@(0) */
  andb #24,%d7
addr_1526:
  rts
addr_1528:
  clrw %d6
  bsrb addr_153e
  bnes addr_153c
  btst #2,%d7
  eorib #4,%ccr
  bnes addr_153c
  .short 0x4269,0                         /* clrw %a1@(0) */
addr_153c:
  rts

addr_153e:
flopcmds:
  movew %a1@(2),%d0
  andb #3,%d0
  orb %d0,%d6
  movel #0x40000,%d7
  movew #128,%fp@
  bsrw addr_1626
  btst #7,%d0
  bnes addr_1562
  movel #0x60000,%d7
addr_1562:
  bsrw addr_1608
addr_1566:
  subql #1,%d7
  beqs addr_157c
  btst #5,mfp_pp
  bnes addr_1566
  bsrw addr_161c
  clrw %d6
  rts
addr_157c:
  bsrb addr_1582
  moveq #1,%d6
  rts

addr_1582:
fdcreset:
.global fdcreset
  movew #128,%fp@
  movew #208,%d7
  bsrw addr_1612
  movew #15,%d7
addr_1592:
  dbf %d7,addr_1592
  bsrw addr_161c
  rts

addr_159c:
select:
.global select
  clrw %a5@(ram_unknown164)
  movew %a5@(ram_unknown130),%d0
  addqb #1,%d0
  lslb #1,%d0
  orw %a5@(fd_side),%d0
  eorib #7,%d0
  andb #7,%d0
  bsrb addr_15e2
  movew #130,%fp@
  .short 0x3e29,0                         /* movew %a1@(0),%d7 */
  bsrb addr_1612
  clrb %a5@(ram_unknown165)
addr_15c4:
  movew #132,%fp@
  movew %a5@(fd_sect),%d7
  bsrb addr_1612
  moveb %a5@(fd_buffer + 3),%a5@(dma_pointer_low + 1)
  moveb %a5@(fd_buffer + 2),%a5@(dma_pointer_mid + 1)
  moveb %a5@(fd_buffer + 1),%a5@(dma_pointer_high + 1)
  rts

addr_15e2:
setporta:
  movew %sr,%sp@-
  oriw #1792,%sr
  moveb #14,psg
  moveb psg,%d1
  moveb %d1,%d2
  andb #-8,%d1
  orb %d0,%d1
  moveb %d1,psg_write_data
  movew %sp@+,%sr
  rts

addr_1608:
  bsrb addr_162e
  movew %d6,dma_sector_count
  bras addr_162e

addr_1612:
wrfdcd7:
.global wrfdcd7
  bsrb addr_162e
  movew %d7,dma_sector_count
  bras addr_162e

addr_161c:
  bsrb addr_162e
  movew dma_sector_count,%d7
  bras addr_162e

addr_1626:
rdfdcd0:
.global rdfdcd0
  bsrb addr_162e
  movew dma_data_register,%d0
addr_162e:
  movew %sr,%sp@-
  movew %d7,%sp@-
  movew #32,%d7
addr_1636:
  dbf %d7,addr_1636
  movew %sp@+,%d7
  movew %sp@+,%sr
  rts

/* test for disk change */
addr_1640:
fdchange:
.global fdchange
  cmpiw #1,_nflops
  bnes addr_1680
  movew %sp@(16),%d0
  cmpw ram_unknown157,%d0
  beqs addr_167c
  movew %d0,%sp@-
  movew #-17,%sp@-
  bsrw callcrit
  addqw #4,%sp
  movew #-1,ram_unknown158
  lea ram_unknown159,%a0
  clrl %a0@+
  clrl %a0@
  movew %sp@(16),ram_unknown157
addr_167c:
  clrw %sp@(16)
addr_1680:
  rts

addr_1682:
setdchg:
  lea %a5@(ram_unknown131),%a0
  moveb %d0,%sp@-
  movew %a5@(ram_unknown130),%d0
  moveb %sp@+,%a0@(0,%d0:w)
	rts

addr_1692:
floprate:
.global floprate
  lea ram_unknown128,%a0
  tstw %sp@(4)
  beqs addr_16a4
  lea ram_unknown129,%a0
addr_16a4:
  movew %a0@(2),%d0
  movew %sp@(6),%d1
  cmpw #-1,%d1
  beqs addr_16b6
  movew %d1,%a0@(2)
addr_16b6:
  extl %d0
  rts  
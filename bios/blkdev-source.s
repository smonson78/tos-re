.text

/*
 * default function for system variable hdv_init
 */
addr_16ba:
_bhdv_init:
.global _bhdv_init
  linkw %fp,#-16
  movel #82,ram_unknown167
  clrw %d0
  movew %d0,_nflops
  movew %d0,ram_unknown157
  movew %d0,%fp@(-2)
  bras addr_1726
addr_16dc:
  moveal #ram_unknown131,%a0
  moveaw %fp@(-2),%a1
  addal %a1,%a0
  clrb %a0@
  clrl %sp@-
  clrw %sp@-
  movew %fp@(-2),%sp@-
  clrl %sp@-
  clrl %sp@-
  jsr _flopini
  addaw #16,%sp
  movew %d0,%sp@-
  moveaw %fp@(-2),%a0
  addal %a0,%a0
  addal #ram_unknown168,%a0
  movew %sp@+,%a0@
  bnes addr_1722
  addqw #1,_nflops
  oril #3,_drvbits
addr_1722:
  addqw #1,%fp@(-2)
addr_1726:
  cmpiw #2,%fp@(-2)
  blts addr_16dc
  unlk %fp
  rts

/*
 * XBIOS #11 - Dbmsg - Output debug message
 *
 * Available Only if a resident debugger was loaded,
 * which supports this call. The only debugger that currently
 * supports this call is the Atari debugger.
 * Was never implemented in any offical ROM version.
 */
addr_1732:
_dbmsg:
.global _dbmsg
  linkw %fp,#-4
  clrl %d0
  unlk %fp
	rts
	
/*
 * default function for system variable hdv_bpb
 */
addr_173c:
_bhdv_getbpb:
.global _bhdv_getbpb
  linkw %fp,#-12
  moveml %d5-%d7/%a4-%a5,%sp@-
  cmpiw #2,%fp@(8)
  blts addr_1752
  clrl %d0
  braw addr_18e2
addr_1752:
  movew %fp@(8),%d0
  aslw #5,%d0
  extl %d0
  moveal %d0,%a5
  addal #ram_unknown177,%a5
  moveal %a5,%a4
addr_1764:
  movew #1,%sp@
  clrl %sp@-
  movew #1,%sp@-
  movew %fp@(8),%sp@-
  clrl %sp@-
  movel #disk_buffer,%sp@-
  .short 0x4eb9                           /* jsr floprd */
  .long floprd
  addaw #16,%sp
  movel %d0,%fp@(-12)
  tstl %fp@(-12)
  bges addr_17a4
  movew %fp@(8),%sp@
  movel %fp@(-12),%d0
  movew %d0,%sp@-
  .short 0x4eb9                           /* jsr callcrit */
  .long callcrit
  addql #2,%sp
  movel %d0,%fp@(-12)
addr_17a4:
  movel %fp@(-12),%d0
  cmpl #65536,%d0
  beqs addr_1764
  tstl %fp@(-12)
  bges addr_17bc
  clrl %d0
  braw addr_18e2
addr_17bc:
  movel #ram_unknown176,%sp@
  bsrw addr_1e5e
  movew %d0,%d7
  bles addr_17d8
  moveb ram_unknown175,%d6
  extw %d6
  andw #255,%d6
  bgts addr_17de
addr_17d8:
  clrl %d0
  braw addr_18e2
addr_17de:
  movew %d7,%a4@
  movew %d6,%a4@(2)
  movel #ram_unknown174,%sp@
  bsrw addr_1e5e
  movew %d0,%a4@(8)
  movew %a4@(8),%d0
  addqw #1,%d0
  movew %d0,%a4@(10)
  movew %a4@,%d0
  mulsw %a4@(2),%d0
  movew %d0,%a4@(4)
  movel #ram_unknown173,%sp@
  bsrw addr_1e5e
  aslw #5,%d0
  extl %d0
  divsw %a4@,%d0
  movew %d0,%a4@(6)
  movew %a4@(10),%d0
  addw %a4@(6),%d0
  addw %a4@(8),%d0
  movew %d0,%a4@(12)
  movel #ram_unknown169,%sp@
  bsrw addr_1e5e
  subw %a4@(12),%d0
  extl %d0
  divsw %a4@(2),%d0
  movew %d0,%a4@(14)
  clrw %a4@(16)
  movel #ram_unknown172,%sp@
  bsrw addr_1e5e
  movew %d0,%a5@(20)
  movel #ram_unknown171,%sp@
  bsrw addr_1e5e
  movew %d0,%a5@(24)
  movew %a5@(20),%d0
  mulsw %a5@(24),%d0
  movew %d0,%a5@(22)
  movel #ram_unknown170,%sp@
  bsrw addr_1e5e
  movew %d0,%a5@(26)
  movel #ram_unknown169,%sp@
  bsrw addr_1e5e
  extl %d0
  divsw %a5@(22),%d0
  movew %d0,%a5@(18)
  clrw %d7
  bras addr_18aa
addr_1894:
  moveal %a5,%a0
  moveaw %d7,%a1
  addal %a1,%a0
  moveaw %d7,%a1
  addal #disk_buffer,%a1
  moveb %a1@(8),%a0@(28)
  addqw #1,%d7
addr_18aa:
  cmpw #3,%d7
  blts addr_1894
  moveal #ram_unknown158,%a0
  moveaw %fp@(8),%a1
  addal %a1,%a0
  moveal #ram_unknown162,%a1
  moveaw %fp@(8),%a2
  addal %a2,%a1
  moveb %a1@,%a0@
  beqs addr_18d0
  moveq #1,%d0
  bras addr_18d2
addr_18d0:
  clrw %d0
addr_18d2:
  moveal #ram_unknown131,%a1
  moveaw %fp@(8),%a2
  addal %a2,%a1
  moveb %d0,%a1@
  movel %a5,%d0
addr_18e2:
  tstl %sp@+
  moveml %sp@+,%d6-%d7/%a4-%a5
  unlk %fp
  rts

/*
 * default function for system variable hdv_mediach
 */
addr_18ec:
_bhdv_mediach:
.global _bhdv_mediach
  linkw %fp,#0
  moveml %d6-%d7/%a5,%sp@-
  cmpiw #2,%fp@(8)
  blts addr_1900
  moveq #-15,%d0
  bras addr_194c
addr_1900:
  movew %fp@(8),%d7
  moveaw %d7,%a5
  addal #ram_unknown131,%a5
  cmpib #2,%a5@
  bnes addr_1916
  moveq #2,%d0
  bras addr_194c
addr_1916:
  moveal #ram_unknown158,%a0
  tstb %a0@(0,%d7:w)
  beqs addr_1926
  moveb #1,%a5@
addr_1926:
  movel _frlock,%d0
  moveaw %d7,%a1
  addal %a1,%a1
  addal %a1,%a1
  addal #ram_unknown159,%a1
  movel %a1@,%d1
  subl %d1,%d0
  cmpl ram_unknown167,%d0
  bges addr_1948
  clrw %d0
  bras addr_194c
addr_1948:
  moveb %a5@,%d0
  extw %d0
addr_194c:
  tstl %sp@+
  moveml %sp@+,%d7/%a5
  unlk %fp
  rts


addr_1956:
_ckmediach:
  linkw %fp,#0
  moveml %d4-%d7/%a5,%sp@-
  movew %fp@(8),%d6
  movew %d6,%d0
  aslw #5,%d0
  extl %d0
  moveal %d0,%a5
  addal #ram_unknown177,%a5
  movew %d6,%sp@
  bsrw _bhdv_mediach
  movew %d0,%d7
  cmpw #2,%d7
  bnes addr_1988
  movew %d7,%d0
  braw addr_1a1a
  braw addr_1a18
addr_1988:
  cmpw #1,%d7
  bnew addr_1a18
addr_1990:
  movew #1,%sp@
  clrl %sp@-
  movew #1,%sp@-
  movew %d6,%sp@-
  clrl %sp@-
  movel #disk_buffer,%sp@-
  jsr floprd
  addaw #16,%sp
  movel %d0,%d5
  tstl %d5
  bges addr_19c4
  movew %d6,%sp@
  movel %d5,%d0
  movew %d0,%sp@-
  .short 0x4eb9                           /* jsr callcrit */
  .long callcrit
  addql #2,%sp
  movel %d0,%d5
addr_19c4:
  cmpl #0x10000,%d5
  beqs addr_1990
  tstl %d5
  bges addr_19d4
  movel %d5,%d0
  bras addr_1a1a
addr_19d4:
  clrw %d7
  bras addr_19f4
addr_19d8:
  moveal #disk_buffer,%a0
  moveb %a0@(8,%d7:w),%d0
  extw %d0
  moveb %a5@(0x1c,%d7:w),%d1
  extw %d1
  cmpw %d1,%d0
  beqs addr_19f2
  moveq #2,%d0
  bras addr_1a1a
addr_19f2:
  addqw #1,%d7
addr_19f4:
  cmpw #3,%d7
  blts addr_19d8
  moveaw %d6,%a0
  addal #ram_unknown158,%a0
  moveaw %d6,%a1
  addal #ram_unknown162,%a1
  moveb %a1@,%a0@
  bnes addr_1a18
  moveaw %d6,%a0
  addal #ram_unknown131,%a0
  clrb %a0@
addr_1a18:
  clrw %d0
addr_1a1a:
  tstl %sp@+
  moveml %sp@+,%d5-%d7/%a5
  unlk %fp
  rts


/*
 * default function for system variable hdv_rw
 */
addr_1a24:
_bhdv_rwabs:
.global _bhdv_rwabs
  linkw %fp,#0
  moveml %d5-%d7,%sp@-
  movew %fp@(18),%d7
  movew %d7,%d0
  cmpw #2,%d0
  blts addr_1a3e
  moveq #-15,%d0
  braw addr_1aa2
addr_1a3e:
  tstw _nflops
  bnes addr_1a4a
  moveq #-2,%d0
  bras addr_1aa2
addr_1a4a:
  tstl %fp@(10)
  bnes addr_1a66
  movew %fp@(14),%d0
  moveal #ram_unknown131,%a1
  moveaw %fp@(18),%a2
  addal %a2,%a1
  moveb %d0,%a1@
  clrl %d0
  bras addr_1aa2
addr_1a66:
  cmpiw #2,%fp@(8)
  bges addr_1a8a
  movew %d7,%sp@
  bsrw addr_1956
  extl %d0
  movel %d0,%d6
  tstl %d6
  beqs addr_1a8a
  cmpl #0x2,%d6
  bnes addr_1a86
  moveq #-14,%d6
addr_1a86:
  movel %d6,%d0
  bras addr_1aa2
addr_1a8a:
  movew %fp@(14),%sp@
  movew %d7,%sp@-
  movew %fp@(16),%sp@-
  movel %fp@(10),%sp@-
  movew %fp@(8),%sp@-
  bsrb addr_1aac
  addaw #0xa,%sp
addr_1aa2:
  tstl %sp@+
  moveml %sp@+,%d6-%d7
  unlk %fp
  rts

addr_1aac:
_dorwabs:
  linkw %fp,#-6
  moveml %d2-%d7/%a5,%sp@-
  movew %fp@(16),%d0
  aslw #5,%d0
  extl %d0
  moveal %d0,%a5
  addal #ram_unknown177,%a5
  btst #0,%fp@(13)
  bnes addr_1ad0
  clrw %d0
  bras addr_1ad2
addr_1ad0:
  moveq #1,%d0
addr_1ad2:
  movew %d0,%fp@(-2)
  tstw %a5@(22)
  bnes addr_1ae6
  moveq #9,%d0
  movew %d0,%a5@(22)
  movew %d0,%a5@(24)
addr_1ae6:
  braw addr_1c62
addr_1aea:
  tstw %fp@(-2)
  beqs addr_1af8
  movel #disk_buffer,%d0
  bras addr_1afc
addr_1af8:
  movel %fp@(10),%d0
addr_1afc:
  movel %d0,%fp@(-6)
  movew %fp@(14),%d6
  extl %d6
  divsw %a5@(22),%d6
  movew %fp@(14),%d4
  extl %d4
  divsw %a5@(22),%d4
  swap %d4
  cmpw %a5@(24),%d4
  bges addr_1b20
  clrw %d5
  bras addr_1b26
addr_1b20:
  moveq #1,%d5
  subw %a5@(24),%d4
addr_1b26:
  tstw %fp@(-2)
  beqs addr_1b30
  moveq #1,%d3
  bras addr_1b48
addr_1b30:
  movew %a5@(24),%d0
  subw %d4,%d0
  cmpw %fp@(18),%d0
  bges addr_1b44
  movew %a5@(24),%d3
  subw %d4,%d3
  bras addr_1b48
addr_1b44:
  movew %fp@(18),%d3
addr_1b48:
  addqw #1,%d4
addr_1b4a:
  btst #0,%fp@(9)
  beqw addr_1bce
  movel %fp@(-6),%d0
  cmpl %fp@(10),%d0
  beqs addr_1b6e
  movel %fp@(-6),%sp@
  movel %fp@(10),%sp@-
  .short 0x4eb9                           /* jsr addr_bb6 */
  .long addr_bb6
  addql #4,%sp
addr_1b6e:
  movew %d3,%sp@
  movew %d5,%sp@-
  movew %d6,%sp@-
  movew %d4,%sp@-
  movew %fp@(16),%sp@-
  clrl %sp@-
  movel %fp@(-6),%sp@-
  .short 0x4eb9                           /* jsr flopwr */
  .long flopwr
  addaw #0x10,%sp
  movel %d0,%d7
  tstl %d7
  bnes addr_1bcc
  tstw _fverify
  beqs addr_1bcc
  movew %d3,%sp@
  movew %d5,%sp@-
  movew %d6,%sp@-
  movew %d4,%sp@-
  movew %fp@(16),%sp@-
  clrl %sp@-
  movel #disk_buffer,%sp@-
  .short 0x4eb9                           /* jsr flopver */
  .long flopver
  addaw #0x10,%sp
  movel %d0,%d7
  tstl %d7
  bnes addr_1bcc
  movel #disk_buffer,%sp@
  bsrw addr_1e5e
  tstw %d0
  beqs addr_1bcc
  moveq #-16,%d7
addr_1bcc:
  bras addr_1c06
addr_1bce:
  movew %d3,%sp@
  movew %d5,%sp@-
  movew %d6,%sp@-
  movew %d4,%sp@-
  movew %fp@(16),%sp@-
  clrl %sp@-
  movel %fp@(-6),%sp@-
  .short 0x4eb9                           /* jsr floprd */
  .long floprd
  addaw #0x10,%sp
  movel %d0,%d7
  movel %fp@(-6),%d0
  cmpl %fp@(10),%d0
  beqs addr_1c06
  movel %fp@(10),%sp@
  movel %fp@(-6),%sp@-
  .short 0x4eb9                           /* jsr addr_bb6 */
  .long addr_bb6
  addql #4,%sp
addr_1c06:
  tstl %d7
  bges addr_1c3c
  movew %fp@(16),%sp@
  movel %d7,%d0
  movew %d0,%sp@-
  .short 0x4eb9                           /* jsr callcrit */
  .long callcrit
  addql #2,%sp
  movel %d0,%d7
  cmpiw #2,%fp@(8)
  bges addr_1c3c
	cmpl #0x10000,%d7
  bnes addr_1c3c
  movew %fp@(16),%sp@
  bsrw addr_1956
  cmpw #0x2,%d0
  bnes addr_1c3c
  moveq #-14,%d7
addr_1c3c:
  cmpl #0x10000,%d7
  beqw addr_1b4a
  tstl %d7
  bges addr_1c4e
  movel %d7,%d0
  bras addr_1c6c
addr_1c4e:
  movew %d3,%d0
  extl %d0
  moveq #9,%d1
  asll %d1,%d0
  addl %d0,%fp@(10)
  addw %d3,%fp@(14)
  subw %d3,%fp@(18)
addr_1c62:
  tstw %fp@(18)
  bnew addr_1aea
  clrl %d0
addr_1c6c:
  tstl %sp@+
  moveml %sp@+,%d3-%d7/%a5
  unlk %fp
  rts

/*
 * XBIOS #17 - Random - Random number generator
 */
addr_1c76:
_random:
.global _random
  linkw %fp,#-4
  tstl rseed
  bnes addr_1c98
  movel _hz_200,%d0
  moveq #16,%d1
  asll %d1,%d0
  orl _hz_200,%d0
  movel %d0,rseed
addr_1c98:
  movel #0xbb40e62d,%sp@-                 /* This is 3141592621, a magic number based on Pi */
  movel rseed,%sp@-
  .short 0x4eb9                           /* jsr addr_9438 */ /* Must be a long multiply? */
  .long addr_9438
  addql #8,%sp
  addql #1,%d0
  movel %d0,rseed
  movel rseed,%d0
  asrl #8,%d0
  andl #0x00ffffff,%d0
  unlk %fp
	rts

  /*
 * default function for system variable hdv_boot
 */
addr_1cc6:
_bhdv_boot:
.global _bhdv_boot
  linkw %fp,#0
  moveml %d6-%d7,%sp@-
  .short 0x4eb9                           /* jsr addr_bd8 */
  .long addr_bd8
  tstw _nflops
  beqs addr_1d12
  moveq #2,%d7
  movew #0x1,%sp@
  clrl %sp@-
  movew #0x1,%sp@-
  clrw %sp@-
  clrl %sp@-
  movel #disk_buffer,%sp@-
  .short 0x4eb9                           /* jsr floprd */
  .long floprd
  addaw #0x10,%sp
  tstl %d0
  bnes addr_1d04
  clrw %d7
  bras addr_1d10
addr_1d04:
  tstb ram_unknown162
  bnes addr_1d10
  moveq #3,%d0
  bras addr_1d38
addr_1d10:
  bras addr_1d14
addr_1d12:
  moveq #1,%d7
addr_1d14:
  tstw %d7
  beqs addr_1d1c
  movew %d7,%d0
  bras addr_1d38
addr_1d1c:
  movew #256,%sp@
  movel #disk_buffer,%sp@-
  bsrw addr_1e2e
  addql #4,%sp
  cmpw #0x1234,%d0
  bnes addr_1d36
  clrw %d0
  bras addr_1d38
addr_1d36:
  moveq #4,%d0
addr_1d38:
  tstl %sp@+
  moveml %sp@+,%d7
  unlk %fp
  rts


/* Generate a standard floppy disk boot sector into a pointed-to buffer */
addr_1d42:
_protobt:
.global _protobt
  linkw %fp,#-6
  moveml %d5-%d7/%a5,%sp@-
  tstw %fp@(18)
  bges addr_1d6e
  movew #256,%sp@
  movel %fp@(8),%sp@-
  bsrw addr_1e2e
  addql #4,%sp
  cmpw #0x1234,%d0
  beqs addr_1d68
  clrw %d0
  bras addr_1d6a
addr_1d68:
  moveq #1,%d0
addr_1d6a:
  movew %d0,%fp@(18)
addr_1d6e:
  tstl %fp@(12)
  blts addr_1db2
  movel %fp@(12),%d0
  cmpl #0xffffff,%d0
  bles addr_1d88
  bsrw _random
  movel %d0,%fp@(12)
addr_1d88:
  clrw %d7
  bras addr_1dac
addr_1d8c:
  movel %fp@(12),%d0
  andl #255,%d0
  moveaw %d7,%a1
  addal %fp@(8),%a1
  moveb %d0,%a1@(8)
  movel %fp@(12),%d0
  asrl #8,%d0
  movel %d0,%fp@(12)
  addqw #1,%d7
addr_1dac:
  cmpw #3,%d7
  blts addr_1d8c
addr_1db2:
  tstw %fp@(16)
  blts addr_1de0
  movew %fp@(16),%d6
  mulsw #19,%d6
  clrw %d7
  bras addr_1dda
addr_1dc4:
  moveaw %d7,%a0
  addal %fp@(8),%a0
  moveaw %d6,%a1
  .short 0xd3fc                           /* addal addr_2820a,%a1 */
  .long addr_2820a
  moveb %a1@,%a0@(11)
  addqw #1,%d6
  addqw #1,%d7
addr_1dda:
  cmpw #19,%d7
  blts addr_1dc4
addr_1de0:
  clrw %fp@(-6)
  movel %fp@(8),%fp@(-4)
  bras addr_1dfa
addr_1dec:
  moveal %fp@(-4),%a0
  movew %a0@,%d0
  addw %d0,%fp@(-6)
  addql #2,%fp@(-4)
addr_1dfa:
  movel %fp@(8),%d0
  addl #0x1fe,%d0
  cmpl %fp@(-4),%d0
  bhis addr_1dec
  movew #0x1234,%d0
  subw %fp@(-6),%d0
  moveal %fp@(-4),%a1
  movew %d0,%a1@
  tstw %fp@(18)
  bnes addr_1e24
  moveal %fp@(-4),%a0
  addqw #1,%a0@
addr_1e24:
  tstl %sp@+
  moveml %sp@+,%d6-%d7/%a5
  unlk %fp
  rts

addr_1e2e:
_sectsum:
  linkw %fp,#0
  moveml %d6-%d7,%sp@-
  clrw %d7
  bras addr_1e46
addr_1e3a:
  moveal %fp@(8),%a0
  movew %a0@,%d0
  addw %d0,%d7
  addql #2,%fp@(8)
addr_1e46:
  movew %fp@(12),%d0
  subqw #1,%fp@(12)
  tstw %d0
  bnes addr_1e3a
  movew %d7,%d0
  tstl %sp@+
  moveml %sp@+,%d7
  unlk %fp
  rts


addr_1e5e:
_getiword:
  linkw %fp,#-4
  moveal %fp@(8),%a0
  moveb %a0@(1),%d0
  extw %d0
  andw #255,%d0
  aslw #8,%d0
  moveal %fp@(8),%a1
  moveb %a1@,%d1
  extw %d1
  andw #255,%d1
  orw %d1,%d0
  unlk %fp
  rts
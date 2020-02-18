#include <stdint.h>

extern void debug_add(char c);

char hexdigits[] = "0123456789abcdef";

void debug_add_word(uint16_t val) {
	if (val == 0) {
		debug_add('0');
	} else {
		do {
            debug_add(hexdigits[(val & 0xf000) >> 12]);
            val <<= 4;
		} while (val != 0);
	}
}
	
/*

   0:	4e56 fffc      	linkw %fp,#-4
   4:	202e 0008      	movel %fp@(8),%d0
   8:	3000           	movew %d0,%d0
   a:	3d40 fffe      	movew %d0,%fp@(-2)
   e:	4a6e fffe      	tstw %fp@(-2)
  12:	660e           	bnes 22 <debug_add_word+0x22>
  14:	4878 0030      	pea 30 <debug_add_word+0x30>
  18:	4eb9 0000 0000 	jsr 0 <debug_add_word>
  1e:	588f           	addql #4,%sp
  20:	6038           	bras 5a <debug_add_word+0x5a>
  22:	302e fffe      	movew %fp@(-2),%d0
  26:	720c           	moveq #12,%d1
  28:	e268           	lsrw %d1,%d0
  2a:	3000           	movew %d0,%d0
  2c:	0280 0000 ffff 	andil #65535,%d0
  32:	41f9 0000 0000 	lea 0 <debug_add_word>,%a0
  38:	1030 0800      	moveb %a0@(0000000000000000,%d0:l),%d0
  3c:	4880           	extw %d0
  3e:	3040           	moveaw %d0,%a0
  40:	2f08           	movel %a0,%sp@-
  42:	4eb9 0000 0000 	jsr 0 <debug_add_word>
  48:	588f           	addql #4,%sp
  4a:	302e fffe      	movew %fp@(-2),%d0
  4e:	e948           	lslw #4,%d0
  50:	3d40 fffe      	movew %d0,%fp@(-2)
  54:	4a6e fffe      	tstw %fp@(-2)
  58:	66c8           	bnes 22 <debug_add_word+0x22>
  5a:	4e71           	nop
  5c:	4e5e           	unlk %fp
  5e:	4e75           	rts


*/
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

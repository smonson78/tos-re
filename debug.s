/*
debug_init:
.global debug_init
    movel #0x752019f3,%a5@(memvalid)
    moveb #0,DEBUG_STRING
    movel #DEBUG_STRING,DEBUG_POINTER

    movew #'B',%sp@-
    bsr debug_add
    lea %sp@(2),%sp

    jmp debug_return

debug_add:
    movel %a1,%sp@-
    moveal DEBUG_POINTER,%a1
    moveb %sp@(9),%a1@+
    moveb #0,%a1@
    movel %a1,DEBUG_POINTER
    movel %sp@+,%a1
    rts

hex_digits:
    .ascii "0123456789abcdef"

debug_add_word:
    moveml %d0-%d2/%a0-%a3,%sp@-
	movew %sp@(32),%d2
	beqs debug_add_word_2

    lea hex_digits,%a3

debug_add_word_loop:
	movew %d2,%d0
	moveq #12,%d1
	lsrw %d1,%d0
	andil #65535,%d0
	moveb %a3@(0000000000000000,%d0:l),%d0
	extw %d0
	movew %d0,%sp@-
	jsr debug_add
	addql #2,%sp
	lslw #4,%d2
	bnes debug_add_word_loop

debug_add_word_3:
	moveml %sp@+,%d0-%d2/%a0-%a3
	rts
    
debug_add_word_2:
	moveq #'0',%d0
	movew %d0,%sp@-
	jsr debug_add
	jsr debug_add
	jsr debug_add
	jsr debug_add
	addql #2,%sp
	jmp debug_add_word_3


check_intin:    


    lea contrl,%a1

    movew #'=',%sp@-
    bsr debug_add
    lea %sp@(2),%sp

    movel %a0,%sp@-
    moveal INTIN,%a0
    movew %a0@,%sp@-
    bsr debug_add_word
    lea %sp@(2),%sp
    movel %sp@+,%a0

    jsr _screen


    jmp check_intin_return
check_intin_return:
    */
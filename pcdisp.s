nop
nop
jmp %pc@(test,%d1:b)
nop
nop
test:
	.long 0x01020304

/*
4:   323b 0006       movew %pc@(c <test>,%d0:w),%d1
4:   323b 1006       movew %pc@(c <test>,%d1:w),%d1
4:   323b 7006       movew %pc@(c <test>,%d7:w),%d1
4:   323b 8006       movew %pc@(c <test>,%a0:w),%d1
4:   323b f006       movew %pc@(c <test>,%sp:w),%d1

4:   303b 0006       movew %pc@(c <test>,%d0:w),%d0

		--- widths
4:   4efb 1806       jmp %pc@(c <test>,%d1:l)
4:   4efb 1006       jmp %pc@(c <test>,%d1:w)
		--- no such thing as byte width

*/
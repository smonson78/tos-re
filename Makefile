CC=m68k-elf-gcc
AS=m68k-elf-as
OBJCOPY=m68k-elf-objcopy
OBJDUMP=m68k-elf-objdump

ASFLAGS=-m68000 --no-pad-sections --traditional-format
LDFLAGS=-m68000 -nostdlib

OBJECTS=extern.o \
	boot/start1x.o boot.o tos.o

tos.bin: $(OBJECTS)
	m68k-elf-ld \
		--section-start=.ram=0x0 \
		--section-start=.cart=0xfa0000 \
		--section-start=.text=0xfc0000 \
		-T tos.ld -o tos.elf $(OBJECTS)

	$(OBJCOPY) \
		--remove-section=.ram --remove-section=.cart --remove-section=.mmu \
		--output-target=binary tos.elf tos.bin

	@TMP=$$( cmp tos.bin tos104uk.img | sed -e "s/.*differ: byte \([^ ,]*\).*/\1/ p; d" ); if [ -n "$$TMP" ]; then echo $$TMP | xargs printf "\n*** No match to TOS 1.4 at: 0x%0x\n\n"; fi

%.s: %-source.s
	./preprocess.py $^ >$@

clean:
	$(RM) *.o *.pp tos.elf tos.bin boot/*.o

view:
	$(OBJDUMP) -b binary -m 68000 --adjust-vma=0xfc0000 -D tos.bin | less

desk.rsc: tos104uk.img
	dd if=tos104uk.img of=desk.rsc bs=1 skip=183754 count=11240

stats: tos-source.s boot-source.s boot/start1x-source.s
	@printf "%.2f%% disassembled\n" \
	$$(echo "scale=4; (1-((" $$(cat $^ | grep -c \.short) "* 2) / 195542))*100" | bc)

freenames: extern.s
	@echo `sed -e  "s/.*ram_unknown\([0-9]*\).*/\1/ p; d" $< | sort -rn | head -n 1` + 1 | bc
CC=m68k-elf-gcc
AS=m68k-elf-as
OBJCOPY=m68k-elf-objcopy
OBJDUMP=m68k-elf-objdump

ASFLAGS=-m68000 --no-pad-sections
LDFLAGS=-m68000 -nostdlib

OBJECTS=extern.o boot.o tos.o

tos.bin: $(OBJECTS)
	m68k-elf-ld \
		--section-start=.ram=0x0 \
		--section-start=.cart=0xfa0000 \
		--section-start=.text=0xfc0000 \
		-T tos.ld -o tos.elf $(OBJECTS)

	$(OBJCOPY) \
		--remove-section=.ram --remove-section=.cart --remove-section=.mmu \
		--output-target=binary tos.elf tos.bin
	@cmp tos.bin tos104uk.img || echo "No match to TOS 1.4!"

clean:
	$(RM) *.o tos.elf tos.bin

view:
	$(OBJDUMP) -b binary -m 68000 --adjust-vma=0xfc0000 -D tos.bin | less

desk.rsc: tos104uk.img
	dd if=tos104uk.img of=desk.rsc bs=1 skip=183754 count=11240

# to disassemble from an address:
# dd if=tos104uk.img of=linef.bin bs=1 skip=161872 count=5000
# m68k-elf-objdump -b binary -m 68000 --adjust-vma=0xfe877a -D 2877a.bin | less
#!/usr/bin/python2
import re
import sys
import os

cc = [
    "t", "f", "hi", "ls", "cc", "cs", "ne", "eq", "vc", "vs",
    "pl", "mi", "ge", "lt", "gt", "le"
]
branches = []
for code in cc:
    for suffix in ["s", "w"]:
        branches.append("b" + code + suffix)

#print branches

data = bytearray(file("tos104uk.img", "rb").read())

class Storable:
    def __init__(s, address, binary, mnemonic):
        s.address = address
        s.binary = re.sub("[^0123456789abcdef]", "", binary)
        s.mnemonic = mnemonic
        s.recalc()

    def append_binary(s, more):
        s.binary = s.binary + re.sub("[^0123456789abcdef]", "", more)
        s.recalc()

    def recalc(s):
        s.bytes = []
        binary = s.binary
        while len(binary) >= 2:
            s.bytes.append(int(binary[0:2], 16))
            binary = binary[2:]

    def __str__(s):
        return "%s: %s ; %s" % (s.address, s.binary, s.mnemonic)

s = {}
start = 0x0
end = 0x2ffff

def disassemble(addr):
    # print "--- Reloading at address 0x{:x} ---".format(addr)

    cmd="dd if=tos104uk.img of=temp.bin bs=1 skip={0} 2>/dev/null".format(addr - start)
    #print cmd
    os.system(cmd)
    os.system("m68k-elf-objdump -b binary -m 68000 -D temp.bin --adjust-vma {0} ".format(addr)
        + "| grep -v '\.\.\.' | sed -e '1,7 d' >temp.asm")
    new = 0
    for line in file("temp.asm"):
        line = line.strip()
        if len(line) == 0:
            continue

        result = re.match("^([0-9a-f]*):\t([0-9a-f ]{1,14}) *(.*)", line, re.I)
        if result:
            address = int(result.group(1), 16)
            binary = result.group(2)
            mnemonic = result.group(3).strip()

            if len(mnemonic) == 0:
                last_instruction.append_binary(binary)
                continue

            i = Storable(address, binary, mnemonic)
            if address not in s:
                new += 1
                s[address] = i
            last_instruction = i
            continue

        #print "Unrecognised line:", line
    #print new, "new instructions read;", len(s), "total"

print "/* Finding code... */"

def get_ins(pc):
    ins = s.get(pc, None)
    if ins is None:
        disassemble(pc)
        ins = s.get(pc, None)
        if ins is None:
            print "Nothing found at address 0x{:02x}".format(pc)
            sys.exit(1)
    return ins

def search_func(pc, func):

    while True:
        # Get instruction
        ins = get_ins(pc)

        # print "{:06x}".format(pc), ins.bytes, ins.mnemonic

        # Don't retrace steps
        if pc in func:
            return

        # Add to function
        func[pc] = ins

        # Inspect the instruction
        #result = re.match("^([^ ]*) ([^ ,]*).*", ins.mnemonic, re.I)
        result = re.match("^([^ ]*).*", ins.mnemonic, re.I)
        opcode = result.group(1).strip()

        # Stop at rts/rte
        if opcode in ["rts", "rte"]:
            return

        # Follow branch-always
        if opcode in ["jmp", "bras", "braw"]:
            result = re.match("^([^ ]*) ([^ ,]*).*", ins.mnemonic, re.I)
            target = result.group(2).strip()
            if target[0:2] == "0x":
                # Jump to address if it's a known location inside the file
                addr = int(target[2:], 16)
                if addr >= start and addr < end:
                    ins.mnemonic ="{} {}".format(opcode, "addr_{:x}".format(addr))
                    pc = addr
                    continue
            # Otherwise stop here
            return

        # Follow branches, then continue on
        elif opcode in branches:
            result = re.match("^([^ ]*) ([^ ,]*).*", ins.mnemonic, re.I)
            target = result.group(2)
            if target[0:2] == "0x":
                # Recursively follow within this func if it's a known location inside the file
                addr = int(target[2:], 16)
                if addr >= start and addr < end:
                    ins.mnemonic ="{} {}".format(opcode, "addr_{:x}".format(addr))
                    search_func(addr, func)
                # Then continue on.

        elif opcode == "dbf":
            result = re.match("^([^ ]*) ([^ ,]*),([^ ,]*).*", ins.mnemonic, re.I)
            target = result.group(3)

            if target[0:2] == "0x":
                # Recursively follow within this func if it's a known location inside the file
                addr = int(target[2:], 16)
                if addr >= start and addr < end:
                    ins.mnemonic ="{} {},{}".format(opcode, result.group(2), "addr_{:x}".format(addr))
                    search_func(addr, func)
                # Then continue on.

        # Call subroutines recursively
        elif opcode in ["bsr", "jsr"]:
            result = re.match("^([^ ]*) ([^ ,]*).*", ins.mnemonic, re.I)
            target = result.group(2)
            if target[0:2] == "0x":
                # recurse into subroutine if it's a known location inside the file
                addr = int(target[2:], 16)
                if addr >= start and addr < end:
                    ins.mnemonic ="{} {}".format(opcode, "addr_{:x}".format(addr))
                    search(addr)
                # Then continue on.

        # Get next address
        pc += len(ins.bytes)

funcs = {}
def search(pc):
    print "/* Searching subroutine at 0x{:02X} */".format(pc)

    func = {}
    funcs[pc] = func
    search_func(pc, func)

def print_func(f):
    print "/* Subroutine at 0x{:06x} */".format(f)
    print "sub_{0:06x}:".format(f)
    next_addr = f
    for addr in sorted(funcs[f]):
        ins = funcs[f][addr]
        if addr != next_addr:
            print "/* 0x{0:06x}: */".format(next_addr)
            while next_addr < addr:
                print "\t.short 0x{:02x}{:02x}".format(
                    data[next_addr - start], data[next_addr - start + 1]
                )
                next_addr += 2
            print "/* 0x{0:06x}: */".format(addr)

        print "{:11s} {:50s} /* {} */".format("addr_{:x}:".format(addr), ins.mnemonic, ins.binary)
        next_addr = addr + len(ins.bytes)

#search(0x30)
# special case for initialisation routine because it jumps around using FP
# instead of the stack. That's because it hasn't detected the RAM yet.
#search_func(0x56, funcs[0x30])
#search_func(0xdc, funcs[0x30])
#search_func(0xaa, funcs[0x30])
#search_func(0x118, funcs[0x30])
#search_func(0x126, funcs[0x30])
#search_func(0x134, funcs[0x30])
#search_func(0x3ea, funcs[0x30])

def non_code(a, b):
    if a < b:
        print "/* Non-code area */"
        print ". = 0x{:06x}".format(a)
        while a < b:
            if a % 64 == 0:
                print "/* 0x{:06x}: */".format(a)
            print "\t.short 0x{:02x}{:02x}".format(data[a - start], data[a - start + 1])
            a += 2
        print


# Output code for assembler
print
print ". = 0x{:06x}".format(start)
pc = start
for f in sorted(funcs):
    non_code(pc, f)
    print_func(f)
    last_ins = s[sorted(funcs[f])[-1]]
    pc = last_ins.address + len(last_ins.bytes)
non_code(pc, end)

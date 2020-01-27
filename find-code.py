#!/usr/bin/python2
import re

class Storable:
    def __init__(s, adress, binary, mnemonic):
        s.address = address
        s.binary = binary
        s.mnemonic = mnemonic

    def append_binary(s, more):
        s.binary = s.binary + more

    def __str__(s):
        return "%s: %s ; %s" % (s.address, s.binary, s.mnemonic)

s = {}
for line in file("tos-dasm.txt"):
    line = line.strip()
    if len(line) == 0:
        continue

    result = re.match("^([0-9a-f]*):\t([0-9a-f ]{1,14}) *(.*)", line, re.I)
    if result:
        address = int(result.group(1), 16)
        binary = result.group(2)
        mnemonic = result.group(3)

        if len(mnemonic) == 0:
            last_instruction.append_binary(binary)
            continue

        i = Storable(address, binary, mnemonic)
        s[address] = i
        last_instruction = i

        continue

    print "Unrecognised line:", line
    # print line.strip()

print len(s), "entries read."
print "Finding code..."

funcs = {}
def search(pc):
    print "Searching 0x{:02X}".format(pc)
    ins = s[pc]
    if ins is None:
        print "Nothing found at address 0x{:02X}".format(pc)
        System.exit(1)
    result = re.match("^([^ ]*) ([^ ,]*).*", ins.mnemonic, re.I)
    opcode = result.group(1)
    print ins
    print opcode, result.group(2)
    if opcode is "bsr":
        pass
    else:
        pc = pc + 2

search(0x30)

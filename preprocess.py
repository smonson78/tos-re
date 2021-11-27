#!/usr/bin/python3

import sys

infile = open(sys.argv[1])

# Generate text without multi-line comments
def gen_text_ml_comment():
    comment = False
    for line in infile:
        line = line.rstrip()

        while len(line) > 0:

            if comment:
                # Identify the end of a comment
                temp = line.split("*/", 1)
                if len(temp) > 1:
                    # Continue on, but now back outside the comment
                    comment = False
                    line = temp[1]
                else:
                    line = ''
            else:
                # Identify the start of a comment
                temp = line.split("/*", 1)
                if len(temp) > 1:
                    # Continue on, but now inside the comment
                    comment = True
                    yield temp[0]
                    line = temp[1]
                else:
                    yield line
                    line = ''

def generate_text():
    for line in gen_text_ml_comment():
        # Strip // comments out to end of line
        temp = line.split("//")
        line = temp[0]
        yield line


def getreg(name):
    if name == "%fp":
        return 6
    if name == "%sp":
        return 7
    return int(name[2:])

def get_multibase(text):
    if text[0:2] == "0x":
        return int(text[2:], 16)
    else:
        return int(text)

def signedhex(num):
    if num < 0:
        num = -num
        return 0xffffffff - (num - 1)
    return num

def make_imm_arg(imm, width):
    try:
        imm = get_multibase(imm)
        if width == "b":
            imm = imm & 0xff
            imm = "0x{:04x}".format(signedhex(imm))
        elif width == "w":
            imm = imm & 0xffff
            imm = "0x{:04x}".format(signedhex(imm))
        else:
            imm = "0x{:08x}".format(signedhex(imm))
    except ValueError:
        pass
    return imm

def is_ad_reg(reg):
    if reg[0] != "%":
        return False
    if reg[1:] in ["fp", "sp"]:
        return True
    if len(reg) == 3 and reg[1] in ["a", "d"] and reg[2].isdigit():
        return True
    return False

for text in generate_text():
    stripped = text.strip()

    # Skip labels and directives
    if len(stripped) > 0 and stripped[-1] != ":" and stripped[0] != ".":
        # Check for transforms

        # cmp[bwl] #<imm>, reg
        if len(stripped) > 6 and stripped[0:3] == "cmp" and stripped[3] in ["b", "w", "l"] and stripped[4:6] == " #":

            width = stripped[3]
            imm, reg = stripped[6:].split(",", 1)

            # Build operand
            opcode = 0xb000
            
            # Width - in bits 7+6 (0=b, 1=w, 2=l)
            if width == "w":
                opcode |= 0x0040
            elif width == "l":
                opcode |= 0x0080

            # Other operand - immediate:
            opcode |= 0x003c
            # Add other operand register number
            opcode |= getreg(reg) << 9

            if width == "l":
                text = ".short 0x{:04x}\n.long {} /* {} */".format(opcode, imm, stripped)
            else:
                text = ".short 0x{:04x},{} /* {} */".format(opcode, imm, stripped)

            #print(stripped)
            #print(text)
            #print(imm, reg)

        # add[bwl] #<imm>, reg
        if len(stripped) > 6 and stripped[0:3] == "add" and stripped[3] in ["b", "w", "l"] and stripped[4:6] == " #":

            width = stripped[3]

            imm, reg = stripped[6:].split(",", 1)

            # Build operand
            opcode = 0xd000
            
            # Width - in bits 7+6 (0=b, 1=w, 2=l)
            if width == "w":
                opcode |= 0x0040
            elif width == "l":
                opcode |= 0x0080

            # Other operand - immediate:
            opcode |= 0x003c
            # Add other operand register number
            opcode |= getreg(reg) << 9

            if width == "l":
                text = ".short 0x{:04x}\n.long {} /* {} */".format(opcode, imm, stripped)
            else:
                text = ".short 0x{:04x},{} /* {} */".format(opcode, imm, stripped)

            #print(stripped)
            #print(imm, reg)
            #print(text)
            #print()

        # or[bwl] #<imm>, reg
        if len(stripped) > 5 and stripped[0:2] == "or" and stripped[2] in ["b", "w", "l"] and stripped[3:5] == " #":

            width = stripped[2]

            imm, reg = stripped[5:].split(",", 1)

            # Build operand
            opcode = 0x8000
            
            # Width - in bits 7+6 (0=b, 1=w, 2=l)
            if width == "w":
                opcode |= 0x0040
            elif width == "l":
                opcode |= 0x0080

            # Other operand - immediate:
            opcode |= 0x003c
            # Add other operand register number
            opcode |= getreg(reg) << 9

            if width == "l":
                text = ".short 0x{:04x}\n.long {} /* {} */".format(opcode, imm, stripped)
            else:
                text = ".short 0x{:04x},{} /* {} */".format(opcode, imm, stripped)

            #print(stripped)
            #print(imm, reg)
            #print(text)
            #print()            

        # and[bwl] #<imm>, reg
        if len(stripped) > 6 and stripped[0:3] == "and" and stripped[3] in ["b", "w", "l"] and stripped[4:6] == " #":

            width = stripped[3]

            imm, reg = stripped[6:].split(",", 1)

            imm = make_imm_arg(imm, width)

            # Build operand
            opcode = 0xc000
            
            # Width - in bits 7+6 (0=b, 1=w, 2=l)
            if width == "w":
                opcode |= 0x0040
            elif width == "l":
                opcode |= 0x0080

            # Other operand - immediate:
            opcode |= 0x003c
            # Add other operand register number
            opcode |= getreg(reg) << 9

            if width == "l":
                text = ".short 0x{:04x}\n.long {} /* {} */".format(opcode, imm, stripped)
            else:
                text = ".short 0x{:04x},{} /* {} */".format(opcode, imm, stripped)

            #print(stripped)
            #print(imm, reg)
            #print(text)
            #print()

        # lea <addr>, reg
        # GNU as turns this into a 16-bit PC-relative address if the address is close enough
        if len(stripped) > 5 and stripped[0:4] == "lea " and stripped[4] != "%" and stripped[4] != "#":

            addr, reg = stripped[4:].split(",", 1)

            # Build operand
            opcode = 0x41c0
            
            # Other operand - Other/Absolute Long
            opcode |= 0x0039

            # Add other operand register number
            opcode |= getreg(reg) << 9

            text = ".short 0x{:04x}\n.long {} /* {} */".format(opcode, addr, stripped)

            #print(stripped)
            #print(addr, reg)
            #print(text)
            #print()


        # GNU as assembles 8-bit negative signed numbers as 0xffxx while Pure C assembles them as 0x00xx.
        # This is a bit of a pain in the ass. Maybe I should write my own assembler.

    print(text)


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
    return int(name[2:])

def get_multibase(text):
    if text[0:2] == "0x":
        return int(text[2:], 16)
    else:
        return int(text)

for text in generate_text():
    stripped = text.strip()

    # Skip labels and directives
    if len(stripped) > 0 and stripped[-1] != ":" and stripped[0] != ".":
        # Check for transforms

        # cmpb <imm>, reg
        if len(stripped) > 4 and stripped[0:5] == "cmpb " and stripped[5] == "#":

            imm, reg = stripped[6:].split(",", 1)
            imm = get_multibase(imm)

            # Build operand
            opcode = 0xb000
            # Other operand - immediate:
            opcode |= 0x003c
            # Add other operand register number
            opcode |= getreg(reg) << 9

            text = ".short 0x{:04x},0x{:04x} /* {} */".format(opcode, imm, stripped)

            #print(stripped)
            #print(text)
            #print(imm, reg)

        # The solution is to move the target to another file.
        # jsr <dest>
        #if len(stripped) > 4 and stripped[0:3] == 'jsr ':
        #    dest = stripped[4:]
        #    opcode = 0x4eb9
        #    text = ".short 0x{:04x}\n.long {} /* {} */".format(opcode, dest, stripped)

    print(text)


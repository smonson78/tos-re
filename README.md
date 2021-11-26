### TOS 1.4 UK disassembly

I am slowly hand-disassembling parts of TOS 1.4 UK (md5sum 036c5ae4f885cbf62c9bed651c6c58a8).

NOTE: A goal of this project is that it will be buildable with modern plain GCC (built for m68k targets of course), 
not m68k-atari-mint-gcc. 

A primary goal is to be able to build a byte-identical copy of the Atari TOS 1.4 ROM from these sources. This is in order
to confirm that the disassembly is correct. It can then be used as a base for future TOS modification projects such as 
bug fixes.

An unfortunate consequence of using GCC is that is is an optimising assembler, and it will attempt to "help" the
programmer by replacing some instructions with other more efficient ones. Example: cmp, add, or, and and instructions
will be replaced by cmpi, addi, ori, and andi, respectively. This makes it impossible to get the exact byte representation
that I want in order to compare against the original ROM. Unfortunately, it seems impossible to disable this behaviour. 
I am using a preprocessor written in Python to work around that (see details below).

I have referred to other sources for some of the information used to reverse-engineer the binary, including the book 
Atari ST Internals, the book The Atari Compendium, and Thorsten Otto's published Atari TOS 3.06 source code. I have included
copies of comments from source code seen in those sources in this project in order to make the code understandable, and
I do not make any claim of ownership on any comments appearing in this repository. If there is anything appearing here
which should be removed, please contact me and I will be happy to assist.

Conventions:
  * I am using 2 spaces for tabs
  * Source files are written in GNU assembly conventions, notably meaning %-sign register prefices are required
  * I have tried to place end-of-line comments at character 45 in source files where possible
  * I am defining a lot of symbols, especially RAM addresses that are currently unknown, in the file extern.s
  * Sources with the name X-source.s will preprocess to X.s and then assemble to X.o for linking

I'm currently doing most of the disassembly work in the branch `wip2` so as not to pollute `master` with a lot of commits.

## About the preprocessor:
This is simply a script that detects certain instructions and assembles them on behalf of the GNU assembler, turning
them into binary data. 

Example:
```
  andb #28,%d0														/* check for RNF, checksum, lost-data */
```
The above instruction in tos-source.s will appear like this in tos.s, after preprocessing:
```
.short 0xc03c,0x001c /* andb #28,%d0 */
```

Thus, GNU `as` will not ruin things by assembling it into an `andib #28,%d0` instruction.

  


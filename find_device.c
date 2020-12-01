#include <stdint.h>

// TOS system variable 0x2ae4
extern uint16_t *INTIN;
extern uint16_t paltab4[];
extern uint16_t paltab16[];

// Default palette for medium resolution
// TODO use these C versions later when we're sure the old ones aren't being used
/*uint16_t paltab4[] = {
  0x777, 0x700, 0x070, 0x000
};

// Default palette for low resolution
uint16_t paltab16[] = {
  0x777, 0x700, 0x070, 0x770, 0x007, 0x707, 0x077, 0x555,
  0x333, 0x733, 0x373, 0x773, 0x337, 0x737, 0x377, 0x000
};
*/

/* 
  Sets mode requested by *INTIN system variable.
  Available modes:
  1 - No change
  2 - Low resolution
  3 - Medium resolution
  4 - High resolution
*/

enum {
  SYSTEM_VIDMODE_NOCHANGE = 1,
  SYSTEM_VIDMODE_LOW,
  SYSTEM_VIDMODE_MEDIUM,
  SYSTEM_VIDMODE_HIGH
};

enum {
  SHIFTER_MODE_LOW,
  SHIFTER_MODE_MEDIUM,
  SHIFTER_MODE_HIGH
};

#define Setpalette(paltab) do{\
    __asm__ __volatile__ \
    ( \
      "pea %0\n\t" \
      "movew #6,%%sp@-\n\t" \
      "trap #14\n\t" \
      "addql #6,%%sp\n\t" \
    : \
    : "m"(paltab) \
    : "d0", "d1", "d2", "a0", "a1", "a2" \
    ); \
}while(0)

#define Setscreen(laddr, paddr, rez) do{\
    __asm__ __volatile__ \
    ( \
      "movew %2,%%sp@-\n\t" \
      "movel %1,%%sp@-\n\t" \
      "movel %0,%%sp@-\n\t" \
      "movew #5,%%sp@-\n\t" \
      "trap #14\n\t" \
      "lea %%sp@(12),%%sp\n\t" \
    : \
    : "r"(laddr), "r"(paddr), "r"(rez) \
    : "d0", "d1", "d2", "a0", "a1", "a2" \
    ); \
}while(0)

int FindDevice() {

  // Get current resolution via Getrez() (trap #14 function 4)
  int curres;
  __asm__ __volatile__
  (
    "movew #4,%%sp@-\n\t"
    "trap #14\n\t"
    "moveb %%d0,%0\n\t"
    "addql #2,%%sp\n\t"
  : "=rm"(curres) // outputs
  : // inputs
  : "d0", "d1", "d2", "a0", "a1", "a2" // clobbered regs
  );

  //if (curres == SHIFTER_MODE_HIGH) {
    // Mono - can't be changed. Reset the palette and then exit.
  //  newres = curres;
  //} else {

    int newres = *INTIN;
    if (newres == SYSTEM_VIDMODE_NOCHANGE) {
      newres = curres;
    } else {
      newres -= 2;
    }
  //}

  // curres and newres should both be in shifter mode numbers now

  // Change modes if needed
  if (curres != newres) {
    Setscreen(-1, -1, newres);
  }

  // Restore default palette
  if (newres == SHIFTER_MODE_LOW) {
    Setpalette(paltab16);
  } else {
    Setpalette(paltab4);
  }

  return newres + 1;
}
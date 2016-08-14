#include "keymap_common.h"

const uint8_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    /* 0: asetmak */
    KEYMAP(ESC, 1,   2,   3,   4,   5,                         6,   7,   8,   9,   0, MINS,  \
           NO,  Q,   W,   F,   P,   G,                         J,   L,   U,   Y, SCLN,BSLS,  \
          TAB,  A,   S,   E,   T,   D,                         H,   N,   I,   O,   R, QUOT,  \
         LSFT,  Z,   X,   C,   V,   B, LCTL,LALT,  RGUI,RCTL,  K,   M,   COMM,DOT, SLSH,RSFT,\
          ESC, GRV,  NO,LEFT,RGHT,          HOME,  PGUP,          DOWN,  UP,LBRC,RBRC,  NO,  \
                                  BSPC, DEL, END,  PGDN, ENT, SPC                            \
    )
};
const uint16_t PROGMEM fn_actions[] = {};

#include <util/delay.h>
#include "bootloader.h"
#include "keymap_common.h"

const uint8_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    /* 0: Norman layout - Minimize use of center columns. Swap p and j */
    KEYMAP(
     EQL,    1,    2,    3,    4,    5,                             6,    7,    8,    9,    0, MINS,  \
     GRV,    Q,    W,    D,    F,    K,                             P,    U,    R,    L, SCLN, BSLS,  \
     TAB,    A,    S,    E,    T,    G,                             Y,    N,    I,    O,    H, QUOT,  \
    LSFT,    Z,    X,    C,    V,    B,  DEL, HOME,  PGUP, RCTL,    J,    M, COMM,  DOT, SLSH, RSFT,  \
    LGUI,   NO,   NO, LEFT, RGHT,              END,  PGDN,             DOWN,   UP,   NO, RALT, RCTL,  \
                                   FN1,  FN2, LALT,  RGUI,  ENT,  FN3                                 \
    ),

    /* 1: Blueshift */
    KEYMAP(
     FN0,   F1,   F2,   F3,   F4,   F5,                            F6,   F7,   F8,   F9,  F10, TRNS,  \
    TRNS, FN11, FN12, FN13, FN14, FN15,                          FN16, FN17, FN18, FN24,  EQL, TRNS,  \
    TRNS, FN25,   NO, FN23, MINS,   NO,                          LEFT, DOWN,   UP, RGHT,   NO, TRNS,  \
    TRNS,   NO, FN19, LBRC, FN21,   NO, TRNS, TRNS,  TRNS, TRNS,   NO, FN22, RBRC, FN20,   NO, TRNS,  \
    TRNS, TRNS, TRNS, TRNS, TRNS,             TRNS,  TRNS,             TRNS, TRNS, TRNS, TRNS, TRNS,  \
                                  TRNS, TRNS, TRNS,  TRNS, TRNS, TRNS                                 \
    ),

    /* x: asetmak
    KEYMAP(GRV, 1,   2,   3,   4,   5,                         6,   7,   8,   9,   0, MINS,  \
           NO,  Q,   W,   F,   P,   G,                         J,   L,   U,   Y, SCLN,BSLS,  \
          TAB,  A,   S,   E,   T,   D,                         H,   N,   I,   O,   R, QUOT,  \
         LSFT,  Z,   X,   C,   V,   B,  DEL,HOME,  PGUP,RCTL,  K,   M,   COMM,DOT, SLSH,RSFT,\
          ESC,  NO,  NO,LEFT,RGHT,           END,  PGDN,          DOWN,  UP,LBRC,RBRC,  NO,  \
                                  BSPC, FN1,LALT,  RGUI, ENT, SPC                            \
    ) */
};

/* id for user defined functions */
enum function_id {
    TEENSY_KEY,
};

/*
 * Fn action definition
 */
const uint16_t PROGMEM fn_actions[] = {
    ACTION_FUNCTION(TEENSY_KEY),                    // FN0

    // Dual-role keys on thumbs
    ACTION_LAYER_TAP_KEY(1, KC_BSPC),               // FN1
    ACTION_MODS_TAP_KEY(MOD_LCTL, KC_ESC),          // FN2
    ACTION_LAYER_TAP_KEY(1, KC_SPC),                // FN3

    ACTION_LAYER_SET(0, ON_BOTH),                   // FN4
    ACTION_LAYER_SET(3, ON_BOTH),                   // FN5
    ACTION_LAYER_MOMENTARY(1),                      // FN6
    ACTION_LAYER_MOMENTARY(1),                      // FN7
    ACTION_LAYER_MOMENTARY(1),                      // FN8
    ACTION_LAYER_MOMENTARY(1),                      // FN9
    ACTION_LAYER_MOMENTARY(1),                      // FN10

    ACTION_MODS_KEY(MOD_LSFT, KC_1),                // FN11 - !
    ACTION_MODS_KEY(MOD_LSFT, KC_2),                // FN12 - @
    ACTION_MODS_KEY(MOD_LSFT, KC_3),                // FN13 - #
    ACTION_MODS_KEY(MOD_LSFT, KC_4),                // FN14 - $
    ACTION_MODS_KEY(MOD_LSFT, KC_5),                // FN15 - %
    ACTION_MODS_KEY(MOD_LSFT, KC_6),                // FN16 - ^
    ACTION_MODS_KEY(MOD_LSFT, KC_7),                // FN17 - &
    ACTION_MODS_KEY(MOD_LSFT, KC_8),                // FN18 - *
    ACTION_MODS_KEY(MOD_LSFT, KC_9),                // FN19 - (
    ACTION_MODS_KEY(MOD_LSFT, KC_0),                // FN20 - )
    ACTION_MODS_KEY(MOD_LSFT, KC_LBRC),             // FN21 - {
    ACTION_MODS_KEY(MOD_LSFT, KC_RBRC),             // FN22 - }
    ACTION_MODS_KEY(MOD_LSFT, KC_MINS),             // FN23 - _
    ACTION_MODS_KEY(MOD_LSFT, KC_EQL),              // FN24 - +
    ACTION_MODS_KEY(MOD_LSFT, KC_GRV),              // FN25 - ~
};

void action_function(keyrecord_t *event, uint8_t id, uint8_t opt)
{
    print("action_function called\n");
    print("id  = "); phex(id); print("\n");
    print("opt = "); phex(opt); print("\n");
    if (id == TEENSY_KEY) {
        clear_keyboard();
        print("\n\nJump to bootloader... ");
        _delay_ms(250);
        bootloader_jump(); // should not return
        print("not supported.\n");
    }
}


#include "quantum.h"

#ifdef KEYBOARD_dactyl
/* KX1-6 are not present on dactyl, but are on ergodox */
/*  ---------- LEFT HAND -----------   ---------- RIGHT HAND ---------- */
#define KEYMAP( \
    L00,L01,L02,L03,L04,L05,LX1,             RX4,R08,R09,R0A,R0B,R0C,R0D, \
    L10,L11,L12,L13,L14,L15,LX2,             RX5,R18,R19,R1A,R1B,R1C,R1D, \
    L20,L21,L22,L23,L24,L25,                     R28,R29,R2A,R2B,R2C,R2D, \
    L30,L31,L32,L33,L34,L35,LX3,             RX6,R38,R39,R3A,R3B,R3C,R3D, \
    L40,L41,L42,L43,L44,                             R49,R4A,R4B,R4C,R4D, \
                            L06,L16,   R17,R07,                           \
                                L26,   R27,                               \
                        L45,L46,L36,   R37,R47,R48                        \
) { \
    { L00, L01, L02, L03, L04, L05, L06, R07, R08, R09, R0A, R0B, R0C, R0D }, \
    { L10, L11, L12, L13, L14, L15, L16, R17, R18, R19, R1A, R1B, R1C, R1D }, \
    { L20, L21, L22, L23, L24, L25, L26, R27, R28, R29, R2A, R2B, R2C, R2D }, \
    { L30, L31, L32, L33, L34, L35, L36, R37, R38, R39, R3A, R3B, R3C, R3D }, \
    { L40, L41, L42, L43, L44, L45, L46, R47, R48, R49, R4A, R4B, R4C, R4D }  \
}
#endif
#ifdef KEYBOARD_ergodox_ez
#include "ergodox_ez.h"
#define KEYMAP LAYOUT_ergodox_pretty
#endif

#define _______ KC_TRNS
#define XXXXXXX KC_NO

enum custom_keycodes {
  // layouts
  NORM = SAFE_RANGE,
  GREEK
};

// from promethium keyboard in qmk_firmware
enum unicode_name {
  GRIN, // grinning face 😊
  TJOY, // tears of joy 😂
  SMILE, // grining face with smiling eyes 😁
  HEART, // heart ❤
  EYERT, // smiling face with heart shaped eyes 😍
  CRY, // crying face 😭
  SMEYE, // smiling face with smiling eyes 😊
  UNAMU, // unamused 😒
  KISS, // kiss 😘
  HART2, // two hearts 💕
  WEARY, // weary 😩
  OKHND, // ok hand sign 👌
  PENSV, // pensive 😔
  SMIRK, // smirk 😏
  RECYC, // recycle ♻
  WINK, // wink 😉
  THMUP, // thumb up 👍
  THMDN, // thumb down 👎
  PRAY, // pray 🙏
  PHEW, // relieved 😌
  MUSIC, // musical notes
  FLUSH, // flushed 😳
  CELEB, // celebration 🙌
  CRY2, // crying face 😢
  COOL, // smile with sunglasses 😎
  NOEVS, // see no evil
  NOEVH, // hear no evil
  NOEVK, // speak no evil
  POO, // pile of poo
  EYES, // eyes
  VIC, // victory hand
  BHART, // broken heart
  SLEEP, // sleeping face
  SMIL2, // smiling face with open mouth & sweat
  HUNRD, // 100
  CONFU, // confused
  TONGU, // face with tongue & winking eye
  DISAP, // disappointed
  YUMMY, // face savoring delicious food
  CLAP, // hand clapping
  FEAR, // face screaming in fear
  HORNS, // smiling face with horns
  HALO, // smiling face with halo
  BYE, // waving hand
  SUN, // sun
  MOON, // moon
  SKULL, // skull

  // greek letters
  UALPH,
  UBETA,
  UGAMM,
  UDELT,
  UEPSI,
  UZETA,
  UETA,
  UTHET,
  UIOTA,
  UKAPP,
  ULAMB,
  UMU,
  UNU,
  UXI,
  UOMIC,
  UPI,
  URHO,
  USIGM,
  UTAU,
  UUPSI,
  UPHI,
  UCHI,
  UPSI,
  UOMEG,

  LALPH,
  LBETA,
  LGAMM,
  LDELT,
  LEPSI,
  LZETA,
  LETA,
  LTHET,
  LIOTA,
  LKAPP,
  LLAMB,
  LMU,
  LNU,
  LXI,
  LOMIC,
  LPI,
  LRHO,
  LSIGM,
  LTAU,
  LUPSI,
  LPHI,
  LCHI,
  LPSI,
  LOMEG,

  FSIGM,

  LTEQ,
  GTEQ,
  NOTEQ,
  PLMIN,
};

const uint32_t PROGMEM unicode_map[] = {
  [GRIN] = 0x1F600,
  [TJOY] = 0x1F602,
  [SMILE] = 0x1F601,
  [HEART] = 0x2764,
  [EYERT] = 0x1f60d,
  [CRY] = 0x1f62d,
  [SMEYE] = 0x1F60A,
  [UNAMU] = 0x1F612,
  [KISS] = 0x1F618,
  [HART2] = 0x1F495,
  [WEARY] = 0x1F629,
  [OKHND] = 0x1F44C,
  [PENSV] = 0x1F614,
  [SMIRK] = 0x1F60F,
  [RECYC] = 0x267B,
  [WINK] = 0x1F609,
  [THMUP] = 0x1F44D,
  [THMDN] = 0x1F44E,
  [PRAY] = 0x1F64F,
  [PHEW] = 0x1F60C,
  [MUSIC] = 0x1F3B6,
  [FLUSH] = 0x1F633,
  [CELEB] = 0x1F64C,
  [CRY2] = 0x1F622,
  [COOL] = 0x1F60E,
  [NOEVS] = 0x1F648,
  [NOEVH] = 0x1F649,
  [NOEVK] = 0x1F64A,
  [POO] = 0x1F4A9,
  [EYES] = 0x1F440,
  [VIC] = 0x270C,
  [BHART] = 0x1F494,
  [SLEEP] = 0x1F634,
  [SMIL2] = 0x1F605,
  [HUNRD] = 0x1F4AF,
  [CONFU] = 0x1F615,
  [TONGU] = 0x1F61C,
  [DISAP] = 0x1F61E,
  [YUMMY] = 0x1F60B,
  [CLAP] = 0x1F44F,
  [FEAR] = 0x1F631,
  [HORNS] = 0x1F608,
  [HALO] = 0x1F607,
  [BYE] = 0x1F44B,
  [SUN] = 0x2600,
  [MOON] = 0x1F314,
  [SKULL] = 0x1F480,

  // greek letters
  [UALPH] = 0x0391,
  [UBETA] = 0x0392,
  [UGAMM] = 0x0393,
  [UDELT] = 0x0394,
  [UEPSI] = 0x0395,
  [UZETA] = 0x0396,
  [UETA] = 0x0397,
  [UTHET] = 0x0398,
  [UIOTA] = 0x0399,
  [UKAPP] = 0x039A,
  [ULAMB] = 0x039B,
  [UMU] = 0x039C,
  [UNU] = 0x039D,
  [UXI] = 0x039E,
  [UOMIC] = 0x039F,
  [UPI] = 0x03A0,
  [URHO] = 0x03A1,
  [USIGM] = 0x03A3,
  [UTAU] = 0x03A4,
  [UUPSI] = 0x03A5,
  [UPHI] = 0x03A6,
  [UCHI] = 0x03A7,
  [UPSI] = 0x03A8,
  [UOMEG] = 0x03A9,
  [LALPH] = 0x03B1,
  [LBETA] = 0x03B2,
  [LGAMM] = 0x03B3,
  [LDELT] = 0x03B4,
  [LEPSI] = 0x03B5,
  [LZETA] = 0x03B6,
  [LETA] = 0x03B7,
  [LTHET] = 0x03B8,
  [LIOTA] = 0x03B9,
  [LKAPP] = 0x03BA,
  [LLAMB] = 0x03BB,
  [LMU] = 0x03BC,
  [LNU] = 0x03BD,
  [LXI] = 0x03BE,
  [LOMIC] = 0x03BF,
  [LPI] = 0x03C0,
  [LRHO] = 0x03C1,
  [LSIGM] = 0x03C3,
  [LTAU] = 0x03C4,
  [LUPSI] = 0x03C5,
  [LPHI] = 0x03C6,
  [LCHI] = 0x03C7,
  [LPSI] = 0x03C8,
  [LOMEG] = 0x03C9,
  [FSIGM] = 0x03C2, // "final" sigma

  // other
  [LTEQ] = 0x2264, // less than or equal
  [GTEQ] = 0x2265, // greater than or equal
  [NOTEQ] = 0x2260, // not equal
  [PLMIN] = 0xB1, // plus minus
};

#include "keymap_config.h"

void matrix_init_user() {
    set_unicode_input_mode(UC_LNX); // Ctrl-Shift-u support
    //set_unicode_input_mode(UC_WINC); // WinCompose support
}

/* id for user defined functions */
enum function_id {
    TEENSY_KEY,
};

/*
 * Fn action definition
 */
const uint16_t PROGMEM fn_actions[] = {
    ACTION_FUNCTION(TEENSY_KEY),                    // FN0
};

void action_function(keyrecord_t *event, uint8_t id, uint8_t opt) {
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

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  static bool lshift = false;
  static bool rshift = false;
  static uint8_t layer = 0;

  lshift = keyboard_report->mods & MOD_BIT(KC_LSFT);
  rshift = keyboard_report->mods & MOD_BIT(KC_RSFT);
  layer = biton32(layer_state);

  switch (keycode) {

    // handle greek layer shift
    case KC_LSFT:
    case KC_RSFT:
      ;
      if (layer == _GREEKU || layer == _GREEKL) {
        if (record->event.pressed) {
          layer_on(_GREEKU);
          layer_off(_GREEKL);
        } else {
          if (lshift ^ rshift) { // if only one shift was pressed
            layer_on(_GREEKL);
            layer_off(_GREEKU);
          }
        }
      }
      return true;
      break;

    // layer switcher
    //
    case GREEK:
      if (record->event.pressed) {
        if (lshift || rshift) {
          layer_on(_GREEKU);
          layer_off(_GREEKL);
        } else {
          layer_on(_GREEKL);
          layer_off(_GREEKU);
        }
      } else {
        layer_off(_GREEKU);
        layer_off(_GREEKL);
      }
      return false;
      break;
  };

  return true;
}

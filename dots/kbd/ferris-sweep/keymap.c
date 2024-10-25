#include QMK_KEYBOARD_H

enum layers {
    _ALPHA,
    _NUMSYM,
    _NAVCTL,
};

#define ____ KC_NO
#define VVVV KC_TRNS

// Thumb cluster keys
#define TCR1 KC_LCTL
#define TCR0 MT(MOD_LSFT, KC_BSPC)
#define TCL1 LT(_NUMSYM, KC_SPACE)
#define TCL0 LT(_NAVCTL, KC_ENTER)

// Symbols
#define L_PARN LSFT(KC_9)     // (
#define R_PARN LSFT(KC_0)     // )
#define L_BRCE LSFT(KC_LBRC)  // {
#define R_BRCE LSFT(KC_RBRC)  // }
#define PLUS LSFT(KC_EQL)     // +
#define TILDE LSFT(KC_GRV)    // ~
#define EXCLAMAPT LSFT(KC_1)  // !
#define AROBASE LSFT(KC_2)    // @
#define OCTOTHORPE LSFT(KC_3) // #
#define DOLLAR LSFT(KC_4)     // $
#define PERCENT LSFT(KC_5)    // %
#define CARET LSFT(KC_6)      // ^
#define AMPERSAND LSFT(KC_7)  // &
#define ASTERISK LSFT(KC_8)   // *

// Window manager controls
#define DESK1 LGUI(KC_1)
#define DESK2 LGUI(KC_2)
#define DESK3 LGUI(KC_3)
#define MUSIC LGUI(KC_SCLN)
#define PPLAY LGUI(KC_EQL)
#define BMENU LGUI(KC_SPACE)
#define MAXIM LGUI(KC_F)       // Maximize window
#define CALEN LGUI(KC_C)
#define TODOS LGUI(KC_T)
#define KPASS LGUI(KC_P)
#define TOMON LGUI(LSFT(KC_T)) // Move window to monitor
#define SINFO LGUI(KC_E)       // Show clock/battery notification

// Terminal controls
#define LTTAB LALT(KC_LBRC)    // Prev term tab
#define RTTAB LALT(KC_RBRC)    // Next term tab
#define HSPLT LALT(KC_MINS)    // Horizontal split
#define VSPLT LALT(KC_BSLS)    // Vertical split
#define FOCUS LALT(KC_W)       // Focus pane
#define TCOPY LSFT(LALT(KC_C)) // Terminal copy
#define TPAST LSFT(LALT(KC_P)) // Terminal paste
#define TLINK LSFT(LALT(KC_E)) // Terminal open link
#define TPATH LSFT(LALT(KC_O)) // Terminal copy path

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
	[_ALPHA] = LAYOUT(
        KC_Q, KC_W, KC_E, KC_R, KC_T,       KC_Y, KC_U, KC_I,    KC_O,   KC_P,
        KC_A, KC_S, KC_D, KC_F, KC_G,       KC_H, KC_J, KC_K,    KC_L,   KC_SCLN,
        KC_Z, KC_X, KC_C, KC_V, KC_B,       KC_N, KC_M, KC_COMM, KC_DOT, KC_SLSH,
                          TCR1, TCR0,       TCL0, TCL1
    ),
    [_NUMSYM] = LAYOUT(
        KC_GRV, KC_1, KC_2, KC_3, CARET,      ____, ____, L_PARN,  R_PARN,  TILDE,
        ____,   KC_4, KC_5, KC_6, KC_0,       ____, ____, L_BRCE,  R_BRCE,  PERCENT,
        ____,   KC_7, KC_8, KC_9, DOLLAR,     ____, ____, KC_LBRC, KC_RBRC, PLUS,
                            VVVV, VVVV,       VVVV, VVVV
    ),
    [_NAVCTL] = LAYOUT(
        KC_VOLD, KC_VOLU, MUSIC, PPLAY,   BMENU,       MS_WHLU, LTTAB,   KC_UP,   RTTAB,   TCOPY,
        KC_MUTE, DESK1,   DESK2, DESK3,   MAXIM,       MS_WHLD, KC_LEFT, KC_DOWN, KC_RGHT, TPAST,
        KC_LSFT, CALEN,   TODOS, KPASS,   TOMON,       TPATH,   HSPLT,   FOCUS,   VSPLT,   TLINK,
                                 KC_WBAK, KC_WFWD,     ____,    SINFO

    ),
};

// Symbol & special combos
const uint16_t PROGMEM tab[]      = {KC_A, KC_F, COMBO_END};
const uint16_t PROGMEM escape[]   = {KC_S, KC_F, COMBO_END};
const uint16_t PROGMEM equal[]    = {KC_D, KC_G, COMBO_END};
const uint16_t PROGMEM minus[]    = {KC_U, KC_O, COMBO_END};
const uint16_t PROGMEM pipe[]     = {KC_U, KC_P, COMBO_END};
const uint16_t PROGMEM bslash[]   = {KC_Y, KC_P, COMBO_END};
const uint16_t PROGMEM unscore[]  = {KC_M, KC_DOT, COMBO_END};
const uint16_t PROGMEM colon[]    = {KC_J, KC_SCLN, COMBO_END};
const uint16_t PROGMEM quote[]    = {KC_J, KC_L, COMBO_END};
const uint16_t PROGMEM ampers[]   = {KC_W, KC_R, COMBO_END};
const uint16_t PROGMEM arobase[]  = {KC_W, KC_T, COMBO_END};
const uint16_t PROGMEM exclam[]   = {KC_Q, KC_E, COMBO_END};
const uint16_t PROGMEM asterisk[] = {KC_Q, KC_R, COMBO_END};
const uint16_t PROGMEM octothrp[] = {KC_Q, KC_T, COMBO_END};

// Accented inputs
const uint16_t PROGMEM accent_aigu[]   = {KC_E, KC_W, COMBO_END};
const uint16_t PROGMEM accent_grave[]  = {KC_E, KC_R, COMBO_END};
const uint16_t PROGMEM accent_cflex[]  = {KC_E, KC_R, KC_W, COMBO_END};
const uint16_t PROGMEM accent_cdill[]  = {KC_X, KC_V, KC_C, COMBO_END};

// Terminal control combos
const uint16_t PROGMEM term_new_tab[]  = {LTTAB, RTTAB, COMBO_END};
const uint16_t PROGMEM term_search[]   = {KC_LEFT, KC_RGHT, COMBO_END};
const uint16_t PROGMEM term_max_pane[] = {HSPLT, VSPLT, COMBO_END};

combo_t key_combos[] = {
    COMBO(tab, KC_TAB),
    COMBO(escape, KC_ESC),
    COMBO(equal, KC_EQUAL),
    COMBO(minus, KC_MINUS),
    COMBO(unscore, LSFT(KC_MINUS)),
    COMBO(colon, LSFT(KC_SCLN)),
    COMBO(quote, KC_QUOTE),
    COMBO(pipe, LSFT(KC_BACKSLASH)),
    COMBO(bslash, KC_BACKSLASH),
    COMBO(ampers, AMPERSAND),
    COMBO(exclam, EXCLAMAPT),
    COMBO(asterisk, ASTERISK),
    COMBO(arobase, AROBASE),
    COMBO(octothrp, OCTOTHORPE),

    COMBO(accent_aigu, RALT(KC_QUOTE)),
    COMBO(accent_grave, RALT(KC_GRAVE)),
    COMBO(accent_cflex, RALT(CARET)),
    COMBO(accent_cdill, RALT(KC_COMMA)),

    COMBO(term_new_tab, LALT(KC_T)),
    COMBO(term_search, LALT(KC_QUOTE)),
    COMBO(term_max_pane, LALT(KC_M)),
};
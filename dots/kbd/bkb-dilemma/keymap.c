#include QMK_KEYBOARD_H

enum layers {
    _ALPHA,
    _SYMBOL,
    _NUMBER,
    _NAVCTL,
    _BLENDER,
};

#define LAYOUT LAYOUT_split_3x5_3

#define ____ KC_NO // An unused key
#define XXXX KC_NO // Can't use; trigger for the current layer
#define VVVV KC_TRNS // Passthrough

// Thumb cluster keys
#define CTRL KC_LCTL
#define SHFT KC_LSFT
#define META KC_LGUI
#define SPAC KC_SPACE
#define BKSP KC_BSPC
#define BNAV LT(_NAVCTL, KC_BSPC)
#define ENAV LT(_NAVCTL, KC_ENTER)
#define SCTL MT(MOD_LCTL, KC_SPACE)

#define DSYM LT(_SYMBOL, KC_D)
#define KNUM LT(_NUMBER, KC_K)
#define QGUI MT(MOD_LGUI, KC_Q)
#define ZALT MT(MOD_RALT, KC_Z) // Use as AltGr for accents
// RAlt+e -> aigu
// RAlt+u -> umlaut
// RAlt+i -> cironflex
// RAlt+c -> ç
// RAlt+` -> grave

// Mouse
#define L_CLK MS_BTN1
#define R_CLK MS_BTN2
#define M_CLK MS_BTN3
#define MS_DN DPI_RMOD
#define MS_UP DPI_MOD

// Symbols
#define L_BRK KC_LBRC        // [
#define R_BRK KC_RBRC        // ]
#define L_PAR LSFT(KC_9)     // (
#define R_PAR LSFT(KC_0)     // )
#define L_BRC LSFT(KC_LBRC)  // {
#define R_BRC LSFT(KC_RBRC)  // }
#define L_THN LSFT(KC_COMMA) // <
#define G_THN LSFT(KC_DOT)   // >
#define PLUS  LSFT(KC_EQL)   // +
#define MINUS KC_MINUS       // -
#define EQUAL KC_EQL         // =
#define TILDE LSFT(KC_GRV)   // ~
#define EXCLM LSFT(KC_1)     // !
#define AROBA LSFT(KC_2)     // @
#define OCTHP LSFT(KC_3)     // #
#define DOLAR LSFT(KC_4)     // $
#define PRCNT LSFT(KC_5)     // %
#define CARET LSFT(KC_6)     // ^
#define AMPER LSFT(KC_7)     // &
#define ASTRK LSFT(KC_8)     // *
#define QUOTE KC_QUOTE       // '
#define DBLQT LSFT(KC_QUOTE) // "
#define QMARK LSFT(KC_SLSH)  // ?
#define SLASH KC_SLSH        // /
#define SCOLN KC_SCLN        // ;
#define COLON LSFT(KC_SCLN)  // :
#define USCOR LSFT(KC_MINUS) // _
#define PIPE  LSFT(KC_BSLS)  // |
#define COMMA KC_COMMA       // ,
#define GRAVE KC_GRAVE       // `
#define BSLSH KC_BACKSLASH

// Window Manager
#define DESK1 LGUI(KC_1)
#define DESK2 LGUI(KC_2)
#define DESK3 LGUI(KC_3)
#define FOCWN LGUI(KC_H)       // Change window focus
#define FOCMN LGUI(LCTL(KC_K)) // Change monitor focus
#define TOMON LGUI(LCTL(KC_M)) // Move window to monitor
#define BMENU LGUI(KC_SPACE)   // Launcher
#define CLOSE LGUI(LSFT(LALT(KC_Q))) // (Force) close window

// Media
#define PPLAY LGUI(KC_EQL)
#define VOL_DN KC_VOLD
#define VOL_UP KC_VOLU

// Browser
#define B_BACK KC_WBAK            // History back
#define B_FRWD KC_WFWD            // History forward
#define B_PREV LCTL(LSFT(KC_TAB)) // Prev tab
#define B_NEXT LCTL(KC_TAB)       // Next tab

// Terminal
#define T_PREV LALT(KC_LBRC)    // Prev term tab
#define T_NEXT LALT(KC_RBRC)    // Next term tab
#define T_HSPL LALT(KC_MINUS)   // Horizontal split
#define T_VSPL LALT(KC_BSLS)    // Vertical split
#define T_FOCU LALT(KC_W)       // Focus pane
#define T_FULL LALT(KC_M)       // Maximize pane
#define T_NTAB LALT(KC_T)       // New term tab
#define T_SRCH LALT(KC_QUOTE)   // Terminal search
#define T_HIST LALT(KC_E)       // Terminal scrollback history
#define T_COPY LSFT(LALT(KC_C)) // Terminal copy
#define T_PSTE LSFT(LALT(KC_P)) // Terminal paste
#define T_NAME LALT(KC_COMMA)   // Terminal rename tab
#define T_RSZE LSFT(LALT(KC_R)) // Terminal resize window

#include "blender.c"

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_ALPHA] = LAYOUT(
        QGUI, KC_W, KC_E,  KC_R, KC_T,     KC_Y, KC_U, KC_I,  KC_O,   KC_P,
        KC_A, KC_S, DSYM,  KC_F, KC_G,     KC_H, KC_J, KNUM,  KC_L,   QUOTE,
        ZALT, KC_X, KC_C,  KC_V, KC_B,     KC_N, KC_M, COMMA, KC_DOT, SLASH,
                    L_CLK, SHFT, BNAV,     ENAV, SCTL, GRAVE // Shifted: TILDE
    ),

    [_SYMBOL] = LAYOUT(
        ____,  ____,  ____, ____,   ____,   AROBA, OCTHP, L_BRK, R_BRK, BSLSH,
        CARET, ASTRK, XXXX, DOLAR,  ____,   ____,  L_BRC, L_PAR, R_PAR, R_BRC,
        ____,  ____,  ____, ____,   ____,   ____,  ____,  L_THN, G_THN, QMARK,
                      ____, KC_TAB, AMPER,  EXCLM, SCOLN, ____
    ),

    [_NUMBER] = LAYOUT(
        ____, ____, ____, ____, ____,    ____, ____,  ____, ____,  ____,
        KC_1, KC_2, KC_3, KC_4, ____,    ____, PLUS,  XXXX, PRCNT, SCOLN,
        KC_5, KC_6, KC_7, KC_8, ____,    ____, ____,  ____, ____,  ____,
                    ____, KC_0, KC_9,    ____, VVVV,  ____
    ),

    [_NAVCTL] = LAYOUT(
        // WM                                    // Terminal
        META,   R_CLK,  M_CLK,  MS_DN,  L_CLK,   T_HIST, T_PREV,  KC_UP,   T_NEXT,  T_NTAB,
        SHFT,   DESK1,  DESK2,  DESK3,  FOCMN,   T_HSPL, KC_LEFT, KC_DOWN, KC_RGHT, T_VSPL,
        VOL_DN, VOL_UP, FOCWN,  B_BACK, B_FRWD,  T_COPY, T_FULL,  T_FOCU,  T_SRCH,  T_PSTE,
                        ____,   BMENU,  PPLAY,   XXXX,  ____,   ____
    ),

    [_BLENDER] = BLENDER_MAP,
};

// ----Combos-----------------------
// The downside of combos vs e.g. a layer or shift-modified key
// is that they require more precise timing; that is, there's a
// combo term that both keys must be pressed within, whereas with
// e.g. Shift+Something you can be sloppier in the timing and so
// it is less flow-interrupting.
//
// Try to avoid combos that are common rolls,
// e.g. `re`, `ef`, `es`, `as`, `io`, etc,
// otherwise you may frequently accidentally trigger the combo.
// This is less true for combos which are further apart and thus
// harder to roll w/in the combo term, e.g. `af`.
//
// Also avoid `jk` as I map this to escape in vim.
const uint16_t PROGMEM escape[]   = {KC_S, KC_F, COMBO_END};
const uint16_t PROGMEM colon[]    = {KNUM, KC_L, COMBO_END};
const uint16_t PROGMEM equal[]    = {KC_L, KC_J, COMBO_END};
const uint16_t PROGMEM mute[] = {KC_VOLD, KC_VOLU, COMBO_END};

combo_t key_combos[] = {
    COMBO(escape, KC_ESC),
    COMBO(colon, LSFT(KC_SCLN)),
    COMBO(equal, EQUAL),
    COMBO(mute, KC_MUTE),
};

// ----Shifts-----------------------
const key_override_t s_minus = ko_make_basic(MOD_MASK_SHIFT, KC_COMMA, MINUS);
const key_override_t s_uscore = ko_make_basic(MOD_MASK_SHIFT, KC_DOT, USCOR);
const key_override_t s_dblqt = ko_make_basic(MOD_MASK_SHIFT, QUOTE, DBLQT);
const key_override_t s_pipe = ko_make_basic(MOD_MASK_SHIFT, KC_SLSH, PIPE);

// System
const key_override_t bright_up = ko_make_basic(MOD_MASK_SHIFT, KC_VOLU, KC_BRIGHTNESS_UP);
const key_override_t bright_down = ko_make_basic(MOD_MASK_SHIFT, KC_VOLD, KC_BRIGHTNESS_DOWN);
const key_override_t move_win_mon = ko_make_basic(MOD_MASK_SHIFT, FOCMN, TOMON);
const key_override_t mouse_speed_up = ko_make_basic(MOD_MASK_SHIFT, MS_DN, MS_UP);

// Terminal
const key_override_t term_name_tab = ko_make_basic(MOD_MASK_SHIFT, T_FOCU, T_NAME);
const key_override_t term_resize_win = ko_make_basic(MOD_MASK_SHIFT, T_FULL, T_RSZE);

const key_override_t *key_overrides[] = {
    &bright_up,
    &bright_down,

    &move_win_mon,

    &s_minus,
    &s_uscore,
    &s_pipe,
    &s_dblqt,

    &term_name_tab,
    &term_resize_win,
};

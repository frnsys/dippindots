#include QMK_KEYBOARD_H

// Disable Liatris power LED
#include "gpio.h"
void keyboard_pre_init_user(void) {
    gpio_set_pin_output(24);
    gpio_write_pin_high(24);
}

enum layers {
    _ALPHA,
    _SYMBOL,
    _NUMBER,
    _NAVCTL,
    _BLENDER,
};

#define LAYOUT LAYOUT_split_3x5_2

#define ____ KC_NO // An unused key
#define XXXX KC_NO // Can't use; trigger for the current layer
#define VVVV KC_TRNS // Passthrough

// Thumb cluster keys
#define CTRL KC_LCTL
#define SHFT KC_LSFT
#define META KC_LGUI
#define SPAC KC_SPACE
#define BKSP KC_BSPC
#define ENAV LT(_NAVCTL, KC_ENTER)
#define BCTL MT(MOD_LCTL, KC_BSPC)
#define SCTL MT(MOD_LCTL, KC_SPACE)

#define DSYM LT(_SYMBOL, KC_D)
#define KNUM LT(_NUMBER, KC_K)
#define QGUI MT(MOD_LGUI, KC_Q)

// Mouse
#define L_CLK MS_BTN1
#define R_CLK MS_BTN2
#define M_CLK MS_BTN3

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
#define BMENU LGUI(KC_SPACE)   // Launcher
#define SWAPL LGUI(LSFT(KC_H)) // Swap window left
#define SWAPR LGUI(LSFT(KC_L)) // Swap window right
#define FOCWN LGUI(KC_H)       // Change window focus
#define FOCMN LGUI(LCTL(KC_K)) // Change monitor focus
#define TOMON LGUI(LCTL(KC_M)) // Move window to monitor
#define TDSK1 LGUI(LSFT(KC_1)) // Move window to desktop
#define TDSK2 LGUI(LSFT(KC_2)) // Move window to desktop
#define TDSK3 LGUI(LSFT(KC_3)) // Move window to desktop
#define DESK1 LGUI(KC_1)
#define DESK2 LGUI(KC_2)
#define DESK3 LGUI(KC_3)
#define CLOSE LGUI(LSFT(LALT(KC_Q))) // (Force) close window
#define PREVW LGUI(QUOTE)
#define SIZEUP LGUI(LSFT(KC_LEFT))
#define SIZEDN LGUI(LSFT(KC_RIGHT))

// Media
#define MPLAY LGUI(KC_EQL)
#define VPLAY LGUI(LSFT(KC_EQL))
#define VOL_UP KC_VOLU
#define VOL_DN KC_VOLD
#define BRI_UP KC_BRIGHTNESS_UP
#define BRI_DN KC_BRIGHTNESS_DOWN

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

#define AIGU RALT(KC_QUOTE)
#define CEDI RALT(KC_COMMA)
#define CIRC RALT(LSFT(KC_6))
#define UMLA RALT(LSFT(KC_QUOTE))
#define GRAV RALT(KC_GRAVE)
#define EURO RALT(KC_EQUAL)

#include "blender.c"

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_ALPHA] = LAYOUT(
        QGUI, KC_W, KC_E,  KC_R, KC_T,     KC_Y, KC_U, KC_I,  KC_O,   KC_P,
        KC_A, KC_S, DSYM,  KC_F, KC_G,     KC_H, KC_J, KNUM,  KC_L,   QUOTE,
        KC_Z, KC_X, KC_C,  KC_V, KC_B,     KC_N, KC_M, COMMA, KC_DOT, SLASH,
                           SHFT, BCTL,     ENAV, SCTL
    ),

    [_SYMBOL] = LAYOUT(
        UMLA,  ____,  ____, ____,   CIRC,   AROBA, OCTHP, L_BRK, R_BRK, BSLSH,
        CARET, ASTRK, XXXX, DOLAR,  GRAVE,  AIGU,  L_BRC, L_PAR, R_PAR, R_BRC,
        EURO,  ____,  ____, ____,   ____,   GRAV,  CEDI,  L_THN, G_THN, QMARK,
                            KC_TAB, AMPER,  EXCLM, SCOLN
    ),

    [_NUMBER] = LAYOUT(
        ____, ____, ____, ____, ____,    ____,  ____, ____, ____,  ____,
        KC_1, KC_2, KC_3, KC_4, KC_5,    ____,  PLUS, XXXX, PRCNT, KC_DOT,
        KC_6, KC_7, KC_8, KC_9, ____,    ____,  ____, ____, ____,  ____,
                          KC_0, VVVV,    TILDE, VVVV
    ),

    [_NAVCTL] = LAYOUT(
        // WM                                   // Terminal
        ____,   SIZEDN, FOCMN, SIZEUP, META,    T_HIST, T_PREV,  KC_UP,   T_NEXT,  T_NTAB,
        SHFT,   DESK1,  DESK2, DESK3,  MPLAY,   T_HSPL, KC_LEFT, KC_DOWN, KC_RGHT, T_VSPL,
        VOL_DN, VOL_UP, FOCWN, BRI_DN, BRI_UP,  T_COPY, T_FULL,  T_FOCU,  T_SRCH,  T_PSTE,
                               BMENU,  PREVW,   XXXX,   ____
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
const key_override_t move_win_mon = ko_make_basic(MOD_MASK_SHIFT, FOCMN, TOMON);
const key_override_t move_win_desk_1 = ko_make_basic(MOD_MASK_SHIFT, DESK1, TDSK1);
const key_override_t move_win_desk_2 = ko_make_basic(MOD_MASK_SHIFT, DESK2, TDSK2);
const key_override_t move_win_desk_3 = ko_make_basic(MOD_MASK_SHIFT, DESK3, TDSK3);
const key_override_t mpv_toggle = ko_make_basic(MOD_MASK_SHIFT, MPLAY, VPLAY);

// Terminal
const key_override_t term_name_tab = ko_make_basic(MOD_MASK_SHIFT, T_FOCU, T_NAME);
const key_override_t term_resize_win = ko_make_basic(MOD_MASK_SHIFT, T_FULL, T_RSZE);

const key_override_t *key_overrides[] = {
    &move_win_mon,
    &move_win_desk_1,
    &move_win_desk_2,
    &move_win_desk_3,
    &mpv_toggle,

    &s_minus,
    &s_uscore,
    &s_pipe,
    &s_dblqt,

    &term_name_tab,
    &term_resize_win,
};

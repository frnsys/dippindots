#include QMK_KEYBOARD_H

enum layers {
    _ALPHA,
    _NUMSYM,
    _NAVCTL,
};

#define LAYOUT LAYOUT_split_3x5_3

#define ____ KC_NO // Unused
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

#define DSYM LT(_NUMSYM, KC_D)
#define KSYM LT(_NUMSYM, KC_K)

// Mouse
#define LCLK MS_BTN1
#define RCLK MS_BTN2
#define MCLK MS_BTN3
#define MS_DN DPI_RMOD
#define MS_UP DPI_MOD
#define SNIPE SNP_TOG

// Symbols
#define L_BRAK KC_LBRC          // [
#define R_BRAK KC_RBRC          // ]
#define L_PARN LSFT(KC_9)       // (
#define R_PARN LSFT(KC_0)       // )
#define L_BRCE LSFT(KC_LBRC)    // {
#define R_BRCE LSFT(KC_RBRC)    // }
#define PLUS LSFT(KC_EQL)       // +
#define MINUS KC_MINUS          // -
#define EQUAL KC_EQL            // =
#define TILDE LSFT(KC_GRV)      // ~
#define XMARK LSFT(KC_1)        // !
#define AROBAS LSFT(KC_2)       // @
#define OCTHRP LSFT(KC_3)       // #
#define DOLLAR LSFT(KC_4)       // $
#define PERCENT LSFT(KC_5)      // %
#define CARET LSFT(KC_6)        // ^
#define AMPSND LSFT(KC_7)       // &
#define ASTRSK LSFT(KC_8)       // *
#define L_THAN LSFT(KC_COMMA)   // <
#define G_THAN LSFT(KC_DOT)     // >
#define QUOTE KC_QUOTE          // '
#define DBLQT LSFT(KC_QUOTE)    // "
#define QMARK LSFT(KC_SLSH)     // ?
#define SCOLON KC_SCLN          // ;
#define COLON LSFT(KC_SCLN)     // :
#define USCR LSFT(KC_MINUS)     // _
#define PIPE LSFT(KC_BACKSLASH) // |
#define BSLASH KC_BACKSLASH

// Window Manager
#define DESK1 LGUI(KC_1)
#define DESK2 LGUI(KC_2)
#define DESK3 LGUI(KC_3)
#define FOCWN LGUI(KC_H)       // Change window focus
#define FOCMN LGUI(LCTL(KC_K)) // Change monitor focus
#define TOMON LGUI(LCTL(KC_M)) // Move window to monitor
#define W_OPEN LGUI(KC_SPACE)  // Launcher
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
#define T_HSPL LALT(KC_MINS)    // Horizontal split
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

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_ALPHA] = LAYOUT(
        KC_Q, KC_W, KC_E, KC_R, KC_T,     KC_Y, KC_U, KC_I,    KC_O,   KC_P,
        KC_A, KC_S, DSYM, KC_F, KC_G,     KC_H, KC_J, KSYM,    KC_L,   KC_SCLN,
        KC_Z, KC_X, KC_C, KC_V, KC_B,     KC_N, KC_M, KC_COMM, KC_DOT, KC_SLSH,
                    LCLK, SHFT, BNAV,     ENAV, SCTL, META
    ),

    [_NUMSYM] = LAYOUT(
        PERCENT, KC_1, KC_2, KC_3,   DOLLAR,   AROBAS, OCTHRP, L_BRAK, R_BRAK, COLON,
        CARET,   KC_4, KC_5, KC_6,   KC_0,     MINUS,  L_BRCE, L_PARN, R_PARN, R_BRCE,
        BSLASH,  KC_7, KC_8, KC_9,   TILDE,    ASTRSK, QMARK,  L_THAN, G_THAN, ____,
                       ____, KC_DOT, VVVV,     PLUS,   VVVV,   ____
    ),

    [_NAVCTL] = LAYOUT(
        // WM                                    // Terminal
        META,   RCLK,   MCLK,   MS_DN,  LCLK,    T_HIST, T_PREV,  KC_UP,   T_NEXT,  T_NTAB,
        SHFT,   DESK1,  DESK2,  DESK3,  FOCMN,   T_HSPL, KC_LEFT, KC_DOWN, KC_RGHT, T_VSPL,
        VOL_DN, VOL_UP, FOCWN,  B_BACK, B_FRWD,  T_COPY, T_FULL,  T_FOCU,  T_SRCH,  T_PSTE,
                        ____,   W_OPEN, PPLAY,   XXXX,  ____,   ____
    ),
};

// Symbol & special combos
// -----------------------
// Note: Try to avoid combos that are common rolls,
// e.g. `re`, `ef`, `es`, `as`, etc,
// otherwise you may frequently accidentally trigger the combo.
// This is less true for combos which are further apart and thus
// harder to roll w/in the combo term, e.g. `af`.
//
// Also avoid `jk` as I map this to escape in vim.
//
// Unused combos that feel ok:
// - rs (though maybe a common roll)
// - vc
// - xv
// - xc
// - xb
// - gd
// - vs
// - fx
// - gx
// - ,.
// - ,m

const uint16_t PROGMEM tab[]      = {KC_A, KC_F, COMBO_END};
const uint16_t PROGMEM escape[]   = {KC_S, KC_F, COMBO_END};
const uint16_t PROGMEM minus[]    = {KC_U, KC_O, COMBO_END};
const uint16_t PROGMEM unscore[]  = {KC_M, KC_DOT, COMBO_END};
const uint16_t PROGMEM colon[]    = {KSYM, KC_L, COMBO_END};
const uint16_t PROGMEM quote[]    = {KC_O, KC_J, COMBO_END};
const uint16_t PROGMEM dblquote[]    = {KC_J, KC_L, COMBO_END};
const uint16_t PROGMEM question[]    = {KC_O, KC_I, COMBO_END};
const uint16_t PROGMEM equal[]       = {KC_J, KC_I, COMBO_END};
const uint16_t PROGMEM pipe[]        = {KC_U, KC_I, COMBO_END};
const uint16_t PROGMEM grave[]       = {KC_S, DSYM, COMBO_END};
const uint16_t PROGMEM ampersand[]   = {DSYM, KC_F, COMBO_END};
const uint16_t PROGMEM exclamation[] = {KC_F, KC_W, COMBO_END};

// Accented inputs
const uint16_t PROGMEM accent_aigu[]   = {KC_Q, KC_T, COMBO_END};
const uint16_t PROGMEM accent_grave[]  = {KC_Q, KC_G, COMBO_END};
const uint16_t PROGMEM accent_cflex[]  = {KC_Z, KC_G, COMBO_END};
const uint16_t PROGMEM accent_cdill[]  = {KC_Z, KC_B, COMBO_END};

// WM controls
const uint16_t PROGMEM mute[] = {KC_VOLD, KC_VOLU, COMBO_END};

combo_t key_combos[] = {
    COMBO(tab, KC_TAB),
    COMBO(escape, KC_ESC),
    COMBO(minus, KC_MINUS),
    COMBO(unscore, USCR),
    COMBO(colon, LSFT(KC_SCLN)),
    COMBO(quote, QUOTE),
    COMBO(dblquote, DBLQT),
    COMBO(equal, EQUAL),
    COMBO(pipe, PIPE),
    COMBO(ampersand, AMPSND),
    COMBO(question, QMARK),
    COMBO(exclamation, XMARK),
    COMBO(grave, KC_GRAVE),

    COMBO(accent_aigu, RALT(KC_QUOTE)),
    COMBO(accent_grave, RALT(KC_GRAVE)),
    COMBO(accent_cflex, RALT(CARET)),
    COMBO(accent_cdill, RALT(KC_COMMA)),

    COMBO(mute, KC_MUTE),
};

// System
const key_override_t bright_up = ko_make_basic(MOD_MASK_SHIFT, KC_VOLU, KC_BRIGHTNESS_UP);
const key_override_t bright_down = ko_make_basic(MOD_MASK_SHIFT, KC_VOLD, KC_BRIGHTNESS_DOWN);
const key_override_t move_win_mon = ko_make_basic(MOD_MASK_SHIFT, FOCMN, TOMON);
const key_override_t mouse_speed_up = ko_make_basic(MOD_MASK_SHIFT, MS_DN, MS_UP);

// Alpha
const key_override_t other_tab = ko_make_basic(MOD_MASK_SHIFT, KC_COMMA, KC_TAB); // maybe?
const key_override_t other_other_tab = ko_make_basic(MOD_MASK_SHIFT, KC_DOT, KC_TAB);       // what should this be?

// Terminal
const key_override_t term_name_tab = ko_make_basic(MOD_MASK_SHIFT, T_FOCU, T_NAME);
const key_override_t term_resize_win = ko_make_basic(MOD_MASK_SHIFT, T_FULL, T_RSZE);

// Browser
const key_override_t next_browser_tab = ko_make_basic(MOD_MASK_SHIFT, T_NEXT, B_NEXT);
const key_override_t prev_browser_tab = ko_make_basic(MOD_MASK_SHIFT, T_PREV, B_PREV);


const key_override_t *key_overrides[] = {
    &bright_up,
    &bright_down,

    &move_win_mon,

    &other_other_tab,
    &other_tab,

    &term_name_tab,
    &term_resize_win,

    &next_browser_tab,
    &prev_browser_tab,
};

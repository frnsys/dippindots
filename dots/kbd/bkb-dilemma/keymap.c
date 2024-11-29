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
#define SPAC KC_SPACE
#define BKSP KC_BSPC
#define SCTL MT(MOD_LCTL, KC_SPACE)
#define ENAV LT(_NAVCTL, KC_ENTER)
#define SSYM LT(_NUMSYM, KC_SPACE)
#define BSFT MT(MOD_LSFT, KC_BSPC)
#define LSYM MO(_NUMSYM)

#define DSYM LT(_NUMSYM, KC_D)
#define KSYM LT(_NUMSYM, KC_K)
#define SSFT LT(MOD_LSFT, KC_S)

// Mouse
#define LCLK MS_BTN1
#define RCLK MS_BTN2
#define MCLK MS_BTN3

// Symbols
#define L_BRAK KC_LBRC          // [
#define R_BRAK KC_RBRC          // ]
#define L_PARN LSFT(KC_9)       // (
#define R_PARN LSFT(KC_0)       // )
#define L_BRCE LSFT(KC_LBRC)    // {
#define R_BRCE LSFT(KC_RBRC)    // }
#define PLUS LSFT(KC_EQL)       // +
#define EQUAL KC_EQL            // =
#define TILDE LSFT(KC_GRV)      // ~
#define EXCLAMAPT LSFT(KC_1)    // !
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
#define QUESTION LSFT(KC_SLSH)  // ?
#define SCOLON KC_SCLN          // ;
#define USCR LSFT(KC_MINUS)     // _
#define PIPE LSFT(KC_BACKSLASH) // |

// Window manager controls
#define DESK1 LGUI(KC_1)
#define DESK2 LGUI(KC_2)
#define DESK3 LGUI(KC_3)
#define PPLAY LGUI(KC_EQL)
#define FOCWN LGUI(KC_H)       // Change window focus
#define FOCMN LGUI(LCTL(KC_K)) // Change monitor focus
#define TOMON LGUI(LCTL(KC_M)) // Move window to monitor
#define CLOSE LGUI(LSFT(LALT(KC_Q))) // (Force) close window

// Terminal controls
#define LTTAB LALT(KC_LBRC)    // Prev term tab
#define RTTAB LALT(KC_RBRC)    // Next term tab
#define HSPLT LALT(KC_MINS)    // Horizontal split
#define VSPLT LALT(KC_BSLS)    // Vertical split
#define FOCUS LALT(KC_W)       // Focus pane
#define MXPAN LALT(KC_M)       // Maximize pane
#define NTTAB LALT(KC_T)       // New term tab
#define TSEAR LALT(KC_QUOTE)   // Terminal search
#define THIST LALT(KC_E)       // Terminal scrollback history
#define TNAME LALT(KC_COMMA)   // Terminal rename tab
#define TRSZE LSFT(LALT(KC_R)) // Terminal resize window

#define GUI_SLSH MT(MOD_LGUI, KC_SLSH)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_ALPHA] = LAYOUT(
        KC_Q, KC_W, KC_E, KC_R, KC_T,     KC_Y, KC_U, KC_I,    KC_O,   KC_P,
        KC_A, KC_S, DSYM, KC_F, KC_G,     KC_H, KC_J, KSYM,    KC_L,   KC_SCLN,
        KC_Z, KC_X, KC_C, KC_V, KC_B,     KC_N, KC_M, KC_COMM, KC_DOT, GUI_SLSH,
                    LCLK, SHFT, BKSP,     ENAV, SCTL, QUOTE
    ),
    [_NUMSYM] = LAYOUT(
        KC_GRV,  KC_1, KC_2, KC_3, AMPSND,  CARET,  DOLLAR, L_PARN, R_PARN, TILDE,
        KC_0,    KC_4, KC_5, KC_6, ASTRSK,  PLUS,   DBLQT,  L_BRAK, R_BRAK, EXCLAMAPT,
        PERCENT, KC_7, KC_8, KC_9, AROBAS,  OCTHRP, EQUAL,  L_THAN, G_THAN, QUESTION,
                       VVVV, VVVV, VVVV,    VVVV,   VVVV,   PIPE
    ),
    [_NAVCTL] = LAYOUT(
        // WM                                        // Terminal
        KC_VOLD, KC_VOLU, PPLAY, KC_WBAK, KC_WFWD,   ____, LTTAB,   KC_UP,   RTTAB,   NTTAB,
        KC_LSFT, DESK1,   DESK2, DESK3,   FOCMN,     ____, KC_LEFT, KC_DOWN, KC_RGHT, HSPLT,
        RCLK,    MCLK,    ____,  ____,    FOCWN,     ____, MXPAN,   FOCUS,   TSEAR,   THIST,
                       DPI_RMOD, SNP_TOG, DPI_MOD,   XXXX, ____,   ____
    ),
};

// Symbol & special combos
const uint16_t PROGMEM tab[]      = {KC_A, KC_F, COMBO_END};
const uint16_t PROGMEM escape[]   = {KC_S, KC_F, COMBO_END};
const uint16_t PROGMEM minus[]    = {KC_U, KC_O, COMBO_END};
const uint16_t PROGMEM bslash[]   = {KC_Y, KC_P, COMBO_END};
const uint16_t PROGMEM unscore[]  = {KC_M, KC_DOT, COMBO_END};
const uint16_t PROGMEM colon[]    = {KC_J, KC_SCLN, COMBO_END};

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
    COMBO(bslash, KC_BACKSLASH),

    COMBO(accent_aigu, RALT(KC_QUOTE)),
    COMBO(accent_grave, RALT(KC_GRAVE)),
    COMBO(accent_cflex, RALT(CARET)),
    COMBO(accent_cdill, RALT(KC_COMMA)),

    COMBO(mute, KC_MUTE),
};

// Browser
const key_override_t next_browser_tab = ko_make_basic(MOD_MASK_SHIFT, RTTAB, LCTL(KC_TAB));
const key_override_t prev_browser_tab = ko_make_basic(MOD_MASK_SHIFT, LTTAB, LCTL(LSFT(KC_TAB)));

// WM
const key_override_t move_win_mon = ko_make_basic(MOD_MASK_SHIFT, FOCMN, TOMON);
const key_override_t drag_win = ko_make_basic(MOD_MASK_SHIFT, LCLK, LGUI(LCLK));

// System
const key_override_t bright_up = ko_make_basic(MOD_MASK_SHIFT, KC_VOLU, KC_BRIGHTNESS_UP);
const key_override_t bright_down = ko_make_basic(MOD_MASK_SHIFT, KC_VOLD, KC_BRIGHTNESS_DOWN);

// Terminal
const key_override_t term_v_split = ko_make_basic(MOD_MASK_SHIFT, HSPLT, VSPLT);
const key_override_t term_name_tab = ko_make_basic(MOD_MASK_SHIFT, FOCUS, TNAME);
const key_override_t term_resize_win = ko_make_basic(MOD_MASK_SHIFT, MXPAN, TRSZE);

const key_override_t *key_overrides[] = {
    &next_browser_tab,
    &prev_browser_tab,
    &term_v_split,
    &term_name_tab,
    &term_resize_win,
    &move_win_mon,
    &drag_win,
    &bright_up,
    &bright_down,
};

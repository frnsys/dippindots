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
#define ENAV LT(_NAVCTL, KC_ENTER)
#define SSYM LT(_NUMSYM, KC_SPACE)
#define SCTL MT(MOD_LCTL, KC_SPACE)
#define BSFT MT(MOD_LSFT, KC_BSPC)
#define ALTTAB LALT(KC_TAB)
#define LSYM MO(_NUMSYM)
#define GQUOT MT(MOD_LGUI, KC_QUOTE)

#define DSYM LT(_NUMSYM, KC_D)
#define KSYM LT(_NUMSYM, KC_K)

// Mouse
#define LCLK MS_BTN1
#define RCLK MS_BTN2
#define MCLK MS_BTN3

// Symbols
#define L_PARN LSFT(KC_9)     // (
#define R_PARN LSFT(KC_0)     // )
#define L_BRCE LSFT(KC_LBRC)  // {
#define R_BRCE LSFT(KC_RBRC)  // }
#define PLUS LSFT(KC_EQL)     // +
#define TILDE LSFT(KC_GRV)    // ~
#define EXCLAMAPT LSFT(KC_1)  // !
#define AROBAS LSFT(KC_2)     // @
#define OCTHRP LSFT(KC_3)     // #
#define DOLLAR LSFT(KC_4)     // $
#define PERCENT LSFT(KC_5)    // %
#define CARET LSFT(KC_6)      // ^
#define AMPERSAND LSFT(KC_7)  // &
#define ASTERISK LSFT(KC_8)   // *
#define LTHAN LSFT(KC_COMMA)  // <
#define GTHAN LSFT(KC_DOT)    // >
#define QUOTE KC_QUOTE        // '
#define DBLQT LSFT(KC_QUOTE)  // "

// Window manager controls
#define DESK1 LGUI(KC_1)
#define DESK2 LGUI(KC_2)
#define DESK3 LGUI(KC_3)
#define MUSIC LGUI(KC_SCLN)
#define PPLAY LGUI(KC_EQL)
#define BMENU LGUI(KC_SPACE)
#define MAXIM LGUI(KC_F)       // Maximize window
#define FLOAT LGUI(KC_S)       // Toggle floating window
#define STICK LGUI(KC_Y)       // Toggle sticky window
#define TODOS LGUI(KC_T)
#define KPASS LGUI(KC_P)
#define FOCWN LGUI(KC_H)       // Change window focus
#define SINFO LGUI(KC_E)       // Show clock/battery notification
#define FOCMN LGUI(LCTL(KC_K)) // Change monitor focus
#define TOMON LGUI(LCTL(KC_M)) // Move window to monitor
#define CLOSE LGUI(LSFT(LALT(KC_Q))) // (Force) close pindow

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
#define TCOPY LSFT(LALT(KC_C)) // Terminal copy
#define TPAST LSFT(LALT(KC_P)) // Terminal paste
#define TLINK LSFT(LALT(KC_E)) // Terminal open link
#define TPATH LSFT(LALT(KC_O)) // Terminal copy path
#define TWORD LSFT(LALT(KC_F)) // Terminal copy word

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_ALPHA] = LAYOUT(
        KC_Q, KC_W, KC_E, KC_R, KC_T,       KC_Y, KC_U, KC_I,    KC_O,   KC_P,
        KC_A, KC_S, DSYM, KC_F, KC_G,       KC_H, KC_J, KSYM,    KC_L,   KC_SCLN,
        KC_Z, KC_X, KC_C, KC_V, KC_B,       KC_N, KC_M, KC_COMM, KC_DOT, KC_SLSH,
                    LCLK, BSFT, QUOTE,      ENAV, SCTL, GQUOT
    ),
    [_NUMSYM] = LAYOUT(
        KC_GRV, KC_1, KC_2, KC_3, DBLQT,    GTHAN,  PLUS,     L_PARN,  R_PARN,  TILDE,
        KC_0,   KC_4, KC_5, KC_6, QUOTE,    LTHAN,  KC_EQUAL, L_BRCE,  R_BRCE,  EXCLAMAPT,
        ____,   KC_7, KC_8, KC_9, ____,     OCTHRP, PERCENT,  KC_LBRC, KC_RBRC, AROBAS,
                      VVVV, VVVV, VVVV,     VVVV,   XXXX,     VVVV
    ),
    [_NAVCTL] = LAYOUT(
        // WM                                     // Terminal
        KC_VOLD, KC_VOLU, MUSIC, PPLAY, BMENU,    HSPLT, LTTAB,   KC_UP,   RTTAB,   TPAST,
        KC_LSFT, DESK1,   DESK2, DESK3, FOCMN,    ____,  KC_LEFT, KC_DOWN, KC_RGHT, TCOPY,
        SNP_TOG, FOCWN,   TODOS, ____,  MAXIM,    THIST, MXPAN,   FOCUS,   TSEAR,   TWORD,
                          ____,  ____,  ____,     XXXX,  ____,    ALTTAB
    ),
};

// Symbol & special combos
const uint16_t PROGMEM tab[]      = {KC_A, KC_F, COMBO_END};
const uint16_t PROGMEM escape[]   = {KC_S, KC_F, COMBO_END};
const uint16_t PROGMEM minus[]    = {KC_U, KC_O, COMBO_END};
const uint16_t PROGMEM pipe[]     = {KC_U, KC_P, COMBO_END};
const uint16_t PROGMEM bslash[]   = {KC_Y, KC_P, COMBO_END};
const uint16_t PROGMEM unscore[]  = {KC_M, KC_DOT, COMBO_END};
const uint16_t PROGMEM colon[]    = {KC_J, KC_SCLN, COMBO_END};
const uint16_t PROGMEM ampers[]   = {KC_W, KC_R, COMBO_END};
const uint16_t PROGMEM asterisk[] = {KC_Q, KC_R, COMBO_END};

// Accented inputs
const uint16_t PROGMEM accent_aigu[]   = {KC_Q, KC_T, COMBO_END};
const uint16_t PROGMEM accent_grave[]  = {KC_Q, KC_G, COMBO_END};
const uint16_t PROGMEM accent_cflex[]  = {KC_Z, KC_G, COMBO_END};
const uint16_t PROGMEM accent_cdill[]  = {KC_Z, KC_B, COMBO_END};

// Terminal control combos
const uint16_t PROGMEM term_new_tab[]  = {LTTAB, RTTAB, COMBO_END};

// WM controls
const uint16_t PROGMEM mute[] = {KC_VOLD, KC_VOLU, COMBO_END};
const uint16_t PROGMEM rclick[] = {KC_Z, LCLK, COMBO_END};
const uint16_t PROGMEM mclick[] = {KC_A, LCLK, COMBO_END};
const uint16_t PROGMEM show_info[] = {DESK1, DESK3, COMBO_END};

combo_t key_combos[] = {
    COMBO(tab, KC_TAB),
    COMBO(escape, KC_ESC),
    COMBO(minus, KC_MINUS),
    COMBO(unscore, LSFT(KC_MINUS)),
    COMBO(colon, LSFT(KC_SCLN)),
    COMBO(pipe, LSFT(KC_BACKSLASH)),
    COMBO(bslash, KC_BACKSLASH),
    COMBO(ampers, AMPERSAND),
    COMBO(asterisk, ASTERISK),

    COMBO(accent_aigu, RALT(KC_QUOTE)),
    COMBO(accent_grave, RALT(KC_GRAVE)),
    COMBO(accent_cflex, RALT(CARET)),
    COMBO(accent_cdill, RALT(KC_COMMA)),

    COMBO(term_new_tab, NTTAB),

    COMBO(mute, KC_MUTE),
    COMBO(rclick, RCLK),
    COMBO(mclick, MCLK),
    COMBO(show_info, SINFO),
};

// Vim
const key_override_t dollar = ko_make_basic(MOD_MASK_SHIFT, KC_DOT, DOLLAR);
const key_override_t caret = ko_make_basic(MOD_MASK_SHIFT, KC_COMM, CARET);

// Browser
const key_override_t next_browser_tab = ko_make_basic(MOD_MASK_SHIFT, RTTAB, LCTL(KC_TAB));
const key_override_t prev_browser_tab = ko_make_basic(MOD_MASK_SHIFT, LTTAB, LCTL(LSFT(KC_TAB)));
const key_override_t browser_forward = ko_make_basic(MOD_MASK_SHIFT, KC_RIGHT, KC_WFWD);
const key_override_t browser_backward = ko_make_basic(MOD_MASK_SHIFT, KC_LEFT, KC_WBAK);

// WM
const key_override_t move_win_mon = ko_make_basic(MOD_MASK_SHIFT, FOCMN, TOMON);
const key_override_t float_win = ko_make_basic(MOD_MASK_SHIFT, MAXIM, FLOAT);
const key_override_t stick_win = ko_make_basic(MOD_MASK_SHIFT, FOCWN, STICK);
const key_override_t close_win = ko_make_basic(MOD_MASK_SHIFT, BMENU, CLOSE);
const key_override_t drag_win = ko_make_basic(MOD_MASK_SHIFT, LCLK, LGUI(LCLK));

// System
const key_override_t bright_up = ko_make_basic(MOD_MASK_SHIFT, KC_VOLU, KC_BRIGHTNESS_UP);
const key_override_t bright_down = ko_make_basic(MOD_MASK_SHIFT, KC_VOLD, KC_BRIGHTNESS_DOWN);

// Terminal
const key_override_t select_term_path = ko_make_basic(MOD_MASK_SHIFT, TWORD, TPATH);
const key_override_t term_v_split = ko_make_basic(MOD_MASK_SHIFT, HSPLT, VSPLT);
const key_override_t term_name_tab = ko_make_basic(MOD_MASK_SHIFT, THIST, TNAME);
const key_override_t term_resize_win = ko_make_basic(MOD_MASK_SHIFT, MXPAN, TRSZE);

const key_override_t *key_overrides[] = {
    &dollar,
    &caret,
    &next_browser_tab,
    &prev_browser_tab,
    &browser_forward,
    &browser_backward,
    &select_term_path,
    &term_v_split,
    &term_name_tab,
    &term_resize_win,
    &move_win_mon,
    &drag_win,
    &float_win,
    &stick_win,
    &close_win,
    &bright_up,
    &bright_down,
};

// Design notes
// ------------
//
// Symbols:
// - Punctuation that is almost always followed by whitespace (space or enter): ,!?:;
//  - `=` is kind of a special case, since it's frequently surrounded by spaces
//  - As such these are ok for combos as long as it allows for easily following up with space or enter
// - Punctuation that is often interleaved between other characters and/or repeated: -_/.'
//  - We could also include the "surrounding puncutation" below here.
//  - As such these are less ideal for combos, since combos are flow-interrupting and awkward ro repeat.
// - Other punctuation that is relatively rare: @*\%~$#]^|
// - Surrounding punctuation:
//  - "'`
//  - [](){}<>
// - Used frequently with numbers: -+.*
//
// - Rare alpha keys: QZX, though often used in shortcuts
//  - But their rarity means they are infrequent in bigrams and so they can be rolled with mods with less issue

#include QMK_KEYBOARD_H

// For accented characters
#include "keymap_us_international.h"
#include "sendstring_us_international.h"

enum layers {
    _ALPHA,
    _NUMSYM,
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

#define DSYM LT(_NUMSYM, KC_D)
#define KSYM LT(_NUMSYM, KC_K)

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
#define SCOLN KC_SCOLN       // ;
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
#define T_PREV LALT(KC_L_BRC)    // Prev term tab
#define T_NEXT LALT(KC_R_BRC)    // Next term tab
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

#include "blender.c"

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_ALPHA] = LAYOUT(
        KC_Q, KC_W, KC_E,  KC_R, KC_T,     KC_Y, KC_U, KC_I,  KC_O,   KC_P,
        KC_A, KC_S, DSYM,  KC_F, KC_G,     KC_H, KC_J, KSYM,  KC_L,   SCOLN,
        KC_Z, KC_X, KC_C,  KC_V, KC_B,     KC_N, KC_M, COMMA, KC_DOT, SLASH,
                    L_CLK, SHFT, BNAV,     ENAV, SCTL, META
    ),

    [_NUMSYM] = LAYOUT(
        PLUS,  KC_1, KC_2, KC_3,   MINUS,   AROBA, OCTHP, L_BRK, R_BRK, ____,
        ASTRK, KC_4, KC_5, KC_6,   KC_0,    PIPE,  L_BRC, L_PAR, R_PAR, R_BRC,
        CARET, KC_7, KC_8, KC_9,   DOLAR,   TILDE, ____,  L_THN, G_THN, GRAVE,
                    PRCNT, KC_DOT, VVVV,    ____,  VVVV,  BSLSH
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
// Note: Try to avoid combos that are common rolls,
// e.g. `re`, `ef`, `es`, `as`, `io`, etc,
// otherwise you may frequently accidentally trigger the combo.
// This is less true for combos which are further apart and thus
// harder to roll w/in the combo term, e.g. `af`.
//
// Also avoid `jk` as I map this to escape in vim.
const uint16_t PROGMEM tab[]      = {KC_A, KC_F, COMBO_END};
const uint16_t PROGMEM escape[]   = {KC_S, KC_F, COMBO_END};
const uint16_t PROGMEM minus[]    = {KSYM, KC_H, COMBO_END};
const uint16_t PROGMEM unscore[]  = {KSYM, KC_M, COMBO_END};
const uint16_t PROGMEM colon[]    = {KSYM, KC_L, COMBO_END};
// const uint16_t PROGMEM quote[]    = {KC_O, KC_J, COMBO_END};
const uint16_t PROGMEM dblquote[]    = {KC_J, KC_L, COMBO_END};
const uint16_t PROGMEM question[]    = {KC_L, KC_M, COMBO_END};
// const uint16_t PROGMEM equal[]       = {KC_J, KC_I, COMBO_END};
const uint16_t PROGMEM equal[]       = {KC_O, KC_J, COMBO_END};
const uint16_t PROGMEM pipe[]        = {KC_COMMA, KC_DOT, COMBO_END};
const uint16_t PROGMEM grave[]       = {KC_S, DSYM, COMBO_END};
const uint16_t PROGMEM ampersand[]   = {DSYM, KC_F, COMBO_END};
const uint16_t PROGMEM exclamation[] = {KC_F, KC_W, COMBO_END};
const uint16_t PROGMEM mute[] = {KC_VOLD, KC_VOLU, COMBO_END};

// TODO try using dead keys from us intl layout
const uint16_t PROGMEM accent_aigu[]   = {KC_Q, KC_T, COMBO_END};
const uint16_t PROGMEM accent_grave[]  = {KC_Q, KC_G, COMBO_END};
const uint16_t PROGMEM accent_cflex[]  = {KC_Z, KC_G, COMBO_END};
const uint16_t PROGMEM accent_cdill[]  = {KC_Z, KC_B, COMBO_END};

combo_t key_combos[] = {
    // HIGHER TERM----
    // COMBO(unscore, USCOR),
    COMBO(exclamation, EXCLM),
    COMBO(escape, KC_ESC),
    // ----END HIGHER TERM

    COMBO(tab, KC_TAB),
    // COMBO(minus, KC_MINUS),
    COMBO(colon, LSFT(KC_SCLN)),
    // COMBO(quote, QUOTE),
    // COMBO(dblquote, DBLQT),
    COMBO(equal, EQUAL),
    // COMBO(pipe, PIPE),
    COMBO(ampersand, AMPER),
    COMBO(question, QMARK),
    // COMBO(grave, KC_GRAVE),

    // TODO have a separate accent dead key layer?
    COMBO(accent_aigu, RALT(KC_QUOTE)),
    COMBO(accent_grave, RALT(KC_GRAVE)),
    COMBO(accent_cflex, RALT(CARET)),
    COMBO(accent_cdill, RALT(KC_COMMA)),

    COMBO(mute, KC_MUTE),
};

// For combos that are infrequent rolls but trickier to fire
// we can bump up the combo term so there are fewer misfires.
uint16_t get_combo_term(uint16_t combo_index, combo_t *combo) {
    if (combo_index <=2) {
        return 60;
    } else {
        return COMBO_TERM;
    }
}


// ----Shifts-----------------------
// <s-;> -> '
// <s-/> -> "
// <s-,> -> -
// <s-.> -> _
const key_override_t s_minus = ko_make_basic(MOD_MASK_SHIFT, KC_COMMA, MINUS);
const key_override_t s_uscore = ko_make_basic(MOD_MASK_SHIFT, KC_DOT, USCOR);
const key_override_t s_quote = ko_make_basic(MOD_MASK_SHIFT, KC_SCLN, QUOTE);
const key_override_t s_dblquote = ko_make_basic(MOD_MASK_SHIFT, KC_SLSH, DBLQT);

// System
const key_override_t bright_up = ko_make_basic(MOD_MASK_SHIFT, KC_VOLU, KC_BRIGHTNESS_UP);
const key_override_t bright_down = ko_make_basic(MOD_MASK_SHIFT, KC_VOLD, KC_BRIGHTNESS_DOWN);
const key_override_t move_win_mon = ko_make_basic(MOD_MASK_SHIFT, FOCMN, TOMON);
const key_override_t mouse_speed_up = ko_make_basic(MOD_MASK_SHIFT, MS_DN, MS_UP);

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

    &s_minus,
    &s_uscore,
    &s_quote,
    &s_dblquote,

    &term_name_tab,
    &term_resize_win,

    &next_browser_tab,
    &prev_browser_tab,
};

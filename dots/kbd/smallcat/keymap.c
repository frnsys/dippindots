#include QMK_KEYBOARD_H
#define LAYOUT LAYOUT_split_3x5_2

enum layers {
    ALPHA,SYMBOL,NUMBER,NAVCTL
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [ALPHA] = LAYOUT(
        KC_L, KC_D, KC_W, KC_F, KC_O, KC_U, KC_N, KC_S, LT(SYMBOL, KC_T), KC_R, KC_G, KC_Y, KC_H, LT(NUMBER, KC_A), KC_E, KC_I, KC_QUOTE, KC_C, KC_P, KC_M, KC_COMMA, KC_DOT, KC_LSFT, MT(MOD_LGUI, KC_BSPC), LT(NAVCTL, KC_ENTER), MT(MOD_LCTL, KC_SPACE)
    ),
    [SYMBOL] = LAYOUT(
        LCTL(KC_C), KC_NO, LCTL(KC_V), LSFT(KC_3), KC_LBRC, KC_RBRC, KC_SLSH, LSFT(KC_8), KC_NO, KC_GRAVE, LSFT(KC_GRV), LSFT(KC_2), LSFT(KC_LBRC), LSFT(KC_9), LSFT(KC_0), LSFT(KC_RBRC), KC_NO, KC_NO, KC_NO, LSFT(KC_SLSH), LSFT(KC_COMMA), LSFT(KC_DOT), KC_TAB, LSFT(KC_7), LSFT(KC_1), KC_SCLN
    ),
    [NUMBER] = LAYOUT(
        KC_1, KC_2, KC_3, RALT(KC_COMMA), KC_NO, RALT(LSFT(KC_6)), LSFT(KC_6), KC_4, KC_5, KC_6, LSFT(KC_4), RALT(KC_EQUAL), LSFT(KC_EQL), KC_NO, LSFT(KC_5), RALT(KC_QUOTE), KC_7, KC_8, KC_9, RALT(KC_GRAVE), KC_NO, RALT(LSFT(KC_QUOTE)), KC_0, LSFT(KC_BSLS), KC_NO, KC_BACKSLASH
    ),
    [NAVCTL] = LAYOUT(
        LGUI(LSFT(KC_RIGHT)), LGUI(LCTL(KC_K)), LGUI(LSFT(KC_LEFT)), LALT(KC_LBRC), KC_UP, LALT(KC_RBRC), KC_LSFT, LGUI(KC_1), LGUI(KC_2), LGUI(KC_3), LCTL(KC_Z), LALT(KC_MINUS), KC_LEFT, KC_DOWN, KC_RIGHT, LALT(KC_T), KC_VOLD, LGUI(KC_EQL), KC_VOLU, LALT(KC_M), LALT(KC_W), LALT(KC_QUOTE), LGUI(KC_SPACE), LGUI(KC_H), KC_NO, KC_NO
    )
};

const uint16_t PROGMEM combo_0[] = {KC_H, KC_E, COMBO_END};
const uint16_t PROGMEM combo_1[] = {KC_C, KC_P, COMBO_END};
const uint16_t PROGMEM combo_2[] = {KC_H, LT(NUMBER, KC_A), COMBO_END};
const uint16_t PROGMEM combo_3[] = {KC_F, KC_O, COMBO_END};
const uint16_t PROGMEM combo_4[] = {KC_L, KC_D, COMBO_END};
const uint16_t PROGMEM combo_5[] = {KC_R, KC_S, COMBO_END};
const uint16_t PROGMEM combo_6[] = {KC_QUOTE, KC_C, COMBO_END};
const uint16_t PROGMEM combo_7[] = {KC_S, LT(SYMBOL, KC_T), COMBO_END};
const uint16_t PROGMEM combo_8[] = {LT(NUMBER, KC_A), KC_E, COMBO_END};
const uint16_t PROGMEM combo_9[] = {KC_D, KC_W, COMBO_END};
const uint16_t PROGMEM combo_10[] = {KC_VOLD, KC_VOLU, COMBO_END};
combo_t key_combos[] = {
    COMBO(combo_0, KC_EQL),
    COMBO(combo_1, KC_V),
    COMBO(combo_2, KC_K),
    COMBO(combo_3, KC_J),
    COMBO(combo_4, KC_Q),
    COMBO(combo_5, KC_ESC),
    COMBO(combo_6, KC_X),
    COMBO(combo_7, KC_B),
    COMBO(combo_8, LSFT(KC_SCLN)),
    COMBO(combo_9, KC_Z),
    COMBO(combo_10, KC_MUTE)
};

const key_override_t shift_0 = ko_make_basic(MOD_MASK_SHIFT, KC_DOT, LSFT(KC_MINUS));
const key_override_t shift_1 = ko_make_basic(MOD_MASK_SHIFT, KC_COMMA, KC_MINUS);
const key_override_t shift_2 = ko_make_basic(MOD_MASK_SHIFT, KC_QUOTE, LSFT(KC_QUOTE));
const key_override_t shift_3 = ko_make_basic(MOD_MASK_SHIFT, LALT(KC_MINUS), LALT(KC_BACKSLASH));
const key_override_t shift_4 = ko_make_basic(MOD_MASK_SHIFT, KC_VOLU, KC_BRIGHTNESS_UP);
const key_override_t shift_5 = ko_make_basic(MOD_MASK_SHIFT, LGUI(LCTL(KC_K)), LGUI(LCTL(KC_M)));
const key_override_t shift_6 = ko_make_basic(MOD_MASK_SHIFT, LGUI(KC_3), LGUI(LSFT(KC_3)));
const key_override_t shift_7 = ko_make_basic(MOD_MASK_SHIFT, LGUI(KC_EQL), LGUI(KC_EQL));
const key_override_t shift_8 = ko_make_basic(MOD_MASK_SHIFT, KC_VOLD, KC_BRIGHTNESS_DOWN);
const key_override_t shift_9 = ko_make_basic(MOD_MASK_SHIFT, LCTL(KC_Z), LCTL(LSFT(KC_Z)));
const key_override_t shift_10 = ko_make_basic(MOD_MASK_SHIFT, LGUI(KC_1), LGUI(LSFT(KC_1)));
const key_override_t shift_11 = ko_make_basic(MOD_MASK_SHIFT, LGUI(KC_2), LGUI(LSFT(KC_2)));
const key_override_t shift_12 = ko_make_basic(MOD_MASK_SHIFT, LALT(KC_T), LALT(KC_E));
const key_override_t *key_overrides[] = {
    &shift_0,
    &shift_1,
    &shift_2,
    &shift_3,
    &shift_4,
    &shift_5,
    &shift_6,
    &shift_7,
    &shift_8,
    &shift_9,
    &shift_10,
    &shift_11,
    &shift_12
};


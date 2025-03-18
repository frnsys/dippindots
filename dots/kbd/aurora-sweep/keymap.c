#include QMK_KEYBOARD_H
#define LAYOUT LAYOUT_split_3x5_2


// Disable Liatris power LED
#include "gpio.h"
void keyboard_pre_init_user(void) {
    gpio_set_pin_output(24);
    gpio_write_pin_high(24);
}


enum layers {
    ALPHA,SYMBOL,NUMBER,NAVCTL
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [ALPHA] = LAYOUT(
        KC_Q, KC_W, KC_E, KC_R, LT(SYMBOL, KC_T), KC_Y, KC_U, KC_I, KC_O, KC_P, LT(NUMBER, KC_A), KC_S, KC_D, KC_F, KC_G, KC_H, KC_J, KC_K, KC_L, KC_QUOTE, KC_Z, KC_X, KC_C, KC_V, KC_B, KC_N, KC_M, KC_COMMA, KC_DOT, KC_SLSH, KC_LSFT, MT(MOD_LGUI, KC_BSPC), LT(NAVCTL, KC_ENTER), MT(MOD_LCTL, KC_SPACE)
    ),
    [SYMBOL] = LAYOUT(
        KC_NO, LCTL(KC_C), KC_NO, LCTL(KC_V), KC_NO, KC_NO, LSFT(KC_3), KC_LBRC, KC_RBRC, KC_NO, KC_SLSH, LSFT(KC_8), KC_NO, KC_GRAVE, LSFT(KC_GRV), LSFT(KC_2), LSFT(KC_LBRC), LSFT(KC_9), LSFT(KC_0), LSFT(KC_RBRC), KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, LSFT(KC_SLSH), LSFT(KC_COMMA), LSFT(KC_DOT), KC_NO, KC_TAB, LSFT(KC_7), LSFT(KC_1), KC_SCLN
    ),
    [NUMBER] = LAYOUT(
        KC_NO, KC_1, KC_2, KC_3, KC_NO, KC_NO, RALT(KC_COMMA), KC_NO, RALT(LSFT(KC_6)), KC_NO, LSFT(KC_6), KC_4, KC_5, KC_6, LSFT(KC_4), RALT(KC_EQUAL), LSFT(KC_EQL), KC_NO, LSFT(KC_5), RALT(KC_QUOTE), KC_NO, KC_7, KC_8, KC_9, KC_NO, KC_NO, RALT(KC_GRAVE), KC_NO, RALT(LSFT(KC_QUOTE)), KC_NO, KC_0, LSFT(KC_BSLS), KC_NO, KC_BACKSLASH
    ),
    [NAVCTL] = LAYOUT(
        KC_NO, LGUI(LSFT(KC_RIGHT)), LGUI(LCTL(KC_K)), LGUI(LSFT(KC_LEFT)), KC_NO, KC_NO, LALT(KC_LBRC), KC_UP, LALT(KC_RBRC), KC_NO, KC_LSFT, LGUI(KC_1), LGUI(KC_2), LGUI(KC_3), LCTL(KC_Z), LALT(KC_MINUS), KC_LEFT, KC_DOWN, KC_RIGHT, LALT(KC_T), KC_NO, KC_VOLD, LGUI(KC_EQL), KC_VOLU, KC_NO, KC_NO, LALT(KC_M), LALT(KC_W), LALT(KC_QUOTE), KC_NO, LGUI(KC_SPACE), LGUI(KC_H), KC_NO, KC_NO
    )
};

const uint16_t PROGMEM combo_0[] = {KC_J, KC_L, COMBO_END};
const uint16_t PROGMEM combo_1[] = {KC_S, KC_F, COMBO_END};
const uint16_t PROGMEM combo_2[] = {KC_K, KC_L, COMBO_END};
const uint16_t PROGMEM combo_3[] = {KC_VOLD, KC_VOLU, COMBO_END};
combo_t key_combos[] = {
    COMBO(combo_0, KC_EQL),
    COMBO(combo_1, KC_ESC),
    COMBO(combo_2, LSFT(KC_SCLN)),
    COMBO(combo_3, KC_MUTE)
};

const key_override_t shift_0 = ko_make_basic(MOD_MASK_SHIFT, KC_QUOTE, LSFT(KC_QUOTE));
const key_override_t shift_1 = ko_make_basic(MOD_MASK_SHIFT, KC_COMMA, KC_MINUS);
const key_override_t shift_2 = ko_make_basic(MOD_MASK_SHIFT, KC_SLSH, LSFT(KC_BSLS));
const key_override_t shift_3 = ko_make_basic(MOD_MASK_SHIFT, KC_DOT, LSFT(KC_MINUS));
const key_override_t shift_4 = ko_make_basic(MOD_MASK_SHIFT, KC_VOLD, KC_BRIGHTNESS_DOWN);
const key_override_t shift_5 = ko_make_basic(MOD_MASK_SHIFT, KC_VOLU, KC_BRIGHTNESS_UP);
const key_override_t shift_6 = ko_make_basic(MOD_MASK_SHIFT, LGUI(KC_2), LGUI(LSFT(KC_2)));
const key_override_t shift_7 = ko_make_basic(MOD_MASK_SHIFT, LCTL(KC_Z), LCTL(LSFT(KC_Z)));
const key_override_t shift_8 = ko_make_basic(MOD_MASK_SHIFT, LGUI(KC_3), LGUI(LSFT(KC_3)));
const key_override_t shift_9 = ko_make_basic(MOD_MASK_SHIFT, LGUI(KC_1), LGUI(LSFT(KC_1)));
const key_override_t shift_10 = ko_make_basic(MOD_MASK_SHIFT, LALT(KC_MINUS), LALT(KC_BACKSLASH));
const key_override_t shift_11 = ko_make_basic(MOD_MASK_SHIFT, LALT(KC_T), LALT(KC_E));
const key_override_t shift_12 = ko_make_basic(MOD_MASK_SHIFT, LGUI(LCTL(KC_K)), LGUI(LCTL(KC_M)));
const key_override_t shift_13 = ko_make_basic(MOD_MASK_SHIFT, LGUI(KC_EQL), LGUI(KC_EQL));
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
    &shift_12,
    &shift_13
};


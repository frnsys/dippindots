#pragma once

// bkb-dilemma-specific features.
// #undef RGB_MATRIX_ENABLE
// #undef ENCODER_ENABLE

// Set the mouse settings to a comfortable speed/accuracy trade-off,
// assuming a screen refresh rate of 60 Htz or higher
// The default is 50. This makes the mouse ~3 times faster and more accurate
#define MOUSEKEY_INTERVAL 16
// The default is 20. Since we made the mouse about 3 times faster with the previous setting,
// give it more time to accelerate to max speed to retain precise control over short distances.
#define MOUSEKEY_TIME_TO_MAX 40
// The default is 300. Let's try and make this as low as possible while keeping the cursor responsive
#define MOUSEKEY_DELAY 100
// It makes sense to use the same delay for the mouseweel
#define MOUSEKEY_WHEEL_DELAY 100
// The default is 100
#define MOUSEKEY_WHEEL_INTERVAL 50
// The default is 40
#define MOUSEKEY_WHEEL_TIME_TO_MAX 100

// Pointer sensitivity
#define DILEMMA_MINIMUM_DEFAULT_DPI 300

#define TAPPING_TERM 150
#define PERMISSIVE_HOLD
// #define HOLD_ON_OTHER_KEY_PRESS
#define QUICK_TAP_TERM 120
#define RETRO_TAPPING

#define COMBO_TERM 30  // Milliseconds allowed to press combo keys
#define COMBO_MUST_HOLD  // Require holding each combo key

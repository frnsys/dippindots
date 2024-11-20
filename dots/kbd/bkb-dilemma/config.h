#pragma once

// Pointer sensitivity
#define DILEMMA_MINIMUM_DEFAULT_DPI 200
#define DILEMMA_DEFAULT_DPI_CONFIG_STEP 200
#define DILEMMA_MINIMUM_SNIPING_DPI 200
#define DILEMMA_SNIPING_DPI_CONFIG_STEP 100

// How long the key must be pressed down to
// be registered as a hold.
//
// Higher values mean it's harder to trigger
// the hold function.
#define TAPPING_TERM 165

// Double-tap under this duration to trigger
// hold-and-repeat.
#define QUICK_TAP_TERM 120

#define RETRO_TAPPING
#define PERMISSIVE_HOLD
#define HOLD_ON_OTHER_KEYPRESS

// Milliseconds allowed to press combo keys.
// Lower if this if rolling keys often triggers combos.
#define COMBO_TERM 30
#define COMBO_MUST_HOLD_MODS // Require holding each combo key for mods

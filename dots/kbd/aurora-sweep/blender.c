// A: Select all
// Alt-A: Unselect all
// Shift-A: Add menu
// Ctrl-A: Apply menu

// X: Delete
// Alt-X: Unhide*
// Shift-X: Hide selected*
// Ctrl-X: Hide unselected*
// When transforming: X-axis lock
//  - Double-press for local

// Y: Fly mode*
// Alt-Y: Frame all*
// Shift-Y: Frame selected*
// Ctrl-Y: View pie menu*
// When transforming: Y-axis lock
//  - Double-press for local

// Z: Save selection*
// Alt-Z: Selection pie menu*
// Shift-Z: Restore selection*
// Ctrl-Z: Toggle selection*
// When transforming: Z-axis lock
//  - Double-press for local

// S: Scale
// Alt-S: Clear scale
// Shift-S: Scale to match*
// Ctrl-S: Save

// R: Rotate
// Alt-R: Clear rotation
// Shift-R: Pivot pie menu
// Ctrl-R: Object menu

// G: Translate
// Alt-G: Move to world origin (clear translation)
// Shift-G: Select grouped
// Ctrl-G: Group

// D: Toggle sidebar*
// Alt-D: Duplicate linked
// Shift-D: Duplicate
// Ctrl-D: Drop It*

// Q: Orientation menu (local/global)*
// Alt-Q: Quick favorites*
// Shift-Q: Gliss props panel*
// Ctrl-Q: Quit

// ;: Bagapie*
// Alt-;: BlenderKit asset search*
// Shift-;: Bagapie Geopack*
// Ctrl-;: Bagapie Tools*

#define BL_MAX LCTL(KC_SPACE)         // Maximize view
#define BL_AQM MT(MOD_LALT, BL_MAX)   // Hold:Alt / Tap:Maximize View
#define BL_STB MT(MOD_LSFT, KC_TAB)   // Hold:Shift / Tap:Tab
#define BL_CMX MT(MOD_LCTL, KC_ENTER) // Hold:Ctrl / Tap:Enter
#define BL_UNDO LCTL(KC_U) // Undo/Redo; see remap notes below.

#define BLENDER_MAP LAYOUT( \
    KC_Q,    ____, ____,  ____,   BL_AQM,   ____, ____, ____, ____, ____, \
    KC_A,    KC_S, KC_R,  KC_G,   KC_D,     ____, ____, ____, ____, ____, \
    BL_UNDO, KC_X, KC_Y,  KC_Z,   KC_SCLN,  ____, ____, ____, ____, ____, \
                          BL_STB, BL_CMX,   ____, ____ \
)

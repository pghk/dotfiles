#include QMK_KEYBOARD_H
#include "version.h"
#define MOON_LED_LEVEL LED_LEVEL
#ifndef ZSA_SAFE_RANGE
#define ZSA_SAFE_RANGE SAFE_RANGE
#endif

enum custom_keycodes {
  MAC_SIRI = ZSA_SAFE_RANGE,
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [0] = LAYOUT_voyager(
    OSL(3),         KC_1,           KC_2,           KC_3,           KC_4,           KC_5,                                           KC_6,           KC_7,           KC_8,           KC_9,           KC_0,           MAC_SIRI,       
    KC_TAB,         KC_Q,           KC_W,           KC_E,           KC_R,           KC_T,                                           KC_Y,           KC_U,           KC_I,           KC_O,           KC_P,           KC_BSLS,        
    MEH_T(KC_ESCAPE),KC_A,           KC_S,           KC_D,           KC_F,           KC_G,                                           KC_H,           KC_J,           KC_K,           KC_L,           KC_SCLN,        KC_QUOTE,       
    KC_LEFT_SHIFT,  KC_Z,           MT(MOD_LCTL, KC_X),MT(MOD_LALT, KC_C),MT(MOD_LGUI, KC_V),KC_B,                                           KC_N,           MT(MOD_RGUI, KC_M),MT(MOD_RALT, KC_COMMA),MT(MOD_RCTL, KC_DOT),KC_SLASH,       KC_RIGHT_SHIFT, 
                                                    OSM(MOD_LGUI),  OSL(2),                                         OSL(1),         KC_SPACE
  ),
  [1] = LAYOUT_voyager(
    KC_F1,          KC_F2,          KC_F3,          KC_F4,          KC_F5,          KC_F6,                                          KC_F7,          KC_F8,          KC_F9,          KC_F10,         KC_F11,         KC_F12,
    KC_HASH,        KC_CIRC,        KC_EQUAL,       KC_UNDS,        KC_DLR,         KC_ASTR,                                        KC_EXLM,        KC_LCBR,        KC_LPRN,        KC_RPRN,        KC_RCBR,        CW_TOGG,
    KC_TILD,        KC_LABK,        KC_PIPE,        KC_MINUS,       KC_RABK,        KC_PERC,                                        C(S(KC_TAB)),   C(KC_TAB),      KC_LBRC,        KC_RBRC,        KC_TRANSPARENT, KC_TRANSPARENT,
    KC_TRANSPARENT, KC_AMPR,        KC_AT,          KC_GRAVE,       KC_PLUS,        KC_BSLS,                                        G(C(KC_LBRC)),  G(C(KC_RBRC)),  G(KC_LBRC),     G(KC_RBRC),     KC_TRANSPARENT, KC_TRANSPARENT,
                                                    KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT
  ),
  [2] = LAYOUT_voyager(
    KC_BRID,        KC_BRIU,        KC_MCTL,        KC_LPAD,        RM_VALD,        RM_VALU,                                        KC_MPRV,        KC_MPLY,        KC_MNXT,        KC_MUTE,        KC_VOLD,        KC_VOLU,
    KC_TRANSPARENT, KC_TRANSPARENT, G(KC_LBRC),     C(S(KC_TAB)),   C(KC_TAB),      G(KC_RBRC),                                     G(KC_LEFT),     A(KC_LEFT),     KC_PGUP,        A(KC_RIGHT),    G(KC_RIGHT),    KC_HOME,
    TO(0),          G(KC_A),        OSM(MOD_LALT),  OSM(MOD_LGUI),  TG(4),          KC_TRANSPARENT,                                     KC_LEFT,        KC_DOWN,        KC_UP,          KC_RIGHT,       KC_TRANSPARENT, KC_TRANSPARENT,
    KC_TRANSPARENT, G(KC_Z),        G(KC_X),        G(KC_C),        G(KC_V),        G(S(KC_Z)),                                     G(KC_UP),       KC_BSPC,        KC_PGDN,        KC_DEL,         G(KC_DOWN),     KC_END,
                                                    KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT
  ),
  [3] = LAYOUT_voyager(
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_NO,          KC_KP_EQUAL,    KC_KP_SLASH,    KC_KP_ASTERISK, KC_TRANSPARENT, KC_BSPC,        
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_NO,          KC_KP_7,        KC_KP_8,        KC_KP_9,        KC_KP_MINUS,    KC_NO,          
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_NO,          KC_KP_4,        KC_KP_5,        KC_KP_6,        KC_KP_PLUS,     KC_KP_ENTER,    
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_SPACE,       KC_KP_1,        KC_KP_2,        KC_KP_3,        KC_KP_PLUS,     KC_TRANSPARENT, 
                                                    KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_KP_0,        KC_KP_DOT
  ),
  [4] = LAYOUT_voyager(
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 S(G(KC_LEFT)),  S(A(KC_LEFT)),  S(KC_PGUP),     S(A(KC_RIGHT)), S(G(KC_RIGHT)), S(KC_HOME),
    TO(0),          G(KC_A),        KC_TRANSPARENT, KC_TRANSPARENT, TG(4),          KC_TRANSPARENT,                                 S(KC_LEFT),     S(KC_DOWN),     S(KC_UP),       S(KC_RIGHT),    KC_TRANSPARENT, KC_TRANSPARENT,
    KC_TRANSPARENT, G(KC_Z),        G(KC_X),        G(KC_C),        G(KC_V),        KC_TRANSPARENT,                                 S(G(KC_UP)),    KC_BSPC,        S(KC_PGDN),     KC_DEL,         S(G(KC_DOWN)),  S(KC_END),
                                                    KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT
  ),
};

const char chordal_hold_layout[MATRIX_ROWS][MATRIX_COLS] PROGMEM = LAYOUT(
  'L', 'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R', 'R', 
  'L', 'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R', 'R', 
  'L', 'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R', 'R', 
  'L', 'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R', 'R', 
  'L', 'L', 'R', 'R'
);

const uint16_t PROGMEM combo0[] = { KC_K, KC_J, COMBO_END};
const uint16_t PROGMEM combo1[] = { KC_D, KC_F, COMBO_END};
const uint16_t PROGMEM combo2[] = { KC_I, KC_U, COMBO_END};

combo_t key_combos[COMBO_COUNT] = {
    COMBO(combo0, KC_ENTER),
    COMBO(combo1, OSL(1)),
    COMBO(combo2, KC_BSPC),
};


extern rgb_config_t rgb_matrix_config;

RGB hsv_to_rgb_with_value(HSV hsv) {
  RGB rgb = hsv_to_rgb( hsv );
  float f = (float)rgb_matrix_config.hsv.v / UINT8_MAX;
  return (RGB){ f * rgb.r, f * rgb.g, f * rgb.b };
}

void keyboard_post_init_user(void) {
  rgb_matrix_enable();
}

static const HSV WHITE  = {89, 93, 210};
static const HSV PURPLE = {197, 211, 194};
static const HSV BLUE   = {165, 237, 255};
static const HSV CYAN   = {114, 237, 255};
static const HSV ORANGE = {23, 247, 217};
static const HSV RED    = {252, 251, 150};
static const HSV GREEN  = {77, 247, 237};
static const HSV YELLOW = {46, 255, 255};
static const HSV GREY   = {81, 115, 163};
static const HSV DARK   = {0, 0, 0};

static uint16_t combo_output(uint16_t keycode) {
  for (uint16_t i = 0; i < COMBO_COUNT; i++) {
    for (const uint16_t *keys = key_combos[i].keys; pgm_read_word(keys) != COMBO_END; keys++) {
      if (pgm_read_word(keys) == keycode) {
        return key_combos[i].keycode;
      }
    }
  }
  return KC_NO;
}

static HSV mod_color(uint8_t mods) {
  if ((mods & MOD_MEH) == MOD_MEH) {
    return RED;
  }
  // A shortcut with several modifiers takes the most significant one's colour.
  if (mods & MOD_LGUI) {
    return PURPLE;
  }
  if (mods & MOD_LCTL) {
    return CYAN;
  }
  if (mods & MOD_LALT) {
    return BLUE;
  }
  return ORANGE;
}

static HSV key_color(uint16_t keycode) {
  switch (keycode) {
    case QK_TO ... QK_TO_MAX:
    case QK_TOGGLE_LAYER ... QK_TOGGLE_LAYER_MAX:
    case QK_ONE_SHOT_LAYER ... QK_ONE_SHOT_LAYER_MAX:
      return WHITE;
    case KC_LEFT_CTRL:
    case KC_RIGHT_CTRL:
      return CYAN;
    case KC_LEFT_SHIFT:
    case KC_RIGHT_SHIFT:
    case CW_TOGG:
      return ORANGE;
    case KC_LEFT_ALT:
    case KC_RIGHT_ALT:
      return BLUE;
    case KC_LEFT_GUI:
    case KC_RIGHT_GUI:
      return PURPLE;
    case KC_RIGHT ... KC_UP:
    case KC_PGUP:
    case KC_PGDN:
    case KC_HOME:
    case KC_END:
    case KC_BSPC:
    case KC_DEL:
    case KC_ENTER:
    case KC_KP_ENTER:
      return GREEN;
    case KC_BRID:
    case KC_BRIU:
    case KC_MCTL:
    case KC_LPAD:
    case RM_VALD:
    case RM_VALU:
    case KC_MPRV:
    case KC_MPLY:
    case KC_MNXT:
    case KC_MUTE:
    case KC_VOLD:
    case KC_VOLU:
    case MAC_SIRI:
      return YELLOW;
    case KC_MINUS ... KC_SLASH:
    case KC_EXLM ... KC_RPRN:
    case KC_UNDS ... KC_QUES:
    case KC_KP_1 ... KC_KP_DOT:
      return GREY;
    // Inverse operations get opposite hues.
    case KC_KP_PLUS:
      return RED;
    case KC_KP_MINUS:
      return CYAN;
    case KC_KP_ASTERISK:
      return ORANGE;
    case KC_KP_SLASH:
      return BLUE;
    case KC_KP_EQUAL:
      return YELLOW;
  }
  if (IS_QK_MOD_TAP(keycode)) {
    return mod_color(QK_MOD_TAP_GET_MODS(keycode));
  }
  if (IS_QK_ONE_SHOT_MOD(keycode)) {
    return mod_color(QK_ONE_SHOT_MOD_GET_MODS(keycode));
  }
  if (IS_QK_MODS(keycode)) {
    return mod_color(QK_MODS_GET_MODS(keycode));
  }
  return DARK;
}

static HSV base_key_color(uint16_t keycode) {
  uint16_t output = combo_output(keycode);
  if (output != KC_NO) {
    return key_color(output);
  }
  // Base symbols are typed like letters, so only the other layers light them.
  if (keycode >= KC_MINUS && keycode <= KC_SLASH) {
    return DARK;
  }
  return key_color(keycode);
}

bool rgb_matrix_indicators_user(void) {
  if (keyboard_config.disable_layer_led) {
    if (rgb_matrix_get_flags() == LED_FLAG_NONE) {
      rgb_matrix_set_color_all(0, 0, 0);
    }
    return true;
  }
  uint8_t layer = get_highest_layer(layer_state);
  for (uint8_t row = 0; row < MATRIX_ROWS; row++) {
    for (uint8_t col = 0; col < MATRIX_COLS; col++) {
      uint8_t led = g_led_config.matrix_co[row][col];
      if (led == NO_LED) {
        continue;
      }
      keypos_t pos = {.row = row, .col = col};
      uint16_t keycode = keymap_key_to_keycode(layer, pos);
      uint16_t base_keycode = keymap_key_to_keycode(0, pos);
      // The key that opened a layer is also the way out of it.
      if (keycode == KC_TRANSPARENT && IS_QK_ONE_SHOT_LAYER(base_keycode) && QK_ONE_SHOT_LAYER_GET_LAYER(base_keycode) == layer) {
        keycode = base_keycode;
      }
      HSV hsv = layer == 0 ? base_key_color(keycode) : key_color(keycode);
      RGB rgb = hsv.v ? hsv_to_rgb_with_value(hsv) : (RGB){0, 0, 0};
      rgb_matrix_set_color(led, rgb.r, rgb.g, rgb.b);
    }
  }
  return true;
}

layer_state_t layer_state_set_user(layer_state_t state) {
  // A lock outliving its layer would make the layer key's next tap only unlock.
  if (get_oneshot_layer_state() == ONESHOT_TOGGLED && !(state & ((layer_state_t)1 << get_oneshot_layer()))) {
    reset_oneshot_layer();
  }
  return state;
}


bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
  case QK_MODS ... QK_MODS_MAX:
    // Mouse and consumer keys (volume, media) with modifiers work inconsistently across operating systems,
    // this makes sure that modifiers are always applied to the key that was pressed.
    if (IS_CONSUMER_KEYCODE(QK_MODS_GET_BASIC_KEYCODE(keycode))) {
      if (record->event.pressed) {
        add_mods(QK_MODS_GET_MODS(keycode));
        send_keyboard_report();
        wait_ms(2);
        register_code(QK_MODS_GET_BASIC_KEYCODE(keycode));
        return false;
      } else {
        wait_ms(2);
        del_mods(QK_MODS_GET_MODS(keycode));
      }
    }
    break;
    case MAC_SIRI:
      HCS(0xCF);

  }
  return true;
}

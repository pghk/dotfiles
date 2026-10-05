#include QMK_KEYBOARD_H
#include "version.h"
#define MOON_LED_LEVEL LED_LEVEL
#ifndef ZSA_SAFE_RANGE
#define ZSA_SAFE_RANGE SAFE_RANGE
#endif

enum custom_keycodes {
  RGB_SLD = ZSA_SAFE_RANGE,
  HSV_0_255_255,
  HSV_74_255_255,
  HSV_169_255_255,
  MAC_SIRI,
};



#define DUAL_FUNC_0 LT(11, KC_F14)
#define DUAL_FUNC_1 LT(8, KC_7)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [0] = LAYOUT_voyager(
    TT(3),          KC_1,           KC_2,           KC_3,           KC_4,           KC_5,                                           KC_6,           KC_7,           KC_8,           KC_9,           KC_0,           DUAL_FUNC_0,    
    KC_TAB,         KC_Q,           KC_W,           KC_E,           KC_R,           KC_T,                                           KC_Y,           KC_U,           KC_I,           KC_O,           KC_P,           KC_BSLS,        
    MEH_T(KC_ESCAPE),KC_A,           KC_S,           KC_D,           KC_F,           KC_G,                                           KC_H,           KC_J,           KC_K,           KC_L,           KC_SCLN,        KC_QUOTE,       
    KC_LEFT_SHIFT,  KC_Z,           MT(MOD_LCTL, KC_X),MT(MOD_LALT, KC_C),MT(MOD_LGUI, KC_V),KC_B,                                           KC_N,           MT(MOD_RGUI, KC_M),MT(MOD_RALT, KC_COMMA),MT(MOD_RCTL, KC_DOT),KC_SLASH,       KC_RIGHT_SHIFT, 
                                                    KC_LEFT_GUI,    OSL(2),                                         OSL(1),         KC_SPACE
  ),
  [1] = LAYOUT_voyager(
    KC_F1,          KC_F2,          KC_F3,          KC_F4,          KC_F5,          KC_F6,                                          KC_F7,          KC_F8,          KC_F9,          KC_F10,         KC_F11,         KC_F12,
    KC_HASH,        KC_CIRC,        KC_EQUAL,       KC_UNDS,        KC_DLR,         KC_ASTR,                                        KC_EXLM,        KC_LCBR,        KC_LPRN,        KC_RPRN,        KC_RCBR,        CW_TOGG,
    KC_TILD,        KC_LABK,        KC_PIPE,        KC_MINUS,       KC_RABK,        KC_PERC,                                        C(S(KC_TAB)),   C(KC_TAB),      KC_LBRC,        KC_RBRC,        KC_TRANSPARENT, KC_TRANSPARENT,
    KC_TRANSPARENT, KC_AMPR,        KC_AT,          KC_GRAVE,       KC_PLUS,        KC_BSLS,                                        G(C(KC_LBRC)),  G(C(KC_RBRC)),  G(KC_LBRC),     G(KC_RBRC),     KC_TRANSPARENT, KC_TRANSPARENT,
                                                    KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT
  ),
  [2] = LAYOUT_voyager(
    KC_BRID,        KC_BRIU,        KC_MCTL,        KC_LPAD,        RGB_VAD,        RGB_VAI,                                        KC_MPRV,        KC_MPLY,        KC_MNXT,        KC_MUTE,        KC_VOLD,        KC_VOLU,
    KC_TRANSPARENT, KC_TRANSPARENT, G(KC_LBRC),     C(S(KC_TAB)),   C(KC_TAB),      G(KC_RBRC),                                     G(KC_LEFT),     A(KC_LEFT),     KC_PGUP,        A(KC_RIGHT),    G(KC_RIGHT),    KC_HOME,
    TO(0),          G(KC_A),        OSM(MOD_LALT),  OSM(MOD_LGUI),  TG(6),          MAC_SIRI,                                       KC_LEFT,        KC_DOWN,        KC_UP,          KC_RIGHT,       KC_TRANSPARENT, KC_TRANSPARENT,
    KC_TRANSPARENT, G(KC_Z),        G(KC_X),        G(KC_C),        G(KC_V),        G(S(KC_Z)),                                     G(KC_UP),       KC_BSPC,        KC_PGDN,        KC_DEL,         G(KC_DOWN),     KC_END,
                                                    KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT
  ),
  [3] = LAYOUT_voyager(
    TO(0),          KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_NO,          KC_KP_EQUAL,    KC_KP_SLASH,    KC_KP_ASTERISK, KC_TRANSPARENT, KC_BSPC,        
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_NO,          KC_KP_7,        KC_KP_8,        KC_KP_9,        KC_KP_MINUS,    KC_NO,          
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_NO,          KC_KP_4,        KC_KP_5,        KC_KP_6,        KC_KP_PLUS,     KC_KP_ENTER,    
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_SPACE,       KC_KP_1,        KC_KP_2,        KC_KP_3,        KC_KP_PLUS,     KC_TRANSPARENT, 
                                                    KC_TRANSPARENT, TO(0),                                          KC_KP_0,        KC_KP_DOT
  ),
  [4] = LAYOUT_voyager(
    KC_F1,          KC_F2,          KC_F3,          KC_F4,          KC_F5,          KC_F6,                                          KC_F7,          KC_F8,          KC_F9,          KC_F10,         KC_F11,         DUAL_FUNC_1,    
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, 
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, 
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, 
                                                    KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT
  ),
  [5] = LAYOUT_voyager(
    TO(0),          KC_BRIGHTNESS_DOWN,KC_BRIGHTNESS_UP,KC_TRANSPARENT, KC_F14,         KC_F15,                                         KC_MEDIA_PREV_TRACK,KC_MEDIA_PLAY_PAUSE,KC_MEDIA_NEXT_TRACK,KC_AUDIO_MUTE,  KC_AUDIO_VOL_DOWN,KC_AUDIO_VOL_UP,
    KC_TRANSPARENT, RGB_VAD,        RGB_VAI,        KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, 
    KC_TRANSPARENT, RGB_HUD,        RGB_HUI,        RGB_TOG,        TOGGLE_LAYER_COLOR,RGB_MODE_FORWARD,                                KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, 
    KC_TRANSPARENT, RGB_SAD,        RGB_SAI,        HSV_0_255_255,  HSV_74_255_255, HSV_169_255_255,                                KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,
                                                    KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT
  ),
  [6] = LAYOUT_voyager(
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,
    KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT, KC_TRANSPARENT,                                 S(G(KC_LEFT)),  S(A(KC_LEFT)),  S(KC_PGUP),     S(A(KC_RIGHT)), S(G(KC_RIGHT)), S(KC_HOME),
    TO(0),          G(KC_A),        KC_TRANSPARENT, KC_TRANSPARENT, TG(6),          KC_TRANSPARENT,                                 S(KC_LEFT),     S(KC_DOWN),     S(KC_UP),       S(KC_RIGHT),    KC_TRANSPARENT, KC_TRANSPARENT,
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

const uint16_t PROGMEM combo0[] = { KC_8, KC_7, COMBO_END};
const uint16_t PROGMEM combo1[] = { KC_K, KC_J, COMBO_END};
const uint16_t PROGMEM combo2[] = { KC_D, KC_F, COMBO_END};
const uint16_t PROGMEM combo3[] = { KC_I, KC_U, COMBO_END};
const uint16_t PROGMEM combo4[] = { KC_MEDIA_PLAY_PAUSE, KC_MEDIA_NEXT_TRACK, COMBO_END};
const uint16_t PROGMEM combo5[] = { MEH_T(KC_ESCAPE), KC_LEFT_GUI, COMBO_END};

combo_t key_combos[COMBO_COUNT] = {
    COMBO(combo0, TG(5)),
    COMBO(combo1, KC_ENTER),
    COMBO(combo2, OSL(1)),
    COMBO(combo3, KC_BSPC),
    COMBO(combo4, TO(0)),
    COMBO(combo5, KC_HYPR),
};

uint16_t get_tapping_term(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case KC_LEFT_GUI:
            return TAPPING_TERM -180;
        case DUAL_FUNC_0:
            return TAPPING_TERM + 100;
        default:
            return TAPPING_TERM;
    }
}


extern rgb_config_t rgb_matrix_config;

RGB hsv_to_rgb_with_value(HSV hsv) {
  RGB rgb = hsv_to_rgb( hsv );
  float f = (float)rgb_matrix_config.hsv.v / UINT8_MAX;
  return (RGB){ f * rgb.r, f * rgb.g, f * rgb.b };
}

void keyboard_post_init_user(void) {
  rgb_matrix_enable();
}

const uint8_t PROGMEM ledmap[][RGB_MATRIX_LED_COUNT][3] = {
    [0] = { {89,93,210}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {252,251,150}, {0,0,0}, {0,0,0}, {89,93,210}, {89,93,210}, {0,0,0}, {23,247,217}, {0,0,0}, {114,237,255}, {165,237,255}, {197,211,194}, {0,0,0}, {197,211,194}, {89,93,210}, {0,0,0}, {89,93,210}, {89,93,210}, {0,0,0}, {0,0,0}, {89,93,210}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {77,247,237}, {77,247,237}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {197,211,194}, {165,237,255}, {114,237,255}, {0,0,0}, {23,247,217}, {89,93,210}, {46,255,255} },

    [1] = { {89,93,210}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {81,255,255}, {23,247,217}, {165,237,255}, {114,237,255}, {77,247,237}, {23,247,217}, {23,247,217}, {252,251,150}, {114,237,255}, {114,237,255}, {252,251,150}, {197,211,194}, {0,0,0}, {197,211,194}, {252,251,150}, {23,247,217}, {46,255,255}, {114,237,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {89,93,210}, {197,211,194}, {114,237,255}, {165,237,255}, {165,237,255}, {114,237,255}, {0,0,0}, {0,0,0}, {0,0,0}, {252,251,150}, {252,251,150}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0} },

    [2] = { {89,93,210}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {197,211,194}, {165,237,255}, {0,0,0}, {165,237,255}, {0,0,0}, {89,93,210}, {0,0,0}, {252,251,150}, {114,237,255}, {252,251,150}, {0,0,0}, {0,0,0}, {77,247,237}, {77,247,237}, {77,247,237}, {77,247,237}, {0,0,0}, {0,0,0}, {197,211,194}, {0,0,0}, {114,237,255}, {0,0,0}, {0,0,0}, {0,0,0}, {40,255,255}, {0,0,0} },

    [3] = { {0,0,0}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {81,115,163}, {0,0,0}, {81,115,163}, {165,237,255}, {197,211,194}, {23,247,217}, {81,115,163}, {252,251,150}, {81,115,163}, {0,0,0}, {0,0,0}, {0,0,0}, {114,237,255}, {81,115,163}, {81,115,163}, {0,0,0}, {0,0,0}, {0,0,0}, {46,255,255}, {77,247,237}, {89,93,210}, {0,0,0}, {0,0,0}, {0,0,0}, {47,255,255}, {81,115,163}, {0,0,0}, {89,93,210} },

    [4] = { {114,237,255}, {165,237,255}, {197,211,194}, {252,251,150}, {23,247,217}, {46,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {77,247,237}, {114,237,255}, {165,237,255}, {197,211,194}, {252,251,150}, {23,247,217}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0} },

    [5] = { {0,0,0}, {0,231,237}, {0,231,237}, {0,0,0}, {14,255,255}, {14,255,255}, {0,0,0}, {0,255,255}, {0,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {74,255,255}, {74,255,255}, {196,255,255}, {134,255,212}, {18,255,255}, {0,0,0}, {169,255,255}, {169,255,255}, {0,255,255}, {74,255,255}, {169,255,255}, {0,0,0}, {0,0,0}, {14,255,255}, {14,255,255}, {14,255,255}, {196,255,255}, {196,255,255}, {196,255,255}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0} },

};

void set_layer_color(int layer) {
  for (int i = 0; i < RGB_MATRIX_LED_COUNT; i++) {
    HSV hsv = {
      .h = pgm_read_byte(&ledmap[layer][i][0]),
      .s = pgm_read_byte(&ledmap[layer][i][1]),
      .v = pgm_read_byte(&ledmap[layer][i][2]),
    };
    if (!hsv.h && !hsv.s && !hsv.v) {
        rgb_matrix_set_color( i, 0, 0, 0 );
    } else {
        RGB rgb = hsv_to_rgb_with_value(hsv);
        rgb_matrix_set_color(i, rgb.r, rgb.g, rgb.b);
    }
  }
}

bool rgb_matrix_indicators_user(void) {
  if (!keyboard_config.disable_layer_led) { 
    switch (biton32(layer_state)) {
      case 0:
        set_layer_color(0);
        break;
      case 1:
        set_layer_color(1);
        break;
      case 2:
        set_layer_color(2);
        break;
      case 3:
        set_layer_color(3);
        break;
      case 4:
        set_layer_color(4);
        break;
      case 5:
        set_layer_color(5);
        break;
     default:
        if (rgb_matrix_get_flags() == LED_FLAG_NONE) {
          rgb_matrix_set_color_all(0, 0, 0);
        }
    }
  } else {
    if (rgb_matrix_get_flags() == LED_FLAG_NONE) {
      rgb_matrix_set_color_all(0, 0, 0);
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

    case DUAL_FUNC_0:
      if (record->tap.count > 0) {
        if (record->event.pressed) {
          register_code16(LGUI(LCTL(KC_F)));
        } else {
          unregister_code16(LGUI(LCTL(KC_F)));
        }
      } else {
        if (record->event.pressed) {
          layer_move(4);
        } else {
          layer_move(4);
        }  
      }  
      return false;
    case DUAL_FUNC_1:
      if (record->tap.count > 0) {
        if (record->event.pressed) {
          register_code16(KC_F12);
        } else {
          unregister_code16(KC_F12);
        }
      } else {
        if (record->event.pressed) {
          layer_move(0);
        } else {
          layer_move(0);
        }  
      }  
      return false;
    case RGB_SLD:
      if (record->event.pressed) {
        rgblight_mode(1);
      }
      return false;
    case HSV_0_255_255:
      if (record->event.pressed) {
        rgblight_mode(1);
        rgblight_sethsv(0,255,255);
      }
      return false;
    case HSV_74_255_255:
      if (record->event.pressed) {
        rgblight_mode(1);
        rgblight_sethsv(74,255,255);
      }
      return false;
    case HSV_169_255_255:
      if (record->event.pressed) {
        rgblight_mode(1);
        rgblight_sethsv(169,255,255);
      }
      return false;
  }
  return true;
}

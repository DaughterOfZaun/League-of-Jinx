class_name BuffMetadata

var buff_name := ""
var buff_texture_name := ""
var minimap_icon_texture_name := ""
var minimap_icon_enemy_texture_name := ""
var popup_message: Array[String] = []

var auto_buff_activate_event := ""
var auto_buff_activate_effect_flags := Enums.EffCreate.NONE
var auto_buff_activate_effect: Array[String] = []
var auto_buff_activate_attach_bone_name: Array[String] = []

var spell_toggle_slot := 0 # [1-4]

var non_dispellable := false
var persists_through_death := false
var is_pet_duration_buff := false
var is_death_recap_source := false

var on_pre_damage_priority := 0
var do_on_pre_damage_in_expiration_order := false

static func from(dict: Dictionary) -> BuffMetadata:
	var inst := new()
	for key in dict:
		inst.set(key, dict[key])
	return inst

class_name BuffData extends Resource

@export var buff_name := ""
@export var buff_texture_name := ""
@export var buff_texture: Texture2D
@export var minimap_icon_texture_name := ""
@export var minimap_icon_texture: Texture2D
@export var minimap_icon_enemy_texture_name := ""
@export var minimap_icon_enemy_texture: Texture2D
@export var popup_message := ""

#region Tooltip
@export_group("Tooltip")
@export var dynamic_tooltip := ""
@export var float_statics_decimals: Array[int] = [ 2, 2, 2, 2, 2, 2 ]
@export var float_vars_decimals: Array[int] = [ 2, 2, 2, 2, 2, 2 ]
@export_group("")
#endregion

#region Auto activate
@export_group("Auto Activate", "auto_buff_activate_")
@export var auto_buff_activate_event := ""
@export var auto_buff_activate_effect_flags := Enums.EffCreate.NONE
@export var auto_buff_activate_effect: Dictionary[String, PackedScene] = {}
@export var auto_buff_activate_attach_bone_name: Array[StringName] = []
@export_group("")
#endregion

@export var spell_toggle_slot := 0 # [1-4]

#region Flags
@export_group("Flags")
@export var non_dispellable := false
@export var persists_through_death := false
@export var is_pet_duration_buff := false
@export var is_death_recap_source := false
@export_group("")
#endregion

#region Pre damage
@export_group("Pre Damage")
@export var on_pre_damage_priority := 0
@export var do_on_pre_damage_in_expiration_order := false
@export_group("")
#endregion

static func from(dict: Dictionary[String, Variant]) -> BuffData:
	var inst := new()
	for key in dict:
		inst.set(key, dict[key])
	return inst

class_name BuffData extends Resource

@export var buff_name: String = ""
@export var buff_texture_name: String = ""
@export var buff_texture: Texture2D
@export var minimap_icon_texture_name: String = ""
@export var minimap_icon_texture: Texture2D
@export var minimap_icon_enemy_texture_name: String = ""
@export var minimap_icon_enemy_texture: Texture2D
@export var popup_message: String = ""

#region Tooltip
@export_group("Tooltip")
@export var dynamic_tooltip: String = ""
@export var float_statics_decimals: Array[int] = [ 2, 2, 2, 2, 2, 2 ]
@export var float_vars_decimals: Array[int] = [ 2, 2, 2, 2, 2, 2 ]
@export_group("")
#endregion

#region Auto activate
@export_group("Auto Activate", "auto_buff_activate_")
@export var auto_buff_activate_event: String = ""
@export var auto_buff_activate_effect_flags: Enums.EffCreate = Enums.EffCreate.NONE
@export var auto_buff_activate_effect: Dictionary[String, PackedScene] = {}
@export var auto_buff_activate_attach_bone_name: Array[StringName] = []
@export_group("")
#endregion

@export var spell_toggle_slot: int = 0 # [1-4]

#region Flags
@export_group("Flags")
@export var non_dispellable: bool = false
@export var persists_through_death: bool = false
@export var is_pet_duration_buff: bool = false
@export var is_death_recap_source: bool = false #TODO: is this spell-only?
@export_group("")
#endregion

#region Pre damage
@export_group("Pre Damage")
@export var on_pre_damage_priority: int = 0
@export var do_on_pre_damage_in_expiration_order: bool = false
@export_group("")
#endregion

static func from(dict: Dictionary[String, Variant]) -> BuffData:
	var inst := new()
	for key in dict:
		inst.set(key, dict[key])
	return inst

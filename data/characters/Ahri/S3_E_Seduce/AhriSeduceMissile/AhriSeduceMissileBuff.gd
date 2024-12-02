class_name AhriSeduceMissileBuff extends Buff

var data := BuffData.from({
	auto_buff_activate_attach_bone_name = [ "" ],
	auto_buff_activate_effect = [ "" ],
	buff_name = "",
	buff_texture_name = "",
})
func on_activate() -> void:
	host.status.can_attack = false
	host.apply_assist_marker(attacker, 10)

func on_deactivate(expired: bool) -> void:
	host.status.can_attack = true

func on_update_stats() -> void:
	host.status.can_attack = false

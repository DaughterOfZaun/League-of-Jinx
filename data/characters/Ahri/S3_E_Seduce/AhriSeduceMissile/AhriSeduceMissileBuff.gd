class_name AhriSeduceMissileBuff extends Buff

const data: BuffData = preload('AhriSeduceMissileBuff.tres')

func on_activate() -> void:
	host.status.can_attack = false
	host.apply_assist_marker(attacker, 10)

func on_deactivate(expired: bool) -> void:
	host.status.can_attack = true

func on_update_stats() -> void:
	host.status.can_attack = false

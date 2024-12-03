class_name AhriSoulCrusher3Buff extends Buff

var data := preload('AhriSoulCrusher3Buff.tres')

var last_time_executed: TimeTracker
func on_deactivate(expired: bool) -> void:
	attacker.buffs.add(attacker, AhriSoulCrusher4Buff.new(), 1, 1, 1, Enums.BuffAddType.STACKS_AND_OVERLAPS, Enums.BuffType.INTERNAL, 0.25, true, false, false)
func on_update_actions() -> void:
	if last_time_executed.execute(1, false):
		if attacker.buffs.count(AhriFoxFireBuff, attacker) == 0:
			host.buffs.clear(AhriSoulCrusher3Buff)

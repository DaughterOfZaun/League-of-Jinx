class_name AhriSoulCrusher3Buff extends Buff

var metadata := BuffMetadata.from({
	auto_buff_activate_effect = [
		"PotionofElusiveness_itm.troy",
		"PotionofBrilliance_itm.troy",
		"PotionofGiantStrength_itm.troy",
	],
	buff_name = "AhriSoulCrusher",
	buff_texture_name = "3017_Egitai_Twinsoul.dds",
	persists_through_death = true,
})
var last_time_executed: TimeTracker
func on_deactivate(expired: bool) -> void:
	attacker.buffs.add(attacker, AhriSoulCrusher4Buff.new(), 1, 1, 1, Enums.BuffAddType.STACKS_AND_OVERLAPS, Enums.BuffType.INTERNAL, 0.25, true, false, false)
func OnUpdateActions() -> void:
	if last_time_executed.execute(1, false):
		if attacker.buffs.count(AhriFoxFireBuff, attacker) == 0:
			host.buffs.clear(AhriSoulCrusher3Buff)
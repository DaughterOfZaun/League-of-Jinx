class_name AhriFoxFireMissileTwoBuff extends Buff

func on_update_actions() -> void:
	if host.buffs.count(AhriFoxFireMissileTwoBuff) == 3:
		host.buffs.clear(AhriFoxFireMissileTwoBuff)
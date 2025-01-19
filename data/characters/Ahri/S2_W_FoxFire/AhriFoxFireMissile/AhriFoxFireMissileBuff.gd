class_name AhriFoxFireMissileBuff extends Buff

var data: BuffData = preload('AhriFoxFireMissileBuff.tres')

func on_deactivate(expired: bool) -> void:
	if host.buffs.count(AhriFoxFireMissileBuff) <= 0:
		host.buffs.remove_by_script(AhriFoxFireBuff, host)

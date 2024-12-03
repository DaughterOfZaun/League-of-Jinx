class_name AhriFoxFireBuff extends Buff

var data := preload('AhriFoxFireBuff.tres')

func on_activate() -> void:
	host.spells.w.set_cooldown(0, false)
	host.spells.w.is_sealed = true

var effect0: Array[float] = [ 9, 8, 7, 6, 5 ]
func on_deactivate(expired: bool) -> void:
	var level := host.spells.w.level
	var cooldown := effect0[level - 1]
	var cooldown_mod := host.stats.get_cooldown_percent() + 1
	var final_cooldown := cooldown * cooldown_mod
	host.spells.w.set_cooldown(final_cooldown, false)
	var duration := host.buffs.get_remaining_duration(AhriFoxFireBuff)
	if duration < -0.001:
		Particle.create(preload("Ahri_foxfire_obd-sound.tscn")).bind(host, "BUFFBONE_GLB_WEAPON_1").target(host)
	host.spells.w.is_sealed = false

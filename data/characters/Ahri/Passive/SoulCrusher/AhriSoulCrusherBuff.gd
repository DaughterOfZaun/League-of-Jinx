class_name AhriSoulCrusherBuff extends Buff

const data: BuffData = preload('AhriSoulCrusherBuff.tres')

func on_activate() -> void:
	host.buffs.add(host, AhriPassiveParticleBuff.new())
func on_deactivate(expired: bool) -> void:
	host.buffs.add(host, AhriIdleParticleBuff.new())
	host.buffs.remove_by_script(AhriPassiveParticleBuff, host)

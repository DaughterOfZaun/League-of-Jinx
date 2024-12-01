class_name AhriIdleCheckBuff extends Buff

func on_deactivate(expired: bool) -> void:
    if host.buffs.count(AhriSoulCrusherBuff, host) > 0:
        host.buffs.add(host, AhriPassiveParticleBuff.new())
    else:
        host.buffs.add(host, AhriIdleParticleBuff.new())

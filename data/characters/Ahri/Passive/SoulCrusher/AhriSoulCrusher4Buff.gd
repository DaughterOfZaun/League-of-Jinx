class_name AhriSoulCrusher4Buff extends Buff

const data: BuffData = preload('AhriSoulCrusher4Buff.tres')

func on_deactivate(expired: bool) -> void:
	vars.fox_fire_is_active = 0

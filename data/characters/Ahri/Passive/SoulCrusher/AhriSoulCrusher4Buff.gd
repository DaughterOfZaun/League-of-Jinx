class_name AhriSoulCrusher4Buff extends Buff

var data := preload('AhriSoulCrusher4Buff.tres')

func on_deactivate(expired: bool) -> void:
	vars.fox_fire_is_active = 0

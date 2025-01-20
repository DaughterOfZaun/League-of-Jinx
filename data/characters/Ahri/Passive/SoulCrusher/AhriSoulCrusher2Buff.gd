class_name AhriSoulCrusher2Buff extends Buff

const data: BuffData = preload('AhriSoulCrusher2Buff.tres')

func on_deactivate(expired: bool) -> void:
	vars.tumble_is_active = 0

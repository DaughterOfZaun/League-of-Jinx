class_name UnlockAnimationBuff extends Buff

func on_deactivate(expired: bool) -> void:
	host.animation.unlock()

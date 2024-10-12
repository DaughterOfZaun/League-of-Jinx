class_name AhriOrbDamageSilenceBuff
extends Buff

var orb_of_deception_is_active: int
var effect_0 := [ 40, 65, 90, 115, 140 ]
func _init(orb_of_deception_is_active := 0) -> void:
	self.orb_of_deception_is_active = orb_of_deception_is_active

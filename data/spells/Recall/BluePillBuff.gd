class_name BluePillBuff extends Buff

var will_remove: bool
func _init(will_remove := false) -> void:
	self.will_remove = will_remove

func on_activate() -> void:
	pass #require_var(this.will_remove)

func on_update_actions() -> void:
	if will_remove:
		host.stop_channeling(Enums.ChannelingStopCondition.CANCEL, Enums.ChannelingStopSource.LOST_TARGET)
		host.buffs.remove_by_script(get_script())

func on_take_damage(attacker: Unit, damage: DamageData) -> void:
	will_remove = true

class_name SpellTargetMissile extends Missile

static func create(spell: Spell, target: Unit) -> SpellTargetMissile:
	var m := SpellTargetMissile.new()
	m.init(spell, target)
	return m

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if linear_movement(delta):
		spell._target_execute(target, self)
		destroy_self()

class_name SpellTargetMissile
extends Missile

var spell: Spell
var target: Unit
func _init(spell: Spell, target: Unit) -> void:
	self.spell = spell
	self.target = target

func _ready() -> void:
	self.global_position = spell.host.get_bone_global_position(spell.missile_bone_idx)

func _physics_process(delta: float) -> void:
	pass

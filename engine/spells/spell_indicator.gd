class_name SpellIndicator extends Node3D

@onready var root := get_tree().current_scene
@onready var input_manager: InputManager = root.get_node("%InputManager")

@onready var spell: Spell #= get_parent()
@onready var line_missile_indicator: Node3D = $LineMissile
@onready var line_missile_indicator_base: Node3D = $LineMissile/Base
@onready var line_missile_indicator_target: Node3D = $LineMissile/Target

func _ready() -> void:
	visible = false
	self.visibility_changed.connect(func () -> void:
		self._physics_process(0)
	)

func _physics_process(delta: float) -> void:
	if !spell || !visible: return
	if line_missile_indicator.visible:
		#var range := spell.get_cast_range()
		var range := spell.get_cast_range_display_override()
		#var range := spell.get_location_targetting_length()
		#var width := spell.get_location_targetting_width()
		var width := spell.data.line_width
		
		width = width * Data.HW2GD
		range = range * Data.HW2GD
		
		line_missile_indicator_base.scale.x = width
		line_missile_indicator_base.scale.z = range - width * 0.5
		line_missile_indicator_target.position.z = -range
		line_missile_indicator_target.scale.x = width
		line_missile_indicator_target.scale.z = width

		line_missile_indicator.look_at(input_manager.hovered_pos * Data.HW2GD)

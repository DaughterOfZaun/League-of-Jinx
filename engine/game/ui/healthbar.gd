class_name Healthbar extends Control

@export var height := 2.5
@export var level_label: Label
@export var health_range: Range
@export var mana_range: Range
@export var name_label: Label

@onready var root := get_tree().current_scene
@onready var camera: Camera3D = root.get_node("%Camera")
@onready var champion: Champion = get_parent()

func _process(delta: float) -> void:
	global_position = camera.unproject_position(champion.global_position + Vector3.UP * height) - pivot_offset
	health_range.value = champion.stats.health_current
	health_range.max_value = champion.stats.get_health()
	mana_range.value = champion.stats.mana_current
	mana_range.max_value = champion.stats.get_mana()
	level_label.text = str(champion.level)
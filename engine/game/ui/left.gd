class_name UILeftPanel
extends Control

@export var champion: Champion
func bind_to(c: Champion) -> void:
	champion = c

@export var attack_damage_label: Label
@export var magical_damage_label: Label
@export var attack_speed_label: Label
@export var movement_speed_label: Label
@export var armor_label: Label
@export var spell_block_label: Label
func _process(delta: float) -> void:
	attack_damage_label.text = str(roundi(champion.stats.get_attack_damage()))
	magical_damage_label.text = str(roundi(champion.stats.get_magic_damage()))
	attack_speed_label.text = str(roundf(champion.stats.get_attack_speed() * 1000.0) / 1000.0)
	movement_speed_label.text = str(roundi(champion.stats.get_movement_speed()))
	armor_label.text = str(roundi(champion.stats.get_armor()))
	spell_block_label.text = str(roundi(champion.stats.get_spell_block()))
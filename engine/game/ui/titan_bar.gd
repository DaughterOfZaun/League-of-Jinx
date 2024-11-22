class_name UITitanBar
extends Control

@export var fps_label: Label
@export var time_label: Label
@export var kills_label: Label
@export var deaths_label: Label
@export var assists_label: Label

@export var champion: Champion
func bind_to(champion: Champion) -> void:
	self.champion = champion

var time := 0.0
func _physics_process(delta: float) -> void:
	time = float(Engine.get_physics_frames()) / Engine.physics_ticks_per_second
	#time += delta

func _process(delta: float) -> void:
	kills_label.text = str(champion.kills)
	deaths_label.text = str(champion.deaths)
	assists_label.text = str(champion.assists)
	fps_label.text = str(roundi(Engine.get_frames_per_second()))
	time_label.text = "%02d:%02d" % [ floori(time / 60), int(time) % 60 ]

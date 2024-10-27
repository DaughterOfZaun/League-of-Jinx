extends Node2D

#var league_2D := 294.
#var league_3D := league_2D * 50.
#var godot_2D := league_2D * (512. / 294.)
#var godot_3D := league_3D / 70.
#	=>	league_2D = league_3D / 50.
#	=>	league_3D = godot_3D * 70.
#	=>	godot_2D = ((godot_3D * 70.) / 50.) * (512. / 294.)
const GD_3D_to_2D := (70. / 50.) * (512. / 294.)

@onready var host: Node3D = get_parent()
@onready var sub_viewport: SubViewport = %SubViewport
@onready var sub_viewport_root: Node2D = sub_viewport.get_child(0)
func _ready() -> void:
	switch_parent.call_deferred()

func switch_parent() -> void:
	host.remove_child(self)
	sub_viewport_root.add_child(self)

func _process(delta: float) -> void:
	position = Vector2(host.global_position.x, -host.global_position.z) * GD_3D_to_2D

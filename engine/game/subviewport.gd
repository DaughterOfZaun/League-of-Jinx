class_name SubViewportEx
extends SubViewport

const GD_3D_to_2D := (70. / 50.) * (512. / 294.)

@export var scale := GD_3D_to_2D
@export var offset := Vector2(64, -64)
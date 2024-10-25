@tool
extends TextureProgressBar

@export var line_width := 1.0
@export var line_color := Color.WHITE



func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var center := self.size * 0.5
	var line_length := self.size.length() * 0.5 - line_width
	draw_line(center, center + Vector2.UP * line_length, line_color, line_width, true)
	draw_line(center, center + Vector2.from_angle(deg_to_rad(360 * (value / max_value) - 90)) * line_length, line_color, line_width, true)


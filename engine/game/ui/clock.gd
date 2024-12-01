@tool extends TextureProgressBar

@export var line_width := 1.0
@export var line_color := Color.WHITE
@export var line_antialiased := false

func _draw() -> void:
	var center := self.size * 0.5
	var line_length := self.size.length() * 0.5 - line_width
	var dir := Vector2.from_angle(deg_to_rad(360 * (value / max_value) - 90))
	draw_line(center, center + Vector2.UP * line_length, line_color, line_width, line_antialiased)
	draw_line(center, center + dir * line_length, line_color, line_width, line_antialiased)

@tool extends TextureProgressBar

@export var line_width: float = 1.0
@export var line_color: Color = Color.WHITE
@export var line_antialiased: bool = false
@export var unit: float = 100.0

func _draw() -> void:
	var num_of_marks := floori(max_value / unit)
	for i in range(num_of_marks):
		var x := (i + 1) * floori(unit * size.x / max_value)
		draw_line(Vector2(x, 0), Vector2(x, size.y), line_color, line_width, line_antialiased)

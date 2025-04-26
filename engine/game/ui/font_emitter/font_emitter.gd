@tool class_name FontEmitter extends GPUParticles3D

@export var letter_width_offset: float = -0.3
var letters: String = """
 0 a k u E O Y
 1 b l v F P Z
 2 c m w G Q !
 3 d n x H R +
 4 e o y I S -
 5 f p z J T .
 6 g q A K U .
 7 h r B L V .
 8 i s C M W .
 9 j t D N X  
""".replace("\n", "").replace(" ", "") + " "

@export_group("Test", "test")
@export var test_scale: float = 1.0
@export var test_speed: float = 5.0
@export var test_color: Color = Color.WHITE
@export var test_text: String
@export var test_offset: float = 0.0
@export_tool_button("Test") var test: Callable = func() -> void:
	emit_text(test_text, test_scale, test_speed, test_color, test_offset)

func emit_text(text: String, scale: float = 1.0, speed: int = 0.0, color: Color = Color.WHITE, offset: float = 0.0) -> void:
	var initial_transform := self.global_transform.scaled_local(Vector3.ONE * test_scale).translated(Vector3.UP * offset)
	var i := 0
	for letter in text:
		var letter_index := letters.find(letter)
		var letter_width := 0.6 + letter_width_offset
		var EmitFlags_ALL := EMIT_FLAG_POSITION | EMIT_FLAG_ROTATION_SCALE | EMIT_FLAG_VELOCITY | EMIT_FLAG_COLOR | EMIT_FLAG_CUSTOM;
		var final_transform := initial_transform.translated(Vector3.RIGHT * letter_width * (i - len(text) * 0.5) * scale)
		var custom := Color(0, 0, float(letter_index) / float(len(letters)), lifetime)
		emit_particle(final_transform, Vector3.UP * speed, color, custom, EmitFlags_ALL)
		i += 1

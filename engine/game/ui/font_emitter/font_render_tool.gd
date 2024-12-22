@tool
extends SubViewport

@export_file("*.webp") var path: String
@export var lossy := false
@export_range(0, 1) var quality := 0.75
@export_tool_button("Render") var render := func() -> void:
	self.get_texture().get_image().save_webp(path)

#func _ready() -> void:
#	await RenderingServer.frame_post_draw
#	render.call()

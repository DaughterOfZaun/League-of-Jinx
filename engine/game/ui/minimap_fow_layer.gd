extends TextureRect

var camera: Camera
var viewport: SubViewportEx
func _ready() -> void:
	var viewport_texture: ViewportTexture = self.texture
	viewport_texture.viewport_path = "/root/Node3D/SubViewport"

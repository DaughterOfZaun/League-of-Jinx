@tool
extends Node3D

@export var decals: Array[Texture2D] = []

@export_tool_button("Save Mesh Instances") var save_mi := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		var path := "res://data/levels/1/meshes/" + mi.name + ".tres"
		var file := FileAccess.open("user://save_game.dat", FileAccess.WRITE)
		file.store_var(mi.mesh)
		mi.mesh.take_over_path(path)

@export_tool_button("Disable Decals") var disable_mi := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		mi.visible = (mi.mesh.surface_get_material(0) as StandardMaterial3D).albedo_texture not in decals

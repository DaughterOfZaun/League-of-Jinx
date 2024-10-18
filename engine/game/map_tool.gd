@tool
extends Node3D

@export var decals: Array[Texture2D] = []

const mi_dir := "res://data/levels/1/meshes"

@export_tool_button("Save Meshes") var save_mi := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		var path := mi_dir + "/" + mi.name + ".tres"
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_var(mi.mesh)
		mi.mesh.take_over_path(path)

@export_tool_button("Disable Decals") var disable_mi := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		mi.visible = (mi.mesh.surface_get_material(0) as StandardMaterial3D).albedo_texture not in decals

@export_tool_button("Instantiate Meshes") var spawn_mi := func() -> void:
	for file_name in DirAccess.get_files_at(mi_dir):
		if !file_name.ends_with(".tres"): continue
		var mi_name := file_name.replace(".tres", "")
		var path := mi_dir + "/" + file_name
		var file := FileAccess.open(path, FileAccess.READ)
		var mi_mesh := file.get_var(true) as Mesh
		if mi_mesh == null: continue
		var mi := MeshInstance3D.new()
		mi.name = mi_name
		mi.mesh = mi_mesh
		add_child(mi)
		mi.owner = self

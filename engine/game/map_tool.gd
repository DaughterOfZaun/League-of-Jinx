@tool
extends Node3D

@export_group("Decals")
@export var decals: Array[Texture2D] = []
@export_tool_button("Disable Decals") var disable_decals := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := mi.mesh.surface_get_material(0) as StandardMaterial3D
		var is_decal := m.albedo_texture in decals
		mi.visible = !is_decal
@export_tool_button("Fix Decals") var fix_decals := func() -> void:
	var i := 0
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := mi.mesh.surface_get_material(0) as StandardMaterial3D
		var is_decal := m.albedo_texture in decals
		if is_decal:
			mi.position.y += 0.001 * i
			m.texture_repeat = false
			mi.visible = true
			i += 1
@export_group("")

@export_group("Meshes")
const mi_dir := "res://data/levels/1/meshes"
@export_tool_button("Save Meshes") var save_meshes := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		var path := mi_dir + "/" + mi.name + ".tres"
		var file := FileAccess.open(path, FileAccess.ModeFlags.WRITE)
		file.store_var(mi.mesh)
		mi.mesh.take_over_path(path)
@export_tool_button("Instantiate Meshes") var spawn_meshes := func() -> void:
	for file_name in DirAccess.get_files_at(mi_dir):
		if !file_name.ends_with(".tres"): continue
		var mi_name := file_name.replace(".tres", "")
		var path := mi_dir + "/" + file_name
		var file := FileAccess.open(path, FileAccess.ModeFlags.READ)
		var mi_mesh := file.get_var(true) as Mesh
		if mi_mesh == null: continue
		var mi := MeshInstance3D.new()
		mi.name = mi_name
		mi.mesh = mi_mesh
		add_child(mi)
		mi.owner = self
@export_group("")

@export_group("NavMesh")
@export var imported: NavigationMesh
@export_file("*.aimesh") var import_path: String
@export_tool_button("Import") var import := func() -> void:
	var nm := imported
	var file := FileAccess.open(import_path, FileAccess.ModeFlags.READ)
	var magic := file.get_buffer(8)
	var version := file.get_32()
	var triangle_count := file.get_32()
	var vertices: Array[Vector3] = []
	var polygons: Array[Vector3i] = []
	for i in range(triangle_count):
		var indeces: Array[int] = []
		for j in range(3):
			var vertex := Vector3(
				file.get_float(),
				file.get_float(),
				file.get_float()
			)
			file.get_16() # unk1
			file.get_16() # unk2
			file.get_16() # triangle_reference
			var index := vertices.find_custom(
				func(existing_vertex: Vector3) -> bool:
					return vertex.is_equal_approx(existing_vertex))
			if index == -1:
				index = len(vertices)
				vertices.append(vertex)
			indeces.append(index)
		polygons.append(Vector3i(indeces[0], indeces[1], indeces[2]))

@export_group("")

@tool
extends Node3D

const HW2GD := 1. / 70.

@export_group("Decals")
@export var decals: Array[Texture2D] = []
@export var show_decals := true:
	get:
		return show_decals
	set(value):
		show_decals = value
		for child in get_children(true):
			var mi := child as MeshInstance3D
			if mi == null: continue
			assert(mi.mesh.get_surface_count() == 1)
			var m := mi.mesh.surface_get_material(0) as StandardMaterial3D
			var is_decal := m.albedo_texture in decals
			mi.visible = value if is_decal else true
@export_tool_button("Fix Decals (Simple)") var fix_decals_simple := func() -> void:
	var mis: Array[MeshInstance3D] = []
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := mi.mesh.surface_get_material(0) as StandardMaterial3D
		var is_decal := m.albedo_texture in decals
		if is_decal:
			mis.append(mi)
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
			m.texture_repeat = false

	mis.sort_custom(
		func(mia: MeshInstance3D, mib: MeshInstance3D) -> bool:
			var miam := mia.mesh.surface_get_material(0) as StandardMaterial3D
			var mibm := mib.mesh.surface_get_material(0) as StandardMaterial3D
			return decals.find(miam.albedo_texture) < decals.find(mibm.albedo_texture)
	)

	var levels: Array[Array] = []
	for mia in mis:
		var mia_aabb := mia.get_aabb()
		var i := levels.find_custom(
			func(level: Array) -> bool:
				for mib: MeshInstance3D in level:
					var mib_aabb := mib.get_aabb()
					if mib_aabb.intersects(mia_aabb):
						return false
				return true
		)
		if i == -1:
			levels.append([ mia ])
		else:
			levels[i].append(mia)

	for i in range(len(levels)):
		var level := levels[i]
		for mi: MeshInstance3D in level:
			mi.position.y = 0.01 + i * 0.01

@export_tool_button("Fix Decals (Advanced)") var fix_decals_advanced := func() -> void:
	for child in get_children(true):
		var d := child as Decal
		if d == null: continue
		remove_child(d)
		d.queue_free()
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := mi.mesh.surface_get_material(0) as StandardMaterial3D
		var is_decal := m.albedo_texture in decals
		if is_decal:
			var d := Decal.new()
			add_child(d)
			d.name = mi.name + "_Decal"
			d.texture_albedo = m.albedo_texture
			d.owner = self
			var gp := uv_to_3d(mi, Vector2.ONE * 0.5)
			if gp.is_finite():
				d.global_position = gp
			else:
				print(mi.name)

func uv_to_3d(mi: MeshInstance3D, uv: Vector2) -> Vector3:
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(mi.mesh, 0)
	for f_i in range(mdt.get_face_count()):
		var vs_i := Vector3i(
			mdt.get_face_vertex(f_i, 0),
			mdt.get_face_vertex(f_i, 1),
			mdt.get_face_vertex(f_i, 2),
		)
		var uvs: Array[Vector2] = [
			mdt.get_vertex_uv(vs_i[0]),
			mdt.get_vertex_uv(vs_i[1]),
			mdt.get_vertex_uv(vs_i[2]),
		]
		var a := area(uvs[0], uvs[1], uvs[2])
		if a == 0: continue
		var bccs := Vector3(
			area(uvs[1], uvs[2], uv),
			area(uvs[2], uvs[0], uv),
			area(uvs[0], uvs[1], uv),
		) / a
		if bccs[0] < 0 || bccs[1] < 0 || bccs[2] < 0: continue
		var vs: Array[Vector3] = [
			mdt.get_vertex(vs_i[0]),
			mdt.get_vertex(vs_i[1]),
			mdt.get_vertex(vs_i[2]),
		]
		var p := (bccs[0] * vs[0]) + (bccs[1] * vs[1]) + (bccs[2] * vs[2])
		return mi.to_global(p)
	return Vector3.INF

func area(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
	var v1: Vector2 = p1 - p3
	var v2: Vector2 = p2 - p3
	return (v1.x * v2.y - v1.y * v2.x) / 2

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
@export_tool_button("Remove LODs and Shadow Meshes") var remove_LODs_and_SMs := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		var m: ArrayMesh = mi.mesh
		(m._surfaces[0] as Dictionary)["lods"] = []
		m.shadow_mesh = null
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
	file.get_32() # zero1
	file.get_32() # zero2
	var vertices: Array[Vector3] = []
	var polygons: Array[PackedInt32Array] = []
	for triangle_i in range(triangle_count):
		var indeces := PackedInt32Array([0, 0, 0])
		for i in range(3):
			var vertex := Vector3(
				file.get_float(),
				file.get_float(),
				file.get_float()
			) * HW2GD
			#var index := vertices.find(vertex)
			var index := vertices.find_custom(
				func(existing_vertex: Vector3) -> bool:
					return vertex.is_equal_approx(existing_vertex))
			if index == -1:
				index = len(vertices)
				vertices.append(vertex)
			indeces[i] = index
		file.get_16() # unk1
		file.get_16() # unk2
		file.get_16() # triangle_reference
		polygons.append(indeces)
	nm.clear()
	nm.set_vertices(PackedVector3Array(vertices))
	for polygon in polygons:
		nm.add_polygon(polygon)

@export_group("")

@export_group("Textures")
@export_tool_button("Enable Normal Maps") var enable_normal_maps := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := mi.mesh.surface_get_material(0) as StandardMaterial3D
		m.normal_enabled = true
		m.normal_texture = load(m.albedo_texture.resource_path.replace(".png", ".normal.webp"))
@export_group("")

# func _ready() -> void:
# 	if Engine.is_editor_hint(): return
# 	remove_LODs_and_SMs.call()

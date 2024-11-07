@tool
class_name MapTool
extends Node3D

const HW2GD := 1. / 70.

static func get_v3(fa: FileAccess) -> Vector3:
	return Vector3(fa.get_float(), fa.get_float(), fa.get_float())

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
			assert(m != null, str(child.name))
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

	var levels := sort_to_levels(mis)
	levels.shuffle()
	for i in range(len(levels)):
		var level := levels[i]
		for mi: MeshInstance3D in level:
			mi.position.y = 0.001 + i * 0.001

func sort_to_levels(mis: Array[Variant]) -> Array[Array]:
	var levels: Array[Array] = []
	for mia: VisualInstance3D in mis:
		var mia_aabb := mia.get_aabb()
		var i := levels.find_custom(
			func(level: Array) -> bool:
				for mib: VisualInstance3D in level:
					var mib_aabb := mib.get_aabb()
					if mib_aabb.intersects(mia_aabb):
						return false
				return true
		)
		if i == -1:
			levels.append([ mia ])
		else:
			levels[i].append(mia)
	return levels

@export_tool_button("Fix Decals (Advanced)") var fix_decals_advanced := func() -> void:
	for child in get_children(true):
		var d := child as Decal
		if d == null: continue
		remove_child(d)
		d.queue_free()
	var ds: Array[Decal] = []
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := mi.mesh.surface_get_material(0) as StandardMaterial3D
		var is_decal := m.albedo_texture in decals
		if is_decal:
			var o := 0.05
			var gpa := uv_to_3d(mi, Vector2(0.5 - o, 0.5 - o)) - Vector3(0, mi.global_position.y, 0)
			var gpb := uv_to_3d(mi, Vector2(0.5 + o, 0.5 + o)) - Vector3(0, mi.global_position.y, 0)
			if gpa.is_finite() and gpb.is_finite():
				var gp := (gpa + gpb) * 0.5
				var gpd := gpb - gpa
				var s := gpd.length() * sqrt(2) * (0.25 / o)
				var r := Vector3(1, 0, 1).signed_angle_to(gpd.normalized(), Vector3.UP)

				var i := ds.find_custom(func(d: Decal) -> bool:
					return d.texture_albedo == m.albedo_texture\
						&& d.global_position.distance_to(gp) <= 0.5)
				if i == -1:
					var d := Decal.new()
					add_child(d)
					d.owner = self
					d.name = mi.name + "_Decal"
					d.texture_albedo = m.albedo_texture
					d.texture_normal = m.normal_texture
					d.cull_mask = 1
					d.global_position = gp
					d.size = Vector3(s, 1, s)
					d.rotate_y(r)
					ds.append(d)
			else:
				print(mi.name)

	#ds.sort_custom(func(da: Decal, db: Decal) -> bool:
	#	return decals.find(da.texture_albedo) < decals.find(db.texture_albedo))
	#var levels := sort_to_levels(ds)
	#for i in range(len(levels)):
	#	var level := levels[i]
	#	for d: Decal in level:
	#		d.sorting_offset = i * 1
	ds.shuffle()
	# var nds: Array[Decal] = [ ds[0] ]
	# while len(ds) > 0:
	# 	ds.sort_custom(func(a: Decal, b: Decal) -> bool:
	# 		var ndslgp := nds[-1].global_position
	# 		return ndslgp.distance_squared_to(a.global_position) > ndslgp.distance_squared_to(b.global_position))
	# 	nds.append(ds.pop_back())
	# ds = nds
	var min_size: float = ds.reduce(func(size: float, d: Decal) -> float: return min(size, d.size.length()), 1000000)
	var max_size: float = ds.reduce(func(size: float, d: Decal) -> float: return max(size, d.size.length()), 0)
	for i in range(len(ds)):
		var d := ds[i]
		d.sorting_offset = ((d.size.length() - min_size) / (max_size - min_size) - 0.5) * 500

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

@export_group("Materials")
@export_tool_button("Replace materials") var replace_materials := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var resource_name := str(mi.mesh.get("surface_0/name")).replace(":", "_")
		#var resource_name := (mi.mesh.surface_get_material(0) as StandardMaterial3D).resource_name
		mi.mesh.surface_set_material(0, load("res://data/levels/1/materials/%s.tres" % resource_name))

@export_tool_button("Enable Normal Maps") var enable_normal_maps := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := mi.mesh.surface_get_material(0) as StandardMaterial3D
		m.normal_enabled = true
		m.normal_texture = load(m.albedo_texture.resource_path.replace(".webp", ".normal.webp"))
@export_group("")

@export_tool_button("TEST") var test := func() -> void:
	pass

func _ready() -> void:
	if Engine.is_editor_hint(): return
	replace_materials_at_runtime()

@export var level_shader: Shader
@export var level_decal_shader: Shader
@export var level_flora_shader: Shader
@export var viewport_texture: ViewportTexture
@onready var viewport: SubViewportEx = $"/root/Node3D/SubViewport"
#@export var shadow_of_war_overlay_material: ShaderMaterial
var material_cache: Dictionary[StandardMaterial3D, ShaderMaterial] = {}
func replace_materials_at_runtime() -> void:
	#var viewport_texture: ViewportTexture = shadow_of_war_overlay_material.get("shader_parameter/density_texture")
	viewport_texture.set_viewport_path_in_scene("/root/Node3D/SubViewport")
	for child in get_children(true):
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null: continue
		#mesh_instance.material_overlay = shadow_of_war_overlay_material
		var material := mesh_instance.mesh.surface_get_material(0) as StandardMaterial3D
		if material == null: continue
		var override_material: ShaderMaterial = material_cache.get(material, null)
		if override_material == null:
			override_material = ShaderMaterial.new()
			material_cache[material] = override_material
			if material.transparency == BaseMaterial3D.Transparency.TRANSPARENCY_DISABLED:
				override_material.shader = level_shader
			if material.transparency == BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA_HASH:
				override_material.shader = level_decal_shader
				override_material.set_shader_parameter("alpha_hash_scale", material.alpha_hash_scale)
			if material.transparency == BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA_SCISSOR:
				override_material.shader = level_flora_shader
				override_material.set_shader_parameter("alpha_scissor_threshold", material.alpha_scissor_threshold)
			override_material.set_shader_parameter("density_texture", viewport_texture)
			override_material.set_shader_parameter("texture_albedo", material.albedo_texture)
			override_material.set_shader_parameter("texture_normal", material.normal_texture)
		mesh_instance.material_override = override_material

#TODO: optimize
func _process(delta: float) -> void:
	for material: ShaderMaterial in material_cache.values():
		material.set_shader_parameter('a', viewport.A)
		material.set_shader_parameter('b', viewport.B)
		material.set_shader_parameter('c', viewport.C)
		material.set_shader_parameter('d', viewport.D)

@export_global_dir var scene_dir: String
var points_root: Node3D
@export_tool_button("Import Points") var import_scene_obj_pos := func() -> void:
	points_root = $Points
	if points_root == null:
		points_root = Node3D.new()
		add_child(points_root)
		points_root.owner = self
		points_root.name = "Points"
	else:
		for child in points_root.get_children():
			points_root.remove_child(child)

	var da := DirAccess.open(scene_dir)
	var level_size := spawn_point_from_file("__LevelSize_.SCB")
	for fname in da.get_files():
		if !fname.to_lower().ends_with(".scb"): continue
		var obj := spawn_point_from_file(fname)
		obj.global_position -= Vector3(1, 0, 1) * level_size.global_position

func spawn_point_from_file(fname: String) -> Node3D:
	var fa := FileAccess.open(scene_dir.path_join(fname), FileAccess.READ)
	var magic := fa.get_buffer(8).get_string_from_utf8()
	var major_ver := fa.get_16()
	var minor_ver := fa.get_16()
	var obj_name := fa.get_buffer(128).get_string_from_utf8()
	var n_verts := fa.get_32()
	var n_faces := fa.get_32()
	var unk := fa.get_32()
	var center := get_v3(fa)

	var obj := MeshInstance3D.new()
	obj.mesh = SphereMesh.new()
	points_root.add_child(obj)
	obj.owner = self
	obj.name = obj_name
	obj.global_position = center * HW2GD
	return obj

@export var create_level_props_script: GDScript
@export_tool_button("Create Level Props")
var post_level_load := func() -> void:
	(create_level_props_script.new() as CreateLevelProps).create_level_props()

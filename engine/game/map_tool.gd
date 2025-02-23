@tool class_name MapTool extends Data

static func vec2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)

static func get_v3(fa: FileAccess) -> Vector3:
	return Vector3(fa.get_float(), fa.get_float(), fa.get_float())

static func surface_get_material(mi: MeshInstance3D) -> StandardMaterial3D:
	var m := mi.get_surface_override_material(0) as StandardMaterial3D
	if m == null:
		m = mi.mesh.surface_get_material(0) as StandardMaterial3D
	return m

@export_group("Decals")
@export var decals: Array[Texture2D] = []
@export var show_decals := true:
	get: return show_decals
	set(value):
		show_decals = value
		set_visible_if_texture_in(decals, value)
func set_visible_if_texture_in(array: Array[Texture2D], value: bool) -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := surface_get_material(mi)
		assert(m != null, str(child.name))
		if m.albedo_texture in array:
			mi.visible = value
@export var ground: Array[Texture2D] = []
@export var show_ground := true:
	get: return show_ground
	set(value):
		show_ground = value
		set_visible_if_texture_in(ground, value)
@export_tool_button("Fix Decals (Simple)") var fix_decals_simple := func() -> void:
	var mis: Array[MeshInstance3D] = []
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := surface_get_material(mi)
		var is_decal := m.albedo_texture in decals
		if is_decal:
			mis.append(mi)
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			#m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
			#m.texture_repeat = false

	mis.shuffle()
	for i in range(len(mis)):
		var mi := mis[i]
		mi.position.y = 0.01 + i * 0.01
	
	#mis.sort_custom(
	#	func(mia: MeshInstance3D, mib: MeshInstance3D) -> bool:
	#		var miam := surface_get_material(mia)
	#		var mibm := surface_get_material(mib)
	#		return decals.find(miam.albedo_texture) < decals.find(mibm.albedo_texture)
	#)

	#var levels := sort_to_levels(mis)
	#levels.shuffle()
	#for i in range(len(levels)):
	#	var level := levels[i]
	#	for mi: MeshInstance3D in level:
	#		mi.position.y = 0.001 + i * 0.001

static func get_aabb(vis: VisualInstance3D) -> AABB:
	var d := vis as Decal
	if d != null:
		return AABB(d.global_position, d.size)
	return vis.get_aabb()

func sort_to_levels(mis: Array[Variant]) -> Array[Array]:
	var levels: Array[Array] = []
	for mia: VisualInstance3D in mis:
		var mia_aabb := get_aabb(mia)
		var i := levels.find_custom(
			func(level: Array) -> bool:
				for mib: VisualInstance3D in level:
					var mib_aabb := get_aabb(mib)
					if mib_aabb.intersects(mia_aabb):
						return false
				return true
		)
		if i == -1:
			levels.append([ mia ])
		else:
			levels[i].append(mia)
	return levels

class Point extends RefCounted:
	var scale: float
	var angle: float
	var normal: Vector3
	var global_position: Vector3

@export_tool_button("Fix Decals (Advanced)") var fix_decals_advanced := func() -> void:
	
	var decals_root := $Decals
	if decals_root == null:
		decals_root = Node3D.new()
		add_child(decals_root)
		move_child(decals_root, 0)
		decals_root.owner = self
		decals_root.name = "Decals"

	var ds: Array[Decal] = []
	
	for child in decals_root.get_children(true):
		var d := child as Decal
		if d == null: continue
		#decals_root.remove_child(d)
		#d.queue_free()
		ds.append(d)
	
	"""
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := surface_get_material(mi)
		if m.albedo_texture in ground:
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.layers = 2
		elif m.albedo_texture in decals:
			var points := uv_to_3d(mi)
			for p in points:
				var i := ds.find_custom(func(d: Decal) -> bool:
					return d.texture_albedo == m.albedo_texture\
						&& d.global_position.distance_to(p.global_position) <= 0.5)
				if i == -1:
					var d := Decal.new()
					decals_root.add_child(d)
					d.owner = self
					d.name = mi.name + "_Decal"
					d.texture_albedo = m.albedo_texture
					d.texture_normal = m.normal_texture
					d.cull_mask = 2
					d.global_position = p.global_position
					d.size = Vector3(p.scale, 1, p.scale)
					d.rotate(p.normal, p.angle)
					ds.append(d)
	"""

	ds.sort_custom(
		func(mia: Decal, mib: Decal) -> bool:
			return decals.find(mia.texture_albedo) < decals.find(mib.texture_albedo)
	)
	#ds.shuffle()

	var levels := sort_to_levels(ds)
	#levels.shuffle()
	for i in range(len(levels)):
		for mia: VisualInstance3D in levels[i]:
			var mia_aabb := get_aabb(mia)
			var max_size_len := 0.0
			for j in range(0, i):
				for mib: VisualInstance3D in levels[j]:
					var mib_aabb := get_aabb(mib)
					if mib_aabb.intersects(mia_aabb):
						var size_len := 0.0
						#size_len = max(size_len, mia.position.distance_to(mib.position))
						#size_len = max(size_len, mib_aabb.size.length())
						size_len += mia.position.distance_to(mib.position)
						size_len += mib_aabb.size.length()
						size_len += mib.sorting_offset
						max_size_len = max(max_size_len, size_len)
			var d := mia as Decal
			#d.size.y = (1.0 / len(levels)) * (i + 1)
			d.size.y = 1
			d.distance_fade_enabled = false
			mia.sorting_offset = max_size_len + 10

	var max_sorting_offset: float = ds.reduce(func(accum: float, d: Decal) -> float: return max(accum, d.sorting_offset), 0)
	var min_sorting_offset: float = ds.reduce(func(accum: float, d: Decal) -> float: return min(accum, d.sorting_offset), 0)
	for d in ds:
		d.sorting_offset = d.sorting_offset - ((max_sorting_offset - min_sorting_offset) * 0.5)

	print(len(levels), ' ', len(ds))

func uv_to_3d(mi: MeshInstance3D, uv := Vector2(0.5, 0.5)) -> Array[Point]:
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(mi.mesh, 0)
	var points: Array[Point] = []
	for f_i in range(mdt.get_face_count()):
		var vs_i := Vector3i(mdt.get_face_vertex(f_i, 0), mdt.get_face_vertex(f_i, 1), mdt.get_face_vertex(f_i, 2))
		var uvs: Array[Vector2] = [ mdt.get_vertex_uv(vs_i[0]), mdt.get_vertex_uv(vs_i[1]), mdt.get_vertex_uv(vs_i[2]) ]
		var a := area(uvs[0], uvs[1], uvs[2])
		if a == 0: continue
		var bccs := Vector3(area(uvs[1], uvs[2], uv), area(uvs[2], uvs[0], uv), area(uvs[0], uvs[1], uv)) / a
		if bccs[0] < 0 || bccs[1] < 0 || bccs[2] < 0: continue
		var vs: Array[Vector3] = [ mdt.get_vertex(vs_i[0]), mdt.get_vertex(vs_i[1]), mdt.get_vertex(vs_i[2]) ]
		var p := Point.new()
		var p_position := (bccs[0] * vs[0]) + (bccs[1] * vs[1]) + (bccs[2] * vs[2])
		p.global_position = mi.to_global(p_position)
		var vs_global_position := mi.to_global(vs[0])
		p.scale = (1 / uv.distance_to(uvs[0])) * p.global_position.distance_to(vs_global_position)
		
		# (vs_global_position - p.global_position).angle_to(Vector3.FORWARD)
		# p_position.signed_angle_to(vs[0], p.normal)
		#p.angle += (uvs[0] - uv).angle()
		#p.angle += vec2(vs[0] - p_position).angle()
		#p.angle -= (vs[0] - p_position).signed_angle_to(Vector3.LEFT, p.normal)
		#p.angle = -p.angle

		#var a1 := vec2(vs[0] - p_position).angle()
		#if a1 < 0: a1 += 360
		#var a2 := (uvs[0] - uv).angle()
		#if a2 < 0: a2 += 360
		#p.angle = a2 - a1

		#var a1 := roundf(rad_to_deg(vec2(mi.to_global(vs[0]) - p.global_position).angle()))
		#var a2 := roundf(rad_to_deg(vec2(mi.to_global(vs[1]) - p.global_position).angle()))
		#var a3 := roundf(rad_to_deg(vec2(mi.to_global(vs[2]) - p.global_position).angle()))
		#var a1 := roundf(rad_to_deg((uvs[0] - uv).angle()))
		#var a2 := roundf(rad_to_deg((uvs[1] - uv).angle()))
		#var a3 := roundf(rad_to_deg((uvs[2] - uv).angle()))
		#print(a1, ' ', a2, ' ', a3)
		
		p.normal = mdt.get_face_normal(f_i)
		points.append(p)
	return points

func area(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
	var v1: Vector2 = p1 - p3
	var v2: Vector2 = p2 - p3
	return (v1.x * v2.y - v1.y * v2.x) / 2

@export_tool_button("Fix Decals Transparency") var fix_decals_v2 := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := surface_get_material(mi)
		var is_decal := m.albedo_texture in decals
		if is_decal:
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			m.render_priority = decals.find(m.albedo_texture) - len(decals)
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.lod_bias = 1.0

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
		#var resource_name := (surface_get_material(mi)).resource_name
		var new_material := load("res://data/levels/1/materials/%s.tres" % resource_name)
		#mi.mesh.surface_set_material(0, new_material)
		mi.set_surface_override_material(0, new_material)

@export_tool_button("Enable Normal Maps") var enable_normal_maps := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := surface_get_material(mi)
		m.normal_enabled = true
		m.normal_texture = load(m.albedo_texture.resource_path.replace(".webp", ".normal.webp"))
@export_tool_button("Enable Height Maps") var enable_height_maps := func() -> void:
	for child in get_children(true):
		var mi := child as MeshInstance3D
		if mi == null: continue
		assert(mi.mesh.get_surface_count() == 1)
		var m := surface_get_material(mi)
		m.heightmap_enabled = true
		m.heightmap_texture = load(m.albedo_texture.resource_path.replace(".webp", ".height.webp"))
@export_group("")

@export_tool_button("TEST") var test := func() -> void:
	pass

func _ready() -> void:
	if Engine.is_editor_hint(): return
	replace_materials_at_runtime()

@export_group("Material Replacement")
@export var viewport_texture: ViewportTexture
@export var material_cache: Dictionary[StandardMaterial3D, ShaderMaterial] = {}
@export_tool_button("Cache Materials") var cache_materials := replace_materials_at_runtime
func replace_materials_at_runtime() -> void:
	
	if viewport_texture != null:
		viewport_texture.set_viewport_path_in_scene("/root/Node3D/SubViewport")

	if Engine.is_editor_hint():
		material_cache = {}

	for child in find_children("*", "MeshInstance3D", true):

		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null: continue

		var material := surface_get_material(mesh_instance)
		if material == null: continue

		var override_material: ShaderMaterial = material_cache.get(material, null)
		if override_material == null:
			override_material = ShaderMaterial.new()
			material_cache[material] = override_material
			
			var code := "shader_type spatial;" + "\n"
			var render_modes: Array[String] = ["blend_mix", "depth_draw_opaque", "cull_back", "diffuse_burley", "specular_schlick_ggx"]
			if material.transparency == BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS:
				render_modes.append("depth_prepass_alpha")
			code += "render_mode " + ", ".join(render_modes) + ";" + "\n"
			
			if material.texture_repeat:
				code += "#define REPEAT_MODE repeat_enable" + "\n"
			else:
				code += "#define REPEAT_MODE repeat_disable" + "\n"

			if material.transparency == BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA_HASH:
				code += "#define ALPHA_HASH_USED" + "\n"
			elif material.transparency == BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA_SCISSOR:
				code += "#define ALPHA_SCISSOR_USED" + "\n"
			elif material.transparency != BaseMaterial3D.Transparency.TRANSPARENCY_DISABLED:
				code += "#define ALPHA_USED" + "\n"

			code += "#include \"res://engine/game/level/level.gdshaderinc\"" + "\n"

			var hash := code.sha256_text().substr(0, 12)
			var res_path := "res://engine/game/cache/shaders/%s.gdshader" % hash
			if !FileAccess.file_exists(res_path):
				var fa := FileAccess.open(res_path, FileAccess.ModeFlags.WRITE)
				fa.store_string(code)
				fa.close()
				fa = FileAccess.open(res_path + ".uid", FileAccess.ModeFlags.WRITE)
				fa.store_string("uid://" + hash)
				fa.close()
			override_material.shader = load(res_path)

			if material.transparency == BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA_HASH:
				override_material.set_shader_parameter("alpha_hash_scale", material.alpha_hash_scale)
			if material.transparency == BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA_SCISSOR:
				override_material.set_shader_parameter("alpha_scissor_threshold", material.alpha_scissor_threshold)
			
			override_material.set_shader_parameter("density_texture", viewport_texture)

			override_material.set_shader_parameter("texture_albedo", material.albedo_texture)
			if material.normal_enabled:
				override_material.set_shader_parameter("texture_normal", material.normal_texture)
			if material.heightmap_enabled:
				override_material.set_shader_parameter("texture_heightmap", material.heightmap_texture)

			override_material.render_priority = material.render_priority
			override_material.resource_local_to_scene = true
		
		if !Engine.is_editor_hint():
			mesh_instance.material_override = override_material

@export_group("")

#TODO: optimize
#func _process(delta: float) -> void:
	#for material: ShaderMaterial in material_cache.values():
		#material.set_shader_parameter('a', viewport.A)
		#material.set_shader_parameter('b', viewport.B)
		#material.set_shader_parameter('c', viewport.C)
		#material.set_shader_parameter('d', viewport.D)

@export_group("Object Placement")
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

@export_file("*.cfg") var object_cfg: String
@export var create_level_props_script: GDScript
@export_tool_button("Create Level Props")
var create_level_props := func() -> void:
	(create_level_props_script.new() as CreateLevelProps).create_level_props()
	var root: Node = null #EditorInterface.get_edited_scene_root()
	var points := find_child("Points", false, false)
	var ini := ini_load(object_cfg)
	for section_name: String in ini:
		var section: Array[Array] = ini[section_name]
		var nav_point_name := section_name.split('\\')[-1].rsplit('.', false, 2)[0]
		var nav_point: Node3D = points.find_child(nav_point_name, false)
		#assert(nav_point != null, nav_point_name)
		if nav_point == null:
			print("nav point %s not found. skipping" % nav_point_name)
			continue

		if !nav_point_name.begins_with("Turret_"): continue

		var char: Unit = find_child(nav_point_name, false)
		if char == null:
			var char_prefab_path := "res://data/characters"
			var i := section.find_custom(func (kv: Array) -> bool:
				var key_array: Array = kv[0]
				var value: Variant = kv[1]
				return key_array[0] == "SkinName" && key_array[1] == 1)
			if i != -1:
				var skin_name: String = section[i][1]
				var prefix := ""
				for s: String in ["Order", "Chaos", "Destroyed"]:
					if skin_name.begins_with(s):
						prefix = s
				if len(prefix):
					char_prefab_path += "/" + skin_name.replace(prefix, "")
					char_prefab_path += "/" + prefix
				else:
					char_prefab_path += "/" + skin_name
				char_prefab_path += "/" + "unit.tscn"

				if !FileAccess.file_exists(char_prefab_path):
					print("char %s not found. skipping" % skin_name)
					continue

				var char_prefab: PackedScene = load(char_prefab_path)
				
				char = char_prefab.instantiate()
				add_child(char)
				char.owner = root
				char.name = nav_point_name
		
		if char != null:
			
			#char.global_position = nav_point.global_position
			#char.rotation_degrees.y = 90

			for entry: Array in section:
				var key_array: Array = entry[0]
				var value: Variant = entry[1]
				match key_array:
					#["Move"]: char.position += vec3_parse(value) * HW2GD
					#["Rot"]: char.rotation_degrees.y += vec3_parse(value).x
					_: char.data.set_from_ini_entry(key_array, value)
@export_group("")

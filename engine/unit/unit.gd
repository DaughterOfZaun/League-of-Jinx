class_name Unit extends Node3DExt #@rollback

@export var team: Enums.Team = 0
@export var data: UnitData

var _stats: Stats
var stats: Stats:
	set(v): _stats = v
	#get: return _stats
	get:
		if Balancer.should_update_stats(self):
		#if Balancer.is_updating_stats:
			return stats_temp
		else:
			return stats_perm
var stats_temp: Stats:
	get:
		_stats.temp = _stats.temp_b
		return _stats
var stats_perm: Stats:
	get:
		_stats.temp = _stats.temp_a
		return _stats

var status: Status
var buffs: Buffs
var spells: Spells
var passive: Passive
var vars: Vars
var ai: AI
var animation: AnimationController

@onready var font_emitter: FontEmitter = find_child("FontEmitter", false, false)

func issue_order(order: Enums.OrderType, targetOfOrderPosition := Vector3.INF, targetOfOrder: Unit = null) -> void:
	ai.order(order, targetOfOrderPosition, targetOfOrder)
func order(type: Enums.OrderType, pos: Vector3, unit: Unit) -> void:
	ai.order(type, pos, unit)
func cast(letter: String, pos: Vector3, unit: Unit) -> void:
	ai.cast(letter, pos, unit)
func emote(type: Enums.EmoteType) -> void:
	ai.emote(type)

func _physics_process(delta: float) -> void:
	#if Engine.is_editor_hint(): return

	_physics_process_rotate(delta)
	_physics_process_update_visibility(delta)
	#_physics_process_sync_char_body_pos(delta)

#region Signals
static var signals: Array[StringName] = []
static var on_signals: Array[StringName] = []
static var signals_init_completed: bool = false
func _init() -> void:
	if signals_init_completed: return
	signals_init_completed = true
	for s in get_signal_list():
		signals.append(StringName(s.name))
		on_signals.append(StringName('on_' + s.name))

func connect_all(to: Node) -> void:
	for i in range(signals.size()):
		var sname := signals[i]
		var mname := on_signals[i]
		if mname in to:
			(self[sname] as Signal).connect(to[mname] as Callable)

signal allow_add(attacker: Unit, buff: Buff)

signal dodge(attacker: Unit)
signal being_dodged(target: Unit)

# HIT
signal hit_unit(target: Unit, damage: DamageData)
signal being_hit(attacker: Unit, damage: DamageData)
signal spell_hit(target: Unit, spell: Spell)
signal being_spell_hit(attacker: Unit, spell: Spell)
signal miss(target: Unit)

# DASH
signal move_end()
signal move_failure()
signal move_success()
signal collision()
signal collision_terrain()

# DEATH
signal kill(target: Unit)
signal assist(attacker: Unit, target: Unit)
signal death(attacker: Unit)
signal nearby_death(attacker: Unit, target: Unit)
signal zombie(attacker: Unit)
signal resurrect()

# CONNECTION
signal disconnect()
signal reconnect()

# LEVEL
signal level_up()
signal level_up_spell(slot: int)

signal pre_attack(target: Unit)
signal launch_attack(target: Unit)
signal launch_missile(spell: Spell, missile: Missile)
signal missile_update(spell: Spell, missile: Missile)
signal missile_end(spell: Spell, missile: Missile)

# DAMAGE
signal pre_deal_damage(target: Unit, damage: DamageData)
signal pre_mitigation_damage(target: Unit, damage: DamageData) #TODO: target -> attacker
signal pre_damage(target: Unit, damage: DamageData) #TODO: target -> attacker
signal take_damage(attacker: Unit, damage: DamageData)
signal deal_damage(target: Unit, damage: DamageData)

signal heal(heal: HealData)

signal spell_cast(spell: Spell)

#signal set_vars_by_level() #TODO: Specific to char_script and talent_script
#signal update_ammo() #TODO: Specific to buff_script
#signal update_buffs() #TODO: Specific to buff_script

#endregion

@onready var direction_angle: float = rotation.y
@onready var direction: Vector2 = Vector2.from_angle(direction_angle)
func face_direction(pos: Vector3) -> void:
	face_dir(pos - self.position_3d)
func face_dir(dir: Vector3) -> void:
	direction = Vector2(dir.x, dir.z).normalized()
	direction_angle = atan2(dir.x, dir.z)
func get_point_by_facing_offset(distance: float, offset_angle: float) -> Vector3:
	var v2 := direction.rotated(deg_to_rad(offset_angle)) * distance
	return position_3d + Vector3(v2.x, 0, v2.y)

#var rot_speed := deg_to_rad(180. / ((0.08 + (0.01/3.))))
var rot_speed: float = deg_to_rad(180 / 0.2)
func _physics_process_rotate(delta: float) -> void:
	var rot_delta := angle_difference(rotation.y, direction_angle)
	if is_zero_approx(rot_delta): return
	rotation.y += sign(rot_delta) * min(abs(rot_delta), rot_speed * delta)

@onready var skinned_mesh_root: Node = find_child("SkinnedMesh", false, false)
@onready var skeleton: Skeleton3D = skinned_mesh_root.find_child("Skeleton3D", true, false) if skinned_mesh_root else null
func get_bone_global_position(bone_idx: int) -> Vector3:
	return skeleton.to_global(skeleton.get_bone_global_pose(bone_idx).origin)
func get_bone_idx(bone_name: StringName) -> int:
	return skeleton.find_bone(bone_name.replace("_CSTM_", "_GLB_"))

#func teleport(cast_position: Vector3) -> void:
#func teleport(team: Enums.Team, location: Enums.SpawnType) -> void:
func teleport(team_or_cast_position: Variant, location: Enums.SpawnType = 0) -> void:
	assert(team_or_cast_position is Vector3 || (team_or_cast_position is Enums.Team && location != 0))
	push_warning("Unit.teleport is unimplemented")

#region Movement
func move(
	target: Vector3,
	speed: float,
	gravity: float = 0,
	move_back_by: float = 0,
	movement_type: Enums.ForceMovementType = 0,
	movement_orders_type: Enums.ForceMovementOrdersType = 0,
	ideal_distance: float = 0,
	movement_orders_facing: Enums.ForceMovementOrdersFacing = 0
) -> void:
	var aims := ai.move_state
	aims.move_target_position = target
	aims.speed = speed
	aims.gravity = gravity
	aims.movement_type = movement_type
	aims.movement_orders_type = movement_orders_type
	aims.movement_orders_facing = movement_orders_facing
	aims.move = AIMoveState.MoveType.TO_POS
	aims.move_back_by = move_back_by
	aims.ideal_distance = ideal_distance
	aims.try_enter()

func move_away(
	away_from: Vector3,
	speed: float,
	gravity: float,
	distance: float,
	distance_inner: float,
	movement_type: Enums.ForceMovementType = 0,
	movement_orders_type: Enums.ForceMovementOrdersType = 0,
	ideal_distance: float = 0,
	movement_orders_facing: Enums.ForceMovementOrdersFacing = 0
) -> void:
	var aims := ai.move_state
	aims.move_target_position = away_from
	aims.speed = speed
	aims.gravity = gravity
	aims.movement_type = movement_type
	aims.movement_orders_type = movement_orders_type
	aims.movement_orders_facing = movement_orders_facing
	aims.move = AIMoveState.MoveType.AWAY_FROM
	aims.distance = distance
	aims.distance_inner = distance_inner
	aims.try_enter()

func move_to_unit(
	target: Unit,
	speed: float,
	gravity: float,
	movement_orders_type: Enums.ForceMovementOrdersType,
	move_back_by: float,
	max_track_distance: float,
	ideal_distance: float,
	time_override: float
) -> void:
	var aims := ai.move_state
	aims.move_target = target
	aims.speed = speed
	aims.gravity = gravity
	#aims.movement_type = movement_type
	aims.movement_orders_type = movement_orders_type
	#aims.movement_orders_facing = movement_orders_facing
	aims.move = AIMoveState.MoveType.TO_UNIT
	aims.move_back_by = move_back_by
	aims.ideal_distance = ideal_distance
	aims.max_track_distance = max_track_distance
	aims.time_override = time_override
	aims.try_enter()

func stop_move() -> void:
	push_warning("Unit.stop_move is unimplemented")

func stop_move_block() -> void:
	push_warning("Unit.stop_move_block is unimplemented")
#endregion

#region Health&Life
func inc_par(delta: float, par_type := Enums.PARType.MANA) -> void:
	push_warning("Unit.inc_par is unimplemented")

func inc_health(delta: float, healer: Unit = null) -> void:
	push_warning("Unit.inc_health is unimplemented")

func inc_max_health(delta: float, inc_current_health: bool) -> void:
	push_warning("Unit.inc_max_health is unimplemented")

func apply_damage(
	attacker: Unit,
	damage: float,
	damage_type: Enums.DamageType,
	source_damage_type: Enums.DamageSource,
	percent_of_attack: float = 0,
	spell_damage_ratio: float = 0,
	physical_damage_ratio: float = 0,
	ignore_damage_increase_mods: bool = false,
	ignore_damage_crit: bool = false,
	call_for_help_attacker: Unit = null
) -> void:

	var damage_data := DamageData.new()
	damage_data.amount = damage
	damage_data.type = damage_type
	damage_data.source = source_damage_type
	damage_data.result = Enums.HitResult.NORMAL

	var target := self

	if damage_data.source == Enums.DamageSource.ATTACK:
		target.being_hit.emit(attacker, damage_data)
		attacker.hit_unit.emit(target, damage_data)
		if damage_data.result == Enums.HitResult.DODGE:
			target.dodge.emit(attacker)
			attacker.being_dodged.emit(target)
		elif damage_data.result == Enums.HitResult.MISS:
			attacker.miss.emit(target)

	var can_take_damage := damage_data.source == Enums.DamageSource.INTERNALRAW || (
		!target.status.invulnerable && (
			(damage_data.type == Enums.DamageType.PHYSICAL && !target.status.physical_immune) ||\
			(damage_data.type == Enums.DamageType.MAGICAL && !target.status.magic_immune) ||\
			(damage_data.type == Enums.DamageType.TRUE)
		)
	)
	if !(can_take_damage && damage_data.amount > 0): return

	attacker.pre_deal_damage.emit(target, damage_data)
	target.pre_mitigation_damage.emit(target, damage_data)

	#TODO: migitation

	if !(damage_data.amount > 0): return

	target.pre_damage.emit(damage_data)
	target.stats_perm.health_current -= damage_data.amount
	font_emitter.emit_text(str(roundi(damage_data.amount)), 0.5, 2.5, Color.RED, 1.0)

	target.take_damage.emit(attacker, damage_data)
	attacker.deal_damage.emit(target, damage_data)

	#TODO: lifesteal/spellvamp

	#TODO: death

func force_dead() -> void:
	push_warning("Unit.force_dead is unimplemented")
func reincarnate() -> void:
	push_warning("Unit.reincarnate is unimplemented")
#endregion
#region AutoAttack
func override_auto_attack(spell: Spell, auto_attack_spell_level: int, cancelAttack: bool) -> void:
	push_warning("Unit.override_auto_attack is unimplemented")
func remove_override_auto_attack(cancel_attack: bool) -> void:
	push_warning("Unit.remove_override_auto_attack is unimplemented")
func cancel_auto_attack(reset: bool) -> void:
	push_warning("Unit.cancel_auto_attack is unimplemented")
func skip_next_auto_attack() -> void:
	push_warning("Unit.skip_next_auto_attack is unimplemented")
#endregion
#region Shields
func modify_shield(amount: float = 0, magic_shield: bool = false, physical_shield: bool = false, no_fade: bool = false) -> void:
	push_warning("Unit.modify_shield is unimplemented")
func increase_shield(amount: float = 0, magic_shield: bool = false, physical_shield: bool = false) -> void:
	push_warning("Unit.increase_shield is unimplemented")
func reduce_shield(amount: float = 0, magic_shield: bool = false, physical_shield: bool = false) -> void:
	push_warning("Unit.reduce_shield is unimplemented")
func remove_shield(amount: float = 0, magic_shield: bool = false, physical_shield: bool = false) -> void:
	push_warning("Unit.remove_shield is unimplemented")
func break_spell_shields() -> void:
	self.buffs.add(self, SpellShieldMarker.new(), 0, 1, 37037)
#endregion
#region CharData
func push_character_data(skin_name: String, override_spells: bool) -> void:
	push_warning("Unit.push_character_data is unimplemented")
func pop_character_data(id: int) -> void:
	push_warning("Unit.pop_character_data is unimplemented")
func pop_all_character_data() -> void:
	push_warning("Unit.pop_all_character_data is unimplemented")
#endregion
#region Fade
class Fade: pass
func push_fade(fade_amount: float, fade_time: float, id: Fade = null) -> Fade:
	push_warning("Unit.push_fade is unimplemented")
	return null
func pop_fade(id: Fade) -> void:
	push_warning("Unit.pop_fade is unimplemented")
#endregion
#region Misc
var is_in_brush: bool:
	get: return false
func start_tracking_collisions(value: bool) -> void:
	push_warning("Unit.start_tracking_collisions is unimplemented")
func set_voice_override(override_suffix: String) -> void:
	push_warning("Unit.set_voice_override is unimplemented")
func reset_voice_override() -> void:
	push_warning("Unit.reset_voice_override is unimplemented")
func say(to_say: String, src: Variant = null) -> void:
	push_warning("Unit.say is unimplemented")
func debug_say(to_say: String, src: Variant = null) -> void:
	push_warning("Unit.debug_say is unimplemented")
func invalidate() -> void:
	push_warning("Unit.invalidate is unimplemented")
func set_not_targetable_to_team(to_ally: bool, to_enemy: bool) -> void:
	push_warning("Unit.set_not_targetable_to_team is unimplemented")
func update_can_cast() -> void:
	push_warning("Unit.update_can_cast is unimplemented")
#endregion

func apply_assist_marker(source: Unit, duration: float) -> void:
	push_warning("Unit.apply_assist_marker is unimplemented")

func can_see(target: Unit) -> bool:
	push_warning("Unit.can_see is unimplemented")
	return true

func is_in_front(target: Unit) -> bool:
	var d := target.global_position - global_position
	var a := Vector2(d.x, d.z).angle_to(direction)
	return abs(a) <= 160
func is_behind(target: Unit) -> bool:
	return !is_in_front(target)

@onready var nav_map_rid: RID = get_world_3d().navigation_map
func get_nearest_passable_position(pos: Vector3) -> Vector3:
	return NavigationServer3D.map_get_closest_point(nav_map_rid, pos * Data.HW2GD) * Data.GD2HW

func stop_channeling(condition: Enums.ChannelingStopCondition, souce: Enums.ChannelingStopSource) -> void:
	push_warning("unimplemented")

var is_ready: bool = false
static var fow_subviewport: SubViewportEx
static var fow_subviewport_texture: ViewportTexture
static var fow_init_completed: bool = false
func _ready() -> void:
	is_ready = true
	if fow_init_completed: return
	fow_init_completed = true
	fow_subviewport = get_node("/root/Node3D/SubViewport")
	fow_subviewport_texture = fow_subviewport.get_texture()
	#RenderingServer.frame_pre_draw.connect(update_fow_image_if_needed)

func get_visible_in_fow() -> bool:
	return team != Enums.Team.CHAOS #HACK:

static var fow_image: Image = null
static var fow_image_frame: int
static var current_frame: int = 0
func update_fow_image_if_needed() -> void:
	current_frame += 1
	#var current_frame := Engine.get_physics_frames()
	if current_frame - fow_image_frame >= 15: #TODO: Balancer
		fow_image_frame = current_frame
		#await RenderingServer.frame_post_draw
		fow_image = fow_subviewport_texture.get_image()

func _physics_process_update_visibility(delta: float) -> void:	
	
	if get_visible_in_fow(): return
	
	#update_fow_image_if_needed()

	if fow_image == null: return
	var canvas_position := fow_subviewport.to_canvas(global_position)
	var canvas_position_rounded := Vector2i(roundi(canvas_position.x), roundi(canvas_position.y))
	var pixel := fow_image.get_pixelv(canvas_position_rounded)
	
	visible = pixel.r > 0.5

#var prev_transform: Transform3D = Transform3D.IDENTITY
#@onready var character_body: CharacterBody3D = self as Variant #find_child("CharacterBody3D", false, false)
#@onready var navigation_agent: NavigationAgent3D = find_child("NavigationAgent3D", false, false)
#func _physics_process_sync_char_body_pos(delta: float) -> void:
#	if character_body == null: return
#	if transform != prev_transform:
#		character_body.transform = transform
#	else:
#		transform = character_body.transform
#	prev_transform = transform

var _visible: bool = false
var _transform: Transform3D = Transform3D.IDENTITY
#var _character_body_velocity: Vector3 = Vector3.ZERO
#var _navigation_agent_avoidance_enabled: bool = false
#var _navigation_agent_velocity: Vector3 = Vector3.ZERO
#var _navigation_agent_target_position: Vector3 = Vector3.ZERO
#var _navigation_agent_avoidance_priority: float = 0.0
func _save() -> void:
	_visible = visible
	_transform = transform
	# if character_body != null:
	# 	_character_body_velocity = character_body.velocity
	# if navigation_agent != null:
	# 	_navigation_agent_avoidance_enabled = navigation_agent.avoidance_enabled
	# 	_navigation_agent_velocity = navigation_agent.velocity
	# 	_navigation_agent_target_position = navigation_agent.target_position
	# 	_navigation_agent_avoidance_priority = navigation_agent.avoidance_priority
func _load() -> void:
	visible = _visible
	transform = _transform
	# if character_body != null:
	# 	character_body.velocity = _character_body_velocity
	# if navigation_agent != null:
	# 	navigation_agent.avoidance_enabled = _navigation_agent_avoidance_enabled
	# 	navigation_agent.velocity = _navigation_agent_velocity
	# 	navigation_agent.target_position = _navigation_agent_target_position
	# 	navigation_agent.avoidance_priority = _navigation_agent_avoidance_priority

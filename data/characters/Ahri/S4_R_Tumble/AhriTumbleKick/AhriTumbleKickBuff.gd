class_name AhriTumbleKickBuff extends Buff

var data: BuffData = preload('AhriTumbleKickBuff.tres')

var target_pos: Vector3
var distance: float
var dash_speed: float
var self_particle: Particle
#var will_remove: bool # UNUSED
func _init(target_pos := Vector3.INF, distance := 0.0, dash_speed := 0.0) -> void:
	self.target_pos = target_pos
	self.distance = distance
	self.dash_speed = dash_speed
func clone() -> Buff:
	return new(target_pos, distance, dash_speed)

func on_activate() -> void:
	#require_var(self.dash_speed)
	#require_var(self.target_pos)
	#require_var(self.distance)
	host.animation.play("Spell4", 0, true, false, true)
	host.move(target_pos, dash_speed, 0, 0, Enums.ForceMovementType.FURTHEST_WITHIN_RANGE, Enums.ForceMovementOrdersType.CANCEL_ORDER, distance, Enums.ForceMovementOrdersFacing.FACE_MOVEMENT_DIRECTION)
	self_particle = Particle.create(preload("Ahri_SpiritRush_mis.tscn")).bind(host, "BUFFBONE_GLB_GROUND_LOC").target(target, "BUFFBONE_GLB_GROUND_LOC")
	#will_remove = false
	host.status.ghosted = true

func on_deactivate(expired: bool) -> void:
	self_particle.remove()
	host.animation.unlock(true)
	host.status.ghosted = false

func on_move_end() -> void:
	var count := 3
	var owner_pos := host.position_3d
	var level := attacker.spells.r.level
	for unit in API.get_closest_visible_units_in_area(host, host.position_3d, 700, Enums.SpellFlags.AFFECT_ENEMY_HEROES, 3, null, true):
		(host.spells.extra[5] as AhriTumbleMissileSpell).cast(unit, Vector3.INF, Vector3.INF, level, true, true, false, true, false, true, owner_pos)
		count -= 1
	for unit in API.get_closest_visible_units_in_area(host, host.position_3d, 700, Enums.SpellFlags.AFFECT_ENEMY_AND_NEUTRAL_MINIONS, count, null, true):
		(host.spells.extra[5] as AhriTumbleMissileSpell).cast(unit, Vector3.INF, Vector3.INF, level, true, true, false, true, false, true, owner_pos)
	host.buffs.clear(AhriTumbleKickBuff)

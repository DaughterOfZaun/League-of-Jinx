class_name AIMoveState extends AIState

var move_target: Unit
var move_target_position: Vector3:
	get:
		if move_target != null: return move_target.position_3d
		else: return move_target_position
	set(to):
		move_target_position = to
		move_target = null

var speed: float
var gravity: float

var movement_type: Enums.ForceMovementType
var movement_orders_type: Enums.ForceMovementOrdersType
var movement_orders_facing: Enums.ForceMovementOrdersFacing

var move: MoveType
enum MoveType {
	NONE = 0,
	TO_POS = 1,
	TO_UNIT = 2,
	AWAY_FROM = 4,
	TO_POS_OR_UNIT = TO_POS & TO_UNIT,
}

# position & unit
var move_back_by: float
var ideal_distance: float

# unit
var max_track_distance: float
var time_override: float

# away from
var distance: float
var distance_inner: float

func try_enter() -> void:
	if current_state.can_cancel() && can_enter(): enter()

var is_moving: bool = false
func enter() -> void:
	switch_to_self()
	is_moving = true

#TODO: Merge movement code with missile
func _physics_process(delta: float) -> void:
	if !is_moving: return

	var dir := move_target_position - me.position_3d
	var dir_len := dir.length()

	if !is_zero_approx(dir_len):
		me.face_dir(dir)

	var dist := speed * delta
	var target_reached := dist >= dir_len
	if target_reached:
		me.position_3d = move_target_position
		
		me.move_success.emit()
		me.move_end.emit()
		
		switch_to_deffered()
	else:
		var dir_normalized := dir / dir_len
		me.position_3d += dir_normalized * dist

func on_exit() -> void:
	is_moving = false

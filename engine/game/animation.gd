class_name AnimationController extends AnimationTree

@onready var me: Unit = get_parent()
@onready var anim_tree: AnimationTree = me.find_child("AnimationTree", false, false)

func _ready() -> void:
	#if Engine.is_editor_hint(): return
	me.animation = self

var locked: bool = false
# blend is currently ignored
func unlock(blend := true) -> void:
	locked = false

func switch_loop(anim_name: StringName) -> void:
	anim_tree.set("parameters/LoopTransition/transition_request", anim_name)

func switch_to_loop() -> void:
	if locked: return
	anim_tree.set("parameters/MainTransition/transition_request", "Loop")

func play_one_shot(anim_name: StringName) -> void:
	if locked: return
	anim_tree.set("parameters/OneShotTransition/transition_request", anim_name)
	anim_tree.set("parameters/MainTransition/transition_request", "OneShot")

func set_time_scale(anim_name: StringName, time_scale: float) -> void:
	anim_tree.set("parameters/" + str(anim_name) + "TimeScale/scale", time_scale)

# blend and loop are currently ignored 
func play(anim_name: StringName, time_scale := 1.0, loop := false, blend := true, lock := false) -> void:
	if locked: return
	locked = lock
	
	if is_zero_approx(time_scale): time_scale = 1.0
	set_time_scale(anim_name, time_scale)
	
	if anim_name not in [&"Run", &"Idle1", &"Death"]:
		play_one_shot(anim_name)
	else:
		switch_loop(anim_name)
		switch_to_loop()

func override(to_override_anim: StringName, override_anim: StringName) -> void:
	push_warning("unimplemented")

# blend is currently ignored
func stop_current_override(anim_name: StringName, blend := true) -> void:
	push_warning("unimplemented")

func clear_override(to_override_anim: StringName) -> void:
	push_warning("unimplemented")

func pause(pause: bool) -> void:
	push_warning("unimplemented")

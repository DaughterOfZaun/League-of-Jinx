class_name LuaScript extends Node #@rollback

func nameof(callable: Callable) -> StringName:
	return callable.get_method()

var timers: Dictionary[Callable, Timer] = {}
func init_timer(callback: Callable, time_sec: float, oneshot: bool) -> void:
	var timer: Timer = timers.get(callback, null)
	if timer == null:
		timer = Timer.new()
		timer.name = nameof(callback).to_pascal_case()
		timer.timeout.connect(callback)
		timers[callback] = timer
		add_child(timer)
	timer.one_shot = oneshot
	timer.start(time_sec)

func stop_timer(callback: Callable) -> void:
	var timer: Timer = timers.get(callback)
	if timer != null: timer.stop()

func reset_and_start_timer(callback: Callable) -> void:
	var timer: Timer = timers.get(callback)
	if timer != null: timer.start()

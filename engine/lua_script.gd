class_name LuaScript
extends Node

var timers: Dictionary[Callable, Timer] = {}
func init_timer(callback: Callable, time: float, oneshot: bool) -> void:
	var timer: Timer = timers.get(callback, null)
	if timer == null:
		timer = Timer.new()
		timer.name = callback.get_method()
		timer.timeout.connect(callback)
		timers[callback] = timer
		add_child(timer)
	timer.one_shot = oneshot
	timer.start(time)

func stop_timer(callback: Callable) -> void:
	var timer: Timer = timers.get(callback)
	if timer != null: timer.stop()

func reset_and_start_timer(callback: Callable) -> void:
	var timer: Timer = timers.get(callback)
	if timer != null: timer.start()

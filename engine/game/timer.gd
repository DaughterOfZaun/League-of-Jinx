class_name TimerEx extends Node #@rollback

var wait_time: float
var time_passed: float
var time_left: float:
	get: return wait_time - time_passed

var is_running: bool = false
var cancelled: bool = false

func start(wait_time: float) -> void:
	self.wait_time = wait_time
	self.time_passed = 0
	is_running = true
	self.cancelled = false

func cancel() -> void:
	self.cancelled = true
	self._on_timeout_or_canceled()

func _physics_process(delta: float) -> void:
	if is_running:
		time_passed += delta
		if self.time_left <= 0:
			is_running = false
			self._on_timeout_or_canceled()

func _on_timeout_or_canceled() -> void: pass

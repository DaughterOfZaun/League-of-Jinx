class_name TimerEx extends Node #@rollback

var wait_time: float
var time_passed: float
var time_left: float:
	get: return wait_time - time_passed

var cancelled: bool = false
signal timeout_or_canceled()
signal timeout()

func start(wait_time: float) -> void:
	self.wait_time = wait_time
	self.time_passed = 0
	self.cancelled = false

func cancel() -> void:
	self.cancelled = true
	timeout_or_canceled.emit()

func _physics_process(delta: float) -> void:
	if self.time_left <= 0:
		timeout_or_canceled.emit()
		timeout.emit()
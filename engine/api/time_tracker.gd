class_name TimeTracker extends RefCounted #@rollback

var time: float = 0.0

var time_between_executions: float = 0.0
var execute_immediately: bool = false
var tick_time: float = 0.0

func _init(
	time_between_executions: float = 0.0,
	execute_immediately: bool = false,
	tick_time: float = 0.0
) -> void:
	self.time_between_executions = time_between_executions
	self.execute_immediately = execute_immediately
	self.tick_time = tick_time

func execute(
	time_between_executions: Variant = null, # float
	execute_immediately: Variant = null, # bool
	tick_time: Variant = null # float
) -> bool:
	if time_between_executions == null: time_between_executions = self.time_between_executions
	if execute_immediately == null: execute_immediately = self.execute_immediately
	if tick_time == null: tick_time = self.tick_time
	return false

func reset() -> void:
	time = 0

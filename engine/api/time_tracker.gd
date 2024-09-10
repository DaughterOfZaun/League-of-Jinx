class_name TimeTracker

var time := 0.0

var time_between_executions := 0.0
var execute_immediately := false
var tick_time := 0.0

func _init(
	time_between_executions := 0.0,
	execute_immediately := false,
	tick_time := 0.0
):
	self.time_between_executions = time_between_executions
	self.execute_immediately = execute_immediately
	self.tick_time = tick_time

func execute(
	time_between_executions = null,
	execute_immediately = null,
	tick_time = null
) -> bool:
	if time_between_executions == null: time_between_executions = self.time_between_executions
	if execute_immediately == null: execute_immediately = self.execute_immediately
	if tick_time == null: tick_time = self.tick_time
	return false

func reset() -> void:
	time = 0

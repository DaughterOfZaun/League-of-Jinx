class_name GlobalDrainBuff extends Buff

var drain_percent: float
var drained: bool
#static func create(drain_percent: float, drained: bool) -> Callable:
#	return func() -> GlobalDrainBuff:
#		var this: GlobalDrainBuff = preload("GlobalDrainBuff.tscn").instantiate()
#		this.drain_percent = drain_percent
#		this.drained = drained
#		return this
func _init(drain_percent: float, drained: bool) -> void:
	push_warning("GlobalDrainBuff is unimplemented")
func clone() -> Buff:
	return new(drain_percent, drained)

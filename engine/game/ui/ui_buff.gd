class_name UIBuff extends Control

@export var lifetime_progress_bar: TextureProgressBar
@export var icon_texture_rect: TextureRect
@export var count_label: Label
@export var name_label: Label

var top_buff: Buff
func bind_to(slot: BuffSlot, buff: Buff) -> void:
	self.top_buff = buff
	slot.updated.connect(on_update)
	var script: GDScript = buff.get_script()
	name_label.text = str(script.get_global_name())
	var data: BuffData = buff.get(&"data")
	if data != null:
		icon_texture_rect.texture = data.buff_texture

func _process(delta: float) -> void:
	lifetime_progress_bar.max_value = top_buff.wait_time
	lifetime_progress_bar.value = top_buff.wait_time - top_buff.time_left

func on_update(count: int, top_buff: Buff) -> void:
	self.top_buff = top_buff
	visible = count > 0 && top_buff != null
	count_label.text = str(count)
	set_process(visible)

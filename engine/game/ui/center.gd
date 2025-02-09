class_name UICenterPanel extends Control

@export var champion: Champion
@export var q: UISpell
@export var w: UISpell
@export var e: UISpell
@export var r: UISpell
@export var d: UISpell
@export var f: UISpell
@export var b: UISpell
@export var healthbar: Control
@export var manabar: Control
@export var channel_bar: Control
@export var channel_bar_label: Label
@export var channel_bar_range: Range

@export var ui_buffs_container: FlowContainer
@export var ui_buff_scene: PackedScene

func _ready() -> void:
	channel_bar.visible = false

func bind_to(c: Champion) -> void:
	champion = c
	for letter in "qwerdfb":
		var spell: UISpell = self[letter]
		spell.bind_to(letter, c.spells[letter])
	c.buffs.slot_created.connect(func (slot: BuffSlot, buff: Buff) -> void:
		if buff.is_hidden_on_client ||\
		   buff.type in [ Enums.BuffType.UNDEFINED, Enums.BuffType.INTERNAL ] ||\
		   buff.get_data() == null || buff.get_data().buff_texture == null: return
		var ui_buff: UIBuff = ui_buff_scene.instantiate()
		ui_buffs_container.add_child(ui_buff)
		ui_buff.bind_to(slot, buff)
	)

@onready var health_bar_label: Label = healthbar.find_child("Label", false, false)
@onready var health_bar_range: Range = healthbar.find_child("TextureProgressBar", false, false)

@onready var mana_bar_label: Label = manabar.find_child("Label", false, false)
@onready var mana_bar_range: Range = manabar.find_child("TextureProgressBar", false, false)

func _process(delta: float) -> void:
	
	var health := champion.stats_perm.health_current
	var max_health := champion.stats_perm.get_health()
	health_bar_label.text = "%d / %d" % [ roundi(health), roundi(max_health) ]
	health_bar_range.value = health
	health_bar_range.max_value = max_health

	var mana := champion.stats_perm.mana_current
	var max_mana := champion.stats_perm.get_mana()
	mana_bar_label.text = "%d / %d" % [ roundi(mana), roundi(max_mana) ]
	mana_bar_range.value = mana
	mana_bar_range.max_value = max_mana

	var timer := champion.ai.cast_state.timer
	var current_spell := champion.ai.cast_state.current_spell
	if current_spell != null:
		channel_bar_label.text = current_spell.data.display_name

		var timer_time_passed := timer.wait_time - timer.time_left
		channel_bar_range.value = (timer_time_passed / timer.wait_time) * 100
		#channel_bar_range.max_value = timer.wait_time
		#channel_bar_range.value = timer_time_passed
		
		channel_bar.visible = true
	else:
		channel_bar.visible = false

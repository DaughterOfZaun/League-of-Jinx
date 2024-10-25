class_name UISpell
extends Control

var spell: Spell
@onready var icon_texture_rect: TextureRect = get_node("%IconTexture")
@onready var cooldown_progress_bar: TextureProgressBar = get_node("%CooldownBar")
@onready var cooldown_label: Label = get_node("%CooldownLabel")
@onready var level_label: Label = get_node("%LevelLabel")
func bind_to(spell: Spell) -> void:
	assert(spell != null)
	self.spell = spell

func _process(delta: float) -> void:
	icon_texture_rect.texture = spell.icon
	var on_cooldown := spell.state == Spell.State.COOLDOWN
	cooldown_progress_bar.visible = on_cooldown
	cooldown_label.visible = on_cooldown
	if on_cooldown:
		var cd := spell.cooldown_time_left
		var CD := spell.cooldown_wait_time
		cooldown_progress_bar.value = 100 - (cd / CD) * 100
		if cd <= 60:
			cooldown_label.text = str(ceili(cd))
		else:
			cooldown_label.text =\
				str(ceili(cd / 60)) + ":" +\
				str(ceili(fmod(cd, 60)))
	level_label.text = str(spell.level)

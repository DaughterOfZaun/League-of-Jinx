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

func bind_to(c: Champion) -> void:
	champion = c
	for letter in "qwerdfb":
		var spell: UISpell = self[letter]
		spell.bind_to(letter, c.spells[letter])

@onready var health_bar_label: Label = healthbar.find_child("Label", false)
@onready var health_bar_range: Range = healthbar.find_child("TextureProgressBar", false)

@onready var mana_bar_label: Label = manabar.find_child("Label", false)
@onready var mana_bar_range: Range = manabar.find_child("TextureProgressBar", false)

func _process(delta: float) -> void:
	
	var health := champion.stats.health_current
	var max_health := champion.stats.get_health()
	health_bar_label.text = "%d / %d" % [ roundi(health), roundi(max_health) ]
	health_bar_range.value = health
	health_bar_range.max_value = max_health

	var mana := champion.stats.mana_current
	var max_mana := champion.stats.get_mana()
	mana_bar_label.text = "%d / %d" % [ roundi(mana), roundi(max_mana) ]
	mana_bar_range.value = mana
	mana_bar_range.max_value = max_mana

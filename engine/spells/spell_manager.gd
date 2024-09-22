class_name Spells
extends Node

@export var q: Spell
@export var w: Spell
@export var e: Spell
@export var r: Spell
@export var d: Spell
@export var f: Spell
@export var b: Spell
@export var extra: Array[Spell] = []

@export var crit: CritAttack
@export var basic: Array[BasicAttack] = []

@onready var me: Unit = get_parent()
func _ready():
	if Engine.is_editor_hint(): return
	me.spells = self

func get_by_script(script) -> Spell:
	return Spell.new()

func append_spell(spell: Spell, data: Data, node_name: String) -> Spell:
	spell = append_node(self, spell, node_name)
	spell.data = append_node(spell, data, "Data")
	return spell

func append_node(target: Node, node: Node, node_name: String) -> Node:
	target.add_child(node)
	node.name = node_name
	if Engine.is_editor_hint():
		node.owner = EditorInterface.get_edited_scene_root()
	return node

func array_get(a: Array, i: int):
	if a.size() <= i:
		return null
	return a[i]

func array_set(a: Array, i: int, v):
	if a.size() <= i:
		a.resize(i + 1)
	a[i] = v

func num_to_letter(i: int) -> String:
	return ['q', 'w', 'e', 'r'][i]

func assign_name(spell: Spell, name: String):
	if spell.data.spell_name.is_empty()\
	or spell.data.spell_name == "BaseSpell":
		spell.data.spell_name = name
	assert(
		name == "BaseSpell" or spell.data.spell_name == name,
		spell.data.spell_name + " != " + name
	)

func get_spell(i: int, name: String = "BaseSpell") -> Spell:
	var letter := num_to_letter(i)
	var spell: Spell = self[letter]
	if !spell:
		spell = append_spell(Spell.new(), SpellData.new(), letter.to_upper())
		self[letter] = spell
	assign_name(spell, name)
	return spell

func get_extra(i: int, name: String = "BaseSpell") -> Spell:
	var spell: Spell = array_get(extra, i)
	if !spell:
		spell = append_spell(Spell.new(), SpellData.new(), "E" + str(i))
		array_set(extra, i, spell)
	assign_name(spell, name)
	return spell

func get_basic(i: int, name: String = "BaseSpell") -> Spell:
	var spell: Spell = array_get(basic, i)
	if !spell:
		spell = append_spell(BasicAttack.new(), BasicAttackData.new(), "A" + ("A" if i == 0 else str(i)))
		array_set(basic, i, spell)
	assign_name(spell, name)
	return spell

func get_crit(name: String = "BaseSpell") -> Spell:
	var spell := crit
	if !spell:
		spell = append_spell(CritAttack.new(), CritAttackData.new(), "AC")
		crit = spell
	assign_name(spell, name)
	return spell

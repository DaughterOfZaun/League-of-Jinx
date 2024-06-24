class_name Spells
extends Node

var q: Spell
var w: Spell
var e: Spell
var r: Spell
var d: Spell
var f: Spell
var b: Spell
var extra: Array[Spell] = []

@onready var me := get_parent() as Unit
func _ready():
    me.spells = self
    q = find_child("Q"); if q == null: q = Spell.new()
    w = find_child("W"); if w == null: w = Spell.new()
    e = find_child("E"); if e == null: e = Spell.new()
    r = find_child("R"); if r == null: r = Spell.new()
    d = find_child("D"); if d == null: d = Spell.new()
    f = find_child("F"); if f == null: f = Spell.new()
    b = find_child("B"); if b == null: b = Spell.new()

func get_by_script(script) -> Spell:
    return Spell.new()

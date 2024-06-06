class_name CharScript
extends Node

@onready var me := get_parent() as Character
@onready var host := me
@onready var attacker := me
@onready var target := me
@onready var caster := me
@onready var char_vars := me.char_vars

func _ready():
	on_activate()

func on_activate(): pass

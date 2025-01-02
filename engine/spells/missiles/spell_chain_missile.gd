class_name SpellChainMissile extends Missile

static func create(spell: Spell, target: Unit) -> SpellChainMissile:
	var m := SpellChainMissile.new()
	m.init(spell, target)
	return m

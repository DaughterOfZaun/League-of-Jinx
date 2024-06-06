#class_name CharScriptAhri
extends CharScript

func on_activate():
	host.buffs.add(host, AhriIdleParticle.B.new())
	host.buffs.add(host, ChampionChampionDelta.B.new())
	host.buffs.add(host, APBonusDamageToTowers.B.new(), 1, 1, 25000, Enums.BuffAddType.RENEW_EXISTING)
	char_vars.orb_of_deception_is_active = 0
	char_vars.fox_fire_is_active = 0
	char_vars.seduce_is_active = 0
	char_vars.tumble_is_active = 0

func on_spell_cast(spell: Spell):
	if attacker.buffs.count(AhriSoulCrusher.B, attacker) > 0:
		if spell is AhriOrbOfDeception.S:
			char_vars.orb_of_deception_is_active = 1
			host.buffs.remove(AhriPassiveParticle.B, host)
			host.buffs.add(host, AhriIdleCheck.B.new(), 1, 1, 0.75)
		elif spell is AhriFoxFire.S:
			char_vars.fox_fire_is_active = 1
		elif spell is AhriSeduce.S:
			char_vars.seduce_is_active = 1
			host.buffs.remove(AhriPassiveParticle.B, host)
			host.buffs.add(host, AhriIdleCheck.B.new(), 1, 1, 0.75)
		elif spell is AhriTumble.S:
			char_vars.tumble_is_active = 1
	else:
		if spell is AhriOrbOfDeception.S:
			host.buffs.remove(AhriIdleParticle.B, host)
			host.buffs.add(host, AhriIdleCheck.B.new(), 1, 1, 0.75)
		elif spell is AhriSeduce.S:
			host.buffs.remove(AhriIdleParticle.B, host)
			host.buffs.add(host, AhriIdleCheck.B.new(), 1, 1, 0.75)

func on_disconnect():
	host.spells.b.cast(host, host.position, host.position, 1, true)

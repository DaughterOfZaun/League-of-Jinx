#class_name CharScriptAhri
extends Passive

func on_activate() -> void:
	host.buffs.add(host, AhriIdleParticleBuff.new())
	host.buffs.add(host, ChampionChampionDeltaBuff.new())
	host.buffs.add(host, APBonusDamageToTowersBuff.new(), 1, 1, 25000, Enums.BuffAddType.RENEW_EXISTING)
	vars.orb_of_deception_is_active = 0
	vars.fox_fire_is_active = 0
	vars.seduce_is_active = 0
	vars.tumble_is_active = 0

func on_spell_cast(spell: Spell) -> void:
	if attacker.buffs.count(AhriSoulCrusherBuff, attacker) > 0:
		if spell is AhriOrbOfDeceptionSpell:
			vars.orb_of_deception_is_active = 1
			host.buffs.remove_by_script(AhriPassiveParticleBuff, host)
			host.buffs.add(host, AhriIdleCheckBuff.new(), 1, 1, 0.75)
		elif spell is AhriFoxFireSpell:
			vars.fox_fire_is_active = 1
		elif spell is AhriSeduceSpell:
			vars.seduce_is_active = 1
			host.buffs.remove_by_script(AhriPassiveParticleBuff, host)
			host.buffs.add(host, AhriIdleCheckBuff.new(), 1, 1, 0.75)
		elif spell is AhriTumbleSpell:
			vars.tumble_is_active = 1
	else:
		if spell is AhriOrbOfDeceptionSpell:
			host.buffs.remove_by_script(AhriIdleParticleBuff, host)
			host.buffs.add(host, AhriIdleCheckBuff.new(), 1, 1, 0.75)
		elif spell is AhriSeduceSpell:
			host.buffs.remove_by_script(AhriIdleParticleBuff, host)
			host.buffs.add(host, AhriIdleCheckBuff.new(), 1, 1, 0.75)

func on_disconnect() -> void:
	host.spells.b.cast(host, host.position_3d, host.position_3d, 1, true)

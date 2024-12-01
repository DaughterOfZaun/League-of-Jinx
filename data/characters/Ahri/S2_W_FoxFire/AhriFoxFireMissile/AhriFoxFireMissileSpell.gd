class_name AhriFoxFireMissileSpell extends Spell

var effect0: Array[float] = [ 30, 60, 90, 120, 150 ]
var spell_vars_ready: int #TODO: Verify
func on_missile_update(missile: Missile) -> void:
	spell_vars_ready += 1
	if spell_vars_ready >= 3:
		var count := 0
		var level := host.spells.w.level
		for unit: Unit in API.get_closest_visible_units_in_area(host, missile.position_3d, 650, Enums.SpellFlags.AFFECT_ENEMIES | Enums.SpellFlags.AFFECT_HEROES, 1, null, true):
			(host.spells.extra[3] as AhriFoxFireMissileTwoSpell).cast(unit, Vector3.INF, Vector3.INF, level, true, true, false, true, false, true, missile.position_3d)
			count = 1
			missile.destroy()
			host.buffs.remove_stacks(AhriFoxFireMissileBuff, 1, host)
		if count == 0:
			for unit: Unit in API.get_closest_visible_units_in_area(host, missile.position_3d, 650, Enums.SpellFlags.AFFECT_ENEMIES | Enums.SpellFlags.AFFECT_NEUTRAL | Enums.SpellFlags.AFFECT_MINIONS | Enums.SpellFlags.AFFECT_HEROES, 1, null, true):
				(host.spells.extra[3] as AhriFoxFireMissileTwoSpell).cast(unit, Vector3.INF, Vector3.INF, level, true, true, false, true, false, true, missile.position_3d)
				missile.destroy()
				host.buffs.remove_stacks(AhriFoxFireMissileBuff, 1, host)
				#level = host.spells.w.level
				var base_damage := self.effect0[level - 1]
				var my_ap := host.stats.get_magic_damage_flat()
				var my_ap_bonus := my_ap * 0.3
				var total_damage := base_damage + my_ap_bonus
				var their_spell_block := unit.stats.get_spell_block()
				var their_spell_block_percent := their_spell_block / 100
				var their_spell_block_ratio := their_spell_block_percent + 1
				if unit.buffs.count(AhriFoxFireMissileTwoBuff, host) > 0:
					total_damage /= 2
				elif unit.buffs.count(AhriFoxFireMissileTagTwoBuff, host) > 0:
						total_damage *= 1.5
				var projected_damage := total_damage / their_spell_block_ratio
				var their_health := unit.stats.health_current
				if their_health < projected_damage:
					unit.buffs.add(host, AhriFoxFireMissileTagBuff.new(), 1, 1, 0.25)
				else:
					unit.buffs.add(host, AhriFoxFireMissileTagTwoBuff.new(), 1, 1, 0.25)

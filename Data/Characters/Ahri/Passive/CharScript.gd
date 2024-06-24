#class_name CharScriptAhri
extends CharScript

func on_activate():
    host.buffs.add(host, AhriIdleParticleBuff.new())
    host.buffs.add(host, ChampionChampionDeltaBuff.new())
    host.buffs.add(host, APBonusDamageToTowersBuff.new(), 1, 1, 25000, Enums.BuffAddType.RENEW_EXISTING)
    char_vars.orb_of_deception_is_active = 0
    char_vars.fox_fire_is_active = 0
    char_vars.seduce_is_active = 0
    char_vars.tumble_is_active = 0

func on_spell_cast(spell: Spell):
    if attacker.buffs.count(AhriSoulCrusherBuff, attacker) > 0:
        if spell is AhriOrbOfDeceptionSpell:
            char_vars.orb_of_deception_is_active = 1
            host.buffs.remove(AhriPassiveParticleBuff, host)
            host.buffs.add(host, AhriIdleCheckBuff.new(), 1, 1, 0.75)
        elif spell is AhriFoxFireSpell:
            char_vars.fox_fire_is_active = 1
        elif spell is AhriSeduceSpell:
            char_vars.seduce_is_active = 1
            host.buffs.remove(AhriPassiveParticleBuff, host)
            host.buffs.add(host, AhriIdleCheckBuff.new(), 1, 1, 0.75)
        elif spell is AhriTumbleSpell:
            char_vars.tumble_is_active = 1
    else:
        if spell is AhriOrbOfDeceptionSpell:
            host.buffs.remove(AhriIdleParticleBuff, host)
            host.buffs.add(host, AhriIdleCheckBuff.new(), 1, 1, 0.75)
        elif spell is AhriSeduceSpell:
            host.buffs.remove(AhriIdleParticleBuff, host)
            host.buffs.add(host, AhriIdleCheckBuff.new(), 1, 1, 0.75)

func on_disconnect():
    host.spells.b.cast(host, host.position, host.position, 1, true)
